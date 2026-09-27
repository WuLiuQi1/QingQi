import Foundation

public enum FilterState: Equatable, Sendable {
    case notConfigured, requestingAuthorization, requiresApproval
    case configuredEnabled, configuredDisabled, degraded, unsupported
}

public struct FilterSnapshot: Equatable, Sendable {
    public let state: FilterState
    public let appliedRuleVersion: String?
    public let statusEvidence: String
    public init(state: FilterState, appliedRuleVersion: String? = nil, statusEvidence: String) {
        self.state = state; self.appliedRuleVersion = appliedRuleVersion; self.statusEvidence = statusEvidence
    }
}

public enum ConfigurationAttempt: Equatable, Sendable {
    case waitingForSystemApproval, savedAndNeedsReadback, readBack(FilterSnapshot)
}

public enum FilterEngineError: Error, LocalizedError, Sendable {
    case unavailable, operationFailed(String)
    public var errorDescription: String? {
        switch self { case .unavailable: return "当前系统过滤能力尚未接入"; case .operationFailed(let message): return message }
    }
}

public struct RulePackSummary: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let key: String
    public let detail: String
    public init(id: String, title: String, key: String, detail: String) {
        self.id = id; self.title = title; self.key = key; self.detail = detail
    }
    public static let examples = [
        RulePackSummary(id: "domain", title: "广告域名示例", key: "ads.example.com", detail: "保留域名示例，不是生产规则。"),
        RulePackSummary(id: "url", title: "URL 组成项示例", key: "media.example.net/ad/", detail: "需要按 Apple URL 规则规范化并验证。"),
        RulePackSummary(id: "exception", title: "误拦截修复示例", key: "account.example.org", detail: "只展示发布审计概念，不代表按 App 放行。")
    ]
}

public enum AppOperationState: Equatable, Sendable {
    case idle, loading, failed(String)
}

public struct FeedbackDraft: Equatable, Sendable {
    public enum Category: String, CaseIterable, Sendable { case adStillVisible = "广告仍出现"; case pageBroken = "正常页面异常"; case cannotEnable = "无法启用"; case other = "其他" }
    public var appName = ""
    public var appVersion = ""
    public var category: Category = .other
    public var ruleVersion = "示例 v0.1"
    public var systemVersion = "未读取"
    public var diagnosticSummary = ""
    public var description = ""
}
