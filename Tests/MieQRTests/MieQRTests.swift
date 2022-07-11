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
    
    func generatedDirectoryFor(os: String) -> URL? {
        guard let destination = URL(string: "file://\(#file)")?
            .deletingLastPathComponent()
            .appendingPathComponent("Generated")
            .appendingPathComponent(os) else { return nil }
        try? FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        return destination
    }
    
    func save(qr: CIImage?, os: String, filename: String) {
        guard let qr = qr else { return }
        guard let generated = generatedDirectoryFor(os: os) else { return XCTFail("Could not create save directory!") }
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
import UIKit

extension MieQRTests {
    
    func testGenerationWithUrl() throws {
        guard let qr = MieQR(url: url)?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: qr, os: "iOS", filename: "qr")
    }
    
    func testGenerationWithUrlAndTint() {
        guard let qr = MieQR(url: url, tintColor: .brown)?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: qr, os: "iOS", filename: "qr-with-color")
    }
}
#endif

#if os(macOS)
extension MieQRTests {
    func testGenerationWithUrl() {
        guard let qr = MieQR(url: url)?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: qr, os: "macOS", filename: "qr")
    }
    
    func testGenerationWithUrlAndTint() {
        guard let qr = MieQR(url: url, tintColor: .brown)?.image else { return XCTFail("QR Code was not successfully generated!") }
        save(qr: qr, os: "macOS", filename: "qr-with-color")
    }
}
#endif
