//
//  UIFoundation.swift
//  transport-disruption-app
//

import SwiftUI
import UIKit

enum AppSpacing {
    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
    static let section: CGFloat = 28
}

enum AppCornerRadius {
    static let small: CGFloat = 14
    static let medium: CGFloat = 18
    static let large: CGFloat = 22
}

enum AppLayout {
    static let pageMaxWidth: CGFloat = 720
    static let minimumTouchTarget: CGFloat = 44
    static let iconSize: CGFloat = 44
}

enum AppTypography {
    static let pageTitle: Font = .system(.largeTitle, design: .rounded, weight: .bold)
    static let sectionTitle: Font = .system(.title2, design: .rounded, weight: .bold)
    static let cardTitle: Font = .system(.headline, design: .rounded, weight: .semibold)
    static let supporting: Font = .system(.subheadline, design: .rounded)
    static let metadata: Font = .system(.caption, design: .rounded, weight: .medium)
}

enum AppColor {
    static let pageBackground = adaptive(light: 0xF6F5FA, dark: 0x171719)
    static let ink = adaptive(light: 0x212121, dark: 0xF6F5FA)
    static let controlForeground = adaptive(light: 0xFFFFFF, dark: 0x171719)
    static let aliceBlue = adaptive(light: 0xD8DFE9, dark: 0x2B3440)
    static let honeydew = adaptive(light: 0xCFDECA, dark: 0x30412F)
    static let vanilla = adaptive(light: 0xEFF0A3, dark: 0x4B4C23)
    static let surface = adaptive(light: 0xFFFFFF, dark: 0x232326)
    static let elevatedSurface = adaptive(light: 0xECEBF0, dark: 0x2C2C30)
    static let separator = adaptive(light: 0xD4D3D8, dark: 0x45454B)
    static let information = adaptive(light: 0x3E5F82, dark: 0xAFC8E5)
    static let success = adaptive(light: 0x3F6542, dark: 0xABD0A7)
    static let warning = adaptive(light: 0x9A571F, dark: 0xE6A46B)
    static let critical = adaptive(light: 0xA44242, dark: 0xE58B8B)
    static let accent = ink

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            AppColor.uiColor(traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    private static func uiColor(_ rgb: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

enum PresentationStatus: Equatable {
    case normal(String = "Normal service")
    case delayed(String)
    case majorDisruption(String = "Major disruption")
    case cancelled(String = "Cancelled")
    case information(String)
    case success(String)

    var label: String {
        switch self {
        case .normal(let label), .delayed(let label), .majorDisruption(let label),
             .cancelled(let label), .information(let label), .success(let label):
            return label
        }
    }

    var systemImage: String {
        switch self {
        case .normal, .success: return "checkmark.circle.fill"
        case .delayed: return "clock.badge.exclamationmark"
        case .majorDisruption: return "exclamationmark.triangle.fill"
        case .cancelled: return "xmark.octagon.fill"
        case .information: return "info.circle.fill"
        }
    }

    var foregroundStyle: Color {
        switch self {
        case .normal, .success: return AppColor.success
        case .delayed: return AppColor.warning
        case .majorDisruption, .cancelled: return AppColor.critical
        case .information: return AppColor.information
        }
    }

    var backgroundStyle: Color {
        switch self {
        case .normal, .success: return AppColor.honeydew
        case .delayed: return AppColor.warning.opacity(0.14)
        case .majorDisruption, .cancelled: return AppColor.critical.opacity(0.13)
        case .information: return AppColor.aliceBlue
        }
    }
}

enum JourneyEmphasis: String, CaseIterable, Hashable {
    case recommended
    case selected
    case currentJourney

    var label: String {
        switch self {
        case .recommended: return "Recommended"
        case .selected: return "Selected"
        case .currentJourney: return "Current journey"
        }
    }

    var systemImage: String {
        switch self {
        case .recommended: return "star.fill"
        case .selected: return "checkmark.circle.fill"
        case .currentJourney: return "location.fill"
        }
    }

    var backgroundStyle: Color {
        switch self {
        case .recommended, .selected: return AppColor.vanilla
        case .currentJourney: return AppColor.aliceBlue
        }
    }
}

enum AppSurfaceTone {
    case standard
    case information
    case positive
    case emphasized

    var color: Color {
        switch self {
        case .standard: return AppColor.surface
        case .information: return AppColor.aliceBlue
        case .positive: return AppColor.honeydew
        case .emphasized: return AppColor.vanilla
        }
    }
}

struct AppCardModifier: ViewModifier {
    let background: Color
    let showsBorder: Bool
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        content
            .padding(AppSpacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: shape)
            .overlay {
                if showsBorder { shape.stroke(AppColor.separator.opacity(0.75), lineWidth: 1) }
            }
    }
}

struct AppPageWidthModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: AppLayout.pageMaxWidth, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, AppSpacing.large)
    }
}

extension View {
    func appCard(
        tone: AppSurfaceTone = .standard,
        showsBorder: Bool = true,
        cornerRadius: CGFloat = AppCornerRadius.large
    ) -> some View {
        modifier(AppCardModifier(background: tone.color, showsBorder: showsBorder, cornerRadius: cornerRadius))
    }

    func appCard(
        background: Color,
        showsBorder: Bool = true,
        cornerRadius: CGFloat = AppCornerRadius.large
    ) -> some View {
        modifier(AppCardModifier(background: background, showsBorder: showsBorder, cornerRadius: cornerRadius))
    }

    func appPageWidth() -> some View { modifier(AppPageWidthModifier()) }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.cardTitle)
            .foregroundStyle(AppColor.controlForeground)
            .frame(maxWidth: .infinity, minHeight: AppLayout.minimumTouchTarget)
            .padding(.horizontal, AppSpacing.large)
            .background(AppColor.ink)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .opacity(!isEnabled ? 0.45 : configuration.isPressed ? 0.78 : 1)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.cardTitle)
            .foregroundStyle(AppColor.ink)
            .frame(maxWidth: .infinity, minHeight: AppLayout.minimumTouchTarget)
            .padding(.horizontal, AppSpacing.large)
            .background(AppColor.surface)
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                    .stroke(AppColor.ink, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous))
            .opacity(!isEnabled ? 0.45 : configuration.isPressed ? 0.72 : 1)
    }
}

struct IconActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(AppColor.controlForeground)
            .frame(width: AppLayout.minimumTouchTarget, height: AppLayout.minimumTouchTarget)
            .background(AppColor.ink, in: Circle())
            .opacity(!isEnabled ? 0.45 : configuration.isPressed ? 0.76 : 1)
    }
}

#Preview("UI Foundation") {
    VStack(alignment: .leading, spacing: AppSpacing.large) {
        Text("Shared UI Foundation").font(AppTypography.pageTitle)
        Text("Rounded system typography and adaptive Bento surfaces.")
            .font(AppTypography.supporting).appCard(tone: .information)
        Button("Primary action") {}.buttonStyle(PrimaryActionButtonStyle())
        Button("Secondary action") {}.buttonStyle(SecondaryActionButtonStyle())
        Button("Open details", systemImage: "arrow.up.right") {}
            .labelStyle(.iconOnly).buttonStyle(IconActionButtonStyle())
    }
    .appPageWidth().padding(.vertical).background(AppColor.pageBackground)
}
