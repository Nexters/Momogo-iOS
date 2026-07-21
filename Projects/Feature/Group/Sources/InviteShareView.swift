import SwiftUI

struct InviteShareView: View {
    @Bindable private var viewModel: InviteShareViewModel

    private let memberColors: [Color] = [
        Color(red: 216 / 255, green: 90 / 255, blue: 48 / 255),
        Color(red: 29 / 255, green: 158 / 255, blue: 117 / 255),
        Color(red: 212 / 255, green: 83 / 255, blue: 126 / 255)
    ]

    init(viewModel: InviteShareViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(GroupColor.accent)
                    .frame(width: 66, height: 66)
                    .background(GroupColor.secondaryBackground)
                    .overlay {
                        Circle()
                            .strokeBorder(GroupColor.accent, style: StrokeStyle(lineWidth: 2, dash: [4]))
                    }
                    .clipShape(.circle)
                    .accessibilityHidden(true)

                Text("가까운 사람을\n초대해보세요")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                HStack(spacing: -8) {
                    ForEach(memberColors.indices, id: \.self) { index in
                        Circle()
                            .fill(memberColors[index])
                            .frame(width: 28, height: 28)
                            .overlay {
                                Circle().strokeBorder(GroupColor.background, lineWidth: 2)
                            }
                    }
                }
                .accessibilityHidden(true)

                Text(viewModel.inviteCode)
                    .font(.subheadline.weight(.medium))
                    .tracking(3)
                    .foregroundStyle(GroupColor.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(GroupColor.fieldBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(GroupColor.accent, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                    }
                    .clipShape(.rect(cornerRadius: 10))
            }

            Spacer()

            Button {
                viewModel.goToMainTapped()
            } label: {
                Text("메인 화면으로 가기")
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
