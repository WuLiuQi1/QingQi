# Win11 开发与 macOS CI 路线

本项目可以把日常开发、Core 测试和普通 SwiftUI IPA 构建全部放在 Windows 11 完成；GitHub Actions 的 macOS runner 负责调用 Xcode 和 iOS SDK。这个路线不等价于完成真实 URL Filter，因为 Network Extension 的账号能力、签名、系统授权和受控 URL 裁决仍需在 Apple 环境核验。

## 日常循环

1. 在 Win11 修改 `QingQiApp/`、`Core/`、`xcodegen.yml` 或文档。
2. 本机可运行时执行 `swift test --package-path Core`；没有 Swift 时保留“未执行”，不要伪造结果。
3. 提交并推送到 `main`，或在 GitHub Actions 手动运行 `Build unsigned iPhone IPA`。
4. 在 Actions 的 `Toolchain information`、`Core tests`、`Build unsigned device app` 和 `Package IPA` 步骤确认成功。
5. 下载 `QingQi-unsigned-iphoneos` artifact，核对 `.sha256`，再用爱思等外部签名工具签名安装。
6. 在 iPhone 上只记录可复现的 UI、深色模式和纯数据层结果；IPA 的安装成功不能作为真实拦截证据。

## 当前 CI 已覆盖

- macOS runner、Xcode、iOS SDK、Swift 版本打印。
- `Core` 的 Swift Package tests。
- XcodeGen 生成工程。
- `iphoneos` Release 无签名构建和 IPA 打包。
- 构建日志与 SHA-256 作为 artifact 保存。

## 需要 Mac 的部分

真实 URL Filter 需要 Apple 的 `url-filter-provider` Network Extension entitlement、App 与 control extension 的签名、系统授权/状态回读，以及 Bloom/PIR 服务联调。GitHub runner 可以编译已获授权的工程，但不能替代开发者账号能力核验，也不能自动连接你的 iPhone 做系统授权测试。

因此当前仓库保持 `UnavailableFilterEngine` 和明确的演示状态。只有 G0 证据表通过后，才建立生产 Network Extension target。

## Win11 侧故障排查

- Actions 失败：先下载 `build-logs`，把失败步骤和首个错误保留到 `G0_DATA_CAPTURE.csv`。
- IPA 可安装但功能显示演示：这是预期行为，说明真实 URL Filter 尚未接入。
- 远程 Mac 的“Copying OS library symbols”长时间不动：停止 Xcode 调试即可，不影响 Win11 → GitHub CI 的构建路线。
