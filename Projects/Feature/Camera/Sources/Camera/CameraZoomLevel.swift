import CoreGraphics

enum CameraZoomLevel: CaseIterable {
    case half
    case x1
    case x3

    var label: String {
        switch self {
        case .half: ".5"
        case .x1: "1"
        case .x3: "3"
        }
    }

    func rawZoomFactor(for capability: CameraZoomCapability) -> CGFloat {
        switch self {
        case .half: capability.minZoomFactor
        case .x1: capability.nativeZoomFactor
        case .x3: capability.nativeZoomFactor * 3
        }
    }

    func isAvailable(for capability: CameraZoomCapability) -> Bool {
        switch self {
        case .half: capability.minZoomFactor < capability.nativeZoomFactor
        case .x1: true
        case .x3: capability.nativeZoomFactor * 3 <= capability.maxZoomFactor
        }
    }
}
