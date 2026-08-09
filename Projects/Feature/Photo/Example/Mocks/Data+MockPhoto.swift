import UIKit

/// Example 앱에서 촬영 사진 대신 사용할 임시 프리뷰 이미지.
extension Data {
    static let mockPhoto: Data = {
        let size = CGSize(width: 400, height: 400)
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            UIColor.systemOrange.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
        }
        return image.jpegData(compressionQuality: 0.9) ?? Data()
    }()
}
