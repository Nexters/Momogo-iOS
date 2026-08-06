import SwiftUI

import DesignSystem

struct TodayCardView: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }()

    private var dateText: String {
        Self.dateFormatter.string(from: Date())
    }

    var onTapAddGroup: () -> Void = {}
    var onTapSettings: () -> Void = {}
    var onTapShoot: () -> Void = {}

    /// Figma 스펙: 툴팁은 3초 후 자동으로 사라짐(`DSTooltip` 내부 처리)
    @State private var showsInviteTooltip = true

    var body: some View {
        ZStack(alignment: .topTrailing) {
            illustration

            content
        }
        .frame(height: 358)
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Color.primary500)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                titleRow
                headlineBlock
            }

            Spacer(minLength: 0)
            cameraButton
            Spacer(minLength: 0)
            shootButton
        }
        .padding(16)
    }

    private var titleRow: some View {
        HStack(spacing: 0) {
            DSChip(dateText, tone: .primary, size: .small, showsLeadingIcon: false, showsTrailingIcon: false)

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                headerIconButton(DesignSystemAsset.plus, accessibilityLabel: "그룹 추가", action: onTapAddGroup)
                    .momogoTooltip(isPresented: $showsInviteTooltip, text: "초대코드를 받았나요?", arrowDirection: .down)
                headerIconButton(DesignSystemAsset.settings, accessibilityLabel: "설정", action: onTapSettings)
            }
        }
    }

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Figma 스펙은 34px "BM DoHyeon OTF"지만 DesignSystem에 해당 폰트가 없어 가장 가까운 heading26으로 근사한다.
            Text("오늘 모모고?")
                .momogoTypography(.heading26)
                .foregroundStyle(DesignSystem.Color.gray950)

            Text("오늘의 점심 메뉴를 찍어볼까요?")
                .momogoTypography(.smMedium)
                .foregroundStyle(DesignSystem.Color.gray700)
        }
    }

    private func headerIconButton(
        _ asset: DesignSystemImages,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(asset: asset)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(DesignSystem.Color.white)
                .padding(12)
                .background(DesignSystem.Color.gray800, in: Circle())
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var cameraButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
                .fill(DesignSystem.Color.gray900)
                .stroke(Color.white.opacity(0.04), lineWidth: 1.83)

            Image(asset: DesignSystemAsset.camera)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(DesignSystem.Color.gray400)
        }
        .frame(width: 75, height: 75)
        .rotationEffect(.degrees(-2))
        .momogoShadow()
        .accessibilityHidden(true)
    }

    private var shootButton: some View {
        Button(action: onTapShoot) {
            HStack(spacing: 6) {
                Text("오늘의 점심 촬영하러 가기")
                    .momogoTypography(.lgSemistrong)

                Image(asset: DesignSystemAsset.arrowRight)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 12)
            }
            .foregroundStyle(DesignSystem.Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 32)
        }
        .background(.ultraThinMaterial, in: Capsule())
        .background(Color.black.opacity(0.5), in: Capsule())
    }

    private var illustration: some View {
        ZStack(alignment: .topTrailing) {
            Image(asset: DesignSystemAsset.illustHomeBanner)
                .resizable()
                .scaledToFit()
                .frame(width: 230)
                .offset(x: 55, y: 8)

            Image(asset: DesignSystemAsset.sparkleStarLarge)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .offset(x: -20, y: 170)

            Image(asset: DesignSystemAsset.sparkleStarSmall)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .offset(x: 90, y: 130)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))
    }
}
