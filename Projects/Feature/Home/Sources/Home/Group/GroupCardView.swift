import SwiftUI

import DesignSystem
import DomainInterface

struct GroupCardView: View {
    let group: GroupSummary

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(group.groupName)
                .momogoTypography(.heading20)
                .foregroundStyle(DesignSystem.Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(group.totalMemberCount)명")
                .momogoTypography(.xsSemistrong)
                .foregroundStyle(DesignSystem.Color.gray200)
        }
        .padding(20)
        .background(DesignSystem.Color.gray800)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r24))
    }
}
