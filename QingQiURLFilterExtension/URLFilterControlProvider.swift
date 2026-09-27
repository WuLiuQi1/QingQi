import Foundation
import NetworkExtension

/// URL Filter control provider used by NEURLFilterManager.
///
/// The bundled Bloom artifact is intentionally required. A missing or invalid
/// artifact throws instead of returning a fabricated success result.
@available(iOS 26.0, *)
final class URLFilterControlProvider: NSObject, NEURLFilterControlProvider {
    func start() async throws {}

    func stop(reason: NEProviderStopReason) async throws {}

    func fetchPrefilter(existingPrefilterTag: String?) async throws -> NEURLFilterPrefilter? {
        guard let resource = Bundle.main.url(forResource: "bloom_filter", withExtension: "plist") else {
            throw NSError(domain: "QingQi.URLFilter", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "缺少官方 Bloom prefilter；请使用 Apple BloomFilterTool 生成并随 extension 打包"
            ])
        }

        // The property-list schema and hash metadata are Apple sample artifacts.
        // Do not invent values here: copy the output of the official
        // BloomFilterTool into this target before enabling production filtering.
        let plistData = try Data(contentsOf: resource)
        let plist = try PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any]
        guard let data = plist?["data"] as? Data,
              let tag = plist?["tag"] as? String,
              let bitCount = (plist?["bitCount"] as? NSNumber)?.intValue,
              let hashCount = (plist?["hashCount"] as? NSNumber)?.intValue,
              let murmurSeed = (plist?["murmurSeed"] as? NSNumber)?.uint32Value else {
            throw NSError(domain: "QingQi.URLFilter", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Bloom prefilter 格式不是 Apple 官方工具输出"
            ])
        }

        if existingPrefilterTag == tag { return nil }
        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("qingqi-bloom-filter")
        try data.write(to: temporaryURL, options: .atomic)
        return NEURLFilterPrefilter(
            data: .temporaryFilepath(temporaryURL),
            tag: tag,
            bitCount: bitCount,
            hashCount: hashCount,
            murmurSeed: murmurSeed
        )
    }
}
