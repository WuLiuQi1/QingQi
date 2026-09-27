# Native URL Filter G3 Spike

此目录是 G3 真正接入前的执行手册，不是已完成的过滤扩展。当前 Windows 环境没有 Xcode、iOS SDK、Apple Developer 签名或普通非受监管 iPhone，因此不得把本目录标记为可运行。

## 前置条件

1. 在 macOS 安装与 iOS 26 SDK 匹配的 Xcode。
2. 从 Apple 官方 `SimpleURLFilter` 样例建立 workspace，选择自己的开发团队。
3. 申请并确认 URL Filter control extension 的公开能力与 provisioning profile。
4. 按官方 BloomFilterTool 生成与 PIR 服务使用同一输入、同一 dataset 的预过滤数据。
5. 在普通非受监管 iPhone 上完成授权、关闭、移除和 `NEURLFilterManager` 状态回读。

## 接入顺序

先保留 `UnavailableFilterEngine`（位于 `QingQiApp/Services/FilterEngine.swift`）的不可用状态，直到以下证据全部存在：

- extension target 可以签名并安装；
- 配置保存后能观察系统状态变化；
- 用户从系统设置返回后，App 能重新加载配置；
- 受控允许 URL 成功、受控阻止 URL 失败，且已排除断网/服务器故障；
- Bloom 与 PIR dataset 一致；
- 关闭和移除后再次回读为关闭/未配置；
- 失败、超时、过期数据和版本不一致均能回到可恢复状态。

通过后再新增 `NativeURLFilterEngine` 和 `QingQiURLFilterExtension` target，并在 `xcodegen.yml` 中加入它们。生产实现必须调用公开 `NetworkExtension` API，不使用 Packet Tunnel、DNS MITM、私有 API 或自动操作其他 App。

## 不属于 G3 证据

`isEnabled == true` 只代表配置启用，不等于任意第三方 App 已被过滤；Mock、静态 JSON、模拟器运行和单纯请求失败也不能作为过滤成功证据。
