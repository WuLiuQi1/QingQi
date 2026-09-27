# G1 交付记录

## 已实现

- SwiftUI 原生四页入口：概览、规则、诊断、设置。
- `FilterEngine` 协议与 `UnavailableFilterEngine`；Release 默认不能用演示成功状态替代系统状态。
- `MockFilterEngine` 仅在 `DEBUG` 编译条件下存在。
- 状态模型区分未配置、准备授权、等待确认、已启用、已关闭、异常和不支持，并保留失败消息。
- 事件存储、反馈草稿存储、规则元数据仓库的协议与内存实现。
- 规则详情使用 example 保留域名并明确“未测试，不可发布”。
- 原型顶部持续显示演示提示；隐私文案说明不读取浏览记录，PIR/规则分发仍需服务端。
- Dynamic Type、系统字体、VoiceOver 可组合元素和系统 TabView 保留在 SwiftUI 结构中。

## 未完成准入

真实 `NEURLFilterManager`、URL Filter control extension、授权回读、PIR/Bloom、反馈网络提交、Network Extension entitlement 和系统级无障碍审计仍未完成。Apple SDK 编译已由 GitHub macOS runner 完成，普通真机已完成 UI/深色模式安装回归；这些结果不替代 G0 的系统过滤证据。

## 验证

本机为 Windows，未执行本地 `swift test` 或 Xcode。GitHub Actions 已实际执行 Core tests、XcodeGen、iPhoneOS 无签名构建和 IPA 打包；维护者已在 iPhone 13 Pro / iOS 27 完成安装、启动和深色模式回归。
