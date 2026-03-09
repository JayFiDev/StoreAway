import XCTest
@testable import StoreAway

class MappingTests: XCTestCase {

    let testURL = URL(fileURLWithPath: "/tmp/StoreAwayTestDest")

    // MARK: - Custom extension init

    func testInit_withExtensions_isCustom() {
        let mapping = Mapping(path: testURL, fileExtensions: ["pdf", "doc"])
        XCTAssertTrue(mapping.isCustom)
        XCTAssertEqual(mapping.fileExtensions, ["pdf", "doc"])
        XCTAssertNil(mapping.fileType)
        XCTAssertEqual(mapping.path, testURL)
    }

    func testInit_withExtensions_getsUniqueID() {
        let a = Mapping(path: testURL, fileExtensions: ["pdf"])
        let b = Mapping(path: testURL, fileExtensions: ["pdf"])
        XCTAssertNotEqual(a.id, b.id, "Each Mapping should get a unique UUID")
    }

    func testInit_withExtensions_preservesExplicitID() {
        let fixedID = UUID()
        let mapping = Mapping(id: fixedID, path: testURL, fileExtensions: ["mp3"])
        XCTAssertEqual(mapping.id, fixedID)
    }

    func testInit_withExtensions_emptyList() {
        let mapping = Mapping(path: testURL, fileExtensions: [])
        XCTAssertTrue(mapping.isCustom)
        XCTAssertEqual(mapping.fileExtensions, [])
    }

    // MARK: - File type init

    func testInit_withFileType_isNotCustom() {
        let mapping = Mapping(path: testURL, fileType: DefinedTypes.image)
        XCTAssertFalse(mapping.isCustom)
        XCTAssertNotNil(mapping.fileType)
        XCTAssertNil(mapping.fileExtensions)
        XCTAssertEqual(mapping.path, testURL)
    }

    func testInit_withFileType_preservesExplicitID() {
        let fixedID = UUID()
        let mapping = Mapping(id: fixedID, path: testURL, fileType: DefinedTypes.video)
        XCTAssertEqual(mapping.id, fixedID)
        XCTAssertFalse(mapping.isCustom)
    }

    func testInit_withFileType_displaysCorrectInfo() {
        let mapping = Mapping(path: testURL, fileType: DefinedTypes.image)
        XCTAssertEqual(mapping.fileType?.displayString, "Image")
        XCTAssertEqual(mapping.fileType?.symbol, "camera")
    }

    // MARK: - Codable round-trip

    func testCodable_extensionMapping_roundTrip() throws {
        let original = Mapping(path: testURL, fileExtensions: ["swift", "m", "h"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Mapping.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.path, original.path)
        XCTAssertEqual(decoded.fileExtensions, original.fileExtensions)
        XCTAssertTrue(decoded.isCustom)
        XCTAssertNil(decoded.fileType)
    }

    func testCodable_fileTypeMapping_roundTrip() throws {
        let original = Mapping(path: testURL, fileType: DefinedTypes.audio)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Mapping.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.path, original.path)
        XCTAssertFalse(decoded.isCustom)
        XCTAssertNil(decoded.fileExtensions)
        XCTAssertEqual(decoded.fileType?.displayString, original.fileType?.displayString)
    }

    // MARK: - Hashable

    func testHashable_equalMappings() {
        let id = UUID()
        let a = Mapping(id: id, path: testURL, fileExtensions: ["pdf"])
        let b = Mapping(id: id, path: testURL, fileExtensions: ["pdf"])
        XCTAssertEqual(a, b)
    }
}
