import Foundation

import DomainInterface

extension UpdateGroupNameUseCase {
    static let happyPath = UpdateGroupNameUseCase { groupId, groupName in
        try? await Task.sleep(for: .seconds(0.4))
        return UpdateGroupNameResponse(groupId: groupId, groupName: groupName)
    }
}
