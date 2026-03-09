import XCTest
@testable import StoreAway

class UserDataHandlerTests: XCTestCase {

    var handler: UserDataHandler!

    // Keys written by UserDataHandler
    private let optionKeys = ["DetailView", "CopyOnly", "AskEveryFileDialog", "keepFolderStructure",
                              "autoOrganize", "launchAtLogin", "showDockIcon", "showMenuBarIcon"]
    private let dataKeys = ["WatchedFolders", "Mapping", "OperationHistory"]

    override func setUp() {
        super.setUp()
        handler = UserDataHandler()
        cleanDefaults()
    }

    override func tearDown() {
        cleanDefaults()
        super.tearDown()
    }

    private func cleanDefaults() {
        (optionKeys + dataKeys).forEach { UserDefaults.standard.removeObject(forKey: $0) }
        UserDefaults.standard.synchronize()
    }

    // MARK: - Options

    func testOptions_defaultValues() {
        // After removing all keys, loadOptions should return default values
        let options = handler.loadOptions()
        XCTAssertFalse(options.detailViewEnabled)
        XCTAssertFalse(options.copyObjects)
        XCTAssertFalse(options.askEveryFile)
        XCTAssertTrue(options.keepFolderStructure, "keepFolderStructure should default to true")
        XCTAssertFalse(options.autoOrganize)
        XCTAssertFalse(options.launchAtLogin)
        XCTAssertTrue(options.showDockIcon, "showDockIcon should default to true")
        XCTAssertFalse(options.showMenuBarIcon)
    }

    func testOptions_saveAndLoad_roundTrip() {
        let original = Options(
            detailViewEnabled: true,
            copyObjects: false,
            askEveryFile: true,
            keepFolderStructure: false,
            autoOrganize: true,
            launchAtLogin: false,
            showDockIcon: true,
            showMenuBarIcon: true
        )
        handler.saveOptions(options: original)
        let loaded = handler.loadOptions()

        XCTAssertEqual(loaded.detailViewEnabled, original.detailViewEnabled)
        XCTAssertEqual(loaded.copyObjects, original.copyObjects)
        XCTAssertEqual(loaded.askEveryFile, original.askEveryFile)
        XCTAssertEqual(loaded.keepFolderStructure, original.keepFolderStructure)
        XCTAssertEqual(loaded.autoOrganize, original.autoOrganize)
        XCTAssertEqual(loaded.launchAtLogin, original.launchAtLogin)
        XCTAssertEqual(loaded.showDockIcon, original.showDockIcon)
        XCTAssertEqual(loaded.showMenuBarIcon, original.showMenuBarIcon)
    }

    func testOptions_saveAndLoad_allTrue() {
        let allTrue = Options(
            detailViewEnabled: true,
            copyObjects: true,
            askEveryFile: true,
            keepFolderStructure: true,
            autoOrganize: true,
            launchAtLogin: true,
            showDockIcon: true,
            showMenuBarIcon: true
        )
        handler.saveOptions(options: allTrue)
        let loaded = handler.loadOptions()

        XCTAssertTrue(loaded.detailViewEnabled)
        XCTAssertTrue(loaded.copyObjects)
        XCTAssertTrue(loaded.askEveryFile)
        XCTAssertTrue(loaded.keepFolderStructure)
        XCTAssertTrue(loaded.autoOrganize)
        XCTAssertTrue(loaded.launchAtLogin)
        XCTAssertTrue(loaded.showDockIcon)
        XCTAssertTrue(loaded.showMenuBarIcon)
    }

    // MARK: - Watched Folders

    func testWatchedFolders_emptyByDefault() {
        let loaded = handler.loadURL()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testWatchedFolders_saveAndLoad() {
        let urls = [
            URL(fileURLWithPath: "/tmp/folder1"),
            URL(fileURLWithPath: "/tmp/folder2")
        ]
        handler.saveWatchedFoldersToUserData(current: urls)
        let loaded = handler.loadURL()

        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].path, "/tmp/folder1")
        XCTAssertEqual(loaded[1].path, "/tmp/folder2")
    }

    func testWatchedFolders_overwrite() {
        handler.saveWatchedFoldersToUserData(current: [URL(fileURLWithPath: "/tmp/old")])
        handler.saveWatchedFoldersToUserData(current: [URL(fileURLWithPath: "/tmp/new")])
        let loaded = handler.loadURL()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].path, "/tmp/new")
    }

    // MARK: - Mapping

    func testMapping_emptyByDefault() {
        let loaded = handler.loadMapping()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testMapping_saveAndLoad_extensionMapping() {
        let url = URL(fileURLWithPath: "/tmp/dest")
        let original = [Mapping(path: url, fileExtensions: ["pdf", "doc"])]
        handler.saveMappingToUserData(current: original)
        let loaded = handler.loadMapping()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].id, original[0].id)
        XCTAssertEqual(loaded[0].fileExtensions, ["pdf", "doc"])
        XCTAssertTrue(loaded[0].isCustom)
    }

    func testMapping_saveAndLoad_multipleEntries() {
        let mappings = [
            Mapping(path: URL(fileURLWithPath: "/tmp/images"), fileType: DefinedTypes.image),
            Mapping(path: URL(fileURLWithPath: "/tmp/vids"), fileType: DefinedTypes.video),
            Mapping(path: URL(fileURLWithPath: "/tmp/custom"), fileExtensions: ["xyz"])
        ]
        handler.saveMappingToUserData(current: mappings)
        let loaded = handler.loadMapping()

        XCTAssertEqual(loaded.count, 3)
        XCTAssertFalse(loaded[0].isCustom)
        XCTAssertFalse(loaded[1].isCustom)
        XCTAssertTrue(loaded[2].isCustom)
    }

    // MARK: - History

    func testHistory_emptyByDefault() {
        let loaded = handler.loadHistory()
        XCTAssertTrue(loaded.isEmpty)
    }

    func testHistory_saveAndLoad_singleRecord() {
        let record = OperationRecord(date: Date(), filesMoved: 3, filesCopied: 1, triggerSource: .manual)
        handler.saveHistory(history: [record])
        let loaded = handler.loadHistory()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].id, record.id)
        XCTAssertEqual(loaded[0].filesMoved, 3)
        XCTAssertEqual(loaded[0].filesCopied, 1)
        XCTAssertEqual(loaded[0].triggerSource, .manual)
    }

    func testHistory_saveAndLoad_multipleRecords() {
        let records = [
            OperationRecord(date: Date(), filesMoved: 5, filesCopied: 0, triggerSource: .menuBar),
            OperationRecord(date: Date(), filesMoved: 0, filesCopied: 2, triggerSource: .autoWatch)
        ]
        handler.saveHistory(history: records)
        let loaded = handler.loadHistory()

        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].triggerSource, .menuBar)
        XCTAssertEqual(loaded[1].triggerSource, .autoWatch)
    }

    func testHistory_overwrite() {
        let first = [OperationRecord(date: Date(), filesMoved: 1, filesCopied: 0, triggerSource: .manual)]
        let second = [OperationRecord(date: Date(), filesMoved: 9, filesCopied: 9, triggerSource: .menuBar)]
        handler.saveHistory(history: first)
        handler.saveHistory(history: second)
        let loaded = handler.loadHistory()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].filesMoved, 9)
    }
}
