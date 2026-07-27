import SwiftUI

struct JoinConfirmView: View {
    @Bindable private var viewModel: JoinConfirmViewModel

    init(viewModel: JoinConfirmViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(GroupColor.success)
                        .frame(width: 70, height: 70)

                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)
                }
                .accessibilityHidden(true)

                Text("그룹에 참여했다모")
                    .font(.largeTitle.weight(.medium))
                    .foregroundStyle(.white)

                Text("우리 가족에 합류했다모")
                    .font(.caption)
                    .foregroundStyle(GroupColor.secondaryText)
            }

            Spacer()

            Button {
                viewModel.startTapped()
            } label: {
                Text("시작하기")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(GroupColor.accentText)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
                    .background(GroupColor.accent)
                    .clipShape(.rect(cornerRadius: 24))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .background(GroupColor.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}
