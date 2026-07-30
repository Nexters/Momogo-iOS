import Foundation

import Dependencies
import DomainInterface

@Observable
@MainActor
public final class HomeViewModel {
    var groups: [GroupSummary] = []
    var isLoading: Bool = false
    var errorMessage: String?

    @ObservationIgnored
    @Dependency(\.getGroupsUseCase) private var getGroupsUseCase

    public init() {}

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            groups = try await getGroupsUseCase.execute().groups
        } catch {
            errorMessage = "잠시 후 다시 시도해주세요."
        }
    }
}
