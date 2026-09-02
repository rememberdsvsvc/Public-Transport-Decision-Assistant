//
//  CurrentJourneyView.swift
//  transport-disruption-app
//

import SwiftUI

struct CurrentJourneyView: View {
    @Binding var journey: Journey

    @State private var origin: String
    @State private var destination: String
    @State private var selectedTime: Date

    @State private var currentJourneys: [JourneyOption] = []
    @State private var hasSearched = false
    @State private var goToDisruptionInformation = false

    init(journey: Binding<Journey>) {
        self._journey = journey
        _origin = State(initialValue: journey.wrappedValue.origin)
        _destination = State(initialValue: journey.wrappedValue.destination)
        _selectedTime = State(initialValue: journey.wrappedValue.selectedTime)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.section) {
                PageHeader(
                    title: "Current Journey",
                    subtitle: "Enter your journey details, search nearby departures, then select the complete journey you are planning to use."
                )

                journeySearchPanel

                if !hasSearched {
                    InformationNotice(
                        title: "Search window",
                        message: "Journeys departing approximately 10 minutes before or after your selected time will be shown. Direct and transfer journeys may both appear."
                    )
                }

                if hasSearched {
                    searchResults
                }
            }
            .appPageWidth()
            .padding(.vertical, AppSpacing.extraLarge)
        }
        .background(AppColor.pageBackground.ignoresSafeArea())
        .tint(AppColor.ink)
        .onChange(of: origin) { _, newOrigin in
            updateDestination(for: newOrigin)
            resetSearch()
        }
        .onChange(of: destination) { _, _ in
            resetSearch()
        }
        .onChange(of: selectedTime) { _, _ in
            resetSearch()
        }
        .navigationDestination(isPresented: $goToDisruptionInformation) {
            DisruptionInformationView(journey: $journey)
        }
    }

    private var journeySearchPanel: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionHeader(
                title: "Your Journey",
                subtitle: "Choose an origin, destination and approximate departure time.",
                systemImage: "point.topleft.down.to.point.bottomright.curvepath"
            )

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    originField
                        .frame(minWidth: 170)
                    destinationField
                        .frame(minWidth: 170)
                    timeField
                        .frame(minWidth: 150)
                }

                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    originField
                    destinationField
                    timeField
                }
            }

            PrimaryActionButton(
                title: "Find Current Journeys",
                systemImage: "magnifyingglass",
                trailingSystemImage: nil
            ) {
                searchCurrentJourneys()
            }
            .tint(AppColor.ink)
            .accentColor(AppColor.ink)
        }
        .padding(AppSpacing.extraLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.aliceBlue)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
    }

    private var originField: some View {
        journeyField(title: "From", systemImage: "location.fill") {
            Picker("From", selection: $origin) {
                ForEach(availableOrigins, id: \.self) { location in
                    Text(location)
                        .tag(location)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .accessibilityLabel("From")
            .accessibilityValue(origin)
        }
    }

    private var destinationField: some View {
        journeyField(title: "To", systemImage: "mappin.circle.fill") {
            Picker("To", selection: $destination) {
                ForEach(availableDestinations, id: \.self) { location in
                    Text(location)
                        .tag(location)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .accessibilityLabel("To")
            .accessibilityValue(destination)
        }
    }

    private var timeField: some View {
        journeyField(title: "Approximate Time", systemImage: "clock.fill") {
            DatePicker(
                "Journey Time",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .accessibilityLabel("Approximate journey time")
        }
    }

    private func journeyField<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.ink.opacity(0.72))

            content()
                .frame(
                    maxWidth: .infinity,
                    minHeight: AppLayout.minimumTouchTarget,
                    alignment: .leading
                )
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.pageBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
    }

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: AppSpacing.extraLarge) {
            SectionHeader(
                title: "Possible Current Journeys",
                subtitle: "Select the complete journey that best matches the route you are planning to take.",
                systemImage: "list.bullet.rectangle"
            )

            if currentJourneys.isEmpty {
                EmptyStateView(
                    title: "No Journeys Found",
                    message: "No matching journeys were found within approximately 10 minutes before or after the selected time. Try another time or journey.",
                    systemImage: "arrow.triangle.branch"
                )
            } else {
                ForEach(Array(currentJourneys.enumerated()), id: \.element.id) { index, option in
                    journeyResult(option: option, index: index)
                }
            }
        }
    }

    @ViewBuilder
    private func journeyResult(option: JourneyOption, index: Int) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            JourneySummary(
                title: "Journey \(index + 1): \(option.transportModeText)",
                systemImage: mainTransportIcon(for: option),
                route: option.routeSummary,
                origin: option.origin,
                destination: option.destination,
                metrics: [
                    JourneyMetric(
                        title: "Departure",
                        value: scheduledDepartureText(for: option),
                        systemImage: "arrow.up.right"
                    ),
                    JourneyMetric(
                        title: "Expected arrival",
                        value: option.expectedArrival,
                        systemImage: "arrow.down.right"
                    ),
                    JourneyMetric(
                        title: "Duration",
                        value: "\(option.totalMinutes) min",
                        systemImage: "clock"
                    ),
                    JourneyMetric(
                        title: "Transfers",
                        value: option.transferText,
                        systemImage: "arrow.triangle.branch"
                    )
                ],
                status: presentationStatus(for: option)
            )

            if option.orderedSegments.count > 1 {
                JourneyTimeline(
                    title: "Journey details",
                    segments: option.orderedSegments.map(segmentPresentation)
                )
            }

            PrimaryActionButton(
                title: "This Is My Current Journey",
                systemImage: "checkmark.circle.fill"
            ) {
                selectJourney(option)
            }
            .tint(AppColor.ink)
            .accentColor(AppColor.ink)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Journey option \(index + 1)")
    }

    private var availableOrigins: [String] {
        let locations = DatabaseManager.shared.availableOrigins()

        if locations.isEmpty {
            return [origin]
        }

        return locations
    }

    private var availableDestinations: [String] {
        let locations = DatabaseManager.shared.availableDestinations(from: origin)

        if locations.isEmpty {
            return [destination]
        }

        return locations
    }

    private func searchCurrentJourneys() {
        currentJourneys = DatabaseManager.shared.searchCurrentJourneys(
            origin: origin,
            destination: destination,
            selectedTime: selectedTime
        )

        hasSearched = true
    }

    private func selectJourney(_ option: JourneyOption) {
        journey.origin = origin
        journey.destination = destination
        journey.selectedTime = selectedTime
        journey.setSelectedJourney(option)
        goToDisruptionInformation = true
    }

    private func mainTransportIcon(for option: JourneyOption) -> String {
        guard let firstSegment = option.orderedSegments.first else {
            return "arrow.triangle.branch"
        }

        return firstSegment.transportIcon
    }

    private func scheduledDepartureText(for option: JourneyOption) -> String {
        guard let firstSegment = option.orderedSegments.first else {
            return option.expectedDeparture
        }

        return firstSegment.scheduledDeparture
            ?? firstSegment.expectedDeparture
            ?? option.expectedDeparture
    }

    private func presentationStatus(for option: JourneyOption) -> PresentationStatus {
        if option.isCancelled {
            return .cancelled("Cancelled service")
        }

        if option.totalDelayMinutes > 0 {
            return .delayed("\(option.totalDelayMinutes) min delay")
        }

        if option.hasDisruption {
            return .information("Service disruption")
        }

        return .normal()
    }

    private func segmentPresentation(_ segment: JourneySegment) -> JourneySegmentPresentation {
        JourneySegmentPresentation(
            systemImage: segment.transportIcon,
            route: segment.routeDisplayText,
            origin: segment.origin,
            destination: segment.destination,
            departure: segment.departureText,
            arrival: segment.arrivalText,
            status: presentationStatus(for: segment)
        )
    }

    private func presentationStatus(for segment: JourneySegment) -> PresentationStatus {
        if segment.isCancelled {
            return .cancelled()
        }

        if segment.delayMinutes > 0 {
            return .delayed(segment.delayText)
        }

        if segment.disruptionType != "Normal Service" {
            return .information(segment.disruptionType)
        }

        return .normal("On time")
    }

    private func updateDestination(for newOrigin: String) {
        let destinations = DatabaseManager.shared.availableDestinations(from: newOrigin)

        guard let firstDestination = destinations.first else {
            return
        }

        if !destinations.contains(destination) {
            destination = firstDestination
        }
    }

    private func resetSearch() {
        currentJourneys = []
        hasSearched = false
    }
}

private struct CurrentJourneyPreview: View {
    @State private var journey = Journey.empty

    var body: some View {
        NavigationStack {
            CurrentJourneyView(journey: $journey)
        }
    }
}

#Preview("Current Journey") {
    CurrentJourneyPreview()
}

#Preview("Current Journey - Dark and Large Type") {
    CurrentJourneyPreview()
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility1)
}
