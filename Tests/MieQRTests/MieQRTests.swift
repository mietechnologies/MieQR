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
    
    var generatedDirectory: URL? {
        // Get save directory
        guard let destination = URL(string: "file://\(#file)")?
            .deletingLastPathComponent()
            .appendingPathComponent("Generated") else { return nil }
        try? FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        return destination
    }
    
    func save(qr: CIImage?, filename: String = "qr") {
        guard let qr = qr else { return }
        guard let generated = generatedDirectory else { return XCTFail("") }
        let destination = generated.appendingPathComponent("\(filename).jpeg")
        
        if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
            do {
                let context = CIContext()
                try context.writeJPEGRepresentation(of: qr, to: destination, colorSpace: colorSpace, options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : 1.0])
                print("QR code saved to \(destination.absoluteString)")
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
        guard let qr = MieQR(url: url)?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: qr)
    }
    
    func testGenerationWithUrlAndTint() {
        guard let qr = MieQR(url: url, tintColor: .brown)?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: qr, filename: "qr-with-color")
    }
    
    func testGenerationWithUrlAndLogo() {
        guard let path = Bundle.module.url(forResource: "logo", withExtension: "png") else { return XCTFail("Could not construct path to logo image!") }
        guard let qr = MieQR(url: url, logo: NSImage(contentsOf: path))?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: qr, filename: "qr-with-logo")
    }
    
    func testCompleteGeneration() {
        guard let path = Bundle.module.url(forResource: "logo", withExtension: "png") else { return XCTFail("Could not construct path to logo image!") }
        guard let qr = MieQR(url: url, tintColor: .brown, logo: NSImage(contentsOf: path))?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: qr, filename: "qr-with-all-options")
    }
}
#endif
