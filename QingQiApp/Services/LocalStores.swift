import Foundation

public struct ConfigurationEvent: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let date: Date
    public let name: String
    public init(id: UUID = UUID(), date: Date = .now, name: String) { self.id = id; self.date = date; self.name = name }
}

public protocol ConfigurationEventStore: Sendable {
    func append(_ event: ConfigurationEvent) async
    func events() async -> [ConfigurationEvent]
    func removeAll() async
}

public actor InMemoryConfigurationEventStore: ConfigurationEventStore {
    private var values: [ConfigurationEvent] = []
    public init() {}
    public func append(_ event: ConfigurationEvent) { values.insert(event, at: 0) }
    public func events() -> [ConfigurationEvent] { values }
    public func removeAll() { values.removeAll() }
}

public protocol FeedbackDraftStore: Sendable {
    func load() async -> FeedbackDraft
    func save(_ draft: FeedbackDraft) async
}

public actor InMemoryFeedbackDraftStore: FeedbackDraftStore {
    private var draft = FeedbackDraft()
    public init() {}
    public func load() -> FeedbackDraft { draft }
    public func save(_ draft: FeedbackDraft) { self.draft = draft }
}
