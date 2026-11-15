import XCTest
@testable import FamilyCore

final class CalendarBridgeTests: XCTestCase {
    func testAppEventsAreRecognizedByMarker() {
        let notes = "encrypted-block\n" + CalendarBridge.marker(for: "abc-123")
        XCTAssertEqual(CalendarBridge.origin(notes: notes), .app(id: "abc-123"))
        XCTAssertFalse(CalendarBridge.needsAdultConfirmation(.app(id: "abc-123")))
    }

    func testWallEventsNeedAdultConfirmation() {
        XCTAssertEqual(CalendarBridge.origin(notes: nil), .wall)
        XCTAssertEqual(CalendarBridge.origin(notes: "Soccer at 5"), .wall)
        XCTAssertEqual(CalendarBridge.origin(notes: CalendarBridge.markerPrefix + "]"), .wall)
        XCTAssertTrue(CalendarBridge.needsAdultConfirmation(.wall))
        XCTAssertFalse(CalendarBridge.canConfirm(.teen))
        XCTAssertTrue(CalendarBridge.canConfirm(.spouse))
    }
}
