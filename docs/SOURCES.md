# 官方依据与核查范围

核查日期：2026-09-26。以下为苹果官方文档，可能随 SDK 或政策变化。开发前需再次核实。
文档说明的是平台能力，不代表对本产品授予权限或保证审核通过。

## S1 · TN3120: Expected use cases for Network Extension packet tunnel providers
支持：将 Packet Tunnel 用于纯内容过滤、全 DNS 拦截、通过代理从其他接口转发已接管流量等被列为不支持用途。

```text
https://developer.apple.com/documentation/technotes/tn3120-expected-use-cases-for-network-extension-packet-tunnel-providers
```

## S2 · TN3134: Network Extension provider deployment
支持：URL Filter 的 iOS 26+ 基线；DNS Proxy、Content Filter 与 per-app VPN 的部署限制。Screen Time 内容过滤例外限儿童设备，不能推广为一般个人授权。

```text
https://developer.apple.com/documentation/technotes/tn3134-network-extension-provider-deployment
```

## S3 · URL filters
支持：本地 Bloom + 远端 PIR；WebKit / URLSession 覆盖；其他网络栈参与 API；CloudKit Console Identity & Trust 注册要求。

```text
https://developer.apple.com/documentation/networkextension/url-filters
```

## S4 · Filtering traffic by URL
支持：官方 SimpleURLFilter 样例、最低系统/工具版本、配置与系统授权过程。

```text
https://developer.apple.com/documentation/networkextension/filtering-traffic-by-url
```

## S5 · WWDC25: Filter and tunnel network traffic with NetworkExtension
支持：系统 URL Filter 的架构、隐私机制和未参与网络栈的覆盖限制。

```text
https://developer.apple.com/videos/play/wwdc2025/234/
```

## S6 · NEURLFilterManager
支持：URL 解析、Punycode、Bloom/PIR 不原生支持通配符/正则键、NSPIRConfiguration、管理器配置与状态 API。具体版本属性需以部署 SDK 核验。

```text
https://developer.apple.com/documentation/networkextension/neurlfiltermanager
```

## S7 · Using the Bloom filter tool to configure a URL filter
支持：共同输入生成 Bloom 与 PIR 数据、sub-URL 展开、官方位向量和哈希格式。不要自行发明不兼容 Bloom 文件。

```text
https://developer.apple.com/documentation/networkextension/using-the-bloom-filter-tool
```

## S8 · Setting up a PIR server for URL filtering
支持：存在独立 PIR 服务部署工作。该网页正文在本次浏览工具中部分未能展开，实施细节必须结合官方可下载样例进一步核查，本文没有据此声称其生产性能或费用。

```text
https://developer.apple.com/documentation/networkextension/setting-up-a-pir-server-for-url-filtering
```

## S9 · NEURLFilterManager.reportEndpoint
支持：检索到的报告属性文档标有版本/测试状态限制，并明确只在受监管设备发送报告。因此不得据此承诺普通设备可获得完整 URL 拦截记录。

```text
https://developer.apple.com/documentation/networkextension/neurlfiltermanager/reportendpoint
```

## S10 · App Review Guidelines
支持：公开 API 应用于预期用途；VPN 实际功能相关审核条款及隐私要求。产品名称不替代实际合规性判断。

```text
https://developer.apple.com/app-store/review/guidelines/
```

## S11 · DNS settings / NEDNSSettingsManager
支持：系统加密 DNS 配置指向 DoH/DoT 解析服务并需用户启用；这不是本地规则执行回调。

```text
https://developer.apple.com/documentation/networkextension/dns-settings
https://developer.apple.com/documentation/networkextension/nednssettingsmanager
```

## S12 · IdentityLookup Message Filter Extension
支持：短信过滤扩展的系统边界、未知发送者 SMS/MMS 范围及扩展处理限制。

```text
https://developer.apple.com/documentation/identitylookup/sms-and-mms-message-filtering
```

## S13 · CallKit Call Directory
支持：Call Directory 扩展的号码识别/阻止、批量加载与系统管理边界。

```text
https://developer.apple.com/documentation/callkit/identifying-and-blocking-calls
```

## 设计假设与待核验项

名称/商标可用性、目标 App 覆盖率、规则来源许可、最低后端成本、用户增长模型、PIR 生产容量、审核结果均未被本包验证。
所有示例数值与规则在原型中明确标为示例。
