import SwiftUI

import SwiftUINavigation

public struct InviteCodeInputView: View {
    @Bindable private var viewModel: InviteCodeInputViewModel

    public init(viewModel: InviteCodeInputViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("초대코드를\n입력해주라모")
                .font(.largeTitle.weight(.medium))
                .foregroundStyle(.white)

            Spacer()

            VStack(spacing: 12) {
                TextField(
                    "",
                    text: $viewModel.code,
                    prompt: Text("코드 입력")
                        .foregroundStyle(GroupColor.placeholder)
                )
                .textFieldStyle(.plain)
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(GroupColor.fieldBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(GroupColor.fieldBorder, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                }
                .clipShape(.rect(cornerRadius: 14))

                Button {
                    viewModel.joinTapped()
                } label: {
                    Text("참여하기")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(GroupColor.accentText)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 48)
                        .background(GroupColor.accent)
                        .clipShape(.rect(cornerRadius: 24))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(GroupColor.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $viewModel.destination.joinConfirm) { joinConfirmViewModel in
            JoinConfirmView(viewModel: joinConfirmViewModel)
        }
    }
}
