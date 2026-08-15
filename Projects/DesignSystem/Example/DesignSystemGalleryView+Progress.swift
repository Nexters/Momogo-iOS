import SwiftUI

import DesignSystem

extension DesignSystemDetailView {
    // DesignSystemGalleryView.swift의 content switch에서 참조하므로 private을 붙이지 않는다.
    var progressSection: some View {
        ProgressGroupPreview()
    }
}

private struct ProgressGroupPreview: View {
    @State private var isOverlayPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            backgroundContrastRow
            sizeVariantRow
            overlayTrigger
        }
    }

    // 로띠 원본에 다크(#1D1C1C) 레이어가 섞여 있어, gray900 배경에서 묻히는지 눈으로 비교하기 위한 섹션.
    private var backgroundContrastRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Background").momogoTypography(.xsMedium).foregroundStyle(DesignSystem.Color.gray400)
            HStack(spacing: 12) {
                swatch(background: DesignSystem.Color.gray900, label: "gray900")
                swatch(background: DesignSystem.Color.gray50, label: "gray50")
                swatch(background: .white, label: "white")
            }
        }
    }

    private func swatch(background: Color, label: String) -> some View {
        VStack(spacing: 6) {
            DSProgressView()
                .frame(width: 60, height: 60)
                .padding(16)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
            Text(label).momogoTypography(.xsMedium).foregroundStyle(DesignSystem.Color.gray400)
        }
    }

    private var sizeVariantRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Size").momogoTypography(.xsMedium).foregroundStyle(DesignSystem.Color.gray400)
            HStack(alignment: .bottom, spacing: 16) {
                DSProgressView(size: 40)
                DSProgressView(size: 60)
                DSProgressView(size: 80)
            }
        }
    }

    // 토글 버튼은 오버레이 범위 밖에 둬서, 오버레이가 떠 있는 동안에도 다시 눌러 끌 수 있게 한다.
    // (오버레이 자체가 딤 배경으로 터치를 막는 동작은 데모 박스 안에서 확인한다.)
    private var overlayTrigger: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overlay").momogoTypography(.xsMedium).foregroundStyle(DesignSystem.Color.gray400)
            Color.clear
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(DesignSystem.Color.gray800)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
                .momogoLoadingOverlay(isPresented: isOverlayPresented)
            Button("토글") { isOverlayPresented.toggle() }
                .buttonStyle(.momogoButton(kind: .solid, tone: .primary, isFullWidth: true))
        }
    }
}
