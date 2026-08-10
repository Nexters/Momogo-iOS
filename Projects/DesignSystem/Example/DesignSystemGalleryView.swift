import SwiftUI

import DesignSystem

enum DesignSystemCategory: String, CaseIterable, Identifiable {
    case color
    case typography
    case icons
    case radius
    case shadow
    case button
    case chip
    case control
    case input
    case modal
    case alert
    case bottomSheet
    case navigation
    case menu

    var id: String { rawValue }

    var title: String {
        switch self {
        case .color: "Color"
        case .typography: "Typography"
        case .icons: "Icons"
        case .radius: "Radius"
        case .shadow: "Shadow"
        case .button: "Button"
        case .chip: "Chip"
        case .control: "Control"
        case .input: "Input"
        case .modal: "Modal"
        case .alert: "Alert"
        case .bottomSheet: "Bottom Sheet"
        case .navigation: "Navigation"
        case .menu: "Menu"
        }
    }
}

struct DesignSystemGalleryView: View {
    var body: some View {
        NavigationStack {
            List(DesignSystemCategory.allCases) { category in
                NavigationLink(category.title, value: category)
            }
            .navigationTitle("Design System")
            .navigationDestination(for: DesignSystemCategory.self) { category in
                DesignSystemDetailView(category: category)
            }
        }
    }
}

struct DesignSystemDetailView: View {
    let category: DesignSystemCategory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.GridIOS.margin) {
                content
            }
            .padding(DesignSystem.GridIOS.margin)
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch category {
        case .color: colorSection
        case .typography: typographySection
        case .icons: iconSection
        case .radius: radiusSection
        case .shadow: shadowSection
        case .button: buttonSection
        case .chip: chipSection
        case .control: controlSection
        case .input: inputSection
        case .modal: modalSection
        case .alert: alertSection
        case .bottomSheet: bottomSheetSection
        case .navigation: navigationSection
        case .menu: menuSection
        }
    }
}

