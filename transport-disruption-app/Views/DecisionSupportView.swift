//
//  DecisionSupportView.swift
//  transport-disruption-app
//

import SwiftUI

private enum DecisionPriority: String, CaseIterable, Identifiable {
    case arriveSooner
    case avoidDisruption
    case fewerTransfers
    case lessWalking

    var id: String { rawValue }

    var title: String {
        switch self {
        case .arriveSooner:
            return "Arrive sooner"
        case .avoidDisruption:
            return "Avoid disruption"
        case .fewerTransfers:
            return "Fewer transfers"
        case .lessWalking:
            return "Less walking"
        }
    }

    var subtitle: String {
        switch self {
        case .arriveSooner:
            return "Reach your destination as early as possible."
        case .avoidDisruption:
            return "Prefer services with lower disruption-related delay risk."
        case .fewerTransfers:
            return "Reduce the number of changes."
        case .lessWalking:
            return "Reduce additional walking."
        }
    }

    var icon: String {
        switch self {
        case .arriveSooner:
            return "bolt.fill"
        case .avoidDisruption:
            return "shield.fill"
        case .fewerTransfers:
            return "arrow.triangle.branch"
        case .lessWalking:
            return "figure.walk"
        }
    }
}

struct DecisionSupportView: View {
    @Binding var journey: Journey
    @State private var goToEvaluation = false
    @State private var selectedPriority: DecisionPriority = .arriveSooner
    @State private var showPrioritySheet = false

    // Only one option's detailed itinerary is expanded at a time.
    @State private var expandedJourneyOptionID: Int?

