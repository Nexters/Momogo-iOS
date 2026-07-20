import SwiftUI

struct NicknameView: View {
    @State private var nickname: String = ""
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("모라고\n불러줄까?")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            VStack(spacing: 12) {
                TextField(
                    "",
                    text: $nickname,
                    prompt: Text("닉네임 입력")
                        .foregroundColor(OnboardingColor.placeholder)
                )
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(OnboardingColor.fieldBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        .foregroundColor(OnboardingColor.fieldBorder)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button(action: onNext) {
                    Text("다음")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(OnboardingColor.accentText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(OnboardingColor.accent)
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
