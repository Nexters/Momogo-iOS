import SwiftUI

import SwiftUINavigation

struct NicknameView: View {
    @Bindable private var viewModel: NicknameViewModel

    init(viewModel: NicknameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("모라고\n불러줄까?")
                .font(.largeTitle.weight(.medium))
                .foregroundStyle(.white)

            Spacer()

            VStack(spacing: 12) {
                TextField(
                    "",
                    text: $viewModel.nickname,
                    prompt: Text("닉네임 입력")
                        .foregroundStyle(OnboardingColor.placeholder)
                )
                .textFieldStyle(.plain)
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(OnboardingColor.fieldBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(OnboardingColor.fieldBorder, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                }
                .clipShape(.rect(cornerRadius: 14))

                Button {
                    viewModel.nextTapped()
                } label: {
                    Text("다음")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(OnboardingColor.accentText)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                        .background(OnboardingColor.accent)
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
        .navigationDestination(item: $viewModel.destination.groupSelect) { groupSelectViewModel in
            GroupSelectView(viewModel: groupSelectViewModel)
        }
    }
}
