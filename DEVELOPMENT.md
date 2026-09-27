# QingQi 开发与验证

本仓库目前提供 SwiftUI G1 工程骨架和独立 `Core` Swift Package。Windows 环境不能运行 Xcode 或 iOS SDK；未执行的构建不应标记为通过。

在 macOS 上安装 XcodeGen 后，可用 `xcodegen generate` 根据 `xcodegen.yml` 生成 `QingQi.xcodeproj`，再执行：

```sh
swift test --package-path Core
xcodebuild -project QingQi.xcodeproj -scheme QingQi \
  -sdk iphonesimulator -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

GitHub Actions 还会执行 `iphoneos` Release 无签名构建并打包 `QingQi-unsigned.ipa`；该产物需要爱思等工具重新签名，不能直接安装到普通 iPhone。普通 UI 真机回归可以使用个人签名；真实网络过滤仍需 Apple Developer 团队、Network Extension 能力、extension 签名和受控设备证据。

真实 URL Filter 仍属于 G0 阶段：必须从 Apple SimpleURLFilter 样例建立 extension target，完成系统授权、状态回读、受控 URL 测试和 PIR/Bloom 测量后，才能接入 `FilterEngine` 的生产实现。
