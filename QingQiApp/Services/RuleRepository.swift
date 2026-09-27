import Foundation

public protocol RuleRepository: Sendable {
    func currentPack() async -> [RulePackSummary]
}

public struct DemoRuleRepository: RuleRepository, Sendable {
    public init() {}
    public func currentPack() async -> [RulePackSummary] { RulePackSummary.examples }
}
