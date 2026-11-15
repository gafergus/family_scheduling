import XCTest
@testable import FamilyCore

final class WhatsAppExportTests: XCTestCase {
    let utc = TimeZone(identifier: "UTC")!

    func components(_ date: Date?) -> DateComponents? {
        guard let date else { return nil }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    }

    func testDayFirst24Hour() {
        let text = "[15/11/2026, 14:03:22] Coach Dana: Practice moved to 5pm\n"
        let messages = WhatsAppExportParser(order: .dayFirst, timeZone: utc).parse(text)
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(messages[0].sender, "Coach Dana")
        XCTAssertEqual(messages[0].body, "Practice moved to 5pm")
        let c = components(messages[0].date)
        XCTAssertEqual(c?.year, 2026)
        XCTAssertEqual(c?.month, 11)
        XCTAssertEqual(c?.day, 15)
        XCTAssertEqual(c?.hour, 14)
    }

    func testMonthFirst12HourWithNarrowSpaceAndTwoDigitYear() {
        let text = "[11/15/26, 2:03:22\u{202F}PM] Sam: Pick up at 3"
        let messages = WhatsAppExportParser(order: .monthFirst, timeZone: utc).parse(text)
        XCTAssertEqual(messages.count, 1)
        let c = components(messages[0].date)
        XCTAssertEqual(c?.year, 2026)
        XCTAssertEqual(c?.month, 11)
        XCTAssertEqual(c?.day, 15)
        XCTAssertEqual(c?.hour, 14)
    }

    func testMultilineAndDirectionMarks() {
        let text = """
        \u{200E}[15/11/2026, 09:00:00] Sam: Shopping list:
        milk
        [eggs]
        [15/11/2026, 09:01:00] Alex: Got it
        """
        let messages = WhatsAppExportParser(order: .dayFirst, timeZone: utc).parse(text)
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages[0].body, "Shopping list:\nmilk\n[eggs]")
        XCTAssertEqual(messages[1].sender, "Alex")
    }

    func testIncrementalDropsOldAndDuplicateMessages() {
        let text = """
        [15/11/2026, 09:00:00] Sam: old
        [15/11/2026, 10:00:00] Sam: new
        [15/11/2026, 10:00:00] Sam: new
        """
        let parser = WhatsAppExportParser(order: .dayFirst, timeZone: utc)
        let messages = parser.parse(text)
        let cutoff = messages[0].date
        let fresh = WhatsAppExportParser.incremental(messages, after: cutoff)
        XCTAssertEqual(fresh.map(\.body), ["new"])
    }

    func testUnparseableStampKeepsMessageWithoutDate() {
        let messages = WhatsAppExportParser(order: .dayFirst, timeZone: utc).parse("[Monday, 9ish] Sam: hi")
        XCTAssertEqual(messages.count, 1)
        XCTAssertNil(messages[0].date)
    }
}
