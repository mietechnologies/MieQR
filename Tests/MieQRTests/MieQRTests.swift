import XCTest
@testable import MieQR

extension Bundle {
    public func url(testFile: String, withExtension: String) -> URL? {
        // resources in SPM are a new thing, this supports older xcodes. The path to this file is known
        // (through #file), and the test files are all in subdirectories of the dir the source file is in
        let testsDirectory = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let targetFile = "/\(testFile).\(withExtension)"

        let allFiles = FileManager.default.enumerator(atPath: testsDirectory.path)!
        while let file = allFiles.nextObject() as? String {
            if file.hasSuffix(targetFile) {
                return testsDirectory.appendingPathComponent(file)
            }
        }

        return nil
    }
}

final class MieQRTests: XCTestCase {
    let url: String = "https://mietechnologies.com"
    
    func save(qr: CIImage?, filename: String = "qr") {
        guard let qr = qr else { return }
        let bundle = Bundle(for: type(of: self))
        var destinationURL = bundle.bundleURL.appendingPathComponent("generated")
        try? FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true)
        destinationURL = destinationURL.appendingPathComponent("\(filename).jpeg")
        
        if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
            do {
                let context = CIContext()
                try context.writeJPEGRepresentation(of: qr, to: destinationURL, colorSpace: colorSpace, options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : 1.0])
                print(destinationURL.path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#if os(iOS)
extension MieQRTests {
    
    func testGenerationWithUrl() throws {
        let qr = MieQR(url: url)
        guard let image = qr?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: image)
    }
}
#endif

#if os(macOS)
extension MieQRTests {
    func testGenerationWithUrl() {
        let qr = MieQR(url: url)
        guard let image = qr?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: image)
    }
    
    func testGenerationWithUrlAndTint() {
        let qr = MieQR(url: url, tintColor: .brown)
        guard let image = qr?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: image, filename: "qr-with-color")
    }
    
    func testGenerationWithUrlAndLogo() {
        var qr = MieQR(url: url)
        
        // Add image
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: "logo", withExtension: "png") else { return XCTFail("Could not construct path to logo image!") }
        guard let image = qr?.adding(logo: NSImage(contentsOf: path)) else { return XCTFail("QR Code was not successfully generated!") }
        
        save(qr: image, filename: "qr-with-logo")
    }
    
    func testCompleteGeneration() {
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.url(forResource: "logo_with_bg", withExtension: "png") else { return }
        let qr = MieQR(url: url, logo: NSImage(contentsOf: path))
        guard let image = qr?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: image, filename: "qr-with-all-options")
    }
}
#endif