extension DesignSystemDetailView {
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            swatchRow(DesignSystem.Color.black, DesignSystem.Color.white)
            swatchRow(
                DesignSystem.Color.gray900,
                DesignSystem.Color.gray700,
                DesignSystem.Color.gray500,
                DesignSystem.Color.gray300,
                DesignSystem.Color.gray100
            )
            swatchRow(
                DesignSystem.Color.primary700,
                DesignSystem.Color.primary500,
                DesignSystem.Color.primary300,
                DesignSystem.Color.primary100
            )
            swatchRow(
                DesignSystem.Color.secondary700,
                DesignSystem.Color.secondary500,
                DesignSystem.Color.secondary300,
                DesignSystem.Color.secondary100
            )
            swatchRow(
                DesignSystem.Color.systemGreen700,
                DesignSystem.Color.systemGreen500,
                DesignSystem.Color.systemGreen300
            )
            swatchRow(
                DesignSystem.Color.systemRed700,
                DesignSystem.Color.systemRed500,
                DesignSystem.Color.systemRed300
            )
            swatchRow(
                DesignSystem.Color.systemBlue700,
                DesignSystem.Color.systemBlue500,
                DesignSystem.Color.systemBlue300
            )
        }
    }

    private func swatchRow(_ colors: Color...) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
                    .fill(color)
                    .frame(width: 40, height: 40)
            }
        }
    }

    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heading 32").momogoTypography(.heading32)
            Text("MD Semistrong 16").momogoTypography(.mdSemistrong)
            Text("XS Medium 12").momogoTypography(.xsMedium)
        }
    }

    private var iconSection: some View {
        let icons: [(DesignSystemImages, String)] = [
            (DesignSystemAsset.chevronLeft, "chevronLeft"),
            (DesignSystemAsset.chevronRight, "chevronRight"),
            (DesignSystemAsset.x, "x"),
            (DesignSystemAsset.share2, "share2"),
            (DesignSystemAsset.settings, "settings"),
            (DesignSystemAsset.ellipsisVertical, "ellipsisVertical")
        ]
        let columns = [GridItem(.adaptive(minimum: 64), spacing: 16)]
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(icons, id: \.1) { asset, name in
                VStack(spacing: 6) {
                    asset.swiftUIImage
                        .foregroundStyle(DesignSystem.Color.white)
                        .frame(width: 24, height: 24)
                    Text(name)
                        .momogoTypography(.xsMedium)
                        .foregroundStyle(DesignSystem.Color.gray400)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
    }

    private var radiusSection: some View {
        let radii = [DesignSystem.Radius.r12, DesignSystem.Radius.r16, DesignSystem.Radius.r20, DesignSystem.Radius.r24]
        return HStack(spacing: 12) {
            ForEach(radii, id: \.self) { radius in
                RoundedRectangle(cornerRadius: radius)
                    .fill(DesignSystem.Color.gray200)
                    .frame(width: 60, height: 60)
            }
        }
    }

    private var shadowSection: some View {
        RoundedRectangle(cornerRadius: DesignSystem.Radius.r16)
            .fill(DesignSystem.Color.white)
            .frame(width: 120, height: 80)
            .momogoShadow()
    }

    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button("Solid") {}.buttonStyle(.momogoButton(kind: .solid, tone: .primary))
                    Button("Outlined") {}.buttonStyle(.momogoButton(kind: .outlined, tone: .primary))
                    Button("Text") {}.buttonStyle(.momogoButton(kind: .text, tone: .primary))
                }
            }
            Button("Disabled") {}.buttonStyle(.momogoButton()).disabled(true)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button("Button") {}.buttonStyle(.momogoButton(showsLeadingIcon: true))
                    Button("Button") {}.buttonStyle(.momogoButton(showsTrailingIcon: true))
                    Button("Button") {}.buttonStyle(.momogoButton(showsLeadingIcon: true, showsTrailingIcon: true))
                }
            }

            HStack(spacing: 8) {
                Button("Button") {}.buttonStyle(.momogoButton(size: .large))
                Button("Button") {}.buttonStyle(.momogoButton(size: .small))
            }

            Button("Full Width") {}.buttonStyle(.momogoButton(showsLeadingIcon: true, isFullWidth: true))
        }
    }

    private var chipSection: some View {
        ChipGroupPreview()
    }

    private var controlSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            RadioGroupPreview(title: "Active", isSelected: true)
            RadioGroupPreview(title: "Inactive", isSelected: false)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            InputGroupPreview(title: "Input/Normal", showsCount: false)
            InputGroupPreview(title: "Input/Count", showsCount: true)
        }
    }

    private var modalSection: some View {
        VStack {
            DSModal(
                title: "Title",
                description: "Description",
                primaryTitle: "Button",
                primaryAction: {},
                secondaryTitle: "Button",
                secondaryAction: {},
                onClose: {}
            )
            DSModal(
                title: "Title",
                description: "Description",
                primaryTitle: "Button",
                primaryAction: {},
                onClose: {}
            )
            DSModal(
                title: "Multiline Title",
                description: "First line of description.\nSecond line of description.",
                primaryTitle: "Button",
                primaryAction: {}
            )
        }
    }

    private var menuSection: some View {
        DSMenu([
            DSMenu.Item("그룹 생성", icon: DesignSystemAsset.usersThree, action: {}),
            DSMenu.Item("그룹 참여", icon: DesignSystemAsset.login, action: {})
        ])
    }

    private var alertSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                DSToast("Notice", tone: .notice)
                DSToast("Error", tone: .error)
                DSToast("Success", tone: .success)
            }
            VStack(alignment: .leading, spacing: 8) {
                DSTopToast("Notice", tone: .notice)
                DSTopToast("Error", tone: .error)
                DSTopToast("Success", tone: .success)
            }
            DSTooltip("Tooltip", arrowDirection: .down)
        }
    }

    private var bottomSheetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DSBottomSheet(title: "Title", headerAlignment: .center, onClose: {}, content: {
                VStack(spacing: 0) {
                    DSBottomSheetAtom("Atom", state: .activate)
                    DSBottomSheetAtom("Atom", state: .deactivate)
                }
                Button("Button") {}
                    .buttonStyle(.momogoButton(kind: .solid, tone: .primary, isFullWidth: true))
            })
            DSBottomSheet(title: "Title", headerAlignment: .left, onClose: {}, content: {
                EmptyView()
            })
            DSBottomSheet(title: "Title", onClose: {}, isLoading: true, content: {
                EmptyView()
            })
        }
    }

    private var navigationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nav/Top (title 없음)").momogoTypography(.smMedium)
            VStack(spacing: 8) {
                DSTopNavigationBar(leading: { DSBackButton(action: {}) })
                DSTopNavigationBar(
                    leading: { DSBackButton(action: {}) },
                    trailing: { DSIconButton(.settings, action: {}) }
                )
                DSTopNavigationBar(
                    leading: { DSBackButton(action: {}) },
                    trailing: {
                        saveButton
                    }
                )
            }
            .background(DesignSystem.Color.gray800)

            Text("Nav/Top/Text-Center").momogoTypography(.smMedium)
            VStack(spacing: 8) {
                DSTopNavigationBar(title: "Page Title", leading: { DSBackButton(action: {}) })
                DSTopNavigationBar(
                    title: "Page Title",
                    leading: { DSBackButton(action: {}) },
                    trailing: {
                        HStack(spacing: 8) {
                            DSIconButton(.share, action: {})
                            DSIconButton(.settings, action: {})
                        }
                    }
                )
                DSTopNavigationBar(
                    title: "Page Title",
                    leading: { DSBackButton(action: {}) },
                    trailing: {
                        saveButton
                    }
                )
            }
            .background(DesignSystem.Color.gray800)

            Text("Nav/Top/Text-Left").momogoTypography(.smMedium)
            VStack(spacing: 8) {
                DSTopNavigationBar(
                    title: "Page Title",
                    alignment: .leading,
                    leading: { DSBackButton(action: {}) }
                )
                DSTopNavigationBar(
                    title: "Page Title",
                    alignment: .leading,
                    leading: { DSBackButton(action: {}) },
                    trailing: { DSIconButton(.more, action: {}) }
                )
                DSTopNavigationBar(
                    title: "Page Title",
                    alignment: .leading,
                    leading: { DSBackButton(action: {}) },
                    trailing: {
                        saveButton
                    }
                )
            }
            .background(DesignSystem.Color.gray800)

            Text("Nav/Top/Logo (로고 확정 시 교체 예정)").momogoTypography(.smMedium)
            DSTopNavigationBar(leading: { DSNavigationLogo() })
                .background(DesignSystem.Color.gray800)
        }
    }

    private var saveButton: some View {
        Button {} label: {
            Text("저장하기")
                .momogoTypography(.mdSemistrong)
                .foregroundStyle(DesignSystem.Color.gray50)
        }
    }
}

