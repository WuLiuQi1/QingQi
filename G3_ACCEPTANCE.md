# G3 交付记录

## 当前结论

部分实现，尚未通过。App 已接入 `NEURLFilterManager`，并建立 URL Filter control-provider extension target；但 G0 运行准入和真实数据服务尚未满足，因此不能标记为真实过滤完成。

## 已准备

- G1 的 `FilterEngine` 接口可作为 UI 与系统实现的隔离边界。
- `NativeURLFilterEngine` 已调用 Apple `NEURLFilterManager` 的加载、保存、启用、关闭和移除 API；缺少 PIR 配置时返回失败，不伪造成功。
- `QingQiURLFilterExtension` 已实现 `NEURLFilterControlProvider` 生命周期和 prefilter 读取入口；缺少 Apple 官方 BloomFilterTool 输出时明确失败。
- Release 默认使用 `UnavailableFilterEngine`，系统能力不可用时显示不可用状态。
- [spikes/NativeURLFilter/README.md](spikes/NativeURLFilter/README.md) 固化了从 Apple SimpleURLFilter 样例开始的接入顺序、证据要求和禁止事项。
- `xcodegen.yml` 已包含 App 与 extension target；Xcode 仍需为两个 target 选择团队并确认 `url-filter-provider` entitlement。

## 阻塞原因

- 当前主机为 Windows，没有 Xcode、iOS 26 SDK 或 `xcodebuild`。
- 当前只有 Apple Personal Team；普通 App 签名和 iPhone 13 Pro 已验证，但 `url-filter-provider` entitlement、extension profile 和系统授权尚未验证。
- 没有 Apple 官方 BloomFilterTool 输出、PIR 服务、Bloom/PIR 共同数据集和成本测量。
- 没有真实受控允许/阻止 URL 结果、关闭/移除回读结果或组合网络测试。

## G3 准入后的人工操作

在 Mac 上运行 Apple 官方 SimpleURLFilter 样例，记录脱敏日志和 target bundle identifiers；在专用真机完成授权、开启、关闭、移除、WebKit/URLSession、缓存、断网、PIR 超时和版本不一致测试；维护者确认结果后，才实现 `NativeURLFilterEngine` 与扩展 target。
