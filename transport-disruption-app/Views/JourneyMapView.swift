//
//  JourneyMapView.swift
//  transport-disruption-app
//
//  Minimal direction-constrained MapKit route preview.
//
//  Principle:
//  1. Let MapKit draw normal roads whenever possible.
//  2. Only use RouteWaypoints to correct the initial corridor.
//  3. Do not manually connect waypoints with straight route lines.
//

import SwiftUI
import MapKit

struct JourneyMapView: View {

    let option: JourneyOption

    @State private var position: MapCameraPosition = .automatic
    @State private var routePolylines: [MKPolyline] = []
    @State private var ferryPolylines: [MKPolyline] = []
    @State private var fallbackLines: [[CLLocationCoordinate2D]] = []
    @State private var isLoadingRoute = false

    private var segments: [JourneySegment] {
        option.orderedSegments
    }

    private var routeKey: String {
        segments.map {
            "\($0.id)-\($0.routeID ?? "NO_ROUTE")-\($0.origin)-\($0.destination)-\($0.transportMode)"
        }
        .joined(separator: "|")
    }

    private var mapStops: [(name: String, coordinate: CLLocationCoordinate2D)] {
        var result: [(String, CLLocationCoordinate2D)] = []

        for name in option.mapStopNames {
            guard let coordinate =
                    StopCoordinates.coordinate(for: name)
            else {
                continue
            }

            if result.last?.0 != name {
                result.append((name, coordinate))
            }
        }

        return result
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {

            Map(position: $position) {

                ForEach(
                    Array(routePolylines.enumerated()),
                    id: \.offset
                ) { _, polyline in

                    MapPolyline(polyline)
                        .stroke(
                            .blue,
                            lineWidth: 5
                        )
                }

                ForEach(
                    Array(ferryPolylines.enumerated()),
                    id: \.offset
                ) { _, polyline in

                    MapPolyline(polyline)
                        .stroke(
                            .blue,
                            lineWidth: 5
                        )
                }

                // Dashed fallback appears only when MapKit cannot
                // calculate a usable route for that segment.
                ForEach(
                    Array(fallbackLines.enumerated()),
                    id: \.offset
                ) { _, coordinates in

                    MapPolyline(
                        coordinates: coordinates
                    )
                    .stroke(
                        .blue.opacity(0.55),
                        style: StrokeStyle(
                            lineWidth: 4,
                            dash: [8, 6]
                        )
                    )
                }

                ForEach(
                    Array(mapStops.enumerated()),
                    id: \.offset
                ) { index, stop in

                    Annotation(
                        stop.name,
                        coordinate: stop.coordinate
                    ) {
                        markerView(
                            for: index,
                            total: mapStops.count
                        )
                    }
                }
            }
            .mapStyle(.standard)

            if isLoadingRoute {
                ProgressView()
                    .controlSize(.small)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .padding(10)
            }
        }
        .frame(height: 260)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    Color.blue.opacity(0.15),
                    lineWidth: 1
                )
        }
        .task(id: routeKey) {
            await loadRoutes()
        }
    }

    // MARK: - Route Loading

    @MainActor
    private func loadRoutes() async {

        routePolylines = []
        ferryPolylines = []
        fallbackLines = []

        guard !segments.isEmpty else {
            fallbackToWholeJourney()
            return
        }

        isLoadingRoute = true
        defer { isLoadingRoute = false }

        var newPolylines: [MKPolyline] = []
        var newFerryPolylines: [MKPolyline] = []
        var newFallbacks: [[CLLocationCoordinate2D]] = []

        for segment in segments {

            if Task.isCancelled {
                return
            }

            guard
                let start =
                    StopCoordinates.coordinate(
                        for: segment.origin
                    ),
                let end =
                    StopCoordinates.coordinate(
                        for: segment.destination
                    )
            else {
                continue
            }

            // Ferry must stay on the Brisbane River.
            // Do not send it through MKDirections automobile/walking routing.
            if segment.transportMode.lowercased() == "ferry" {

                let riverPoints =
                    RouteWaypoints.ferryCoordinates(
                        origin: segment.origin,
                        destination: segment.destination
                    )

                if !riverPoints.isEmpty {
                    let coordinates =
                        [start] + riverPoints + [end]

                    newFerryPolylines.append(
                        MKPolyline(
                            coordinates: coordinates,
                            count: coordinates.count
                        )
                    )

                    continue
                }

                // Unknown ferry pair: keep a visible direct fallback rather
                // than incorrectly drawing the ferry over roads.
                newFallbacks.append([start, end])
                continue
            }

            let anchors =
                RouteWaypoints.coordinates(
                    for: segment.routeID,
                    origin: segment.origin,
                    destination: segment.destination,
                    transportMode: segment.transportMode
                )

            let controlPoints =
                [start] + anchors + [end]

            do {
                let calculated =
                    try await calculateSegment(
                        controlPoints: controlPoints,
                        segment: segment
                    )

                newPolylines.append(
                    contentsOf: calculated
                )

            } catch {

                // First retry WITHOUT custom anchors.
                // This is particularly useful for routes such as 412:
                // normal MapKit road routing is usually the best result.
                do {
                    let direct =
                        try await calculateSegment(
                            controlPoints: [start, end],
                            segment: segment,
                            forceNormalRoadGeometry: true
                        )

                    newPolylines.append(
                        contentsOf: direct
                    )

                } catch {
                    newFallbacks.append(
                        [start, end]
                    )
                }
            }
        }

        routePolylines = newPolylines
        ferryPolylines = newFerryPolylines
        fallbackLines = newFallbacks

        if routePolylines.isEmpty,
           ferryPolylines.isEmpty,
           fallbackLines.isEmpty {
            fallbackToWholeJourney()
        }
    }

    @MainActor
    private func fallbackToWholeJourney() {

        let coordinates =
            mapStops.map(\.coordinate)

        if coordinates.count >= 2 {
            fallbackLines = [coordinates]
        }
    }

    // MARK: - MapKit Directions

    private func calculateSegment(
        controlPoints: [CLLocationCoordinate2D],
        segment: JourneySegment,
        forceNormalRoadGeometry: Bool = false
    ) async throws -> [MKPolyline] {

        guard controlPoints.count >= 2 else {
            return []
        }

        var result: [MKPolyline] = []

        for index in 0..<(controlPoints.count - 1) {

            if Task.isCancelled {
                return result
            }

            let route =
                try await calculateRoute(
                    from: controlPoints[index],
                    to: controlPoints[index + 1],
                    segment: segment,
                    forceNormalRoadGeometry:
                        forceNormalRoadGeometry
                )

            result.append(route.polyline)
        }

        return result
    }

    private func calculateRoute(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        segment: JourneySegment,
        forceNormalRoadGeometry: Bool
    ) async throws -> MKRoute {

        let request = MKDirections.Request()

        request.source =
            MKMapItem(
                placemark:
                    MKPlacemark(
                        coordinate: start
                    )
            )

        request.destination =
            MKMapItem(
                placemark:
                    MKPlacemark(
                        coordinate: end
                    )
            )

        request.transportType =
            mapKitTransportType(
                for: segment,
                forceNormalRoadGeometry:
                    forceNormalRoadGeometry
            )

        request.requestsAlternateRoutes = false

        let response =
            try await MKDirections(
                request: request
            )
            .calculate()

        guard let route = response.routes.first else {
            throw JourneyMapRouteError.noRoute
        }

        return route
    }

    private func mapKitTransportType(
        for segment: JourneySegment,
        forceNormalRoadGeometry: Bool
    ) -> MKDirectionsTransportType {

        let mode =
            segment.transportMode
                .lowercased()

        if mode == "walk"
            || mode == "walking" {
            return .walking
        }

        if forceNormalRoadGeometry {
            return .automobile
        }

        // 66 / 169 / 199:
        // use walking geometry as a visual helper only, because
        // automobile routing may reject the UQ busway bridge.
        if RouteWaypoints.prefersBuswayGeometry(
            for: segment.routeID
        ) {
            return .walking
        }

        // 412 and ordinary road-based bus routes:
        // let MapKit calculate the normal road path directly.
        return .automobile
    }

    // MARK: - Markers

    @ViewBuilder
    private func markerView(
        for index: Int,
        total: Int
    ) -> some View {

        if index == 0 {

            mapMarker(
                icon: "location.fill",
                label: "Start",
                color: .green
            )

        } else if index == total - 1 {

            mapMarker(
                icon: "mappin.and.ellipse",
                label: "Destination",
                color: .red
            )

        } else {

            mapMarker(
                icon: "arrow.triangle.swap",
                label: "Transfer",
                color: .orange
            )
        }
    }

    private func mapMarker(
        icon: String,
        label: String,
        color: Color
    ) -> some View {

        VStack(spacing: 3) {

            Image(systemName: icon)
                .font(
                    .system(
                        size: 16,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.white)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(color)
                .clipShape(Circle())
                .shadow(radius: 2)

            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }
}

private enum JourneyMapRouteError: Error {
    case noRoute
}

