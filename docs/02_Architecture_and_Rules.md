# 02 · 架构、规则与成本

## 1. 技术决策

采用 Swift + SwiftUI。架构采用轻量 MVVM / 单向状态更新，View 不直接操作系统过滤配置。

生产能力基线：iOS 26+ 官方 URL Filter；在有 Apple 开发者签名的普通非受监管真机上完成 G0 验证后，才进入正式集成。[S2][S4]

不把以下方案作为首版主线：
- 用 NEPacketTunnelProvider 做纯本地拦截、重注入或全 DNS 拦截：苹果列为不支持用途。[S1]
- 面向普通消费设备直接使用 NEDNSProxyProvider / NEFilterDataProvider：部署有限制；Screen Time 的内容过滤例外也不是任意成年个人设备权限。[S2]
- 通过换产品名称规避 VPN 规则：审核看实际功能，不靠命名改变适用要求。[S10]
- 私有 API、越狱、根证书 MITM、遍历其他 App UI、浏览记录抓取。

系统加密 DNS 配置是另一条官方路径，但“设置一个 DNS 服务器”不等于本地执行自定义规则；规则过滤由选定解析服务实现。DNS 也不必然需要“很多服务器”，规模与冗余应由实际请求量测算。[S11] 本版不同时混入第二套引擎。

## 2. 运行结构

```text
SwiftUI 主 App
  ├── 状态与授权流程
  ├── 规则元数据与版本展示
  ├── 用户主动诊断
  └── 本地设置 / 反馈草稿
          │ FilterEngine 协议
          ▼
NativeURLFilterEngine（G0 通过后实现）
  ├── NEURLFilterManager：配置、保存、状态回读
  └── URL Filter 控制扩展：提供有效 Bloom 数据
          │
          ▼
iOS 执行过滤
  ├── 本机 Bloom：确定未匹配 → 允许
  └── 潜在匹配 → PIR 隐私查询 → 系统决定允许 / 阻止
```

Bloom 不是最终裁决数据库。它存在假阳性，不能把“Bloom 命中”当作“拦截成功”。PIR 为官方机制的一部分。[S3][S4]

规则后端：

```text
来源及授权审计
    → 候选规则、人工验证、业务回归
    → 规范化 / 去重 / 冲突检查
    → 共同规则快照
        ├── Bloom 数据
        ├── PIR 数据库
        ├── 元数据
        └── 签名 manifest
    → 灰度 / 发布 / 保留上一版本
```

## 3. 覆盖与观测边界

官方 URL Filter 可在系统支持的网络 API 层处理完整 URL，不需要本 App 解密 TLS。[S3] 因此“同一 HTTPS 域名下不同路径永远无法区分”对这种新架构不成立；那是只观察域名/IP 的旧方案限制。

但是：
- 自定义网络栈不自动覆盖。[S5]
- URL 可阻止，不等于能编辑广告接口 JSON 或让页面主动跳过倒计时。
- 不保证读取全设备每次请求、来源 App、拦截计数。
- 文档中受监管设备或标记为 Beta 的报告能力，不作为普通用户 V1 的前提。[S9]

诊断只对受控测试资源给出可证实结果。

## 4. 模块边界

```text
QingQiApp/
  Features/{Overview,Rules,Diagnostics,Settings}
  DesignSystem/
  AppState/
  Services/
    FilterEngine
    RuleRepository
    ConfigurationEventStore
    FeedbackDraftStore

QingQiURLFilterExtension/   # G0 通过后建立真实 target
  PrefilterLoader
  VerifiedArtifactStore

Packages/
  QingQiCore/              # 纯 Swift 数据与校验，无系统过滤 API
  QingQiRuleCompiler/      # 后续服务端构建工具

Backend/
  RulePublisher
  PIRService
  ArtifactStorage
  FeedbackEndpoint
```

共享配置只通过明确授权的容器/机制交换；App Group 是否需要及相应 entitlement 根据实际 target 实现核验。扩展不能随意访问主 App 私有目录。

建议协议：

```swift
protocol FilterEngine {
    func readSnapshot() async throws -> FilterSnapshot
    func requestEnable() async throws -> ConfigurationAttempt
    func disable() async throws -> FilterSnapshot
    func removeConfiguration() async throws -> FilterSnapshot
}
```

`requestEnable()` 返回“已发起 / 等待用户 / 已回读”等结果，不把“配置保存完成”直接当成“已启用”。所有异步 UI 状态变化在主线程；错误携带可恢复操作。

## 5. 首版规则格式

`rules.example.json` 是元数据格式，不是苹果系统可直接执行的过滤文件。

支持的生产候选：
- 域名后缀键：对独立广告域名，验证后使用。
- 苹果规范允许的 URL 组成键：需要对规范化与 sub-URL 展开做一致性测试后启用。

苹果 Bloom / PIR 的键不原生支持通配符或正则规则列表；管理器有 URL 解析配置，不能据此宣称兼容全部 ABP、Surge 或其他工具规则。[S6][S7]

