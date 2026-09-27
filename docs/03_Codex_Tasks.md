# 03 · 交给 Codex 的开发任务

你负责在本设计基础上开发原生 iOS App「轻启」。使用 Swift + SwiftUI，不改为 WebView、Flutter 或 React Native。

## 必须先读
README.md → 01_Product_and_UI.md → 02_Architecture_and_Rules.md → 04_Test_Plan_and_Risks.md → SOURCES.md。

本包是启动材料，不是已完工的网络过滤器。浏览器与 SwiftUI 演示行为均为 Mock。不要因演示能够点亮开关就认为系统过滤已实现。

## 永久约束
- 只用公开 API 和明确支持的部署方式。
- 不把 NEPacketTunnelProvider 当作纯本地内容过滤主线。
- 不假定普通 iPhone 可以安装任意 DNS Proxy / Content Filter。
- 不依赖来源 App 标识、全设备访问日志、自动点击或 TLS MITM。
- 不伪造启用结果、拦截次数、节省流量、兼容性与性能。
- 不在生产中硬编码示例 token、私钥、测试服务器或示例域名规则。
- 不复制未经授权审计的第三方规则/项目。
- 所有真实失败都要映射为用户可恢复状态。
- 不把 `fatalError("TODO")` 或空成功回调当作已完成实现。
- Release 必须排除演示引擎；在真实状态不可用时显示不可用。

## G0：先验证核心可行性（阻塞后续集成）

建立单独的 `spikes/NativeURLFilter/`。以苹果官方 SimpleURLFilter 与 PIR 样例为参考，并遵守样例许可。使用开发者自己的账号与签名，不伪造 entitlement。

任务：
1. 记录当前稳定 Xcode/SDK、最低部署版本、API 可用性及能力配置。
2. 跑通受控允许/阻止 URL 的样例链路。
3. 在普通、非受监管真机上完成授权、关闭和配置回读。
4. 核实生产签名、扩展配置、NSPIRConfiguration、CloudKit Console Identity & Trust 注册和隐私认证要求。[S3][S6]
5. 验证 WebKit、URLSession，以及不自动参与的自定义网络实现。
6. 验证参数变化、同域不同路径、IDN/Punycode、缓存、sub-URL 展开。
7. 验证远端不可达、超时、Bloom/PIR 版本不同步与修复流程。
8. 跑实际规则规模下的延迟、峰值 CPU/内存、查询字节和吞吐测量。
9. 记录与用户已有 VPN、系统 DNS / Private Relay 的组合测试，不提前承诺互不冲突。
10. 证明哪个字段是“配置启用”，哪个证据表示“受控过滤有效”，不要混淆。

交付：
- `G0_REPORT.md`：环境、步骤、真实结果、失败日志的脱敏摘要、明确未验证项。
- `API_CAPABILITY_MATRIX.md`：功能、API、普通设备支持情况、证据。
- `COST_MEASUREMENTS.csv`：实测数据，不填猜测数。
- `DATASET_ROLLOUT.md`：版本一致性、迁移与回退设计。
- 决策：通过 / 有条件通过 / 不通过，并说明条件。

G0 无法执行（例如没有 Mac、真机、签名、服务器）时，明确报告阻塞。可以继续 UI 与纯数据层，但不能把网络功能标为完成。

## G1：原生 UI 与状态机

把 `iOSPrototype/QingQiPrototype.swift` 作为交互参考，不必保持单文件结构。拆分 Features、DesignSystem、Services、Models。

交付：
- 四个主页面、规则详情、授权说明、反馈草稿、隐私说明。
- `FilterEngine` 协议与 DEBUG Mock。
- 真实状态与 UI 状态映射。
- 深浅色、Dynamic Type、VoiceOver、Reduce Motion。
- 测试：状态切换、等待授权、失败重试、退出返回后的回读、关闭失败。

G1 可与 G0 并行，但不得对外发布成真正的过滤产品。

## G2：规则流水线

基于独立 Swift Package 建立规范化、来源与授权登记、冲突检查和审计输出。当前 Core 只支持 ASCII 域名；生产 IDN 处理需选择可信实现并增加测试，不要简单 lowercased 后宣称支持所有 Unicode 域名。

交付：
- 输入 schema 与严格错误报告。
- 初期只支持经验证的格式子集。
- 官方兼容 Bloom / PIR 生成器。
- 签名 manifest、不可变文件、原子切换。
- 规则许可清单与来源 commit。
- 有效/过期/错误/回滚用例。

## G3：接入真实过滤

仅在 G0 通过后建立生产 URL Filter extension 和正式引擎。
完成授权状态回读、版本同步、错误处理、关闭/移除、受控诊断。
测试真实 App 前，由维护者列出目标 App 名单、版本与测试地区；没有这些信息只做技术样例测试，不自行编造兼容清单。

## G4：测试与发布准备

- 普通非受监管真机、开发签名与分发路径分别验证。
- App Store 审核说明如实描述功能、服务器、数据流、失败行为。
- 隐私政策、第三方规则许可、联系渠道、后端可用性。
- 不因为叫“广告过滤”而忽略实际功能触发的审核要求。[S10]
- 删除调试凭证、假数据、未完成按钮，保留有意义的不可用说明。
- 未经显式批准不做付费、订阅或额外用户数据收集。

## 每阶段完成报告模板

已完成：
真实运行/测试结果：
未完成与原因：
依赖的环境/账号：
已知风险：
下一阶段准入是否满足：

不要用“代码已生成”替代“已编译、已运行、已真机验证”。三个状态分别报告。
