import Foundation

@Observable
@MainActor
final class ToastStore {
    var toast: DSTopToastContent?
}