    private let metricColumns = [
        GridItem(
            .adaptive(minimum: 128),
            spacing: AppSpacing.large,
            alignment: .top
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.section) {
                PageHeader(
                    title: "Decision Support",
                    subtitle: "See how each option changes your disrupted journey, including the benefits and trade-offs."
                )

                if let currentJourney = journey.selectedJourney {
                    currentSituation(currentJourney)
                }

                prioritySection

                optionsSection

                if let selectedOption = journey.selectedOption {
                    selectionSummary(selectedOption)
                }
            }
            .appPageWidth()
            .padding(.vertical, AppSpacing.extraLarge)
        }
        .background(AppColor.pageBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if let selectedOption = journey.selectedOption {
                pageThreeConfirmationBar(selectedOption)
            }
        }
        .navigationDestination(isPresented: $goToEvaluation) {
            EvaluationView(journey: $journey)
        }
        .sheet(isPresented: $showPrioritySheet) {
            prioritySheet
                .presentationDetents([.medium])
        }
    }

    private var displayedOptions: [JourneyOption] {
        let allOptions = journey.alternativeOptions

        guard !allOptions.isEmpty else {
            return []
        }

        let sortedOptions = allOptions.sorted {
            optionComesBefore(
                $0,
                $1,
                for: selectedPriority
            )
        }

        guard
            let currentJourney = journey.selectedJourney,
            !currentJourney.isCancelled
        else {
            return Array(sortedOptions.prefix(5))
        }

        // Keep "stay with current journey" available even if it would
        // otherwise fall outside the first five after priority sorting.
        let withoutCurrent = sortedOptions.filter {
            $0.id != currentJourney.id
        }

        var candidates =
            Array(withoutCurrent.prefix(4))

        candidates.append(currentJourney)

        return candidates.sorted {
            optionComesBefore(
                $0,
                $1,
                for: selectedPriority
            )
        }
    }

    private var standoutOptionID: Int? {
        displayedOptions.first?.id
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack {
                Label(
                    "Decision Priority",
                    systemImage: "slider.horizontal.3"
                )
                .font(AppTypography.cardTitle)

                Spacer()

                Button("Change") {
                    showPrioritySheet = true
                }
                .font(AppTypography.metadata)
                .foregroundStyle(AppColor.accent)
            }

            Button {
                showPrioritySheet = true
            } label: {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: selectedPriority.icon)
                        .font(.title3)
                        .foregroundStyle(AppColor.accent)
                        .frame(width: AppLayout.iconSize)

                    VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                        Text(selectedPriority.title)
                            .font(AppTypography.cardTitle)

                        Text(selectedPriority.subtitle)
                            .font(AppTypography.supporting)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppColor.accent)
                        .accessibilityHidden(true)
                }
                .appCard(
                    background: AppColor.accent.opacity(0.06),
                    showsBorder: true
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var prioritySheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                Text("Decision Priority")
                    .font(.title2.bold())

                Text("What matters most to you during this disruption?")
                    .font(AppTypography.supporting)

                VStack(spacing: AppSpacing.small) {
                    ForEach(DecisionPriority.allCases) { priority in
                        Button {
                            selectedPriority = priority
                            showPrioritySheet = false
                        } label: {
                            HStack(alignment: .top, spacing: AppSpacing.medium) {
                                Image(systemName: priority.icon)
                                    .foregroundStyle(AppColor.accent)
                                    .frame(width: AppLayout.iconSize)

                                VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                                    Text(priority.title)
                                        .font(AppTypography.cardTitle)

                                    Text(priority.subtitle)
                                        .font(AppTypography.supporting)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                if selectedPriority == priority {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppColor.accent)
                                }
                            }
                            .padding(.vertical, AppSpacing.small)
                        }
                        .buttonStyle(.plain)

                        if priority != DecisionPriority.allCases.last {
                            Divider()
                        }
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.large)
        }
    }

    @ViewBuilder
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionHeader(
                title: "Your Options",
                subtitle: "Ordered by your priority: \(selectedPriority.title).",
                systemImage: "arrow.triangle.branch"
            )

            if displayedOptions.isEmpty {
                EmptyStateView(
                    title: "No Available Options",
                    message: "No suitable journeys are currently available for comparison.",
                    systemImage: "exclamationmark.triangle"
                )
            } else {
                ForEach(
                    Array(displayedOptions.enumerated()),
                    id: \.element.id
                ) { index, option in
                    decisionOptionCard(
                        option: option,
                        position: index
                    )
                }
            }
        }
    }

    private func currentSituation(_ option: JourneyOption) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            JourneySummary(
                title: "Current disrupted journey",
                systemImage: mainTransportIcon(for: option),
                route: option.routeSummary,
                origin: option.origin,
                destination: option.destination,
                metrics: comparisonMetrics(for: option),
                status: serviceStatus(for: option)
            )

            delayRiskPanel(for: option)
        }
    }

    private func decisionOptionCard(
        option: JourneyOption,
        position: Int
    ) -> some View {
        let isSelected = journey.selectedOption?.id == option.id
        let isCurrent = journey.isCurrentJourney(option)
        let standsOut = standoutOptionID == option.id

        return Button {
            journey.toggleOption(option)
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                optionStateLabels(
                    isCurrent: isCurrent,
                    isSelected: isSelected,
                    standsOut: standsOut,
                    position: position
                )

                routeIdentity(option)

                if standsOut,
                   let currentJourney = journey.selectedJourney {
                    priorityMatchSummary(
                        option: option,
                        currentJourney: currentJourney
                    )
                }

                Divider()

                LazyVGrid(
                    columns: metricColumns,
                    alignment: .leading,
                    spacing: AppSpacing.large
                ) {
                    ForEach(Array(comparisonMetrics(for: option).enumerated()), id: \.offset) { _, metric in
                        MetricColumn(
                            title: metric.title,
                            value: metric.value,
                            systemImage: metric.systemImage
                        )
                    }
                }

                delayRiskPanel(for: option)

                if isSelected {
                    Divider()

                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Label(
                            "Route Map",
                            systemImage: "map.fill"
                        )
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppColor.accent)

                        Text("Showing the route you selected.")
                            .font(AppTypography.supporting)
                            .fixedSize(horizontal: false, vertical: true)

                        JourneyMapView(
                            option: option
                        )
                    }
                }

                if let currentJourney = journey.selectedJourney {
                    Divider()

                    if isCurrent {
                        currentJourneyExplanation(option)
                    } else {
                        comparisonPanel(
                            option: option,
                            currentJourney: currentJourney
                        )
                    }

                }

                if option.orderedSegments.count > 1 {
                    Divider()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedJourneyOptionID =
                                expandedJourneyOptionID == option.id
                                ? nil
                                : option.id
                        }
                    } label: {
                        HStack(spacing: AppSpacing.small) {
                            Image(
                                systemName:
                                    expandedJourneyOptionID == option.id
                                    ? "chevron.down"
                                    : "chevron.right"
                            )
                            .font(.caption.bold())
                            .foregroundStyle(AppColor.accent)

                            Text(
                                expandedJourneyOptionID == option.id
                                ? "Hide journey details"
                                : "View journey details"
                            )
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppColor.ink)

                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if expandedJourneyOptionID == option.id {
                        journeySegments(option.orderedSegments)
                            .transition(
                                .opacity.combined(with: .move(edge: .top))
                            )
                    }
                }
            }
            .appCard(
                background: isSelected
                    ? AppColor.accent.opacity(0.08)
                    : AppColor.surface,
                showsBorder: true
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.large)
                    .stroke(
                        isSelected ? AppColor.accent : Color.clear,
                        lineWidth: 2
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: option))
        .accessibilityHint("Double tap to \(isSelected ? "deselect" : "select") this journey.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func optionStateLabels(
        isCurrent: Bool,
        isSelected: Bool,
        standsOut: Bool,
        position: Int
    ) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: AppSpacing.small) {
                stateBadges(
                    isCurrent: isCurrent,
                    isSelected: isSelected,
                    standsOut: standsOut,
                    position: position
                )
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                stateBadges(
                    isCurrent: isCurrent,
                    isSelected: isSelected,
                    standsOut: standsOut,
                    position: position
                )
            }
        }
    }

    @ViewBuilder
    private func stateBadges(
        isCurrent: Bool,
        isSelected: Bool,
        standsOut: Bool,
        position: Int
    ) -> some View {
        if standsOut {
            Label(
                "Best match · \(selectedPriority.title)",
                systemImage: selectedPriority.icon
            )
            .font(AppTypography.metadata)
            .foregroundStyle(AppColor.accent)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, AppSpacing.extraSmall)
            .background(AppColor.accent.opacity(0.10))
            .clipShape(Capsule())
        } else {
            Text("Option \(position + 1)")
                .font(AppTypography.metadata)
        }

        if isCurrent {
            JourneyEmphasisBadge(emphasis: .currentJourney)
        }

        if isSelected {
            JourneyEmphasisBadge(emphasis: .selected)
        }
    }

    private func routeIdentity(_ option: JourneyOption) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: mainTransportIcon(for: option))
                .font(.title2)
                .foregroundStyle(AppColor.accent)
                .frame(width: AppLayout.iconSize, height: AppLayout.iconSize)
                .background(AppColor.accent.opacity(0.10))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(option.transportModeText)
                    .font(AppTypography.metadata)

                Text(option.routeSummary)
                    .font(AppTypography.cardTitle)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(option.origin) to \(option.destination)")
                    .font(AppTypography.supporting)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpacing.small)
        }
    }

    private func delayRiskPanel(for option: JourneyOption) -> some View {
        let colour = delayRiskColour(for: option)

        return VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: delayRiskIcon(for: option))
                    .foregroundStyle(colour)
                    .accessibilityHidden(true)

                Text(delayRiskTitle(for: option))
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(colour)
            }

            Text(option.delayRiskExplanation)
                .font(AppTypography.supporting)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colour.opacity(0.10))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
                .stroke(colour.opacity(0.35), lineWidth: 1)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
        )
    }

    private func currentJourneyExplanation(_ option: JourneyOption) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("If you stay with this journey")
                .font(AppTypography.cardTitle)

            Text(currentJourneyDecisionText(option))
                .font(AppTypography.supporting)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func comparisonPanel(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Compared with your current journey")
                .font(AppTypography.cardTitle)

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                comparisonLine(
                    icon: "clock",
                    text: arrivalComparisonText(
                        option: option,
                        currentJourney: currentJourney
                    ),
                    colour: arrivalComparisonColour(
                        option: option,
                        currentJourney: currentJourney
                    )
                )

                comparisonLine(
                    icon: "hourglass",
                    text: waitingComparisonText(
                        option: option,
                        currentJourney: currentJourney
                    ),
                    colour: waitingComparisonColour(
                        option: option,
                        currentJourney: currentJourney
                    )
                )

                comparisonLine(
                    icon: "arrow.triangle.branch",
                    text: transferComparisonText(
                        option: option,
                        currentJourney: currentJourney
                    ),
                    colour: transferComparisonColour(
                        option: option,
                        currentJourney: currentJourney
                    )
                )

                comparisonLine(
                    icon: "figure.walk",
                    text: walkingComparisonText(
                        option: option,
                        currentJourney: currentJourney
                    ),
                    colour: walkingComparisonColour(
                        option: option,
                        currentJourney: currentJourney
                    )
                )

                comparisonLine(
                    icon: "exclamationmark.triangle",
                    text: disruptionComparisonText(
                        option: option,
                        currentJourney: currentJourney
                    ),
                    colour: disruptionComparisonColour(
                        option: option,
                        currentJourney: currentJourney
                    )
                )
            }

            Divider()

            Label(
                "Why consider this option?",
                systemImage: "checkmark.circle.fill"
            )
            .font(AppTypography.cardTitle)
            .foregroundStyle(.green)

            Text(benefitText(
                option: option,
                currentJourney: currentJourney
            ))
            .font(AppTypography.supporting)
            .fixedSize(horizontal: false, vertical: true)

            if let tradeOff = tradeOffText(
                option: option,
                currentJourney: currentJourney
            ) {
                Label(
                    "Trade-off",
                    systemImage: "exclamationmark.circle.fill"
                )
                .font(AppTypography.metadata)
                .foregroundStyle(.orange)

                Text(tradeOff)
                    .font(AppTypography.supporting)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func comparisonLine(
        icon: String,
        text: String,
        colour: Color
    ) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            Image(systemName: icon)
                .frame(width: AppLayout.iconSize)
                .foregroundStyle(colour)
                .accessibilityHidden(true)

            Text(text)
                .font(AppTypography.supporting)
                .foregroundStyle(colour)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Sticky Confirmation Bar

    private func pageThreeConfirmationBar(_ option: JourneyOption) -> some View {
        VStack(spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppColor.accent)

                Text(
                    journey.isCurrentJourney(option)
                    ? "Selected: Stay with \(option.routeSummary)"
                    : "Selected: \(option.routeSummary)"
                )
                .font(AppTypography.metadata)
                .lineLimit(1)

                Spacer(minLength: 0)
            }

            PrimaryActionButton(
                title: "Confirm My Choice",
                systemImage: "checkmark.circle.fill"
            ) {
                goToEvaluation = true
            }
            .tint(AppColor.ink)
            .accentColor(AppColor.ink)
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.top, AppSpacing.medium)
        .padding(.bottom, AppSpacing.small)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private func selectionSummary(_ option: JourneyOption) -> some View {
        let title =
            journey.isCurrentJourney(option)
            ? "You chose to stay"
            : "Selected Alternative"

        let message =
            journey.isCurrentJourney(option)
            ? "You chose to continue with \(option.routeSummary), arriving at \(option.expectedArrival)."
            : "You chose \(option.routeSummary), arriving at \(option.expectedArrival)."

        return InformationNotice(
            title: title,
            message: message,
            status: .success("Selected")
        )
    }

    private func journeySegments(_ segments: [JourneySegment]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Journey details")
                .font(AppTypography.cardTitle)

            ForEach(segments) { segment in
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    Image(systemName: segment.transportIcon)
                        .foregroundStyle(serviceStatus(for: segment).foregroundStyle)
                        .frame(width: AppLayout.iconSize)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                        Text(segment.routeDisplayText)
                            .font(AppTypography.cardTitle)

                        Text("\(segment.origin) to \(segment.destination)")
                            .font(AppTypography.supporting)
                            .fixedSize(horizontal: false, vertical: true)

                        StatusBadge(status: serviceStatus(for: segment))
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func comparisonMetrics(for option: JourneyOption) -> [JourneyMetric] {
        var metrics = [
            JourneyMetric(
                title: "Departure",
                value: departureText(for: option),
                systemImage: "arrow.up.right"
            ),
            JourneyMetric(
                title: "Expected arrival",
                value: option.expectedArrival,
                systemImage: "arrow.down.right"
            ),
            JourneyMetric(
                title: "Transfers",
                value: "\(option.transfers)",
                systemImage: "arrow.triangle.branch"
            ),
            JourneyMetric(
                title: "Duration",
                value: "\(option.totalMinutes) min",
                systemImage: "clock"
            ),
            JourneyMetric(
                title: "Delay",
                value: option.delayText,
                systemImage: "clock.badge.exclamationmark"
            )
        ]

        if option.walkingMinutes > 0 {
            metrics.append(
                JourneyMetric(
                    title: "Walking",
                    value: "\(option.walkingMinutes) min",
                    systemImage: "figure.walk"
                )
            )
        }

        return metrics
    }

    // MARK: - Comparison Logic

    private func arrivalComparisonText(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> String {
        let difference =
            signedTimeDifference(
                from: currentJourney.expectedArrival,
                to: option.expectedArrival
            )

        if difference < 0 {
            return "\(abs(difference)) min earlier expected arrival"
        }

        if difference > 0 {
            return "\(difference) min later expected arrival"
        }

        return "Same expected arrival time"
    }

    private func waitingComparisonText(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> String {
        let currentWait =
            waitingMinutes(
                for: currentJourney
            )

        let optionWait =
            waitingMinutes(
                for: option
            )

        let difference =
            optionWait - currentWait

        if difference < 0 {
            return "\(abs(difference)) min less waiting"
        }

        if difference > 0 {
            return "\(difference) min more waiting"
        }

        return "Similar waiting time"
    }

    private func transferComparisonText(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> String {
        let difference =
            option.transfers - currentJourney.transfers

        if difference < 0 {
            return "\(abs(difference)) fewer transfer\(abs(difference) == 1 ? "" : "s")"
        }

        if difference > 0 {
            return "\(difference) additional transfer\(difference == 1 ? "" : "s")"
        }

        return "Same number of transfers"
    }

    private func walkingComparisonText(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> String {
        let difference =
            option.walkingMinutes - currentJourney.walkingMinutes

        if difference < 0 {
            return "\(abs(difference)) min less walking"
        }

        if difference > 0 {
            return "\(difference) min more walking"
        }

        return "Same walking time"
    }

    private func disruptionComparisonText(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> String {
        let optionRisk =
            riskScore(option.delayRiskLevel)

        let currentRisk =
            riskScore(currentJourney.delayRiskLevel)

        if optionRisk < currentRisk {
            return "Lower disruption-related delay risk"
        }

        if optionRisk > currentRisk {
            return "Higher disruption-related delay risk"
        }

        return "Similar disruption-related delay risk"
    }

    private func benefitText(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> String {
        var benefits: [String] = []

        let arrivalDifference =
            signedTimeDifference(
                from: currentJourney.expectedArrival,
                to: option.expectedArrival
            )

        if arrivalDifference < 0 {
            benefits.append(
                "it is expected to arrive \(abs(arrivalDifference)) minutes earlier"
            )
        }

        let waitDifference =
            waitingMinutes(for: option)
            - waitingMinutes(for: currentJourney)

        if waitDifference < 0 {
            benefits.append(
                "it reduces waiting by \(abs(waitDifference)) minutes"
            )
        }

        if option.transfers < currentJourney.transfers {
            benefits.append(
                "it requires fewer transfers"
            )
        }

        if option.walkingMinutes < currentJourney.walkingMinutes {
            benefits.append(
                "it requires less walking"
            )
        }

        if riskScore(option.delayRiskLevel) <
            riskScore(currentJourney.delayRiskLevel) {

            benefits.append(
                "it has lower disruption-related delay risk"
            )
        }

        if benefits.isEmpty {
            return "This option does not provide a clear advantage over your current journey on the displayed measures, but it remains available for you to compare."
        }

        return "This option may be worth considering because \(joinedReasonText(benefits))."
    }

    private func tradeOffText(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> String? {
        var tradeOffs: [String] = []

        let arrivalDifference =
            signedTimeDifference(
                from: currentJourney.expectedArrival,
                to: option.expectedArrival
            )

        if arrivalDifference > 0 {
            tradeOffs.append(
                "it may arrive \(arrivalDifference) minutes later"
            )
        }

        let waitDifference =
            waitingMinutes(for: option)
            - waitingMinutes(for: currentJourney)

        if waitDifference > 0 {
            tradeOffs.append(
                "it may require \(waitDifference) more minutes of waiting"
            )
        }

        if option.transfers > currentJourney.transfers {
            let extraTransfers =
                option.transfers - currentJourney.transfers

            tradeOffs.append(
                "it requires \(extraTransfers) additional transfer\(extraTransfers == 1 ? "" : "s")"
            )
        }

        if option.walkingMinutes > currentJourney.walkingMinutes {
            let extraWalking =
                option.walkingMinutes - currentJourney.walkingMinutes

            tradeOffs.append(
                "it requires \(extraWalking) additional minutes of walking"
            )
        }

        if riskScore(option.delayRiskLevel) >
            riskScore(currentJourney.delayRiskLevel) {

            tradeOffs.append(
                "it has higher disruption-related delay risk"
            )
        }

        if tradeOffs.isEmpty {
            return nil
        }

        return "\(joinedReasonText(tradeOffs).capitalizedFirstSentence)."
    }

    private func currentJourneyDecisionText(
        _ option: JourneyOption
    ) -> String {
        if option.isCancelled {
            return "This journey is unavailable because at least one service has been cancelled."
        }

        if option.delayRiskLevel == "High" {
            return "Staying keeps your original travel plan, but the journey is currently exposed to a high disruption-related delay risk."
        }

        if option.delayRiskLevel == "Moderate" {
            return "Staying keeps your original travel plan, but the journey is currently affected by disruption."
        }

        return "Staying keeps your original travel plan and avoids changing to another service."
    }

    private func priorityMatchSummary(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.small) {
            Image(systemName: selectedPriority.icon)
                .foregroundStyle(AppColor.accent)
                .frame(width: AppLayout.iconSize)
                .accessibilityHidden(true)

            Text(
                priorityReason(
                    option: option,
                    currentJourney: currentJourney
                )
            )
            .font(AppTypography.supporting)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.accent.opacity(0.07))
        .clipShape(
            RoundedRectangle(cornerRadius: AppCornerRadius.large)
        )
    }

    private func optionComesBefore(
        _ first: JourneyOption,
        _ second: JourneyOption,
        for priority: DecisionPriority
    ) -> Bool {
        switch priority {
        case .arriveSooner:
            let firstArrival = minutesFromTimeString(first.expectedArrival)
            let secondArrival = minutesFromTimeString(second.expectedArrival)

            if firstArrival != secondArrival {
                return firstArrival < secondArrival
            }

            if riskScore(first.delayRiskLevel) != riskScore(second.delayRiskLevel) {
                return riskScore(first.delayRiskLevel) < riskScore(second.delayRiskLevel)
            }

            if first.transfers != second.transfers {
                return first.transfers < second.transfers
            }

            return first.walkingMinutes < second.walkingMinutes

        case .avoidDisruption:
            let firstRisk = riskScore(first.delayRiskLevel)
            let secondRisk = riskScore(second.delayRiskLevel)

            if firstRisk != secondRisk {
                return firstRisk < secondRisk
            }

            if first.totalDelayMinutes != second.totalDelayMinutes {
                return first.totalDelayMinutes < second.totalDelayMinutes
            }

            return minutesFromTimeString(first.expectedArrival)
                < minutesFromTimeString(second.expectedArrival)

        case .fewerTransfers:
            if first.transfers != second.transfers {
                return first.transfers < second.transfers
            }

            if riskScore(first.delayRiskLevel) != riskScore(second.delayRiskLevel) {
                return riskScore(first.delayRiskLevel) < riskScore(second.delayRiskLevel)
            }

            return minutesFromTimeString(first.expectedArrival)
                < minutesFromTimeString(second.expectedArrival)

        case .lessWalking:
            if first.walkingMinutes != second.walkingMinutes {
                return first.walkingMinutes < second.walkingMinutes
            }

            if riskScore(first.delayRiskLevel) != riskScore(second.delayRiskLevel) {
                return riskScore(first.delayRiskLevel) < riskScore(second.delayRiskLevel)
            }

            return minutesFromTimeString(first.expectedArrival)
                < minutesFromTimeString(second.expectedArrival)
        }
    }

    private func priorityReason(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> String {
        switch selectedPriority {
        case .arriveSooner:
            let difference =
                signedTimeDifference(
                    from: currentJourney.expectedArrival,
                    to: option.expectedArrival
                )

            if journey.isCurrentJourney(option) {
                return "Your current journey already has the earliest expected arrival among the displayed options."
            }

            if difference < 0 {
                return "This option is expected to arrive \(abs(difference)) minutes earlier than your current journey."
            }

            return "This option has the earliest expected arrival among the displayed alternatives."

        case .avoidDisruption:
            if journey.isCurrentJourney(option) {
                return "Your current journey has the lowest disruption-related delay risk among the displayed options."
            }

            return "This option has \(option.delayRiskLevel.lowercased()) disruption-related delay risk, compared with \(currentJourney.delayRiskLevel.lowercased()) risk for your current journey."

        case .fewerTransfers:
            if journey.isCurrentJourney(option) {
                return "Your current journey requires the fewest transfers among the displayed options."
            }

            let difference =
                currentJourney.transfers - option.transfers

            if difference > 0 {
                return "This option requires \(difference) fewer transfer\(difference == 1 ? "" : "s") than your current journey."
            }

            return "This option is among those requiring the fewest transfers."

        case .lessWalking:
            if journey.isCurrentJourney(option) {
                return "Your current journey requires the least walking among the displayed options."
            }

            let difference =
                currentJourney.walkingMinutes - option.walkingMinutes

            if difference > 0 {
                return "This option requires \(difference) fewer minutes of walking than your current journey."
            }

            return "This option is among those requiring the least walking."
        }
    }

    private func arrivalComparisonColour(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> Color {
        let difference = signedTimeDifference(
            from: currentJourney.expectedArrival,
            to: option.expectedArrival
        )

        if difference < 0 { return .green }
        if difference > 0 { return .orange }
        return .primary
    }

    private func waitingComparisonColour(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> Color {
        let difference =
            waitingMinutes(for: option)
            - waitingMinutes(for: currentJourney)

        if difference < 0 { return .green }
        if difference > 0 { return .orange }
        return .primary
    }

    private func transferComparisonColour(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> Color {
        let difference =
            option.transfers - currentJourney.transfers

        if difference < 0 { return .green }
        if difference > 0 { return .orange }
        return .primary
    }

    private func walkingComparisonColour(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> Color {
        let difference =
            option.walkingMinutes - currentJourney.walkingMinutes

        if difference < 0 { return .green }
        if difference > 0 { return .orange }
        return .primary
    }

    private func disruptionComparisonColour(
        option: JourneyOption,
        currentJourney: JourneyOption
    ) -> Color {
        let difference =
            riskScore(option.delayRiskLevel)
            - riskScore(currentJourney.delayRiskLevel)

        if difference < 0 { return .green }
        if difference > 0 { return .red }
        return .primary
    }

    // MARK: - Time Helpers

    private func waitingMinutes(
        for option: JourneyOption
    ) -> Int {
        let referenceMinutes =
            minutesFromDate(journey.selectedTime)

        let departureMinutes =
            minutesFromTimeString(
                option.expectedDeparture
            )

        guard departureMinutes >= 0 else {
            return 0
        }

        return forwardMinuteDifference(
            from: referenceMinutes,
            to: departureMinutes
        )
    }

    private func signedTimeDifference(
        from firstTime: String,
        to secondTime: String
    ) -> Int {
        let first =
            minutesFromTimeString(firstTime)

        let second =
            minutesFromTimeString(secondTime)

        guard first >= 0, second >= 0 else {
            return 0
        }

        var difference =
            second - first

        if difference > 720 {
            difference -= 1440
        } else if difference < -720 {
            difference += 1440
        }

        return difference
    }

    private func minutesFromDate(
        _ date: Date
    ) -> Int {
        let components =
            Calendar.current.dateComponents(
                [.hour, .minute],
                from: date
            )

        return (components.hour ?? 0) * 60
            + (components.minute ?? 0)
    }

    private func minutesFromTimeString(
        _ time: String
    ) -> Int {
        let components =
            time.split(separator: ":")

        guard
            components.count >= 2,
            let hour = Int(components[0]),
            let minute = Int(components[1])
        else {
            return -1
        }

        return hour * 60 + minute
    }

    private func forwardMinuteDifference(
        from start: Int,
        to end: Int
    ) -> Int {
        if end >= start {
            return end - start
        }

        return (1440 - start) + end
    }

    private func riskScore(
        _ level: String
    ) -> Int {
        switch level {
        case "High":
            return 3
        case "Moderate":
            return 2
        default:
            return 1
        }
    }

    private func joinedReasonText(
        _ items: [String]
    ) -> String {
        guard !items.isEmpty else {
            return ""
        }

        if items.count == 1 {
            return items[0]
        }

        if items.count == 2 {
            return "\(items[0]) and \(items[1])"
        }

        return items.dropLast().joined(separator: ", ")
            + ", and "
            + items.last!
    }

    // MARK: - Presentation Helpers

    private func delayRiskIcon(
        for option: JourneyOption
    ) -> String {
        switch option.delayRiskLevel {
        case "High":
            return "exclamationmark.triangle.fill"
        case "Moderate":
            return "clock.badge.exclamationmark"
        default:
            return "checkmark.shield.fill"
        }
    }

    private func delayRiskTitle(
        for option: JourneyOption
    ) -> String {
        if option.isCancelled {
            return "Cancelled"
        }

        switch option.delayRiskLevel {
        case "High":
            return "High delay risk"
        case "Moderate":
            return "Moderate delay risk"
        default:
            return "Low delay risk"
        }
    }

    private func delayRiskColour(
        for option: JourneyOption
    ) -> Color {
        if option.isCancelled {
            return .red
        }

        switch option.delayRiskLevel {
        case "High":
            return .red
        case "Moderate":
            return .orange
        default:
            return .green
        }
    }

    private func serviceStatus(for option: JourneyOption) -> PresentationStatus {
        if option.isCancelled {
            return .cancelled("Unavailable")
        }

        if option.hasDisruption {
            return .delayed(option.delayText)
        }

        return .normal("On time")
    }

    private func serviceStatus(for segment: JourneySegment) -> PresentationStatus {
        if segment.isCancelled {
            return .cancelled()
        }

        if segment.delayMinutes > 0 || segment.disruptionType != "Normal Service" {
            return .delayed(
                segment.delayMinutes > 0
                    ? "\(segment.delayMinutes) min delay"
                    : segment.disruptionType
            )
        }

        return .normal("On time")
    }

    private func departureText(for option: JourneyOption) -> String {
        option.firstSegment?.scheduledDeparture
            ?? option.firstSegment?.expectedDeparture
            ?? option.expectedDeparture
    }

    private func mainTransportIcon(for option: JourneyOption) -> String {
        option.firstSegment?.transportIcon ?? "arrow.triangle.branch"
    }

    private func accessibilityLabel(for option: JourneyOption) -> String {
        let current =
            journey.isCurrentJourney(option)
            ? "Current journey. "
            : ""

        return "\(current)\(option.routeSummary), from \(option.origin) to \(option.destination), expected arrival \(option.expectedArrival), \(option.transferText), \(option.delayText), \(option.delayRiskLevel) delay risk."
    }
}

private extension String {
    var capitalizedFirstSentence: String {
        guard let first else {
            return self
        }

        return first.uppercased() + dropFirst()
    }
}



