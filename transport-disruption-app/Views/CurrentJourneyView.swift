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


    // ========================================================
    // MARK: - Search State
    // ========================================================

    @State private var currentJourneys:
        [JourneyOption] = []


    @State private var hasSearched =
        false


    @State private var goToDisruptionInformation =
        false


    // ========================================================
    // MARK: - Initialisation
    // ========================================================

    init(
        journey: Binding<Journey>
    ) {

        self._journey =
            journey


        _origin =
            State(
                initialValue:
                    journey.wrappedValue.origin
            )


        _destination =
            State(
                initialValue:
                    journey.wrappedValue.destination
            )


        _selectedTime =
            State(
                initialValue:
                    journey.wrappedValue.selectedTime
            )
    }


    // ========================================================
    // MARK: - Body
    // ========================================================

    var body: some View {

        ScrollView {

            VStack(
                alignment:
                    .leading,
                spacing:
                    24
            ) {


                // =================================================
                // MARK: Page Header
                // =================================================

                VStack(
                    alignment:
                        .leading,
                    spacing:
                        8
                ) {

                    Text(
                        "Current Journey"
                    )
                    .font(
                        .largeTitle
                    )
                    .fontWeight(
                        .bold
                    )


                    Text(
                        "Enter your journey details and select the complete journey you are currently planning to use."
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }


                // =================================================
                // MARK: Journey Search
                // =================================================

                VStack(
                    alignment:
                        .leading,
                    spacing:
                        18
                ) {

                    Text(
                        "Your Journey"
                    )
                    .font(
                        .title2
                    )
                    .fontWeight(
                        .bold
                    )


                    // -------------------------------------------------
                    // From
                    // -------------------------------------------------

                    VStack(
                        alignment:
                            .leading,
                        spacing:
                            8
                    ) {

                        Label(
                            "From",
                            systemImage:
                                "location.fill"
                        )
                        .font(
                            .headline
                        )


                        Picker(
                            "From",
                            selection:
                                $origin
                        ) {

                            ForEach(
                                availableOrigins,
                                id:
                                    \.self
                            ) {
                                location in

                                Text(
                                    location
                                )
                                .tag(
                                    location
                                )
                            }
                        }
                        .pickerStyle(
                            .menu
                        )
                        .frame(
                            maxWidth:
                                .infinity,
                            alignment:
                                .leading
                        )
                    }


                    Divider()


                    // -------------------------------------------------
                    // To
                    // -------------------------------------------------

                    VStack(
                        alignment:
                            .leading,
                        spacing:
                            8
                    ) {

                        Label(
                            "To",
                            systemImage:
                                "mappin.circle.fill"
                        )
                        .font(
                            .headline
                        )


                        Picker(
                            "To",
                            selection:
                                $destination
                        ) {

                            ForEach(
                                availableDestinations,
                                id:
                                    \.self
                            ) {
                                location in

                                Text(
                                    location
                                )
                                .tag(
                                    location
                                )
                            }
                        }
                        .pickerStyle(
                            .menu
                        )
                        .frame(
                            maxWidth:
                                .infinity,
                            alignment:
                                .leading
                        )
                    }


                    Divider()


                    // -------------------------------------------------
                    // Time
                    // -------------------------------------------------

                    VStack(
                        alignment:
                            .leading,
                        spacing:
                            8
                    ) {

                        Label(
                            "Approximate Time",
                            systemImage:
                                "clock.fill"
                        )
                        .font(
                            .headline
                        )


                        DatePicker(
                            "Journey Time",
                            selection:
                                $selectedTime,
                            displayedComponents:
                                .hourAndMinute
                        )
                        .labelsHidden()
                    }


                    // -------------------------------------------------
                    // Search Button
                    // -------------------------------------------------

                    Button {

                        searchCurrentJourneys()

                    } label: {

                        HStack {

                            Spacer()


                            Image(
                                systemName:
                                    "magnifyingglass"
                            )


                            Text(
                                "Find Current Journeys"
                            )
                            .fontWeight(
                                .semibold
                            )


                            Spacer()
                        }
                        .padding(
                            .vertical,
                            4
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                }
                .padding()
                .background(
                    Color(
                        .secondarySystemBackground
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius:
                            18
                    )
                )


                // =================================================
                // MARK: Search Explanation
                // =================================================

                if !hasSearched {

                    HStack(
                        alignment:
                            .top,
                        spacing:
                            12
                    ) {

                        Image(
                            systemName:
                                "info.circle.fill"
                        )
                        .foregroundStyle(
                            .blue
                        )


                        Text(
                            "Journeys departing approximately 10 minutes before or after your selected time will be shown. Direct and transfer journeys may both appear."
                        )
                        .font(
                            .subheadline
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }
                    .padding()
                    .background(
                        Color.blue.opacity(
                            0.06
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius:
                                14
                        )
                    )
                }


                // =================================================
                // MARK: Search Results
                // =================================================

                if hasSearched {

                    VStack(
                        alignment:
                            .leading,
                        spacing:
                            16
                    ) {

                        Text(
                            "Possible Current Journeys"
                        )
                        .font(
                            .title2
                        )
                        .fontWeight(
                            .bold
                        )


                        Text(
                            "Select the journey that best matches the route you are currently planning to take."
                        )
                        .font(
                            .subheadline
                        )
                        .foregroundStyle(
                            .secondary
                        )


                        if currentJourneys.isEmpty {

                            noJourneysView

                        } else {

                            ForEach(
                                Array(
                                    currentJourneys.enumerated()
                                ),
                                id:
                                    \.element.id
                            ) {
                                index,
                                option in


                                currentJourneyCard(
                                    option:
                                        option,
                                    index:
                                        index
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(
            "Journey"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )


        // =====================================================
        // MARK: Origin Change
        // =====================================================

        .onChange(
            of:
                origin
        ) {
            _,
            newOrigin in


            updateDestination(
                for:
                    newOrigin
            )


            resetSearch()
        }


        // =====================================================
        // MARK: Destination Change
        // =====================================================

        .onChange(
            of:
                destination
        ) {
            _,
            _ in


            resetSearch()
        }


        // =====================================================
        // MARK: Time Change
        // =====================================================

        .onChange(
            of:
                selectedTime
        ) {
            _,
            _ in


            resetSearch()
        }


        // =====================================================
        // MARK: Navigation
        // =====================================================

        .navigationDestination(
            isPresented:
                $goToDisruptionInformation
        ) {

            DisruptionInformationView(
                journey:
                    $journey
            )
        }
    }


    // ========================================================
    // MARK: - Available Origins
    // ========================================================

    private var availableOrigins:
        [String] {

        let locations =
            DatabaseManager
                .shared
                .availableOrigins()


        if locations.isEmpty {

            return [
                origin
            ]
        }


        return locations
    }


    // ========================================================
    // MARK: - Available Destinations
    // ========================================================

    private var availableDestinations:
        [String] {

        let locations =
            DatabaseManager
                .shared
                .availableDestinations(
                    from:
                        origin
                )


        if locations.isEmpty {

            return [
                destination
            ]
        }


        return locations
    }


    // ========================================================
    // MARK: - Search Current Journeys
    // ========================================================

    private func searchCurrentJourneys() {

        currentJourneys =
            DatabaseManager
                .shared
                .searchCurrentJourneys(

                    origin:
                        origin,

                    destination:
                        destination,

                    selectedTime:
                        selectedTime
                )


        hasSearched =
            true
    }


    // ========================================================
    // MARK: - Select Journey
    // ========================================================

    private func selectJourney(
        _ option: JourneyOption
    ) {

        journey.origin =
            origin


        journey.destination =
            destination


        journey.selectedTime =
            selectedTime


        journey.setSelectedJourney(
            option
        )


        goToDisruptionInformation =
            true
    }


    // ========================================================
    // MARK: - Journey Option Card
    // ========================================================

    @ViewBuilder
    private func currentJourneyCard(
        option: JourneyOption,
        index: Int
    ) -> some View {

        Button {

            selectJourney(
                option
            )

        } label: {

            VStack(
                alignment:
                    .leading,
                spacing:
                    14
            ) {


                // -------------------------------------------------
                // Top Row
                // -------------------------------------------------

                HStack(
                    alignment:
                        .top,
                    spacing:
                        12
                ) {

                    Image(
                        systemName:
                            mainTransportIcon(
                                for:
                                    option
                            )
                    )
                    .font(
                        .title2
                    )
                    .frame(
                        width:
                            34
                    )


                    VStack(
                        alignment:
                            .leading,
                        spacing:
                            5
                    ) {

                        Text(
                            option.transportModeText
                        )
                        .font(
                            .headline
                        )
                        .foregroundStyle(
                            .primary
                        )


                        Text(
                            option.routeSummary
                        )
                        .font(
                            .subheadline
                        )
                        .foregroundStyle(
                            .secondary
                        )


                        Text(
                            "\(option.origin) → \(option.destination)"
                        )
                        .font(
                            .caption
                        )
                        .foregroundStyle(
                            .secondary
                        )
                    }


                    Spacer()


                    Image(
                        systemName:
                            "chevron.right"
                    )
                    .font(
                        .caption
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }


                Divider()


                // -------------------------------------------------
                // Departure / Arrival
                // -------------------------------------------------

                HStack(
                    alignment:
                        .top,
                    spacing:
                        16
                ) {

                    informationColumn(
                        title:
                            "Departure",
                        value:
                            scheduledDepartureText(
                                for:
                                    option
                            )
                    )


                    informationColumn(
                        title:
                            "Expected Arrival",
                        value:
                            option.expectedArrival
                    )
                }


                // -------------------------------------------------
                // Transfer / Duration
                // -------------------------------------------------

                HStack(
                    alignment:
                        .top,
                    spacing:
                        16
                ) {

                    informationColumn(
                        title:
                            "Transfers",
                        value:
                            option.transferText
                    )


                    informationColumn(
                        title:
                            "Duration",
                        value:
                            "\(option.totalMinutes) min"
                    )
                }


                // -------------------------------------------------
                // Status
                // -------------------------------------------------

                HStack(
                    spacing:
                        7
                ) {

                    Image(
                        systemName:
                            statusIcon(
                                for:
                                    option
                            )
                    )


                    Text(
                        statusText(
                            for:
                                option
                        )
                    )
                }
                .font(
                    .caption
                )
                .foregroundStyle(
                    option.hasDisruption
                    ? .orange
                    : .secondary
                )


                // -------------------------------------------------
                // Multi-Segment Summary
                // -------------------------------------------------

                if option.orderedSegments.count > 1 {

                    Divider()


                    VStack(
                        alignment:
                            .leading,
                        spacing:
                            10
                    ) {

                        Text(
                            "Journey Details"
                        )
                        .font(
                            .subheadline
                        )
                        .fontWeight(
                            .semibold
                        )


                        ForEach(
                            option.orderedSegments
                        ) {
                            segment in


                            HStack(
                                alignment:
                                    .top,
                                spacing:
                                    10
                            ) {

                                Image(
                                    systemName:
                                        segment.transportIcon
                                )
                                .frame(
                                    width:
                                        22
                                )


                                VStack(
                                    alignment:
                                        .leading,
                                    spacing:
                                        3
                                ) {

                                    Text(
                                        segment.routeDisplayText
                                    )
                                    .font(
                                        .subheadline
                                    )
                                    .fontWeight(
                                        .medium
                                    )


                                    Text(
                                        "\(segment.origin) → \(segment.destination)"
                                    )
                                    .font(
                                        .caption
                                    )
                                    .foregroundStyle(
                                        .secondary
                                    )
                                }


                                Spacer()
                            }
                        }
                    }
                }


                // -------------------------------------------------
                // Action
                // -------------------------------------------------

                HStack {

                    Spacer()


                    Text(
                        "This Is My Current Journey"
                    )
                    .font(
                        .subheadline
                    )
                    .fontWeight(
                        .semibold
                    )


                    Image(
                        systemName:
                            "arrow.right.circle.fill"
                    )


                    Spacer()
                }
                .padding(
                    .top,
                    4
                )
                .foregroundStyle(
                    Color.accentColor
                )
            }
            .padding()
            .frame(
                maxWidth:
                    .infinity,
                alignment:
                    .leading
            )
            .background(
                Color(
                    .secondarySystemBackground
                )
            )
            .overlay {

                RoundedRectangle(
                    cornerRadius:
                        18
                )
                .stroke(
                    Color.secondary.opacity(
                        0.18
                    ),
                    lineWidth:
                        1
                )
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius:
                        18
                )
            )
        }
        .buttonStyle(
            .plain
        )
    }


    // ========================================================
    // MARK: - Information Column
    // ========================================================

    @ViewBuilder
    private func informationColumn(
        title: String,
        value: String
    ) -> some View {

        VStack(
            alignment:
                .leading,
            spacing:
                4
        ) {

            Text(
                title
            )
            .font(
                .caption
            )
            .foregroundStyle(
                .secondary
            )


            Text(
                value
            )
            .font(
                .subheadline
            )
            .fontWeight(
                .semibold
            )
            .foregroundStyle(
                .primary
            )
        }
        .frame(
            maxWidth:
                .infinity,
            alignment:
                .leading
        )
    }


    // ========================================================
    // MARK: - Main Transport Icon
    // ========================================================

    private func mainTransportIcon(
        for option: JourneyOption
    ) -> String {

        guard let firstSegment =
                option.orderedSegments.first
        else {

            return
                "arrow.triangle.branch"
        }


        return firstSegment
            .transportIcon
    }


    // ========================================================
    // MARK: - Scheduled Departure Text
    // ========================================================

    private func scheduledDepartureText(
        for option: JourneyOption
    ) -> String {

        guard let firstSegment =
                option.orderedSegments.first
        else {

            return
                option.expectedDeparture
        }


        return firstSegment.scheduledDeparture
            ??
            firstSegment.expectedDeparture
            ??
            option.expectedDeparture
    }


    // ========================================================
    // MARK: - Status
    // ========================================================

    private func statusText(
        for option: JourneyOption
    ) -> String {

        if option.isCancelled {

            return
                "Journey contains a cancelled service"
        }


        if option.totalDelayMinutes > 0 {

            return
                "\(option.totalDelayMinutes) min disruption delay"
        }


        return
            "No significant disruption"
    }


    private func statusIcon(
        for option: JourneyOption
    ) -> String {

        if option.isCancelled {

            return
                "xmark.circle.fill"
        }


        if option.hasDisruption {

            return
                "exclamationmark.triangle.fill"
        }


        return
            "checkmark.circle.fill"
    }


    // ========================================================
    // MARK: - Update Destination
    // ========================================================

    private func updateDestination(
        for newOrigin: String
    ) {

        let destinations =
            DatabaseManager
                .shared
                .availableDestinations(
                    from:
                        newOrigin
                )


        guard let firstDestination =
                destinations.first
        else {

            return
        }


        if !destinations.contains(
            destination
        ) {

            destination =
                firstDestination
        }
    }


    // ========================================================
    // MARK: - Reset Search
    // ========================================================

    private func resetSearch() {

        currentJourneys =
            []


        hasSearched =
            false
    }


    // ========================================================
    // MARK: - No Journeys View
    // ========================================================

    private var noJourneysView:
        some View {

        VStack(
            spacing:
                14
        ) {

            Image(
                systemName:
                    "arrow.triangle.branch"
            )
            .font(
                .system(
                    size:
                        40
                )
            )
            .foregroundStyle(
                .secondary
            )


            Text(
                "No Journeys Found"
            )
            .font(
                .headline
            )


            Text(
                "No matching journeys were found within approximately 10 minutes before or after the selected time. Try another time or journey."
            )
            .font(
                .subheadline
            )
            .foregroundStyle(
                .secondary
            )
            .multilineTextAlignment(
                .center
            )
        }
        .frame(
            maxWidth:
                .infinity
        )
        .padding(
            .vertical,
            30
        )
        .padding(
            .horizontal
        )
        .background(
            Color(
                .secondarySystemBackground
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius:
                    16
            )
        )
    }
}
