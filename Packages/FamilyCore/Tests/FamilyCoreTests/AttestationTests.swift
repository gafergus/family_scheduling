import XCTest
@testable import FamilyCore

final class AttestationTests: XCTestCase {
    func testRecordStoresExactWordingAndVersion() {
        let record = AttestationRecord(kind: .spouseInvite, subjectName: "Sam", accepted: true)
        XCTAssertEqual(record.text, "I attest that Sam is my spouse and is joining with their own device and consent.")
        XCTAssertEqual(record.wordingVersion, Attestation.wordingVersion)
        XCTAssertTrue(record.allowsContinuing)
    }

    func testNoStopsTheApp() {
        let record = AttestationRecord(kind: .guardianOfTeen, subjectName: "Ava", accepted: false)
        XCTAssertFalse(record.allowsContinuing)
    }

    func testRecordRoundTripsThroughJSON() throws {
        let record = AttestationRecord(kind: .spouseAcceptance, subjectName: "Sam", accepted: true, date: Date(timeIntervalSince1970: 0))
        let decoded = try JSONDecoder().decode(AttestationRecord.self, from: JSONEncoder().encode(record))
        XCTAssertEqual(decoded, record)
    }
}
