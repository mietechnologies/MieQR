#if os(iOS)
import UIKit
#else
import Cocoa
#endif

public struct MieQR {
    private var url: String?
    #if os(iOS)
    private var tint: UIColor?
    #else
    private var tint: NSColor?
    #endif
    private var logo: CIImage?
    
    public var image: CIImage? {
        guard let url = url, let url = URL(string: url) else { return nil }
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData = url.absoluteString.data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")
        
        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        var image = qrFilter.outputImage?.transformed(by: qrTransform)
        
        if let tint = tint {
            print(tint)
            image = image?.tinted(using: tint)
        }
        
        if let logo = logo {
            print(logo)
            image = image?.addLogo(with: logo)
        }
        
        return image
    }
    
    public func set(url: String) -> CIImage? {
        guard let url = URL(string: url) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = url.absoluteString.data(using: .ascii)
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 12.0, y: 12.0)
        return filter.outputImage?.transformed(by: transform)
    }
    
    #if os(iOS)
    public init?(url: String, tintColor: UIColor? = nil, logo: UIImage? = nil) {
        self.url = url
        self.tint = tintColor
        self.logo = logo?.ciImage
    }
    #endif
    
    #if os(macOS)
    public init?(url: String, tintColor: NSColor? = nil, logo: NSImage? = nil) {
        self.url = url
        self.tint = tintColor
        
        if let data = logo?.tiffRepresentation, let bitmap = NSBitmapImageRep(data: data) {
            self.logo = CIImage(bitmapImageRep: bitmap)
        }
    }
    #endif
}
