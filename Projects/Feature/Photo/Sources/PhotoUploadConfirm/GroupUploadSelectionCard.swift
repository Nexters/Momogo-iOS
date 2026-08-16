import SwiftUI

import DesignSystem

/// 업로드 대상 그룹 1개를 표시하는 체크 카드. Feature/Group의 SelectionCard와 동일한 톤이지만
/// 아이콘 대신 그룹명/멤버 목록을 보여주고, 라디오가 아닌 다중 선택 체크박스로 동작한다.
struct GroupUploadSelectionCard: View {
    let group: PhotoUploadGroupOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.groupName)
                        .momogoTypography(.lgSemistrong)
                        .foregroundStyle(DesignSystem.Color.gray50)

                    if let subtitle {
                        Text(subtitle)
                            .momogoTypography(.smMedium)
                            .foregroundStyle(DesignSystem.Color.gray300)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                // 오늘 이미 업로드한 그룹은 선택 대상이 아니라 체크박스 자체를 보여주지 않는다.
                if group.isUploadable {
                    // checkbox-inactive는 template 렌더링이라 자체 색(검정)이 무시되고 이 tint를
                    // 따라간다. 지정하지 않으면 시스템 기본 전경색(라이트 외관에서 검정)이 적용돼
                    // 어두운 카드 위에서 보이지 않는다. Feature/Group의 SelectionCard와 동일하게
                    // Figma의 Gray/50(#EFEFEF)을 쓴다. checkbox-active는 original 렌더링이라
                    // 자체 노란색을 유지하며 이 tint의 영향을 받지 않는다.
                    Image(asset: isSelected ? DesignSystemAsset.checkboxActive : DesignSystemAsset.checkboxInactive)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(DesignSystem.Color.gray50)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(isSelected ? DesignSystem.Color.white.opacity(0.08) : DesignSystem.Color.white.opacity(0.02))
            .clipShape(.rect(cornerRadius: DesignSystem.Radius.r16))
            .shadow(color: DesignSystem.Color.black.opacity(0.08), radius: 20, x: 0, y: 2)
            .contentShape(.rect(cornerRadius: DesignSystem.Radius.r16))
            .opacity(group.isUploadable ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!group.isUploadable)
        .animation(nil, value: isSelected)
    }

    private var subtitle: String? {
        guard group.isUploadable else { return CardCopy.alreadyUploadedToday }
        return group.memberNames.isEmpty ? nil : group.memberNamesText
    }
}

private enum CardCopy {
    static let alreadyUploadedToday = "오늘 이미 업로드했어요"
}
