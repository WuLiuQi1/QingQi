# G2 交付记录

已完成：

- `RuleDocument`：schema、dataset、来源 commit、许可证和阻止/例外域名。
- 许可证未确认、空数据集、未知 schema 和非法输入会失败，不静默放宽规则。
- 复用 Core 的 ASCII 域名校验、点边界匹配和例外优先冲突抑制。
- 输出 `CompiledRuleSnapshot` 与可审计的 `suppressed-overlap` 记录。
- 使用排序 JSON 生成确定性快照。
- `RuleManifest` 校验 dataset、sequence、产物大小、SHA-256 字段、key id 和签名字段。
- `AtomicSnapshotWriter` 先写临时文件，再原子替换目标文件。
- 增加 Core 单元测试覆盖冲突审计、许可/schema 拒绝、确定性编码和 manifest。

刻意未实现：Apple 专用 Bloom/PIR 生成器、生产签名密钥、真实 PIR 数据库和远端发布服务。G2 只能在获得官方样例工具与许可后接入，不能用自定义算法宣称兼容 Apple URL Filter。

本机为 Windows，未执行 Swift 测试；GitHub macOS runner 已实际执行 `swift test --package-path Core` 并通过。Apple 专用 Bloom/PIR 工具、生产数据库、签名密钥和发布服务仍属于外部准入项，不能在当前环境伪造完成。
