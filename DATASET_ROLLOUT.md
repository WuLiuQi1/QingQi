# 数据集版本发布与回退（G0 草案）

客户端只接受签名 manifest 指向的不可变 Bloom/PIR 共同快照。manifest 至少包含 schema、dataset、profile、parser、sequence、有效期、产物哈希/大小、key id 和签名。

发布顺序：上传不可变产物 → 确认 PIR 已服务同一 dataset → 发布 manifest → 客户端验签、校验哈希/有效期 → 系统安装并回读 → 受控测试通过后标记生效。保留上一有效快照，使用更高 sequence 发布回退内容。

未验证项：Apple PIR 数据库更新和多版本客户端迁移协议、过期行为、密钥轮换与真实回滚耗时。不得把客户端 JSON 替换成功当作系统过滤已生效。
