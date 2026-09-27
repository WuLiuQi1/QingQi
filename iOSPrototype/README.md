# SwiftUI 界面原型

这是四个页面的 UI 演示，不含任何真实过滤能力。

## 在 Mac 的 Xcode 中使用
1. 新建 iOS App 项目，Interface 选 SwiftUI，Language 选 Swift。
2. 将 deployment target 设为 iOS 26.0 或更高，以对应正式产品计划基线。
3. 删除新项目自动生成的 `@main` App 源文件，避免存在两个程序入口。
4. 把本目录 `QingQiPrototype.swift` 添加到 App target。
5. 选择自己的开发团队，在模拟器或已授权设备上编译运行。

不需要 VPN / Network Extension entitlement，因为这里没有网络过滤功能。
本包未生成 `.xcodeproj`、签名产物或 IPA，也未在 Mac 上完成类型检查/运行验证。

## 能体验
概览、规则搜索与详情、模拟等待授权与启用/关闭、演示诊断、配置事件、深浅色与说明弹窗。

## 不能体验
真正安装系统过滤配置、拦截广告、规则在线更新、PIR 查询、真实网络自检。

正式开发请将单文件拆为 DesignSystem / Features / Models / Services，并用真实 FilterEngine 替换演示流程。Release 构建应隔离所有演示数据和能力，不能只隐藏“演示”横幅。

## 代码检查范围
Linux Swift 编译器可以做语法分析，但没有 SwiftUI / iOS SDK，不能据此声称原生 App 编译通过。纯 Swift Core 包的单元测试是另一项独立验证。