导入策略：
- 纯域名、严格限定的 hosts 条目：在确认语义一致后转换。
- `||host^`：只有完整符合已支持子集且无选项/额外语义时才候选转换。
- 元素隐藏、脚本注入、响应重写、按来源页面条件、资源类型选项等：拒绝，并给出原因。
- 不认识的语法：拒绝，不静默降级成更宽泛的域名屏蔽。

规则包含来源 commit、授权标识与检查记录、验证日期、测试版本、适用说明、已知影响。App 名称仅作验证元数据，不作为可执行 per-app scope。

## 6. 例外与冲突

V1 只有发布者维护的固定配置档，不承诺每用户独立白名单立即生效。任意个人例外会涉及系统表达能力、个性化 Bloom、PIR 数据一致性和服务成本，需独立验证。

发布级安全策略：**例外优先，宁可减少覆盖也不误伤。**

仅删除同名 block 条目不够。例如阻止 `example.com`，允许 `pay.example.com`，父域名规则仍可能匹配支付域名。编译器必须识别父子域重叠：

- 不能证明可精确表达例外时，撤掉重叠的宽泛阻止规则。
- 不自动生成未经验证的其他子域替代规则。
- 为每次抑制输出审计记录。
- 引擎最终匹配结果仍必须在真机验证。

包内 `QingQiCore` 实现了 ASCII 域名校验、点边界后缀匹配和这种保守冲突抑制；它不是完整 Apple sub-URL 编译器。

## 7. 原子更新与回滚

生产发布不能仅以“客户端 JSON 替换成功”为准。

manifest 建议字段：
`schema_version / dataset_id / profile_id / parser_config_id / sequence / published_at / expires_at / min_os / artifacts / key_id / signature`

每个产物包括精确字节大小和 SHA-256。签名覆盖**明确定义的原始字节或确定性编码**；不可任意重排 JSON 后再验证。客户端固定可信公钥，私钥只在受保护发布环境中。

基本顺序：
1. 发布不可变版本产物与对应 PIR 数据集。
2. 验证 PIR 已服务该数据集。
3. 发布签名 manifest，允许客户端下载。
4. 客户端验签、校验哈希、schema、大小、有效期，保留当前有效版本。
5. 以官方接口安装；成功回读/受控测试后标记生效。
6. 上一数据集保留足够迁移时间，不提前删除。

**阻塞项**：Apple PIR 协议如何处理数据库更新和多版本客户端，需要以官方样例和服务端实现验证；不能假设能给系统请求随便加 dataset_id。G0 必须输出版本迁移方案。

失败保留最后有效快照；过期状态明确展示。rollback 使用更高发布 sequence 指向上一份安全内容，避免把正常安全回滚与重放攻击混为一谈。

更新由系统回调和前台检查配合，不保证任意精确后台刷新频率。远程紧急修复不能替代用户本地关闭入口。

## 8. 服务器与成本

这不是转发视频、图片等完整业务流量的 VPN，但也不是纯静态文件服务。PIR 的算力与查询开销需要实测，不保证比 DNS 更便宜。[S3][S8]

MVP 逻辑组件：
- 不可变产物存储 / CDN。
- PIR 服务与生产隐私认证配置。
- 小型规则发布工具。
- 可选反馈接口，不需要用户账号系统。

这些是逻辑组件，不等于必须分别购买多台服务器。生产冗余和地域部署由延迟、可用性与成本目标决定。

测量模型：
- N：日活设备数。
- T：每设备每日参与过滤的 URL 评估量。
- h：进入远端候选查询的比例，包含真实候选与 Bloom 假阳性。
- c：系统缓存避免重复查询的比例。
- b：实际批处理、sub-URL 展开带来的调用折算系数，必须测。
- PIR_calls/day ≈ N × T × h × (1-c) × b。
- 带宽 ≈ 查询次数 × 实测请求/响应字节 + 规则分发字节。
- 算力 ≈ 查询次数 × 实测 CPU 时间，并考虑峰值并发与内存。

不得在没有数据时承诺“十万用户几乎零成本”。首版先测小型、接近真实规模的规则集，再做负载外推。

## 9. 隐私设计

默认不上传完整 URL、查询参数、最近域名列表、来源 App、账号或浏览历史。
PIR、隐私认证和系统中继按官方机制配置，不能用普通明文 URL 查询 HTTP API 假装 PIR。[S3][S5][S8]

后端的运维日志也需审查：限制 IP/标识保留、避免请求体记录、定义留存期限。不要把“应用不主动收集”写成“整个链路不存在任何元数据”。

反馈手动发起，提交前可预览、删除或取消。URL 文本与自由输入应提示敏感信息，并默认移除参数/片段后再讨论上传必要性。

## 10. 降级原则

消费广告过滤优先不破坏联网；可配置的失败行为需验证其真实覆盖范围。`shouldFailClosed = false` 等配置不是所有网络错误都自动恢复的保证。[S6]

服务器失败、数据损坏、配置被关闭、系统不支持，都要有独立状态。  
URL Filter 的准入验证不通过时，停止该核心能力的商业承诺。Safari 内容拦截或第三方过滤 DNS 是不同产品范围，不能悄悄替换后声称完成了全 App 广告过滤。
