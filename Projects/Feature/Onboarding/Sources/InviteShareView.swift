import SwiftUI

struct InviteShareView: View {
    let inviteCode: String
    let onGoToMain: () -> Void

    private let memberColors: [Color] = [
        Color(red: 216 / 255, green: 90 / 255, blue: 48 / 255),
        Color(red: 29 / 255, green: 158 / 255, blue: 117 / 255),
        Color(red: 212 / 255, green: 83 / 255, blue: 126 / 255)
    ]

    init(inviteCode: String = "A1B2C3", onGoToMain: @escaping () -> Void) {
        self.inviteCode = inviteCode
        self.onGoToMain = onGoToMain
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(OnboardingColor.accent)
                    .frame(width: 66, height: 66)
                    .background(OnboardingColor.secondaryBackground)
                    .overlay(
                        Circle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4]))
                            .foregroundColor(OnboardingColor.accent)
                    )
                    .clipShape(Circle())

                Text("가까운 사람을\n초대해보세요")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                HStack(spacing: -8) {
                    ForEach(memberColors.indices, id: \.self) { index in
                        Circle()
                            .fill(memberColors[index])
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle().strokeBorder(OnboardingColor.background, lineWidth: 2)
                            )
                    }
                }

                Text(inviteCode)
                    .font(.system(size: 15, weight: .medium))
                    .tracking(3)
                    .foregroundColor(OnboardingColor.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(OnboardingColor.fieldBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                            .foregroundColor(OnboardingColor.accent)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                ShareLink(item: inviteCode) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(OnboardingColor.accent)
                }
            }

            Spacer()

            Button(action: onGoToMain) {
                Text("메인 화면으로 가기")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(OnboardingColor.accentText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(OnboardingColor.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingColor.background)
        .ignoresSafeArea()
    }
}
