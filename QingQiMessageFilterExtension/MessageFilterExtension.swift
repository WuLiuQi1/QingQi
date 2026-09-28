import IdentityLookup

/// Conservative offline scaffold. It returns `.none` until a reviewed local
/// ruleset is supplied; it never claims a message was filtered by a mock rule.
final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    func handle(
        _ queryRequest: ILMessageFilterQueryRequest,
        context: ILMessageFilterExtensionContext,
        completion: @escaping (ILMessageFilterQueryResponse) -> Void
    ) {
        let response = ILMessageFilterQueryResponse()
        response.action = .none
        response.subAction = .none
        completion(response)
    }
}
