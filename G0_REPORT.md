# QingQi G0 技术可行性验证报告

核查日期：2026-09-27。结论：有条件通过（Win11 → GitHub macOS CI 与普通真机安装已验证；真实 URL Filter 运行准入仍阻塞）。

## 当前环境

- 操作系统：Windows 10.0.26200（PowerShell，x64 主机信息由系统返回）。
- Swift：不可用；`swift --version` 未找到命令。
- Xcode / xcodebuild / xcrun：不可用；当前不是 macOS。
- iOS SDK：不可用。
- 本机没有 Mac/Xcode；已通过远程 Mac 看到 iPhone 13 Pro（iOS 27）并在 Xcode 中选中设备。Apple Personal Team 签名可用；`url-filter-provider` entitlement 尚未核验。
- PIR 服务：未部署，也未购买或注册任何服务。
- 项目已建立 Git 仓库并推送到 `https://github.com/WuLiuQi1/QingQi`。

## 已验证

1. Apple 官方文档确认 URL Filter 的最低基线为 iOS 26，并使用本地 Bloom filter 加配置的 PIR server 处理完整 URL。
2. `Filtering traffic by URL` 官方样例说明了 `SimpleURLFilter` app 与 `SimpleURLFilterExtension` target、`NEURLFilterManager` 配置保存/加载、系统授权、状态回读和 `NEURLFilterControlProvider.fetchPrefilter`。
3. 官方文档明确：真实生产数据需要 Bloom 与 PIR 的共同输入；PIR 是独立服务部署工作，不能把静态规则文件或本地 Mock 当成完成。
4. 本仓库 Core 是独立纯 Swift 规则预处理模块，未接入 Network Extension。
5. GitHub Actions macOS runner 已成功执行 Swift Core tests、XcodeGen、`iphoneos` Release 无签名构建和 IPA 打包；日志与 SHA-256 作为 artifact 保存。
6. 维护者已在 iPhone 13 Pro / iOS 27 通过爱思个人 ID 签名安装 QingQi；正常启动、深色模式无异常。这只证明当前 SwiftUI/UI 数据层可安装运行，不证明 URL Filter。

## 阻塞与所需人工操作

无法在此环境完成：真实 Xcode 类型检查/构建、iOS 26 SDK 核对、extension 签名、普通非受监管 iPhone 授权/关闭/回读、WebKit/URLSession 与未参与网络栈对照、PIR/Bloom 版本迁移、VPN/DNS/Private Relay 组合测试，以及实际成本/延迟/带宽测量。

继续 G0 需要维护者提供或操作 macOS + Xcode 26/iOS 26 SDK、Apple Developer 团队和 Network Extension 能力申请、普通非受监管 iPhone、受控测试 URL、PIR/Bloom 实验环境。真实测量前不承诺零成本或低成本。

## 状态证据边界

`NEURLFilterManager.isEnabled`/保存配置只能说明配置启用状态；必须结合 manager 状态变化和受控允许/阻止 URL 结果，才能报告过滤有效。任何 Mock 状态均不得映射为真实系统状态。

## 下一步

先按 `G0_ACCOUNT_CHECK.md` 在远程 Mac 的 Apple 官方样例中核验 `URL Filter Provider` 能力和签名；通过后再建立 `spikes/NativeURLFilter/` 实验，跑通授权、关闭、状态回读和受控 URL，然后记录实测数据与失败日志。Win11 日常循环见 `G0_WIN11_CI_PLAN.md`。

执行清单与数据表见 `spikes/NativeURLFilter/G0_RUNBOOK.md` 和 `spikes/NativeURLFilter/G0_DATA_CAPTURE.csv`。

## 本次实际命令

- `Get-Location`、逐项 `Test-Path`：资料文件与 `Core/`、`UI/` 均存在。
- `swift test --package-path Core`：本机未执行，Windows PATH 没有 `swift` 命令；GitHub macOS runner 已执行并通过。
- `xcodebuild -version`：未执行，Windows PATH 没有 `xcodebuild` 命令。
- `xcrun --sdk iphoneos --show-sdk-path`：未执行，Windows PATH 没有 `xcrun` 命令。
- Apple 官方文档静态核查：已完成；官方页面确认 iOS 26 URL Filter、Bloom/PIR、SimpleURLFilter target 与状态回读路径。
- GitHub Actions：已实际成功执行无签名 iPhoneOS 构建和 IPA 打包；该构建不含生产 Network Extension target。
