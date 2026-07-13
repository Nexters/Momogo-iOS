import ProjectDescription

public extension ModulePath {
    // sub-module이 생기면 `String, CaseIterable` enum으로 바꾸고 case를 추가한다 (예: case designSystem = "DesignSystem")
    enum Shared {
        public static let name = "Shared"
    }
}
