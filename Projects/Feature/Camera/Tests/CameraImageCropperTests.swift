import Testing
import UIKit
@testable import FeatureCamera

@Suite("CameraImageCropper")
struct CameraImageCropperTests {
    @Test("정사각형이 아닌 이미지를 중앙 기준 정사각형으로 자른다")
    func cropsToCenteredSquare() throws {
        let image = Self.makeImage(width: 200, height: 100)
        let data = try #require(image.jpegData(compressionQuality: 1))

        let croppedData = try #require(CameraImageCropper.squareCroppedJPEGData(from: data))
        let cropped = try #require(UIImage(data: croppedData))

        #expect(cropped.size.width == cropped.size.height)
    }

    @Test("손상된 데이터는 nil을 반환한다")
    func invalidDataReturnsNil() {
        let croppedData = CameraImageCropper.squareCroppedJPEGData(from: Data([0x00, 0x01]))
        #expect(croppedData == nil)
    }

    private static func makeImage(width: CGFloat, height: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
}
