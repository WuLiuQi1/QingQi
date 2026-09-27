import Foundation

#if canImport(NetworkExtension)
import NetworkExtension

/// The production boundary for Apple's iOS 26 URL Filter API.
///
/// This type deliberately reads the PIR settings from UserDefaults at call time so
/// the Settings screen can configure a test server without putting credentials in
/// source control. It never reports success from a local mock.
@available(iOS 26.0, *)
public struct NativeURLFilterEngine: FilterEngine, Sendable {
    private let manager: NEURLFilterManager

    public init(manager: NEURLFilterManager = .shared) {
        self.manager = manager
    }

    public func readSnapshot() async throws -> FilterSnapshot {
        try await manager.loadFromPreferences()
        return snapshot(for: await manager.status)
    }

    public func requestEnable() async throws -> ConfigurationAttempt {
        let settings = try Configuration.loadFromDefaults()
        try manager.setConfiguration(
            pirServerURL: settings.pirServerURL,
            pirPrivacyPassIssuerURL: settings.pirPrivacyPassIssuerURL,
            pirAuthenticationToken: settings.pirAuthenticationToken,
            controlProviderBundleIdentifier: settings.controlProviderBundleIdentifier
        )
        manager.prefilterFetchInterval = settings.prefilterFetchInterval
        manager.shouldFailClosed = settings.shouldFailClosed
        manager.isEnabled = true
        try await manager.saveToPreferences()
        return .savedAndNeedsReadback
    }

    public func disable() async throws -> FilterSnapshot {
        try await manager.loadFromPreferences()
        manager.isEnabled = false
        try await manager.saveToPreferences()
        try await manager.loadFromPreferences()
        return snapshot(for: await manager.status)
    }

    public func removeConfiguration() async throws -> FilterSnapshot {
        try await manager.removeFromPreferences()
        return FilterSnapshot(state: .notConfigured, statusEvidence: "已调用 NEURLFilterManager.removeFromPreferences()")
    }

    private func snapshot(for status: NEURLFilterManager.Status) -> FilterSnapshot {
        switch status {
        case .invalid:
            return FilterSnapshot(state: .notConfigured, statusEvidence: "系统状态：invalid（未配置或配置无效）")
        case .starting:
            return FilterSnapshot(state: .requiresApproval, statusEvidence: "系统状态：starting（等待系统确认或启动）")
        case .running:
            return FilterSnapshot(state: .configuredEnabled, appliedRuleVersion: "系统 URL Filter 配置", statusEvidence: "系统状态：running（需用受控 URL 继续验证）")
        case .stopping:
            return FilterSnapshot(state: .configuredDisabled, statusEvidence: "系统状态：stopping")
        case .stopped:
            return FilterSnapshot(state: .configuredDisabled, statusEvidence: "系统状态：stopped")
        @unknown default:
            return FilterSnapshot(state: .degraded, statusEvidence: "系统状态：未知枚举值")
        }
    }
}

@available(iOS 26.0, *)
private struct Configuration: Sendable {
    let pirServerURL: URL
    let pirPrivacyPassIssuerURL: URL?
    let pirAuthenticationToken: String
    let controlProviderBundleIdentifier: String
    let prefilterFetchInterval: TimeInterval
    let shouldFailClosed: Bool

    static func loadFromDefaults() throws -> Configuration {
        let defaults = UserDefaults.standard
        guard let value = defaults.string(forKey: "qingqi.pirServerURL"),
              let serverURL = URL(string: value),
              let scheme = serverURL.scheme, scheme == "http" || scheme == "https",
              let token = defaults.string(forKey: "qingqi.pirAuthenticationToken"),
              !token.isEmpty else {
            throw FilterEngineError.operationFailed("请先在设置中填写 PIR 服务地址和认证 token")
        }

        let issuer = defaults.string(forKey: "qingqi.pirPrivacyPassIssuerURL").flatMap(URL.init(string:))
        let appBundle = Bundle.main.bundleIdentifier ?? "com.example.qingqi"
        return Configuration(
            pirServerURL: serverURL,
            pirPrivacyPassIssuerURL: issuer,
            pirAuthenticationToken: token,
            controlProviderBundleIdentifier: "\(appBundle).urlfilter",
            prefilterFetchInterval: max(defaults.double(forKey: "qingqi.prefilterFetchInterval"), 2700),
            shouldFailClosed: defaults.object(forKey: "qingqi.shouldFailClosed") as? Bool ?? true
        )
    }
}
#endif
