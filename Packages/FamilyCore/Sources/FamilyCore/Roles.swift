/// A CloudKit zone. Parents share both; teens see only the family zone.
public enum Zone: String, Codable, Sendable, CaseIterable {
    case family
    case parents
}

/// A member's role in one family. See docs/design.md, "Members and roles".
public enum Role: String, Codable, Sendable, CaseIterable {
    case owner
    case spouse
    case teen

    /// Teens are read only. CloudKit enforces this with `.readOnly` share permission.
    public var canWrite: Bool { self != .teen }

    /// Teens connect no sources and ingest nothing.
    public var canConnectSources: Bool { self != .teen }

    public func canRead(_ zone: Zone) -> Bool {
        switch zone {
        case .family: true
        case .parents: self != .teen
        }
    }
}
