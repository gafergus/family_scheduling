/// The age band reported by the Declared Age Range API, reduced to what the app needs.
public enum AgeBand: Sendable, Equatable {
    case under13
    case teen
    case adult
    /// The user declined to share an age range.
    case undeclared
}

public enum AgeGateDecision: Sendable, Equatable {
    case blocked
    case teenReadOnly
    case adult
}

public enum AgeGate {
    /// Under 13 is blocked. A declined age range is treated as a self-declared adult.
    public static func decide(_ band: AgeBand) -> AgeGateDecision {
        switch band {
        case .under13: .blocked
        case .teen: .teenReadOnly
        case .adult, .undeclared: .adult
        }
    }

    /// Only adults may create and own a family.
    public static func canOwnFamily(_ band: AgeBand) -> Bool {
        decide(band) == .adult
    }
}
