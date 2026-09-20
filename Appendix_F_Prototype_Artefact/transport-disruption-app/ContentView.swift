//
//  ContentView.swift
//  transport-disruption-app
//

import SwiftUI

struct ContentView: View {
    @State private var journey = Journey.empty
    @State private var startJourney = false

    private let stepColumns = [
        GridItem(.adaptive(minimum: 260), spacing: AppSpacing.large, alignment: .top)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    homeHeader
                    startJourneyPanel
                    howItWorks

                    InformationNotice(
                        title: "Prototype Purpose",
                        message: "This prototype explores how public transport disruption information can be presented more clearly and actionably to support passenger decision-making."
                    )
                }
                .appPageWidth()
                .padding(.vertical, AppSpacing.extraLarge)
            }
            .background(AppColor.pageBackground.ignoresSafeArea())
            .navigationDestination(isPresented: $startJourney) {
                CurrentJourneyView(journey: $journey)
            }
        }
        .tint(AppColor.ink)
    }

    private var homeHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            HStack(alignment: .center, spacing: AppSpacing.medium) {
                Image(systemName: "bus.fill")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(
                        width: AppLayout.minimumTouchTarget,
                        height: AppLayout.minimumTouchTarget
                    )
                    .background(AppColor.ink)
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                Text("PERSONAL TRANSPORT CONSOLE")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                Spacer(minLength: 0)
            }

            Text("Public Transport\nDisruption Support")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text("Understand service disruptions, see how they affect your journey, and compare available travel options before making your decision.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var startJourneyPanel: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            Label("Ready to travel?", systemImage: "location.fill")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(AppColor.ink)

            Text("Start with the journey you are planning now.")
                .font(.body)
                .foregroundStyle(AppColor.ink.opacity(0.78))

            PrimaryActionButton(
                title: "Start Journey",
                systemImage: "location.fill"
            ) {
                journey = Journey.empty
                startJourney = true
            }
            .tint(AppColor.ink)
            .accentColor(AppColor.ink)
        }
        .padding(AppSpacing.extraLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.vanilla)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
        .accessibilityElement(children: .contain)
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionHeader(
                title: "How It Works",
                subtitle: "Four short steps from journey search to an informed travel decision."
            )

            LazyVGrid(columns: stepColumns, alignment: .leading, spacing: AppSpacing.large) {
                HomeStepRow(
                    number: "1",
                    icon: "location.fill",
                    title: "Select Your Journey",
                    description: "Enter your origin, destination and approximate travel time, then identify your current service.",
                    background: AppColor.aliceBlue
                )

                HomeStepRow(
                    number: "2",
                    icon: "exclamationmark.triangle.fill",
                    title: "Understand the Disruption",
                    description: "See what has happened and understand how the disruption affects your journey.",
                    background: AppColor.honeydew
                )

                HomeStepRow(
                    number: "3",
                    icon: "arrow.triangle.branch",
                    title: "Compare Your Options",
                    description: "Compare the current service with available alternatives using clear journey information.",
                    background: AppColor.aliceBlue
                )

                HomeStepRow(
                    number: "4",
                    icon: "checkmark.circle.fill",
                    title: "Make Your Decision",
                    description: "Choose the travel option that works for you and evaluate the decision-support experience.",
                    background: AppColor.honeydew
                )
            }
        }
    }
}

struct HomeStepRow: View {
    let number: String
    let icon: String
    let title: String
    let description: String
    let background: Color

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Text(number)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(
                    width: AppLayout.minimumTouchTarget,
                    height: AppLayout.minimumTouchTarget
                )
                .background(AppColor.ink)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Label(title, systemImage: icon)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppColor.ink)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.ink.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Step \(number). \(title). \(description)")
    }
}

#Preview("Home") {
    ContentView()
}

#Preview("Home - Dark and Large Type") {
    ContentView()
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility1)
}
