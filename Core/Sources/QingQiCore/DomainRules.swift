import Foundation

/// Validation is intentionally limited to ASCII/Punycode input.
/// This is rule data preparation, not a Network Extension or a full URL parser.
public enum DomainRuleError: Error, Equatable, Sendable {
    case invalidDomain(String)
}

public struct DomainName: Hashable, Comparable, Sendable {
    public let value: String

    public init(_ input: String) throws {
        var candidate = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard candidate.unicodeScalars.allSatisfy({ $0.isASCII }) else {
            throw DomainRuleError.invalidDomain(input)
        }
        candidate = candidate.lowercased()
        if candidate.hasSuffix(".") { candidate.removeLast() }
        let labels = candidate.split(separator: ".", omittingEmptySubsequences: false)
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789-".utf8)
        let letters = Set("abcdefghijklmnopqrstuvwxyz".utf8)

        guard !candidate.isEmpty, candidate.utf8.count <= 253, labels.count >= 2,
              labels.allSatisfy({ label in
                  !label.isEmpty && label.utf8.count <= 63 &&
                  label.first != "-" && label.last != "-" &&
                  label.utf8.allSatisfy({ allowed.contains($0) })
              }),
              let last = labels.last,
              last.utf8.contains(where: { letters.contains($0) })
        else {
            throw DomainRuleError.invalidDomain(input)
        }
        self.value = candidate
    }

    public static func < (lhs: DomainName, rhs: DomainName) -> Bool {
        lhs.value < rhs.value
    }

    /// Dot-boundary matching: "notexample.com" is not under "example.com".
    public func isEqualToOrSubdomain(of other: DomainName) -> Bool {
        value == other.value || value.hasSuffix("." + other.value)
    }
}

public struct SuppressedDomainRule: Equatable, Sendable {
    public let blocked: String
    public let overlappingExclusions: [String]
}

public struct CompiledDomainRules: Equatable, Sendable {
    public let blockedDomains: [String]
    public let exclusions: [String]
    public let suppressed: [SuppressedDomainRule]

    /// Test helper only; iOS production filtering is performed by the OS.
    public func matchesBlockedHost(_ input: String) throws -> Bool {
        let host = try DomainName(input)
        return try blockedDomains.contains { raw in
            host.isEqualToOrSubdomain(of: try DomainName(raw))
        }
    }
}

public enum DomainRuleCompiler {
    /// Conservative publisher-level conflict handling.
    /// If either domain contains the other, suppress the broad block entirely.
    /// This intentionally reduces coverage rather than claiming an unrepresentable exception.
    public static func compile(
        blocked: [String],
        exclusions: [String]
    ) throws -> CompiledDomainRules {
        let blocks = try Set(blocked.map(DomainName.init)).sorted()
        let allows = try Set(exclusions.map(DomainName.init)).sorted()
        var accepted: [String] = []
        var suppressed: [SuppressedDomainRule] = []

        for block in blocks {
            let conflicts = allows.filter {
                block.isEqualToOrSubdomain(of: $0) || $0.isEqualToOrSubdomain(of: block)
            }
            if conflicts.isEmpty {
                accepted.append(block.value)
            } else {
                suppressed.append(
                    SuppressedDomainRule(
                        blocked: block.value,
                        overlappingExclusions: conflicts.map(\.value)
                    )
                )
            }
        }

        return CompiledDomainRules(
            blockedDomains: accepted,
            exclusions: allows.map(\.value),
            suppressed: suppressed
        )
    }
}
