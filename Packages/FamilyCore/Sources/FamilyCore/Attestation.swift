import Foundation

public enum AttestationKind: String, Codable, Sendable, CaseIterable {
    /// The owner attests that the invitee is their spouse.
    case spouseInvite
    /// The invitee attests on their own device that they join voluntarily.
    case spouseAcceptance
    /// A parent attests guardianship of a teen aged 13 or older.
    case guardianOfTeen
}

public enum Attestation {
    /// Bump when any wording changes, so stored records show which text was shown.
    public static let wordingVersion = 1

    /// Draft wording for legal review.
    public static func text(_ kind: AttestationKind, name: String) -> String {
        switch kind {
        case .spouseInvite:
            "I attest that \(name) is my spouse and is joining with their own device and consent."
        case .spouseAcceptance:
            "I attest that I am the spouse of \(name) and am joining this family voluntarily."
        case .guardianOfTeen:
            "I attest that I am the parent or legal guardian of \(name), who is 13 or older."
        }
    }
}

/// One yes or no answer. Stored in the family's encrypted store, never sent to the publisher.
public struct AttestationRecord: Codable, Sendable, Equatable {
    public let kind: AttestationKind
    public let subjectName: String
    public let text: String
    public let wordingVersion: Int
    public let accepted: Bool
    public let date: Date

    public init(kind: AttestationKind, subjectName: String, accepted: Bool, date: Date = Date()) {
        self.kind = kind
        self.subjectName = subjectName
        self.text = Attestation.text(kind, name: subjectName)
        self.wordingVersion = Attestation.wordingVersion
        self.accepted = accepted
        self.date = date
    }

    /// A no stops the app on this device.
    public var allowsContinuing: Bool { accepted }
}
