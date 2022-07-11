#if os(iOS)
import UIKit
#else
import Cocoa
#endif

public struct MieQR {
    public var image: CIImage?
    
    public init() {  }
    
    public init?(url: String) {
        guard let image = self.set(url: url) else { return nil }
        self.image = image
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
        self.image = set(url: url)
        
        if let tintColor = tintColor {
            self.image = self.tinted(using: tintColor)
        }
        
        if let logo = logo {
            self.image = self.adding(logo: logo)
        }
    }
    
    mutating public func tinted(using color: UIColor) -> CIImage? {
        self.image = self.image?.tinted(using: color)
        return self.image
    }
    
    mutating public func adding(logo: UIImage?) -> CIImage? {
        guard let ciImage = logo?.ciImage else { return self.image }
        self.image = self.image?.addLogo(with: ciImage)
        return self.image
    }
    #endif
    
    #if os(macOS)
    public init?(url: String, tintColor: NSColor? = nil, logo: NSImage? = nil) {
        self.image = set(url: url)
        
        if let tintColor = tintColor {
            self.image = self.tinted(using: tintColor)
        }
        
        if let logo = logo {
            self.image = self.adding(logo: logo)
        }
    }
    
    mutating public func tinted(using color: NSColor) -> CIImage? {
        self.image = self.image?.tinted(using: color)
        return self.image
    }
    
    mutating public func adding(logo: NSImage?) -> CIImage? {
        guard let data = logo?.tiffRepresentation else { return self.image }
        guard let bitmap = NSBitmapImageRep(data: data) else { return self.image }
        guard let ciImage = CIImage(bitmapImageRep: bitmap) else { return self.image }
        self.image = self.image?.addLogo(with: ciImage)
        return self.image
    }
    #endif
}
