import SwiftUI

import SharedDesignSystem

struct DesignSystemGalleryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.GridIOS.margin) {
                colorSection
                typographySection
                radiusSection
                shadowSection
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
}

#Preview {
    DesignSystemGalleryView()
}
