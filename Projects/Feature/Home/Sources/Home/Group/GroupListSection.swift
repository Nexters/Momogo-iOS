import SwiftUI

import DesignSystem
import DomainInterface

struct GroupListSection: View {
    let groups: [GroupSummary]
    let isEmpty: Bool
    let onTapGroup: (GroupSummary) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("내 그룹")
                .momogoTypography(.heading20)
                .foregroundStyle(DesignSystem.Color.gray50)

            if isEmpty {
                GroupEmptyView()
            } else {
                ForEach(groups) { group in
                    GroupCardView(group: group, action: { onTapGroup(group) })
                }
            }
        }
    }
}
