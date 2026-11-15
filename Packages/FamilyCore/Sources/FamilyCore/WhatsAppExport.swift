import Foundation

/// One message from a WhatsApp "Export Chat" `_chat.txt` file.
public struct WhatsAppMessage: Hashable, Sendable {
    /// The timestamp exactly as written in the export.
    public let timestamp: String
    /// The parsed timestamp, or nil when the format is not recognized.
    public let date: Date?
    public let sender: String
    public var body: String
}

/// Day/month order depends on the exporting phone's region, so the user picks it once.
public enum DateOrder: Sendable {
    case dayFirst
    case monthFirst
}

/// Parses the iOS export format: `[15/11/2026, 14:03:22] Alice: text`.
/// Lines without a header continue the previous message.
public struct WhatsAppExportParser: Sendable {
    public let order: DateOrder
    public let timeZone: TimeZone

    public init(order: DateOrder, timeZone: TimeZone = .current) {
        self.order = order
        self.timeZone = timeZone
    }

    public func parse(_ text: String) -> [WhatsAppMessage] {
        var messages: [WhatsAppMessage] = []
        var formatters: [String: DateFormatter] = [:]
        for rawLine in text.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline) {
            let line = Self.clean(String(rawLine))
            if let header = Self.header(line) {
                let date = parseDate(header.stamp, cache: &formatters)
                messages.append(WhatsAppMessage(timestamp: header.stamp, date: date, sender: header.sender, body: header.body))
            } else if !messages.isEmpty {
                messages[messages.count - 1].body += "\n" + line
            }
        }
        return messages.map { message in
            var trimmed = message
            trimmed.body = message.body.trimmingCharacters(in: .newlines)
            return trimmed
        }
    }

    /// Drops exact duplicates and messages at or before `last`. Undated messages are kept.
    public static func incremental(_ messages: [WhatsAppMessage], after last: Date?) -> [WhatsAppMessage] {
        var seen = Set<WhatsAppMessage>()
        return messages.filter { message in
            if let last, let date = message.date, date <= last { return false }
            return seen.insert(message).inserted
        }
    }

    /// Removes direction marks and turns narrow and non-breaking spaces into plain spaces.
    static func clean(_ line: String) -> String {
        var out = String.UnicodeScalarView()
        for scalar in line.unicodeScalars {
            switch scalar.value {
            case 0x200E, 0x200F: continue
            case 0x00A0, 0x202F: out.append(" ")
            default: out.append(scalar)
            }
        }
        return String(out)
    }

    static func header(_ line: String) -> (stamp: String, sender: String, body: String)? {
        guard line.hasPrefix("["), let close = line.firstIndex(of: "]") else { return nil }
        let stamp = String(line[line.index(after: line.startIndex)..<close])
        let rest = line[line.index(after: close)...]
        guard rest.hasPrefix(" ") else { return nil }
        let afterSpace = rest.dropFirst()
        guard let colon = afterSpace.range(of: ": ") else { return nil }
        let sender = String(afterSpace[..<colon.lowerBound])
        let body = String(afterSpace[colon.upperBound...])
        guard stamp.contains(where: \.isNumber), stamp.contains(","), !sender.isEmpty else { return nil }
        return (stamp, sender, body)
    }

    func parseDate(_ stamp: String, cache: inout [String: DateFormatter]) -> Date? {
        for pattern in patterns(for: stamp) {
            let formatter: DateFormatter
            if let cached = cache[pattern] {
                formatter = cached
            } else {
                formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = timeZone
                formatter.dateFormat = pattern
                formatter.isLenient = false
                cache[pattern] = formatter
            }
            if let date = formatter.date(from: stamp) { return date }
        }
        return nil
    }

    /// Picks the year width from the stamp itself, so a two-digit year never parses as year 26.
    func patterns(for stamp: String) -> [String] {
        let datePart = stamp.split(separator: ",").first ?? ""
        let separator = datePart.contains(".") ? "." : "/"
        let yearDigits = datePart.split(whereSeparator: { $0 == "/" || $0 == "." }).last?.count ?? 0
        let year = yearDigits == 4 ? "yyyy" : "yy"
        let date = order == .dayFirst ? "d\(separator)M\(separator)\(year)" : "M\(separator)d\(separator)\(year)"
        let upper = stamp.uppercased()
        let times = upper.contains("AM") || upper.contains("PM") ? ["h:mm:ss a", "h:mm a"] : ["H:mm:ss", "H:mm"]
        return times.map { "\(date), \($0)" }
    }
}
