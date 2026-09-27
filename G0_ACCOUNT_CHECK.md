# G0 账号与能力核验（需要一次 Apple 环境操作）

目的：确认当前 Apple Developer 团队是否能为 URL Filter extension 签名。没有这一步，不能把真实过滤标记为完成。

## 在远程 Mac 上记录

1. Xcode → Settings → Accounts，记录团队名称、Team ID、账号类型（Personal Team 或付费团队）。不要把证书、私钥或登录凭据提交到仓库。
2. 用 Apple 官方 `Filtering traffic by URL` / `SimpleURLFilter` 样例建立临时工程，不要先改 QingQi 生产代码。
3. 给 App target 和 `SimpleURLFilterExtension` target 分别选择该团队。
4. 在 extension target 的 Signing & Capabilities 点击 `+ Capability`，搜索 `Network Extensions`，确认能否选择 `URL Filter Provider`（对应 `url-filter-provider` entitlement）。
5. 记录是否出现以下任一结果：
   - 能添加并自动生成 profile：继续 G0 的授权、保存、关闭、移除和受控 URL 测试。
   - 能看到能力但签名报 requires approval / entitlement：G0 在账号能力处阻塞，保留错误文本。
   - 搜索不到能力：G0 在团队/平台资格处阻塞，不要猜测可用性。
6. 只有 App 与 extension 均能签名、真机授权和状态回读成功后，才把证据复制到 `spikes/NativeURLFilter/G0_DATA_CAPTURE.csv`。

## 不应做的事

- 不把个人签名安装成功当作 Network Extension entitlement 已获批。
- 不把 `NEURLFilterManager.isEnabled` 单独当作 URL 已被拦截。
- 不在生产工程里用 Mock 状态替代系统状态。
- 不提交 provisioning profile、证书、私钥、API token 或 PIR 服务密钥。

官方依据：

- [Filtering traffic by URL](https://developer.apple.com/documentation/networkextension/filtering-traffic-by-url)
- [NEURLFilterManager](https://developer.apple.com/documentation/networkextension/neurlfiltermanager)
- [Network Extension entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.networking.networkextension)
