import SwiftUI
import UIKit

import DesignSystem

public struct CameraView: View {
    @Bindable private var viewModel: CameraViewModel
    @Environment(\.openURL) private var openURL

    public init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // .background(...ignoresSafeArea())를 VStack에 직접 걸면, 배경뿐 아니라 VStack
            // 자체의 레이아웃까지 safe area를 무시하게 되는 경우가 있어(topBar가 상단 safe area
            // 안쪽에 패딩만 주고 있었는데 실제로는 노치/다이나믹 아일랜드 영역까지 밀려 올라가
            // 닫기(X) 버튼이 그 뒤에 가려 안 보이는 문제로 나타났다), 배경을 별도 레이어로 분리해
            // VStack은 항상 safe area를 존중하도록 한다.
            DesignSystem.Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                viewfinderArea
                footer
            }
        }
        .task { await viewModel.onAppear() }
        .onDisappear { viewModel.stopSessionOnDisappear() }
        .momogoModalOverlay(
            isPresented: Binding(get: { viewModel.stage == .permissionDenied }, set: { _ in })
        ) {
            DSModal(
                title: CameraCopy.permissionAlertTitle,
                description: CameraCopy.permissionAlertMessage,
                primaryTitle: CameraCopy.permissionAlertConfirm,
                primaryAction: openSettingsTapped,
                secondaryTitle: CameraCopy.permissionAlertCancel,
                secondaryAction: { viewModel.cancelTapped() }
            )
        }
    }

    /// 설정 앱의 카메라 권한 화면으로 이동한 뒤, 권한 없이는 무용한 카메라 화면을 닫는다.
    private func openSettingsTapped() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
        viewModel.cancelTapped()
    }

    private var topBar: some View {
        HStack {
            Spacer()
            closeButton
        }
        .padding(12)
    }

    private var closeButton: some View {
        Button {
            viewModel.cancelTapped()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DesignSystem.Color.gray900)
                .frame(width: 24, height: 24)
                .background(DesignSystem.Color.gray50)
                .clipShape(Circle())
        }
        .accessibilityLabel(CameraCopy.closeAccessibilityLabel)
    }

    @ViewBuilder
    private var viewfinderArea: some View {
        Group {
            if viewModel.stage == .granted {
                CameraPreviewView(session: viewModel.session)
            } else {
                Color.black
            }
        }
        // .fill을 쓰면 정사각형이 "제안된 공간을 양쪽 다 채우도록" 커진다. 뷰파인더는 세로가 가로보다
        // 길어서 정사각형이 세로에 맞춰 화면 폭보다 넓어지고, VStack은 가장 넓은 자식에 폭을 맞추므로
        // 화면 밖까지 넓어진 VStack 안에서 오른쪽 정렬된 닫기 버튼이 화면 밖으로 밀려났었다.
        // 프리뷰 자체는 AVCaptureVideoPreviewLayer의 resizeAspectFill이 채워주므로 .fit이면 충분하다.
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r24))
        .overlay(alignment: .bottom) {
            instructionChip
                .padding(.bottom, 16)
        }
        .overlay {
            if viewModel.stage == .checking {
                ProgressView().tint(DesignSystem.Color.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var instructionChip: some View {
        Text(CameraCopy.instructionText)
            .momogoTypography(.smSemistrong)
            .foregroundStyle(DesignSystem.Color.gray50)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(DesignSystem.Color.black.opacity(0.32))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r12))
    }

    private var footer: some View {
        VStack(spacing: 32) {
            zoomBar
            shutterButton
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 56)
    }

    private var zoomBar: some View {
        HStack(spacing: 10) {
            ForEach(CameraZoomLevel.allCases, id: \.self) { level in
                zoomButton(level)
            }
        }
        .padding(4)
        .background(DesignSystem.Color.white.opacity(0.04))
        .clipShape(Capsule())
    }

    private func zoomButton(_ level: CameraZoomLevel) -> some View {
        let isActive = viewModel.zoomLevel == level
        let isAvailable = viewModel.isZoomLevelAvailable(level)
        return Button {
            viewModel.zoomTapped(level)
        } label: {
            Text(isActive ? level.label + "x" : level.label)
                .momogoTypography(.smMedium)
                .foregroundStyle(
                    isActive ? DesignSystem.Color.primary500 : DesignSystem.Color.white.opacity(isAvailable ? 1 : 0.3)
                )
                .frame(width: 32, height: 32)
                .background(isActive ? DesignSystem.Color.white.opacity(0.16) : .clear)
                .overlay {
                    if isActive {
                        Circle().stroke(DesignSystem.Color.white.opacity(0.16), lineWidth: 2)
                    }
                }
                .clipShape(Circle())
        }
        .disabled(viewModel.stage != .granted || !isAvailable)
    }

    private var shutterButton: some View {
        Button {
            Task { await viewModel.shutterTapped() }
        } label: {
            Circle()
                .stroke(DesignSystem.Color.white, lineWidth: 4)
                .frame(width: 72, height: 72)
                .overlay {
                    Circle()
                        .fill(DesignSystem.Color.white)
                        .padding(6)
                }
        }
        .disabled(viewModel.stage != .granted || viewModel.isCapturing)
        .accessibilityLabel(CameraCopy.shutterAccessibilityLabel)
    }
}

private enum CameraCopy {
    static let instructionText = "오늘의 점심을 가득 채워 찍어주세요!"

    static let closeAccessibilityLabel = "닫기"
    static let shutterAccessibilityLabel = "촬영하기"

    static let permissionAlertTitle = "카메라 권한이 필요해요"
    static let permissionAlertMessage = "설정에서 카메라 권한을 허용해주세요"
    static let permissionAlertConfirm = "확인"
    static let permissionAlertCancel = "취소"
}
