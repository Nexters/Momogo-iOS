import SwiftUI
import UIKit

import DesignSystem

public struct PhotoUploadConfirmView: View {
    @Bindable private var viewModel: PhotoUploadConfirmViewModel

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
        .momogoToast(
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
            ),
            message: viewModel.errorMessage ?? "",
            tone: .error
        )
    }

    private var photoPreview: some View {
        Image(uiImage: UIImage(data: viewModel.photoData) ?? UIImage())
            .resizable()
            .aspectRatio(1, contentMode: .fill)
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.r24))
            .clipped()
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

    @ViewBuilder
    private var groupList: some View {
        if viewModel.isLoadingGroups {
            ProgressView()
                .tint(DesignSystem.Color.gray50)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        } else {
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
