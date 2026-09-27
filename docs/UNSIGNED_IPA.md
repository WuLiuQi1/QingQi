# 未签名 iPhone IPA

本项目以 MIT 许可开源。Apple 官方样例及第三方规则不包含在许可授权中；
仓库当前未打包这些外部实现。

工作流：Actions → Build unsigned iPhone IPA → Run workflow。
main 分支的代码、Core、工程配置和工作流变更也会自动触发。

构建成功后下载 Artifacts 下的 QingQi-unsigned-iphoneos，解压得到
QingQi-unsigned.ipa 和 SHA-256 文件。外层 artifact ZIP 不是 IPA。
IPA 内包含 Payload/QingQi.app，是 iphoneos Release 产物，不是模拟器包。

将 IPA 交给你使用的签名工具进行重签，再安装到 iOS 26 或更高的 iPhone。
证书、设备注册、描述文件与安装要求由实际签名方案决定。此项目不上传或保存签名密钥，
也不承诺第三方工具一定签名成功。重签不能自动获得 URL Filter entitlement。

当前包只测试原生界面和本地数据逻辑，没有 URL Filter extension 或真实广告过滤。
当前阶段报告属于开发记录，不代表原生构建、所有 G1/G2 验收或 G0 准入已经通过。

手动生成工程时使用：

```sh
xcodegen generate --spec xcodegen.yml
```

Actions 同时上传 build-logs 供检查 Core 与 Xcode 的真实执行结果。
