import XCTest
@testable import MieQR

#if os(iOS)
final class MieQRTests: XCTestCase {
    func testExample() throws {
        let qr = MieQR(url: "https://mietechnologies.com")
        
    }
}
#endif

#if os(macOS)
final class MieQRTests: XCTestCase {
    
}
#endif
