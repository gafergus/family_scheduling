import Foundation

/// Rules for the shared Google calendar that a wall display such as eCalendar also syncs.
/// See docs/design.md, "eCalendar and other wall displays".
public enum CalendarBridge {
    public static let markerPrefix = "[family_scheduling:"

    public enum Origin: Equatable, Sendable {
        /// Written by this app. Skip it on import to avoid an echo loop.
        case app(id: String)
        /// Created on the wall or elsewhere. Unattributed.
        case wall
    }

    /// The marker the app appends to the notes of every event it writes.
    public static func marker(for id: String) -> String {
        "\(markerPrefix)\(id)]"
    }

    public static func appEventID(in notes: String?) -> String? {
        guard let notes, let start = notes.range(of: markerPrefix) else { return nil }
        let rest = notes[start.upperBound...]
        guard let end = rest.firstIndex(of: "]") else { return nil }
        let id = String(rest[..<end])
        return id.isEmpty ? nil : id
    }

    public static func origin(notes: String?) -> Origin {
        appEventID(in: notes).map { .app(id: $0) } ?? .wall
    }

    /// Wall events stay proposals until an adult confirms them. Anyone at the wall can add one.
    public static func needsAdultConfirmation(_ origin: Origin) -> Bool {
        origin == .wall
    }

    public static func canConfirm(_ role: Role) -> Bool {
        role.canWrite
    }
}
