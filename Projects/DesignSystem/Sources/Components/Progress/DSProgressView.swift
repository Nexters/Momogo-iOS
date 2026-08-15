import SwiftUI

import Lottie

/// 로띠(dotLottie) 기반 로딩 인디케이터.
/// 원본 아트보드가 60x60이라 기본 size도 60으로 둔다.
public struct DSProgressView: View {
    private let size: CGFloat

    public init(size: CGFloat = 60) {
        self.size = size
    }

    public var body: some View {
        LottieView {
            try await DotLottieFile.named("loading", bundle: .module)
        }
        .looping()
        .frame(width: size, height: size)
        .accessibilityLabel("로딩 중")
    }
}
