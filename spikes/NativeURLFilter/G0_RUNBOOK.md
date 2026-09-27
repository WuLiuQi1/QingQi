# G0 真机执行清单

目标：验证 Apple 官方 URL Filter 在普通非受监管 iPhone 上的配置、授权、状态回读和受控 URL 裁决。此清单不能由模拟器或当前 UI IPA 替代。

## A. 环境记录

- Mac 型号与 macOS：
- Xcode 版本：
- iOS SDK：
- Swift 版本：
- Apple Developer Team ID：
- iPhone 型号 / iOS / 是否受监管：
- 测试时间、地区、Wi-Fi/蜂窝、IPv6-only：
- 其他 VPN、加密 DNS、Private Relay 状态：

## B. 官方样例

1. 从 Apple 官方 `SimpleURLFilter` 样例建立 workspace，保留样例许可证。
2. 给 App 和 control extension target 选择自己的开发团队，确认 bundle identifier、签名和公开 entitlement。
3. 使用官方 BloomFilterTool 生成 Bloom 数据；PIR 服务端使用同一 URL 输入和 dataset。
4. 不把示例 token、localhost 或样例数据写进 QingQi Release 配置。

## C. 配置与状态回读

- 首次无配置：记录 manager 状态和 UI 状态。
- 保存配置但未确认：必须显示“等待系统确认”。
- 在系统设置批准后返回 App：调用 `loadFromPreferences()`，记录状态和版本证据。
- 关闭：调用关闭动作后重新加载，确认状态为 disabled。
- 移除：移除后重新加载，确认状态为 notConfigured。
- 配置无效、PIR 超时、Bloom 过期：记录可恢复错误，不能显示成功。

## D. 受控 URL 证据

至少准备一组允许 URL、一组阻止 URL，并记录 URL、时间、网络条件和结果。允许 URL 成功且阻止 URL 按预期失败，才可记为“受控裁决通过”。请求失败本身不能判定为拦截成功。

按 URLSession 和 WebKit 分别测试：查询参数、同域不同路径、大小写、片段、IDN/Punycode、缓存、sub-URL 展开。再用未参与 API 的自定义网络栈记录“不保证覆盖”，不得自动扩展结论。

## E. 故障与共存

- 关闭 PIR 服务、增加超时、损坏/过期 Bloom、Bloom/PIR dataset 不一致。
- Wi-Fi/蜂窝切换、断网、门户网络、IPv6-only。
- 既有 VPN、系统 DNS、Private Relay 开关组合。

每项记录：系统状态、受控 URL 结果、App UI 显示、日志摘要、是否恢复联网。

## F. 成本测量

用接近目标规模的小规则集和受控请求量测量 PIR 请求数、请求/响应字节、CPU 时间、峰值并发、内存、Bloom 大小、更新大小和缓存命中率。没有实测数据前，`COST_MEASUREMENTS.csv` 保持空值。

## G. 准入判定

- 通过：配置、回读、受控允许/阻止、故障恢复和成本数据均有证据。
- 有条件通过：核心链路通过，但明确列出未覆盖网络栈或成本风险。
- 不通过：授权/签名/回读失败，或无法证明受控阻止结果。

只有“通过”或明确批准的“有条件通过”后，才建立 QingQi 生产 Network Extension target。
