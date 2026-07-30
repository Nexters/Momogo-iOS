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

            HStack {
                if !group.photos.isEmpty {
                    DSChip("New!", tone: .gray, size: .small, showsLeadingIcon: false, showsTrailingIcon: false)
                }

                Spacer()

                GroupAvatarStackView(photos: group.photos, totalMemberCount: group.totalMemberCount)
            }
        }
        .padding(20)
        .background(HomeColor.groupCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r24))
    }
}
