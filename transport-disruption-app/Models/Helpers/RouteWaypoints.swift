//
//  RouteWaypoints.swift
//  transport-disruption-app
//
//  Minimal direction constraints.
//
//  Important:
//  - 412 uses normal MapKit road routing with NO forced waypoint.
//  - 66 / 169 / 199 only receive a small number of direction anchors
//    so they leave UQ Lakes via the east / south side.
//  - Waypoints are NOT used to manually draw the route.
//

import Foundation
import CoreLocation

struct RouteWaypoints {

    // MARK: - Route Groups

    private static let uqEastSouthRoutes: Set<String> = [
        "66",
        "169",
        "199"
    ]

    // MARK: - Minimal Direction Anchors

    /// One bridge-side anchor is enough to stop MapKit from choosing
    /// the Toowong / western side for UQ east/south services.
    ///
    /// Keep this list intentionally small. Too many anchors cause
    /// unnecessary loops because MKDirections recalculates every leg.
    private static let uqEastExitAnchor =
        CLLocationCoordinate2D(
            latitude: -27.5005,
            longitude: 153.0267
        )

    /// Inner-south / busway-side anchor.
    /// Used only for journeys continuing toward South Bank / the City.
    private static let innerSouthAnchor =
        CLLocationCoordinate2D(
            latitude: -27.4937,
            longitude: 153.0292
        )

    /// Cultural Centre corridor anchor for BUS journeys from
    /// South Bank toward Brisbane City.
    private static let culturalCentreAnchor =
        CLLocationCoordinate2D(
            latitude: -27.4738,
            longitude: 153.0198
        )

    // MARK: - Ferry River Geometry

    /// Prototype river geometry for ferry journeys between the UQ / St Lucia
    /// side and central Brisbane. These points follow the Brisbane River
    /// corridor visually instead of asking MapKit to calculate a road route.
    ///
    /// This is display geometry only; it does not change journey duration,
    /// service data, or the transport mode stored in the database.
    private static let uqToCityRiverCorridor: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: -27.4971, longitude: 153.0172),
        CLLocationCoordinate2D(latitude: -27.4948, longitude: 153.0145),
        CLLocationCoordinate2D(latitude: -27.4918, longitude: 153.0125),
        CLLocationCoordinate2D(latitude: -27.4886, longitude: 153.0119),
        CLLocationCoordinate2D(latitude: -27.4854, longitude: 153.0132),
        CLLocationCoordinate2D(latitude: -27.4824, longitude: 153.0161),
        CLLocationCoordinate2D(latitude: -27.4797, longitude: 153.0192),
        CLLocationCoordinate2D(latitude: -27.4770, longitude: 153.0218),
        CLLocationCoordinate2D(latitude: -27.4745, longitude: 153.0238),
        CLLocationCoordinate2D(latitude: -27.4722, longitude: 153.0255)
    ]

    static func ferryCoordinates(
        origin: String,
        destination: String
    ) -> [CLLocationCoordinate2D] {

        let start = normalised(origin)
        let end = normalised(destination)

        let uqNames: Set<String> = [
            "UQ LAKES",
            "UQ ST LUCIA",
            "UNIVERSITY OF QUEENSLAND",
            "UNIVERSITY QLD LAKES STATION"
        ]

        let cityNames: Set<String> = [
            "BRISBANE CITY",
            "CITY",
            "CBD"
        ]

        if uqNames.contains(start),
           cityNames.contains(end) {
            return uqToCityRiverCorridor
        }

        if cityNames.contains(start),
           uqNames.contains(end) {
            return Array(uqToCityRiverCorridor.reversed())
        }

        return []
    }

    // MARK: - Public Lookup

    static func coordinates(
        for routeID: String?,
        origin: String,
        destination: String
    ) -> [CLLocationCoordinate2D] {

        let route = routeID.map(normalised)
        let start = normalised(origin)
        let end = normalised(destination)

        // 412 deliberately has NO custom waypoint.
        // UQ Lakes -> Toowong is a normal road journey and MapKit
        // already knows the direct road route better than our manual points.
        if route == "412" {
            return []
        }

        // 66 / 169 / 199:
        // only constrain the initial direction away from UQ.
        if let route,
           uqEastSouthRoutes.contains(route) {

            if start == normalised("UQ Lakes") {

                if end == normalised("South Bank")
                    || end == normalised("Brisbane City") {
                    return [
                        uqEastExitAnchor,
                        innerSouthAnchor
                    ]
                }

                return [
                    uqEastExitAnchor
                ]
            }

            if end == normalised("UQ Lakes") {

                if start == normalised("South Bank")
                    || start == normalised("Brisbane City") {
                    return [
                        innerSouthAnchor,
                        uqEastExitAnchor
                    ]
                }

                return [
                    uqEastExitAnchor
                ]
            }
        }

        // Generic UQ -> South Bank / City journeys can use the same
        // minimal direction constraint if the database does not provide
        // a recognised route ID.
        if start == normalised("UQ Lakes"),
           end == normalised("South Bank")
            || end == normalised("Brisbane City") {

            return [
                uqEastExitAnchor,
                innerSouthAnchor
            ]
        }

        if end == normalised("UQ Lakes"),
           start == normalised("South Bank")
            || start == normalised("Brisbane City") {

            return [
                innerSouthAnchor,
                uqEastExitAnchor
            ]
        }

        return []
    }

    /// Adds a transport-mode-specific direction constraint.
    ///
    /// Bus: South Bank -> Brisbane City is guided via Cultural Centre.
    /// Train: no Cultural Centre override; MapKit keeps the rail-oriented
    /// geometry selected by JourneyMapView.
    static func coordinates(
        for routeID: String?,
        origin: String,
        destination: String,
        transportMode: String
    ) -> [CLLocationCoordinate2D] {

        let start = normalised(origin)
        let end = normalised(destination)
        let mode = normalised(transportMode)

        if mode == "BUS",
           start == normalised("South Bank"),
           end == normalised("Brisbane City") {
            return [culturalCentreAnchor]
        }

        if mode == "BUS",
           start == normalised("Brisbane City"),
           end == normalised("South Bank") {
            return [culturalCentreAnchor]
        }

        return coordinates(
            for: routeID,
            origin: origin,
            destination: destination
        )
    }

    /// Busway-style UQ routes cannot reliably be drawn with automobile
    /// geometry because normal-car routing may reject the busway bridge
    /// and send the path toward Toowong.
    ///
    /// This flag affects MAP GEOMETRY ONLY.
    static func prefersBuswayGeometry(
        for routeID: String?
    ) -> Bool {

        guard let routeID else {
            return false
        }

        return uqEastSouthRoutes.contains(
            normalised(routeID)
        )
    }

    private static func normalised(
        _ value: String
    ) -> String {

        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
    }
}
