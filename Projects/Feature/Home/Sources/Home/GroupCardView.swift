import SwiftUI

import DesignSystem
import DomainInterface

struct GroupCardView: View {
    let group: GroupSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                Text(group.groupName)
                    .momogoTypography(.heading20)
                    .foregroundStyle(DesignSystem.Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(group.participateMemberCount) / \(group.totalMemberCount)")
                    .momogoTypography(.xsSemistrong)
                    .foregroundStyle(DesignSystem.Color.gray200)
            }

            GroupAvatarStackView(photos: group.photos, totalMemberCount: group.totalMemberCount)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(20)
        .background(DesignSystem.Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r24))
    }
}
