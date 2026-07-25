import SwiftUI

import SharedDesignSystem

struct DesignSystemGalleryView: View {
    @State private var normalText = ""
    @State private var focusedText = "Placeholder"
    @State private var errorText = "Placeholder"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.GridIOS.margin) {
                colorSection
                typographySection
                iconSection
                radiusSection
                shadowSection
                componentSection
                inputSection
                modalSection
                alertSection
                bottomSheetSection
                navigationSection
            }
            .padding(DesignSystem.GridIOS.margin)
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Color").momogoTypography(.heading24)
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
            Text("Typography").momogoTypography(.heading24)
            Text("Heading 32").momogoTypography(.heading32)
            Text("MD Semistrong 16").momogoTypography(.mdSemistrong)
            Text("XS Medium 12").momogoTypography(.xsMedium)
        }
    }

    private var iconSection: some View {
        let icons: [(SharedDesignSystemImages, String)] = [
            (SharedDesignSystemAsset.chevronLeft, "chevronLeft"),
            (SharedDesignSystemAsset.chevronRight, "chevronRight"),
            (SharedDesignSystemAsset.x, "x"),
            (SharedDesignSystemAsset.share2, "share2"),
            (SharedDesignSystemAsset.settings, "settings"),
            (SharedDesignSystemAsset.ellipsisVertical, "ellipsisVertical")
        ]
        let columns = [GridItem(.adaptive(minimum: 64), spacing: 16)]
        return VStack(alignment: .leading, spacing: 8) {
            Text("Icons").momogoTypography(.heading24)
            LazyVGrid(columns: columns, spacing: 16) {
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
    }

    private var radiusSection: some View {
        let radii = [DesignSystem.Radius.r12, DesignSystem.Radius.r16, DesignSystem.Radius.r20, DesignSystem.Radius.r24]
        return VStack(alignment: .leading, spacing: 8) {
            Text("Radius").momogoTypography(.heading24)
            HStack(spacing: 12) {
                ForEach(radii, id: \.self) { radius in
                    RoundedRectangle(cornerRadius: radius)
                        .fill(DesignSystem.Color.gray200)
                        .frame(width: 60, height: 60)
                }
            }
        }
    }

    private var shadowSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shadow").momogoTypography(.heading24)
            RoundedRectangle(cornerRadius: DesignSystem.Radius.r16)
                .fill(DesignSystem.Color.white)
                .frame(width: 120, height: 80)
                .momogoShadow()
        }
    }

    private var componentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Components").momogoTypography(.heading24)

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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    DSChip("Gray", tone: .gray)
                    DSChip("Primary", tone: .primary)
                    DSChip("Secondary", tone: .secondary)
                    DSChip("Green", tone: .green)
                    DSChip("Blue", tone: .blue)
                    DSChip("Red", tone: .red)
                }
            }

            DSRadioButton("Selected", isSelected: .constant(true))
            DSRadioButton("Unselected", isSelected: .constant(false))
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Input").momogoTypography(.heading24)
            DSTextField("Placeholder", text: $normalText, comment: "Comment")
            DSTextField("Placeholder", text: $focusedText, characterLimit: 20, state: .focused)
            DSTextField("Placeholder", text: $errorText, comment: "Comment", state: .error)
            DSTextField("Placeholder", text: .constant(""), comment: "Comment")
                .disabled(true)
        }
    }

    private var modalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Modal").momogoTypography(.heading24)
            DSModal(
                title: "Title",
                description: "Description",
                primaryTitle: "Button",
                primaryAction: {},
                secondaryTitle: "Button",
                secondaryAction: {},
                onClose: {}
            )
        }
    }

    private var alertSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Alert").momogoTypography(.heading24)
            VStack(alignment: .leading, spacing: 8) {
                DSToast("Notice", tone: .notice)
                DSToast("Error", tone: .error)
                DSToast("Success", tone: .success)
            }
            DSTooltip("Tooltip", arrowDirection: .down)
        }
    }

    private var bottomSheetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bottom Sheet").momogoTypography(.heading24)
            DSBottomSheet(title: "Title", headerAlignment: .center, onClose: {}, content: {
                VStack(spacing: 0) {
                    DSBottomSheetAtom("Atom", state: .activate)
                    DSBottomSheetAtom("Atom", state: .deactivate)
                }
                Button("Button") {}.buttonStyle(.momogoButton(kind: .solid, tone: .primary))
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
            Text("Navigation").momogoTypography(.heading24)

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
                        Button("저장하기") {}.buttonStyle(.momogoButton(kind: .text, tone: .gray, size: .large))
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
                        Button("저장하기") {}.buttonStyle(.momogoButton(kind: .text, tone: .gray, size: .large))
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
                        Button("저장하기") {}.buttonStyle(.momogoButton(kind: .text, tone: .gray, size: .large))
                    }
                )
            }
            .background(DesignSystem.Color.gray800)

            Text("Nav/Top/Logo (로고 확정 시 교체 예정)").momogoTypography(.smMedium)
            DSTopNavigationBar(leading: { DSNavigationLogo() })
                .background(DesignSystem.Color.gray800)
        }
    }
}

#Preview {
    DesignSystemGalleryView()
}
