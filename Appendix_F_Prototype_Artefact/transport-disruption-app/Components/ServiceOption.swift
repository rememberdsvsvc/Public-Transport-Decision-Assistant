//
//  ServiceOption.swift
//  transport-disruption-app
//

import SwiftUI

struct ServiceOptionPresentation {
    let title: String
    let systemImage: String
    let route: String
    let origin: String
    let destination: String
    let metrics: [JourneyMetric]
    let status: PresentationStatus
    var emphases: Set<JourneyEmphasis> = []
    var segments: [JourneySegmentPresentation] = []
}

struct ServiceOption: View {
    let option: ServiceOptionPresentation
    let buttonTitle: String
    var isActionEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            JourneySummary(
                title: option.title,
                systemImage: option.systemImage,
                route: option.route,
                origin: option.origin,
                destination: option.destination,
                metrics: option.metrics,
                status: option.status,
                emphases: option.emphases
            )

            if !option.segments.isEmpty {
                JourneyTimeline(title: "Journey details", segments: option.segments)
            }

            PrimaryActionButton(title: buttonTitle, trailingSystemImage: "arrow.right") {
                action()
            }
            .disabled(!isActionEnabled)
        }
    }
}

#Preview("Service option states") {
    AppPageContainer {
        ServiceOption(
            option: ServiceOptionPresentation(
                title: "Option 1",
                systemImage: "bus.fill",
                route: "Route 66 via Cultural Centre",
                origin: "University of Queensland Lakes",
                destination: "Brisbane City",
                metrics: [
                    JourneyMetric(title: "Departure", value: "8:10 AM"),
                    JourneyMetric(title: "Expected arrival", value: "9:05 AM"),
                    JourneyMetric(title: "Transfers", value: "Direct"),
                    JourneyMetric(title: "Duration", value: "55 min")
                ],
                status: .normal(),
                emphases: [.recommended, .selected]
            ),
            buttonTitle: "Use This Journey"
        ) {}

        ServiceOption(
            option: ServiceOptionPresentation(
                title: "Current journey",
                systemImage: "tram.fill",
                route: "Ipswich Line with an intentionally long service description",
                origin: "Roma Street",
                destination: "Indooroopilly Station",
                metrics: [
                    JourneyMetric(title: "Departure", value: "9:12 AM"),
                    JourneyMetric(title: "Expected arrival", value: "Unavailable")
                ],
                status: .cancelled(),
                emphases: [.currentJourney]
            ),
            buttonTitle: "Unavailable",
            isActionEnabled: false
        ) {}
    }
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility1)
}
