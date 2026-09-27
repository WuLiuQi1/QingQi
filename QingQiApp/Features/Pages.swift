import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var model: QingQiAppModel
    var body: some View { NavigationStack { QingQiPage { Text("让每一次打开，更轻一点。").foregroundStyle(QingQiColors.secondary); QingQiCard { Label("过滤能力尚未接入", systemImage: "leaf").font(.title2.bold()); Text("当前仅提供 UI 和纯数据层演示，不会安装系统配置或拦截广告。").foregroundStyle(QingQiColors.secondary); Text(model.message).font(.footnote).foregroundStyle(QingQiColors.secondary); QingQiPrimaryButton("重新读取系统状态") { Task { await model.refresh() } } }; QingQiCard { Text("当前配置").font(.headline); Text("系统状态：\(String(describing: model.snapshot.state))"); Text("规则版本：\(model.snapshot.appliedRuleVersion ?? "无")") }; Text("真实版本需在 iOS 26+、签名 target 和普通真机上完成 G0 验证。").font(.footnote).foregroundStyle(QingQiColors.secondary) }.navigationTitle("轻启") }
}

struct RulesView: View {
    var body: some View { NavigationStack { QingQiPage { Text("规则透明，使用才安心。").foregroundStyle(QingQiColors.secondary); QingQiCard { Text("基础广告规则").font(.title2.bold()); Text("固定配置档的元数据演示，未接入真实 Bloom/PIR 数据。").foregroundStyle(QingQiColors.secondary) }; ForEach(["ads.example.com", "media.example.net/ad/", "account.example.org"], id: \.self) { item in QingQiCard { Text("示例规则").font(.headline); Text(item).font(.body.monospaced()); Text("未测试，不可发布").font(.footnote).foregroundStyle(QingQiColors.secondary) } } }.navigationTitle("规则") } }
}

struct DiagnosticsView: View {
    @EnvironmentObject private var model: QingQiAppModel
    var body: some View { NavigationStack { QingQiPage { Text("先弄清问题，再调整设置。").foregroundStyle(QingQiColors.secondary); QingQiCard { Label("受控自检尚未可用", systemImage: "stethoscope").font(.title2.bold()); Text("当前不会发送真实请求，也不会读取浏览记录。").foregroundStyle(QingQiColors.secondary); QingQiPrimaryButton("重新读取配置") { Task { await model.refresh() } }.disabled(model.isBusy) }; QingQiCard { Text("检查项目").font(.headline); Text("系统配置：\(model.stateTitle)"); Text("规则数据：示例，不代表生效"); Text("受控资源：未发送真实请求"); Text("PIR 服务：尚未接入") }; if !model.events.isEmpty { QingQiCard { Text("配置事件").font(.headline); ForEach(model.events.prefix(5)) { Text($0.name).font(.footnote).foregroundStyle(QingQiColors.secondary) } } } }.navigationTitle("诊断") } }
}

struct SettingsView: View {
    @EnvironmentObject private var model: QingQiAppModel
    var body: some View { NavigationStack { QingQiPage { Text("简单设置，清楚掌控。").foregroundStyle(QingQiColors.secondary); QingQiCard { Text("外观").font(.headline); Text("跟随系统（工程骨架）") }; QingQiCard { Text("隐私与数据").font(.headline); Text("浏览记录：不读取"); Text("诊断上传：默认不上报"); Text("正式 PIR 与规则分发的服务端数据流需在 G0 后实测披露。" ).foregroundStyle(QingQiColors.secondary); Button("清除本地配置事件") { Task { await model.clearEvents() } }.frame(minHeight: 44) }; QingQiCard { Text("反馈草稿").font(.headline); Text("问题类别：\(model.feedback.category.rawValue)"); Button("保存当前草稿") { Task { await model.saveFeedback() } }.frame(minHeight: 44) }; QingQiCard { Text("帮助").font(.headline); Text("真实版本提供可验证的关闭与移除入口。") } }.navigationTitle("设置") } }
}
