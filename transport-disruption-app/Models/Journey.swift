//
//  Journey.swift
//  transport-disruption-app
//

import Foundation


struct Journey {

    var origin: String

    var destination: String

    var selectedTime: Date


    // ========================================================
    // MARK: - Current Journey
    // ========================================================

    /*
     The journey selected on Page 1.

     This can now be:

     - Direct Bus
     - Direct Train
     - Direct Ferry
     - Bus → Train
     - Bus → Bus
     - Walk → Ferry → Walk
     - Any other complete JourneyOption
     */

    var selectedJourney:
        JourneyOption?


    // ========================================================
    // MARK: - Decision Support
    // ========================================================

    /*
     Options shown on Page 3.

     These include the current journey itself
     when it is still usable, together with
     alternative journeys.
     */

    var alternativeOptions:
        [JourneyOption]


    /*
     The option selected by the passenger
     on the Decision Support page.
     */

    var selectedOption:
        JourneyOption?


    // ========================================================
    // MARK: - Basic State
    // ========================================================

    var hasSelectedJourney: Bool {

        selectedJourney != nil
    }


    var hasAlternativeOptions: Bool {

        !alternativeOptions.isEmpty
    }


    var hasSelectedOption: Bool {

        selectedOption != nil
    }


    // ========================================================
    // MARK: - Current Journey Summary
    // ========================================================

    var selectedJourneySummary: String {

        guard let journey =
                selectedJourney
        else {

            return
                "No current journey selected"
        }


        return """
        \(journey.transportModeText)
        \(journey.routeSummary)
        \(journey.origin) → \(journey.destination)
        Departure: \(journey.expectedDeparture)
        Expected arrival: \(journey.expectedArrival)
        """
    }


    // ========================================================
    // MARK: - Selected Decision Summary
    // ========================================================

    var selectedOptionSummary: String {

        guard let option =
                selectedOption
        else {

            return
                "No travel option selected"
        }


        return """
        \(option.transportModeText)
        \(option.routeSummary)
        \(option.origin) → \(option.destination)
        Departure: \(option.expectedDeparture)
        Expected arrival: \(option.expectedArrival)
        """
    }


    // ========================================================
    // MARK: - Set Current Journey
    // ========================================================

    mutating func setSelectedJourney(
        _ option: JourneyOption
    ) {

        selectedJourney =
            option


        origin =
            option.origin


        destination =
            option.destination


        resetDecision()
    }


    // ========================================================
    // MARK: - Reset Current Journey
    // ========================================================

    mutating func clearSelectedJourney() {

        selectedJourney =
            nil


        resetDecision()
    }


    // ========================================================
    // MARK: - Reset Decision
    // ========================================================

    mutating func resetDecision() {

        alternativeOptions =
            []


        selectedOption =
            nil
    }


    // ========================================================
    // MARK: - Set Decision Options
    // ========================================================

    mutating func setAlternativeOptions(
        _ options: [JourneyOption]
    ) {

        alternativeOptions =
            options


        selectedOption =
            nil
    }


    // ========================================================
    // MARK: - Toggle Decision Option
    // ========================================================

    mutating func toggleOption(
        _ option: JourneyOption
    ) {

        if selectedOption?.id ==
            option.id {

            // Tap the same option again
            // → deselect

            selectedOption =
                nil

        } else {

            // Select another option

            selectedOption =
                option
        }
    }


    // ========================================================
    // MARK: - Is Current Journey
    // ========================================================

    func isCurrentJourney(
        _ option: JourneyOption
    ) -> Bool {

        guard let currentJourney =
                selectedJourney
        else {

            return false
        }


        return currentJourney.id ==
            option.id
    }


    // ========================================================
    // MARK: - Current Journey Cancelled
    // ========================================================

    var currentJourneyIsCancelled: Bool {

        guard let currentJourney =
                selectedJourney
        else {

            return false
        }


        /*
         If any transport segment in the journey
         is cancelled, the whole journey is treated
         as unavailable.
         */

        return currentJourney.isCancelled
    }


    // ========================================================
    // MARK: - Current Journey Selectability
    // ========================================================

    var currentJourneyCanBeSelected: Bool {

        guard let currentJourney =
                selectedJourney
        else {

            return false
        }


        return !currentJourney.isCancelled
    }


    // ========================================================
    // MARK: - Current Journey Disruption
    // ========================================================

    var currentJourneyHasDisruption: Bool {

        guard let currentJourney =
                selectedJourney
        else {

            return false
        }


        return currentJourney.hasDisruption
    }


    // ========================================================
    // MARK: - Disrupted Segments
    // ========================================================

    var disruptedSegments:
        [JourneySegment] {

        guard let currentJourney =
                selectedJourney
        else {

            return []
        }


        return currentJourney
            .orderedSegments
            .filter {

                $0.isCancelled
                ||
                $0.delayMinutes > 0
                ||
                $0.disruptionType !=
                    "Normal Service"
            }
    }


    // ========================================================
    // MARK: - Empty Journey
    // ========================================================

    static var empty: Journey {

        Journey(

            origin:
                "UQ Lakes",

            destination:
                "Brisbane City",

            selectedTime:
                Date(),

            selectedJourney:
                nil,

            alternativeOptions:
                [],

            selectedOption:
                nil
        )
    }
}
