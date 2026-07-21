import SwiftUI

import FeatureGroup
import SwiftUINavigation

struct GroupSelectView: View {
    @Bindable private var viewModel: GroupSelectViewModel

    init(viewModel: GroupSelectViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("모모님, 모부터\n시작할까?")
                .font(.largeTitle.weight(.medium))
                .foregroundStyle(.white)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    viewModel.createGroupTapped()
                } label: {
                    Text("그룹 만들기")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(OnboardingColor.accentText)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                        .background(OnboardingColor.accent)
                        .clipShape(.rect(cornerRadius: 24))
                }

                Button {
                    viewModel.joinWithCodeTapped()
                } label: {
                    Text("초대코드로 참여하기")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(OnboardingColor.accent)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                        .background(OnboardingColor.secondaryBackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(OnboardingColor.accent, lineWidth: 1.5)
                        }
                        .clipShape(.rect(cornerRadius: 24))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(OnboardingColor.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.groupName) { groupNameViewModel in
            GroupNameView(viewModel: groupNameViewModel)
        }
        .navigationDestination(item: $viewModel.destination.inviteCode) { inviteCodeViewModel in
            InviteCodeInputView(viewModel: inviteCodeViewModel)
        }
    }
}
