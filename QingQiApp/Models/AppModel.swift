import Foundation
import Combine

@MainActor
final class QingQiAppModel: ObservableObject {
    @Published private(set) var snapshot = FilterSnapshot(state: .unsupported, statusEvidence: "尚未在 Apple SDK 环境读取")
    @Published private(set) var message = "真实系统状态尚未可用"
    @Published private(set) var operation: AppOperationState = .idle
    @Published private(set) var events: [ConfigurationEvent] = []
    @Published var feedback = FeedbackDraft()
    private let engine: any FilterEngine
    private let eventStore: any ConfigurationEventStore
    private let feedbackStore: any FeedbackDraftStore

    init(engine: any FilterEngine = UnavailableFilterEngine(), eventStore: any ConfigurationEventStore = InMemoryConfigurationEventStore(), feedbackStore: any FeedbackDraftStore = InMemoryFeedbackDraftStore()) {
        self.engine = engine; self.eventStore = eventStore; self.feedbackStore = feedbackStore
    }

    func refresh() async {
        operation = .loading
        do { snapshot = try await engine.readSnapshot(); message = snapshot.statusEvidence; operation = .idle }
        catch { snapshot = FilterSnapshot(state: .unsupported, statusEvidence: error.localizedDescription); message = error.localizedDescription; operation = .failed(error.localizedDescription) }
    }

    func requestEnable() async {
        operation = .loading
        do {
            _ = try await engine.requestEnable()
            await record("开始配置 / 等待系统确认")
            await refresh()
        } catch { message = error.localizedDescription; operation = .failed(error.localizedDescription) }
    }

    func disable() async {
        operation = .loading
        do { snapshot = try await engine.disable(); message = snapshot.statusEvidence; await record("用户关闭过滤") ; operation = .idle }
        catch { message = error.localizedDescription; operation = .failed(error.localizedDescription) }
    }

    func removeConfiguration() async {
        operation = .loading
        do {
            snapshot = try await engine.removeConfiguration()
            message = snapshot.statusEvidence
            await record("移除系统过滤配置")
            operation = .idle
        } catch {
            message = error.localizedDescription
            operation = .failed(error.localizedDescription)
        }
    }

    func record(_ name: String) async {
        await eventStore.append(ConfigurationEvent(name: name)); events = await eventStore.events()
    }

    func loadLocalData() async {
        events = await eventStore.events(); feedback = await feedbackStore.load()
    }

    func saveFeedback() async { await feedbackStore.save(feedback); await record("保存反馈草稿") }

    func clearEvents() async { await eventStore.removeAll(); events = [] }

    var isBusy: Bool { if case .loading = operation { return true }; return false }
    var canClaimFiltering: Bool { snapshot.state == .configuredEnabled && snapshot.appliedRuleVersion != nil }
    var stateTitle: String {
        switch snapshot.state { case .notConfigured: return "尚未配置"; case .requestingAuthorization: return "正在准备配置"; case .requiresApproval: return "等待系统确认"; case .configuredEnabled: return "配置已启用"; case .configuredDisabled: return "过滤已关闭"; case .degraded: return "自检发现异常"; case .unsupported: return "当前系统不支持" }
    }
}
