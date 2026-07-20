import SwiftUI

struct GroupSelectView: View {
    let onCreateGroup: () -> Void
    let onJoinWithCode: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("모모님, 모부터\n시작할까?")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            VStack(spacing: 12) {
                Button(action: onCreateGroup) {
                    Text("그룹 만들기")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(OnboardingColor.accentText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(OnboardingColor.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }

                Button(action: onJoinWithCode) {
                    Text("초대코드로 참여하기")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(OnboardingColor.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(OnboardingColor.secondaryBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(OnboardingColor.accent, lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
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
