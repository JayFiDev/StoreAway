import XCTest
@testable import StoreAway

class FileHandlerTests: XCTestCase {

    var handler: FileHandler!

    override func setUp() {
        super.setUp()
        handler = FileHandler()
    }

    // MARK: - sizeToString

    func testSizeToString_zero() {
        let result = handler.sizeToString(size: 0)
        XCTAssertTrue(result.contains("bytes"), "0 should display in bytes, got: \(result)")
    }

    func testSizeToString_smallBytes() {
        let result = handler.sizeToString(size: 500)
        XCTAssertTrue(result.contains("bytes"), "500 bytes should stay in bytes, got: \(result)")
        XCTAssertTrue(result.contains("500"), "Should contain 500, got: \(result)")
    }

    func testSizeToString_exactlyOneKilobyte_staysBytes() {
        // The loop condition is `value > 1024`, so exactly 1024 stays in bytes
        let result = handler.sizeToString(size: 1024)
        XCTAssertTrue(result.contains("bytes"), "1024 bytes (not > 1024) should stay in bytes, got: \(result)")
    }

    func testSizeToString_justOverOneKilobyte_convertsToKB() {
        let result = handler.sizeToString(size: 1025)
        XCTAssertTrue(result.contains("KB"), "1025 bytes should convert to KB, got: \(result)")
    }

    func testSizeToString_megabytes() {
        let oneMB: UInt64 = 1024 * 1025   // just over 1 MB after one KB division
        let result = handler.sizeToString(size: 1024 * 1024 + 1)
        XCTAssertTrue(result.contains("MB"), "~1 MB should display as MB, got: \(result)")
    }

    func testSizeToString_gigabytes() {
        let overOneGB: UInt64 = 1024 * 1024 * 1024 + 1
        let result = handler.sizeToString(size: overOneGB)
        XCTAssertTrue(result.contains("GB"), "~1 GB should display as GB, got: \(result)")
    }

    func testSizeToString_terabytes() {
        let overOneTB: UInt64 = 1024 * 1024 * 1024 * 1024 + 1
        let result = handler.sizeToString(size: overOneTB)
        XCTAssertTrue(result.contains("TB"), "~1 TB should display as TB, got: \(result)")
    }

    func testSizeToString_formatHasOneDecimalPlace() {
        // All outputs should contain a decimal point
        let result = handler.sizeToString(size: 1500)
        XCTAssertTrue(result.contains("."), "Result should contain a decimal point, got: \(result)")
    }

    func testSizeToString_1500bytes_isApprox1point5KB() {
        // 1500 > 1024 → 1500/1024 ≈ 1.46 → "1.5 KB"
        let result = handler.sizeToString(size: 1500)
        XCTAssertTrue(result.contains("KB"), "1500 bytes should be KB, got: \(result)")
        XCTAssertTrue(result.contains("1.5"), "1500 bytes ≈ 1.5 KB, got: \(result)")
    }
}
