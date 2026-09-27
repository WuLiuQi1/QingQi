# 轻启 · QingQi

开源许可：MIT。新增 GitHub Actions 真机未签名 IPA 构建，操作见
[未签名 IPA 说明](docs/UNSIGNED_IPA.md)。当前产品主线是短信过滤与来电过滤；广告拦截暂缓。
## iPhone 短信与来电过滤工具｜产品设计与开发启动包 V2

设计日期：2026-09-26  
技术选择：Swift + SwiftUI。生产功能基线：iOS 26+。  
当前交付状态：**短信/来电产品规格、离线交互原型、SwiftUI 四页界面、可测试的纯 Swift 数据模块**。
**短信过滤和来电过滤的系统扩展尚未完成；广告 URL Filter 暂缓，不作为当前版本承诺。**

## 先读这一段

此前讨论中的“纯本地 VPN 可直接过滤所有流量并稳定上架”“普通 iPhone 可自由使用 DNS Proxy / Content Filter”“可以按来源 App 实施任意规则”等假设不应作为开发依据。苹果 TN3120 / TN3134 对这些能力有明确限制。[S1][S2]

本版正式技术路线是：**先接入 iOS IdentityLookup 短信过滤和 CallKit Call Directory，再评估广告 URL Filter**。短信扩展只处理未知发送者的 SMS/MMS，不能处理 iMessage 或通讯录联系人；来电目录由系统批量加载号码识别/拦截表。[S3][S4]

不使用 WebKit / URLSession 且未主动接入参与 API 的 App 请求，不保证覆盖。本地缓存、内置广告、广告加载失败后的倒计时，也不保证被消除。[S3][S5]

## 文件导航

- `docs/01_Product_and_UI.md`：短信/来电产品范围、四个主页面、视觉规范、状态与文案。
- `docs/02_Architecture_and_Rules.md`：IdentityLookup、Call Directory 架构，及暂缓的 URL Filter。
- `docs/03_Codex_Tasks.md`：可直接交给编码代理执行的分阶段任务和禁做事项。
- `docs/04_Test_Plan_and_Risks.md`：真机测试、技术准入与风险清单。
- `docs/SOURCES.md`：苹果官方依据及核查日期。
- `UI/index.html`：无需联网的浏览器交互原型；所有过滤行为都是演示。
- `iOSPrototype/QingQiPrototype.swift`：SwiftUI 四页面演示源码；没有拦截能力。
- `Core/`：独立 Swift Package，包含规则校验、号码规范化、保守冲突处理和单元测试。
- `samples/rules.example.json`：非生产规则示例，仅使用 example 保留域名。

## 使用

### 查看设计
直接用浏览器打开 `UI/index.html`。切换底部页面、模拟授权、运行演示自检、切换深浅色。原型不会发起网络请求，不会安装配置，不会保存浏览记录。

### 运行原生 UI 演示
按 `iOSPrototype/README.md` 在 Mac 的 Xcode 中新建 SwiftUI iOS App 项目，再导入单文件源码。此包不包含已配置签名的 Xcode 工程，不能直接安装到手机。

### 验证规则模块
进入 `Core/`，执行：

```sh
swift test
```

规则模块只是短信/号码数据预处理与测试辅助，不代表系统扩展已经启用。广告 URL Filter 的 Bloom/PIR 数据仍不在当前版本范围内。

### 开始开发
把整个目录交给 Codex，要求先读取本文件及 `docs/03_Codex_Tasks.md`。短信/来电系统扩展没有完成真机验证前，不承诺拦截覆盖率；广告 URL Filter 保持后续研究状态。

## 不在本版承诺范围
- 自动点击其他 App 的“跳过”按钮。
- 屏蔽全部 App / 全部广告，或者保证开屏零等待。
- 普通设备上可靠的逐 App 流量归属、逐 App 规则例外。
- 实时全设备请求日志、精确拦截次数、节省流量或节省时间统计。
- 全系统个人白名单立即生效，或任意规则格式完整兼容。
- 纯离线全系统过滤、零后端成本、保证 App Store 审核通过。

开源规则必须逐个核查授权、署名与再分发条件；本包没有收录第三方广告规则库。

## 本次验证
Core：17 项测试通过。浏览器：7 组交互检查通过，无 JavaScript 错误或外部 HTTP 请求。
SwiftUI：仅语法分析通过，未进行 Apple SDK 类型检查、Xcode 构建或真机运行。
详见 `docs/VALIDATION.md`。视觉总览见 `UI/preview.png`。
