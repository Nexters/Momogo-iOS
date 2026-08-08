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
        ZStack(alignment: .topLeading) {
            // 배경(색상+일러스트)에만 라운드 클립을 적용한다. 카드 전체를 클립하면 카드 경계 밖으로
            // 확장되는 초대 툴팁까지 함께 잘려나간다.
            ZStack(alignment: .topLeading) {
                DesignSystem.Color.primary500
                illustration
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))

            content

            // Figma 갱신 스펙: 카메라 버튼이 더 이상 콘텐츠 흐름에 끼워진 요소가 아니라, 카드 기준
            // 절대좌표(30, 167)에 고정된 오버레이다.
            cameraButton
                .offset(x: 30, y: 167)

            if showsInviteTooltip {
                DSTooltip("초대코드를 받았나요?", arrowDirection: .up)
                    .offset(x: 170, y: 70)
                    .transition(.opacity)
                    .task {
                        try? await Task.sleep(for: .seconds(3))
                        showsInviteTooltip = false
                    }
            }
        }
        .frame(height: 358)
        .frame(maxWidth: .infinity)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                titleRow
                headlineBlock
            }

            Spacer(minLength: 0)
            shootButton
        }
        .padding(16)
    }

    private var titleRow: some View {
        HStack(spacing: 0) {
            dateChip

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                headerIconButton(DesignSystemAsset.plus, accessibilityLabel: "그룹 추가", action: onTapAddGroup)
                headerIconButton(DesignSystemAsset.settings, accessibilityLabel: "설정", action: onTapSettings)
            }
        }
    }

    // Figma 스펙(가로 10px/세로 8px 패딩, 14px SemiBold)이 `DSChip`의 기존 사이즈 프리셋(.default, .small)
    // 어느 쪽과도 정확히 맞지 않아, 이 칩만 커스텀으로 그린다.
    private var dateChip: some View {
        Text(dateText)
            .momogoTypography(.smSemistrong)
            .foregroundStyle(DesignSystem.Color.gray800)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(DesignSystem.Color.primary300, in: RoundedRectangle(cornerRadius: DesignSystem.Radius.r10))
    }

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Figma 스펙은 34px "BM DoHyeon OTF"지만 DesignSystem에 해당 폰트가 없어(폰트 리소스 추가는
            // 스코프 밖) 가장 가까운 크기인 heading32(32pt)로 근사한다.
            Text("오늘 모모고?")
                .momogoTypography(.heading32)
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
        // Figma 스펙: backdrop-blur(4px) + 검정 50% 불투명도. SwiftUI엔 배경 레이어를 실시간으로
        // 블러하는 API가 마땅치 않아 블러는 재현하지 않고, 불투명도만 스펙대로 맞춘다.
        // (`ultraThinMaterial`을 겹치면 밝은 톤이 섞여 스펙보다 더 옅어 보이므로 쓰지 않는다.)
        .background(Color.black.opacity(0.5), in: Capsule())
    }

    private var illustration: some View {
        ZStack(alignment: .topLeading) {
            // Figma 갱신 스펙에 추가된 큰 햇살 모양 장식(카메라 버튼 뒤쪽에 은은하게 깔림).
            Image(asset: DesignSystemAsset.sparkleSun)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .offset(x: 78, y: 240)

            Image(asset: DesignSystemAsset.sparkleStarLarge)
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)
                .offset(x: 18, y: 230)

            Image(asset: DesignSystemAsset.sparkleStarSmall)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .offset(x: 106, y: 186)

            // 갱신된 원본 SVG 실측 비율(235.3 x 326.5)을 그대로 사용하고, 카드 우/하단 경계에서
            // 자연스럽게 잘리도록 배치한다(Figma도 카드 밖으로 넘치는 부분은 클립되어 보이지 않음).
            Image(asset: DesignSystemAsset.illustHomeBanner)
                .resizable()
                .scaledToFit()
                .frame(width: 235)
                .offset(x: 115, y: 112)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
