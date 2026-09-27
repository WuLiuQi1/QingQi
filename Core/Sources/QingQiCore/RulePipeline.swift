import Foundation

public struct RuleSource: Codable, Equatable, Sendable {
    public let identifier: String
    public let commit: String
    public let license: String
    public let licenseVerified: Bool
    public init(identifier: String, commit: String, license: String, licenseVerified: Bool) {
        self.identifier = identifier; self.commit = commit; self.license = license; self.licenseVerified = licenseVerified
    }
}

public struct RuleDocument: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let datasetID: String
    public let source: RuleSource
    public let blockedDomains: [String]
    public let exclusions: [String]
    public init(schemaVersion: Int = 1, datasetID: String, source: RuleSource, blockedDomains: [String], exclusions: [String] = []) {
        self.schemaVersion = schemaVersion; self.datasetID = datasetID; self.source = source; self.blockedDomains = blockedDomains; self.exclusions = exclusions
    }
}

public enum RulePipelineError: Error, Equatable, Sendable {
    case unsupportedSchema(Int)
    case emptyDatasetID
    case unverifiedLicense
    case emptyRuleSet
    case invalidManifest(String)
}

public struct RuleAuditEntry: Codable, Equatable, Sendable {
    public let blocked: String
    public let exclusions: [String]
    public let action: String
    public init(blocked: String, exclusions: [String], action: String) { self.blocked = blocked; self.exclusions = exclusions; self.action = action }
}

public struct CompiledRuleSnapshot: Codable, Equatable, Sendable {
    public let datasetID: String
    public let schemaVersion: Int
    public let blockedDomains: [String]
    public let exclusions: [String]
    public let audit: [RuleAuditEntry]
    public let source: RuleSource
}

public enum RulePipeline {
    public static func decode(_ data: Data) throws -> RuleDocument {
        let decoder = JSONDecoder()
        return try decoder.decode(RuleDocument.self, from: data)
    }

    public static func compile(_ document: RuleDocument) throws -> CompiledRuleSnapshot {
        guard document.schemaVersion == 1 else { throw RulePipelineError.unsupportedSchema(document.schemaVersion) }
        guard !document.datasetID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw RulePipelineError.emptyDatasetID }
        guard document.source.licenseVerified else { throw RulePipelineError.unverifiedLicense }
        guard !document.blockedDomains.isEmpty else { throw RulePipelineError.emptyRuleSet }
        let result = try DomainRuleCompiler.compile(blocked: document.blockedDomains, exclusions: document.exclusions)
        let audit = result.suppressed.map { RuleAuditEntry(blocked: $0.blocked, exclusions: $0.overlappingExclusions, action: "suppressed-overlap") }
        return CompiledRuleSnapshot(datasetID: document.datasetID, schemaVersion: document.schemaVersion, blockedDomains: result.blockedDomains, exclusions: result.exclusions, audit: audit, source: document.source)
    }

    public static func deterministicData(_ snapshot: CompiledRuleSnapshot) throws -> Data {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(snapshot)
    }
}

public struct RuleArtifact: Codable, Equatable, Sendable {
    public let name: String
    public let byteCount: Int
    public let sha256: String
    public init(name: String, byteCount: Int, sha256: String) { self.name = name; self.byteCount = byteCount; self.sha256 = sha256 }
}

public struct RuleManifest: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let datasetID: String
    public let sequence: UInt64
    public let artifacts: [RuleArtifact]
    public let keyID: String
    public let signature: String
    public init(schemaVersion: Int = 1, datasetID: String, sequence: UInt64, artifacts: [RuleArtifact], keyID: String, signature: String) {
        self.schemaVersion = schemaVersion; self.datasetID = datasetID; self.sequence = sequence; self.artifacts = artifacts; self.keyID = keyID; self.signature = signature
    }
    public func validate() throws {
        guard schemaVersion == 1, !datasetID.isEmpty, sequence > 0, !artifacts.isEmpty, !keyID.isEmpty, !signature.isEmpty else {
            throw RulePipelineError.invalidManifest("schema、dataset、sequence、artifact、key_id 和 signature 均为必需")
        }
        guard artifacts.allSatisfy({ $0.byteCount >= 0 && $0.name.isEmpty == false && $0.sha256.count == 64 }) else {
            throw RulePipelineError.invalidManifest("产物大小、名称或 SHA-256 字段无效")
        }
    }
}

/// Writes a fully prepared snapshot to a temporary file before replacing the destination.
/// Hashing and signature verification remain the responsibility of the platform publisher.
public struct AtomicSnapshotWriter: Sendable {
    public init() {}
    public func replace(_ data: Data, at url: URL) throws {
        let fm = FileManager.default
        let directory = url.deletingLastPathComponent()
        try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        let temporary = directory.appendingPathComponent(".\(url.lastPathComponent).\(UUID().uuidString).tmp")
        try data.write(to: temporary)
        if fm.fileExists(atPath: url.path) { _ = try fm.replaceItemAt(url, withItemAt: temporary) }
        else { try fm.moveItem(at: temporary, to: url) }
    }
}
