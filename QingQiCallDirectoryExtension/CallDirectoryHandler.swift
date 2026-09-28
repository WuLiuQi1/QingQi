import CallKit

/// Call Directory scaffold. Empty lists are intentional until a reviewed,
/// normalized E.164 ruleset is supplied by the host app's data layer.
final class CallDirectoryHandler: CXCallDirectoryProvider {
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        context.delegate = self
        // Do not add sample numbers: a template number must never be treated
        // as a real block or identification rule.
        context.completeRequest()
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {
    func requestFailed(
        for extensionContext: CXCallDirectoryExtensionContext,
        withError error: Error
    ) {
        NSLog("Call Directory request failed: \(error.localizedDescription)")
    }
}
