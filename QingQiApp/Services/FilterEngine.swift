import Foundation

public protocol FilterEngine: Sendable {
    func readSnapshot() async throws -> FilterSnapshot
    func requestEnable() async throws -> ConfigurationAttempt
    func disable() async throws -> FilterSnapshot
    func removeConfiguration() async throws -> FilterSnapshot
}

/// DEBUG/Preview only. It never changes device configuration or network traffic.
#if DEBUG
public actor MockFilterEngine: FilterEngine {
    private var snapshot = FilterSnapshot(state: .notConfigured, statusEvidence: "DEBUG 演示，没有系统证据")
    public init() {}
    public func readSnapshot() async throws -> FilterSnapshot { snapshot }
    public func requestEnable() async throws -> ConfigurationAttempt {
        snapshot = FilterSnapshot(state: .configuredEnabled, appliedRuleVersion: "示例 v0.1", statusEvidence: "DEBUG 演示，没有系统证据")
        return .readBack(snapshot)
    }
    public func disable() async throws -> FilterSnapshot { snapshot = FilterSnapshot(state: .configuredDisabled, statusEvidence: "DEBUG 演示，没有系统证据"); return snapshot }
    public func removeConfiguration() async throws -> FilterSnapshot { snapshot = FilterSnapshot(state: .notConfigured, statusEvidence: "DEBUG 演示，没有系统证据"); return snapshot }
}
#endif

public struct UnavailableFilterEngine: FilterEngine, Sendable {
    public init() {}
    public func readSnapshot() async throws -> FilterSnapshot { throw FilterEngineError.unavailable }
    public func requestEnable() async throws -> ConfigurationAttempt { throw FilterEngineError.unavailable }
    public func disable() async throws -> FilterSnapshot { throw FilterEngineError.unavailable }
    public func removeConfiguration() async throws -> FilterSnapshot { throw FilterEngineError.unavailable }
}
