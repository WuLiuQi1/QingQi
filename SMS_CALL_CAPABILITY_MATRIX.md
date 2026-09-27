# SMS / Call Capability Matrix

| 能力 | Apple 公共 API | V2 目标 | 当前证据 |
| --- | --- | --- | --- |
| 未知发送者 SMS/MMS 分类 | IdentityLookup Message Filter Extension | 是 | 官方文档边界已核对；真机链路待执行 |
| iMessage 分类 | 不在本扩展范围 | 否 | 明确排除 |
| 通讯录联系人短信分类 | 不在本扩展范围 | 否 | 明确排除 |
| 来电号码识别 | CallKit Call Directory Extension | 是 | 官方文档边界已核对；真机目录待执行 |
| 来电号码阻止 | CallKit Call Directory Extension | 是 | 官方文档边界已核对；真机目录待执行 |
| 每通电话实时服务端查询 | Call Directory 不提供此模型 | 否 | 明确排除 |
| 全设备 URL 广告拦截 | URL Filter 相关 API / entitlement | 暂缓 | 不属于当前 V2 验收 |
