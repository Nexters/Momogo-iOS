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
                    // 멤버 이름은 아직 어떤 API도 내려주지 않아, 값이 있을 때만 노출한다.
                    if !group.memberNames.isEmpty {
                        Text(group.memberNamesText)
                            .momogoTypography(.smMedium)
                            .foregroundStyle(DesignSystem.Color.gray300)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                Image(asset: isSelected ? DesignSystemAsset.checkboxActive : DesignSystemAsset.checkboxInactive)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(isSelected ? DesignSystem.Color.white.opacity(0.08) : DesignSystem.Color.white.opacity(0.02))
            .clipShape(.rect(cornerRadius: DesignSystem.Radius.r16))
            .shadow(color: DesignSystem.Color.black.opacity(0.08), radius: 20, x: 0, y: 2)
            .contentShape(.rect(cornerRadius: DesignSystem.Radius.r16))
        }
        .buttonStyle(.plain)
        .animation(nil, value: isSelected)
    }
}
