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
        Self.dateFormatter.string(from: .now)
    }

    var hasGroups: Bool = true
    var recentPhotoURL: URL?
    var onTapAddGroup: () -> Void = {}
    var onTapSettings: () -> Void = {}
    var onTapShoot: () -> Void = {}
    var onTapCreateGroup: () -> Void = {}

    private let cameraSize: CGFloat = 75
    /// Figma 스펙: 카드 leading 기준 30px. `headlineBlock`은 `content`의 16px 패딩 안쪽에서 시작하므로
    /// 그 차이(30-16)만큼만 추가로 민다.
    private let cameraLeadingOffset: CGFloat = 14
    /// Figma 스펙: 라벨(헤드라인+서브텍스트) 하단에서 25px. hasGroups에 따라 헤드라인이 1줄/2줄로
    /// 바뀌어 라벨의 실제 높이가 달라지므로, 카드 기준 절대 y좌표 대신 라벨의 실제 렌더링된 하단을
    /// 기준으로 계산해야 헤드라인이 길어져도 라벨을 침범하지 않는다.
    private let cameraTopGap: CGFloat = 25

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 배경(색상+일러스트)에만 라운드 클립을 적용한다.
            ZStack(alignment: .topLeading) {
                DesignSystem.Color.primary500
                illustration
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r16))

            content
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
                DSIconButton(.plus, style: .filled, action: onTapAddGroup)
                    .dsMenuAnchor()
                DSIconButton(.settings, style: .filled, action: onTapSettings)
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
            if hasGroups {
                Text("오늘 모모고?")
                    .momogoTypography(.heading32)
                    .foregroundStyle(DesignSystem.Color.gray950)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    Text("모모고?")
                    Text("가치모고!")
                }
                .momogoTypography(.heading32)
                .foregroundStyle(DesignSystem.Color.gray950)
            }

            Text(hasGroups ? "오늘의 점심 메뉴를 찍어볼까요?" : "점심 사진으로 연결되는 사이")
                .momogoTypography(.smMedium)
                .foregroundStyle(DesignSystem.Color.gray700)
        }
        // `.overlay(alignment: .bottomLeading)`는 카메라의 bottomLeading 모서리를 라벨의 bottomLeading
        // 모서리에 맞춘다(= 라벨 위에 겹쳐 위로 확장). 카메라 자신의 높이만큼 아래로 밀어 "겹침"을
        // "라벨 바로 아래 flush"로 바꾼 뒤, 거기서 gap만큼 더 내린다.
        .overlay(alignment: .bottomLeading) {
            if hasGroups {
                cameraButton
                    .offset(x: cameraLeadingOffset, y: cameraSize + cameraTopGap)
            }
        }
    }

    private var cameraButton: some View {
        Button(action: onTapShoot) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.Radius.r12)
                    .fill(DesignSystem.Color.gray900)
                    .stroke(Color.white.opacity(0.04), lineWidth: 1.83)

                if let recentPhotoURL {
                    AsyncImage(url: recentPhotoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        EmptyView()
                    }
                    .frame(width: cameraSize, height: cameraSize)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
                } else {
                    Image(asset: DesignSystemAsset.camera)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(DesignSystem.Color.gray400)
                }
            }
            .frame(width: cameraSize, height: cameraSize)
        }
        .buttonStyle(.plain)
        .rotationEffect(.degrees(-2))
        .momogoShadow()
        .accessibilityLabel("사진 촬영하기")
    }

    private var shootButton: some View {
        Button(action: hasGroups ? onTapShoot : onTapCreateGroup) {
            HStack(spacing: 6) {
                Text(hasGroups ? "오늘의 점심 촬영하러 가기" : "새 그룹 만들러 가기")
                    .momogoTypography(.lgSemistrong)

                if hasGroups {
                    Image(asset: DesignSystemAsset.arrowRight)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 12)
                }
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