private struct ChipGroupPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Default").momogoTypography(.xsMedium).foregroundStyle(DesignSystem.Color.gray400)
            row(size: .default)
            Text("Small").momogoTypography(.xsMedium).foregroundStyle(DesignSystem.Color.gray400)
            row(size: .small)
        }
    }

    private func row(size: DSChip.Size) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                DSChip("Chip", tone: .gray, size: size)
                DSChip("Chip", tone: .primary, size: size)
                DSChip("Chip", tone: .secondary, size: size)
                DSChip("Chip", tone: .green, size: size)
                DSChip("Chip", tone: .blue, size: size)
                DSChip("Chip", tone: .red, size: size)
            }
        }
    }
}

private struct RadioGroupPreview: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).momogoTypography(.smSemistrong)
            HStack(alignment: .top, spacing: 24) {
                column(title: "Default", isDisabled: false)
                column(title: "Disabled", isDisabled: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Color.gray800)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
        }
    }

    private func column(title: String, isDisabled: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .momogoTypography(.xsMedium)
                .foregroundStyle(DesignSystem.Color.gray400)
            DSRadioButton("Radio button", isSelected: .constant(isSelected))
                .disabled(isDisabled)
        }
    }
}

private struct InputGroupPreview: View {
    let title: String
    let showsCount: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).momogoTypography(.smSemistrong)
            row(label: "Default", text: "", state: .normal)
            row(label: "Focus", text: "Placeholder", state: .focused)
            row(label: "Filled", text: "Placeholder", state: .filled)
            row(label: "Disabled", text: "", state: .normal, isDisabled: true)
            row(label: "Error", text: "Placeholder", state: .error)
        }
    }

    private func row(
        label: String,
        text: String,
        state: DSTextField.State,
        isDisabled: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .momogoTypography(.xsMedium)
                .foregroundStyle(DesignSystem.Color.gray400)
            DSTextField(
                "Placeholder",
                text: .constant(text),
                comment: "Comment",
                characterLimit: showsCount ? 20 : nil,
                state: state
            )
            .disabled(isDisabled)
        }
    }
}

#Preview {
    DesignSystemGalleryView()
}
