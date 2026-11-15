import XCTest
@testable import FamilyCore

final class RolesTests: XCTestCase {
    func testTeenIsReadOnlyAndFamilyZoneOnly() {
        XCTAssertFalse(Role.teen.canWrite)
        XCTAssertFalse(Role.teen.canConnectSources)
        XCTAssertTrue(Role.teen.canRead(.family))
        XCTAssertFalse(Role.teen.canRead(.parents))
    }

    func testAdultsReadAndWriteBothZones() {
        for role in [Role.owner, .spouse] {
            XCTAssertTrue(role.canWrite)
            XCTAssertTrue(role.canConnectSources)
            XCTAssertTrue(role.canRead(.family))
            XCTAssertTrue(role.canRead(.parents))
        }
    }

    func testAgeGate() {
        XCTAssertEqual(AgeGate.decide(.under13), .blocked)
        XCTAssertEqual(AgeGate.decide(.teen), .teenReadOnly)
        XCTAssertEqual(AgeGate.decide(.adult), .adult)
        XCTAssertEqual(AgeGate.decide(.undeclared), .adult)
        XCTAssertFalse(AgeGate.canOwnFamily(.teen))
        XCTAssertFalse(AgeGate.canOwnFamily(.under13))
        XCTAssertTrue(AgeGate.canOwnFamily(.adult))
    }
}
