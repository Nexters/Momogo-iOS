import UIKit

enum CameraImageCropper {
    static func squareCroppedJPEGData(from data: Data, compressionQuality: CGFloat = 0.9) -> Data? {
        guard let image = UIImage(data: data), let cgImage = image.cgImage else { return nil }

        let pixelWidth = CGFloat(cgImage.width)
        let pixelHeight = CGFloat(cgImage.height)
        let side = min(pixelWidth, pixelHeight)
        let cropRect = CGRect(
            x: (pixelWidth - side) / 2,
            y: (pixelHeight - side) / 2,
            width: side,
            height: side
        )

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        return croppedImage.jpegData(compressionQuality: compressionQuality)
    }
}
