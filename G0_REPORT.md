# QingQi G0 技术可行性验证报告

核查日期：2026-09-26。结论：有条件通过（仅完成文档/API 静态核查；运行准入阻塞）。

## 当前环境

- 操作系统：Windows 10.0.26200（PowerShell，x64 主机信息由系统返回）。
- Swift：不可用；`swift --version` 未找到命令。
- Xcode / xcodebuild / xcrun：不可用；当前不是 macOS。
- iOS SDK：不可用。
- Mac、iPhone 真机、Apple Developer 签名、Network Extension entitlement：未提供/未验证。
- PIR 服务：未部署，也未购买或注册任何服务。
- 本目录不是 Git 工作树（`git status --short` 返回 not a git repository）。

## 已验证

1. Apple 官方文档确认 URL Filter 的最低基线为 iOS 26，并使用本地 Bloom filter 加配置的 PIR server 处理完整 URL。
2. `Filtering traffic by URL` 官方样例说明了 `SimpleURLFilter` app 与 `SimpleURLFilterExtension` target、`NEURLFilterManager` 配置保存/加载、系统授权、状态回读和 `NEURLFilterControlProvider.fetchPrefilter`。
3. 官方文档明确：真实生产数据需要 Bloom 与 PIR 的共同输入；PIR 是独立服务部署工作，不能把静态规则文件或本地 Mock 当成完成。
4. 本仓库 Core 是独立纯 Swift 规则预处理模块，未接入 Network Extension。

## 阻塞与所需人工操作

无法在此环境完成：真实 Xcode 类型检查/构建、iOS 26 SDK 核对、extension 签名、普通非受监管 iPhone 授权/关闭/回读、WebKit/URLSession 与未参与网络栈对照、PIR/Bloom 版本迁移、VPN/DNS/Private Relay 组合测试，以及实际成本/延迟/带宽测量。

继续 G0 需要维护者提供或操作 macOS + Xcode 26/iOS 26 SDK、Apple Developer 团队和 Network Extension 能力申请、普通非受监管 iPhone、受控测试 URL、PIR/Bloom 实验环境。真实测量前不承诺零成本或低成本。

## 状态证据边界

`NEURLFilterManager.isEnabled`/保存配置只能说明配置启用状态；必须结合 manager 状态变化和受控允许/阻止 URL 结果，才能报告过滤有效。任何 Mock 状态均不得映射为真实系统状态。

## 下一步

在 Mac 上从 Apple SimpleURLFilter 样例建立 `spikes/NativeURLFilter/`，使用自有签名跑通授权、关闭、状态回读和受控 URL，然后记录实测数据与失败日志。

## 本次实际命令

- `Get-Location`、逐项 `Test-Path`：资料文件与 `Core/`、`UI/` 均存在。
- `swift test --package-path Core`：未执行，Windows PATH 没有 `swift` 命令。
- `xcodebuild -version`：未执行，Windows PATH 没有 `xcodebuild` 命令。
- `xcrun --sdk iphoneos --show-sdk-path`：未执行，Windows PATH 没有 `xcrun` 命令。
- Apple 官方文档静态核查：已完成；官方页面确认 iOS 26 URL Filter、Bloom/PIR、SimpleURLFilter target 与状态回读路径。
