# 交付验证记录

验证日期：2026-09-27。

## 已实际执行

- Swift 6.2.1（x86_64 Linux）运行 Core `swift test`：17 项 XCTest，0 失败。
- `swiftc -frontend -parse`：SwiftUI 原型文件语法分析通过。
- 已安装的 Chromium + Playwright：7 组浏览器交互检查通过。
- 浏览器检查覆盖演示提示、设置/等待/启用/关闭、规则搜索/详情/空态、演示自检、深浅色、清理事件、375 px 布局与基本键盘路径。
- 检查期间无 JavaScript 运行时错误，无 HTTP/HTTPS 外部请求。
- 浏览器测试报告：`UI_TEST_RESULTS.json`；Core 输出摘要：`CORE_TEST_RESULTS.txt`。

## 尚未执行

- 本机 Windows 上的 Mac Xcode + Apple iOS SDK 编译；GitHub macOS runner 已完成对应构建链验证。
- iPhone 真机的 Network Extension entitlement、系统授权、受控 URL 裁决与正式分发验证。
- 真实广告拦截、目标 App 兼容性、PIR 部署和成本测量。
- 生产规则、签名发布、隐私与审核验证。
- 完整无障碍审计与系统级性能/能耗测试。

纯 Swift 测试通过和 SwiftUI 语法分析通过，不代表 iOS App 编译通过。
浏览器原型不是 WebView 技术选型；原生产品仍按 SwiftUI 实现。

## 真机回归补充

2026-09-27：维护者在 iPhone 13 Pro / iOS 27 上使用爱思个人 Apple ID 签名安装最新 IPA。结果：App 正常启动，深色模式正常，未发现异常。该结果只覆盖 UI/数据层测试包，不代表真实 URL Filter 或广告过滤能力。

2026-09-27：GitHub Actions macOS runner 完成 Swift Core tests、XcodeGen、`iphoneos` Release 无签名构建、IPA 打包和 SHA-256 产物校验。当前构建仍是 App-only，不含生产 Network Extension target。

## 视觉检查
已打开并检查概览页及四页总图；总图由实际浏览器页面截图排版生成。
