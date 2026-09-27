# G0 API 能力矩阵

| 能力 | 官方依据 | 当前结论 |
|---|---|---|
| URL Filter | URL filters / Filtering traffic by URL | 文档已确认，设备运行未验证 |
| iOS 基线 | Apple 文档 availability | iOS 26+；本机无 SDK |
| 本地预过滤 | `NEURLFilterPrefilter`, Bloom | 样例路径已确认，未构建 |
| PIR 查询 | `NEURLFilterManager` 配置与 PIR 文档 | 需要服务端，未部署/未测 |
| 配置保存与回读 | `saveToPreferences`, `loadFromPreferences` | 只能在 Xcode/真机验证 |
| 系统授权 | SimpleURLFilter 样例行为 | 未验证 |
| WebKit / URLSession | URL Filter 文档 | 需真机受控测试 |
| 自定义网络栈 | 官方覆盖边界说明 | 不自动覆盖，需目标栈参与 API |
| 真实广告过滤 | 受控 URL + 目标 App 实验 | 未验证，不能标记完成 |
| 成本 | PIR 请求/响应、规则分发实测 | 未测，不做成本承诺 |
