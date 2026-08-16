import SwiftUI
import UIKit

import DesignSystem

public struct PhotoUploadConfirmView: View {
    private static let previewSide: CGFloat = 200

    @Bindable private var viewModel: PhotoUploadConfirmViewModel
    @State private var previewImage: UIImage?

    public init(viewModel: PhotoUploadConfirmViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSTopNavigationBar(title: ViewCopy.title, leading: {
                DSBackButton(action: viewModel.backTapped)
            })

            ScrollView {
                VStack(spacing: 24) {
                    photoPreview

                    VStack(spacing: 16) {
                        header
                        groupList
                    }
                }
                .padding(16)
            }
            .scrollIndicators(.hidden)

            gradientFade

            Button(ViewCopy.confirmButtonTitle) {
                Task { await viewModel.confirmTapped() }
            }
            .buttonStyle(.momogoButton(kind: .solid, tone: .primary, size: .xl, isFullWidth: true))
            .disabled(!viewModel.isConfirmEnabled)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignSystem.Color.gray950.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.onAppear() }
        // 그룹 목록 조회, 업로드 확정 두 API 호출 모두 진행 중에는 화면을 딤 처리해 상호작용을 막고
        // 로딩 중임을 알린다. 성공/실패 상관없이 호출이 끝나면(ViewModel의 defer) 자동으로 사라진다.
        .momogoLoadingOverlay(isPresented: viewModel.isLoadingGroups || viewModel.isUploading)
        .momogoToast(
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
            ),
            message: viewModel.errorMessage ?? "",
            tone: .error
        )
    }

    /// `body` 안에서 `UIImage(data:)`를 부르면 그룹 체크박스를 누를 때마다(=상태가 바뀔 때마다)
    /// 원본 해상도 JPEG를 메인스레드에서 다시 디코드한다. 표시 크기는 200pt 고정이므로 진입 시
    /// 한 번만, 메인 밖에서, 썸네일 크기로 만들어 들고 있는다.
    private var photoPreview: some View {
        Group {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } else {
                DesignSystem.Color.gray900
            }
        }
        .frame(width: Self.previewSide, height: Self.previewSide)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r24))
        .clipped()
        .task {
            guard previewImage == nil else { return }
            previewImage = await Self.makePreviewImage(from: viewModel.photoData)
        }
    }

    private static func makePreviewImage(from data: Data) async -> UIImage? {
        // 최신 기기 최대 배율(3x) 기준으로 만든다. 2x 기기에서는 조금 더 큰 썸네일이 되지만,
        // 원본(4000px 급)에 비하면 무시할 수준이라 기기별로 나누지 않는다.
        let side = previewSide * 3
        return await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(data: data) else { return nil }
            return image.preparingThumbnail(of: CGSize(width: side, height: side)) ?? image
        }.value
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(ViewCopy.subtitle)
                .momogoTypography(.xlSemistrong)
                .foregroundStyle(DesignSystem.Color.gray100)
                .frame(maxWidth: .infinity, alignment: .leading)

            DSToggle(
                ViewCopy.selectAllTitle,
                isOn: Binding(
                    get: { viewModel.isAllSelected },
                    set: { _ in viewModel.toggleSelectAll() }
                )
            )
        }
    }

    // 로딩 중 표시는 momogoLoadingOverlay가 화면 전체를 딤 처리하며 대신하므로, 여기서는 로딩 여부와
    // 무관하게 그룹 목록만 그린다(로딩 중엔 groups가 비어 있어 빈 VStack이 그려질 뿐이다).
    private var groupList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.groups) { group in
                GroupUploadSelectionCard(
                    group: group,
                    isSelected: viewModel.isSelected(group),
                    action: { viewModel.toggle(group) }
                )
            }
        }
    }

    private var gradientFade: some View {
        LinearGradient(
            colors: [DesignSystem.Color.gray950.opacity(0), DesignSystem.Color.gray950],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 20)
        .allowsHitTesting(false)
    }
}

private enum ViewCopy {
    static let title = "업로드 확인"
    static let subtitle = "어디에 올릴까요?"
    static let selectAllTitle = "모두 선택"
    static let confirmButtonTitle = "선택한 그룹에 올리기"
}
