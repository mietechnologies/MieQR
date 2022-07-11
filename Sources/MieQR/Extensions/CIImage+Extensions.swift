//  CIImage+Extensions.swift
//  Created by Michael Craun on 7/11/22.

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

extension CIImage {
    public var transparent: CIImage? {
        return inverted?.blackTransparent
    }
    
    public var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }
        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }
    
    public var blackTransparent: CIImage? {
        guard let blackTransparentCIFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentCIFilter.setValue(self, forKey: "inputImage")
        return blackTransparentCIFilter.outputImage
    }
    
    public func addLogo(with image: CIImage) -> CIImage? {
        guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
        combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "inputImage")
        combinedFilter.setValue(self, forKey: "inputBackgroundImage")
        return combinedFilter.outputImage
    }
}

#if os(iOS)
extension CIImage {
    public func tinted(using color: UIColor) -> CIImage? {
        guard let transparentQRImage = transparent,
              let filter = CIFilter(name: "CIMultiplyCompositing"),
              let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        
        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage
        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)
        return filter.outputImage
    }
}
#endif

#if os(macOS)
extension CIImage {
    public func tinted(using color: NSColor) -> CIImage? {
        guard let transparentQRImage = transparent,
              let filter = CIFilter(name: "CIMultiplyCompositing"),
              let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        
        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage
        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)
        return filter.outputImage
    }
}
#endif
