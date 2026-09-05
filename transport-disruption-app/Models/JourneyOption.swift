//
//  JourneyOption.swift
//  transport-disruption-app
//

import Foundation

struct JourneyOption: Identifiable, Hashable {

    // MARK: - Identity

    let id: Int


    // MARK: - Complete Journey

    let origin: String
    let destination: String

    let segments: [JourneySegment]


    // MARK: - Overall Journey Information

    let totalMinutes: Int
    let transfers: Int


    // MARK: - Time Information

    let expectedDeparture: String
    let expectedArrival: String


    // MARK: - Display Helpers

    var transferText: String {

        if transfers == 0 {
            return "Direct"
        }

        if transfers == 1 {
            return "1 transfer"
        }

        return "\(transfers) transfers"
    }


    // MARK: - Transport Modes

    var transportModes: [String] {

        var modes: [String] = []

        for segment in segments {

            let mode =
                segment.transportDisplayName

            if !modes.contains(mode) {
                modes.append(mode)
            }
        }

        return modes
    }


    var transportModeText: String {

        transportModes.joined(
            separator: " + "
        )
    }


    // MARK: - Route Summary

    var routeSummary: String {

        segments
            .map {
                $0.routeDisplayText
            }
            .joined(
                separator: " → "
            )
    }


    // MARK: - Disruption

    var totalDelayMinutes: Int {

        segments.reduce(0) {
            result,
            segment in

            result + segment.delayMinutes
        }
    }


    var delayText: String {

        if isCancelled {
            return "Unavailable"
        }

        if totalDelayMinutes <= 0 {
            return "On time"
        }

        return "\(totalDelayMinutes) min delay"
    }


    var hasDisruption: Bool {

        segments.contains {
            $0.delayMinutes > 0 ||
            $0.disruptionType != "Normal Service"
        }
    }


    var isCancelled: Bool {

        segments.contains {
            $0.isCancelled
        }
    }


    // MARK: - Delay Risk

    /*
     This is a prototype-level disruption risk category.
     It does NOT claim to predict real-world service reliability.

     Low:
     - no active disruption and no delay

     Moderate:
     - a minor disruption / short delay is present

     High:
     - a major disruption, cancellation, or larger accumulated delay
    */

    var delayRiskLevel: String {

        if isCancelled {
            return "High"
        }

        let disruptionLabels =
            segments.map {
                $0.disruptionType.lowercased()
            }

        if disruptionLabels.contains(where: {
            $0.contains("major") ||
            $0.contains("cancel")
        }) {
            return "High"
        }

        if totalDelayMinutes >= 10 {
            return "High"
        }

        if hasDisruption || totalDelayMinutes > 0 {
            return "Moderate"
        }

        return "Low"
    }


    var delayRiskExplanation: String {

        switch delayRiskLevel {

        case "High":
            if isCancelled {
                return "This journey includes a cancelled service."
            }

            if totalDelayMinutes > 0 {
                return "This journey is currently affected by disruption and has \(totalDelayMinutes) minutes of recorded delay."
            }

            return "This journey includes a service currently experiencing a major disruption."

        case "Moderate":
            if totalDelayMinutes > 0 {
                return "This journey includes a disrupted service with \(totalDelayMinutes) minutes of recorded delay."
            }

            return "This journey includes a service currently experiencing a minor disruption."

        default:
            return "No active disruption is currently recorded for this journey."
        }
    }


    // MARK: - Walking

    var includesWalking: Bool {

        segments.contains {
            $0.isWalking
        }
    }


    var walkingMinutes: Int {

        segments
            .filter {
                $0.isWalking
            }
            .reduce(0) {
                result,
                segment in

                result + segment.durationMinutes
            }
    }


    // MARK: - First / Last Segment

    var firstSegment: JourneySegment? {

        segments
            .sorted {
                $0.sequence < $1.sequence
            }
            .first
    }


    var lastSegment: JourneySegment? {

        segments
            .sorted {
                $0.sequence < $1.sequence
            }
            .last
    }


    // MARK: - Sorted Segments

    var orderedSegments: [JourneySegment] {

        segments.sorted {
            $0.sequence < $1.sequence
        }
    }


    // MARK: - Map Stops

    var mapStopNames: [String] {

        let ordered = orderedSegments

        guard let firstSegment = ordered.first else {
            return [origin, destination]
        }

        var stops: [String] = [
            firstSegment.origin
        ]

        for segment in ordered {
            if stops.last != segment.destination {
                stops.append(segment.destination)
            }
        }

        return stops
    }


    // MARK: - Journey Description

    var journeyDescription: String {

        if transfers == 0 {

            return """
            \(transportModeText) • \(totalMinutes) min • Direct
            """
        }

        return """
        \(transportModeText) • \(totalMinutes) min • \(transferText)
        """
    }
}


