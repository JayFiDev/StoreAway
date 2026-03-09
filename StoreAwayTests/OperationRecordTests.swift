import XCTest
@testable import StoreAway

class OperationRecordTests: XCTestCase {

    // MARK: - totalFiles

    func testTotalFiles_sumOfMovedAndCopied() {
        let record = OperationRecord(date: Date(), filesMoved: 3, filesCopied: 2, triggerSource: .manual)
        XCTAssertEqual(record.totalFiles, 5)
    }

    func testTotalFiles_onlyMoved() {
        let record = OperationRecord(date: Date(), filesMoved: 7, filesCopied: 0, triggerSource: .manual)
        XCTAssertEqual(record.totalFiles, 7)
    }

    func testTotalFiles_onlyCopied() {
        let record = OperationRecord(date: Date(), filesMoved: 0, filesCopied: 4, triggerSource: .manual)
        XCTAssertEqual(record.totalFiles, 4)
    }

    func testTotalFiles_zero() {
        let record = OperationRecord(date: Date(), filesMoved: 0, filesCopied: 0, triggerSource: .manual)
        XCTAssertEqual(record.totalFiles, 0)
    }

    // MARK: - sourceName

    func testSourceName_manual() {
        let record = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .manual)
        XCTAssertEqual(record.sourceName, "Manual")
    }

    func testSourceName_autoWatch() {
        let record = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .autoWatch)
        XCTAssertEqual(record.sourceName, "Auto")
    }

    func testSourceName_menuBar() {
        let record = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .menuBar)
        XCTAssertEqual(record.sourceName, "Menu bar")
    }

    // MARK: - sourceSymbol

    func testSourceSymbol_manual() {
        let record = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .manual)
        XCTAssertEqual(record.sourceSymbol, "hand.tap")
    }

    func testSourceSymbol_autoWatch() {
        let record = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .autoWatch)
        XCTAssertEqual(record.sourceSymbol, "wand.and.stars")
    }

    func testSourceSymbol_menuBar() {
        let record = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .menuBar)
        XCTAssertEqual(record.sourceSymbol, "menubar.rectangle")
    }

    // MARK: - Codable

    func testCodable_roundTrip() throws {
        let original = OperationRecord(date: Date(), filesMoved: 5, filesCopied: 3, triggerSource: .autoWatch)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(OperationRecord.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.filesMoved, original.filesMoved)
        XCTAssertEqual(decoded.filesCopied, original.filesCopied)
        XCTAssertEqual(decoded.triggerSource, original.triggerSource)
        XCTAssertEqual(decoded.totalFiles, original.totalFiles)
    }

    func testCodable_triggerSourceRawValues() throws {
        for source in [TriggerSource.manual, .autoWatch, .menuBar] {
            let record = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: source)
            let data = try JSONEncoder().encode(record)
            let decoded = try JSONDecoder().decode(OperationRecord.self, from: data)
            XCTAssertEqual(decoded.triggerSource, source, "Trigger source \(source) should survive Codable round-trip")
        }
    }

    // MARK: - Identifiable

    func testUniqueIDs() {
        let a = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .manual)
        let b = OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .manual)
        XCTAssertNotEqual(a.id, b.id, "Each OperationRecord should get a unique ID")
    }
}
