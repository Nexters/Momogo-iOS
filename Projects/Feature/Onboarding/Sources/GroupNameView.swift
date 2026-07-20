import SwiftUI

struct GroupNameView: View {
    @State private var groupName: String = ""
    let onCreateGroup: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("그룹 이름을\n지어주라모")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            VStack(spacing: 12) {
                TextField(
                    "",
                    text: $groupName,
                    prompt: Text("그룹명 입력")
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

                Button(action: onCreateGroup) {
                    Text("그룹 만들기")
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
