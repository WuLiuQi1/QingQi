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

真实 `NEURLFilterManager`、URL Filter control extension、授权回读、PIR/Bloom、反馈网络提交、Apple SDK 编译、真机和无障碍审计均未完成。它们需要 G0 环境，不以 Mock 或静态代码代替。

## 验证

本机为 Windows，未执行 `swift test`、Xcode 构建或 iPhone 测试。GitHub Actions 工作流已配置，待项目进入 GitHub 后运行。
