import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var model: QingQiAppModel
    var body: some View {
        NavigationStack {
            QingQiPage {
                Text("让每一次打开，更轻一点。").foregroundStyle(QingQiColors.secondary)
                QingQiCard {
                    Label("原生 URL Filter", systemImage: "leaf").font(.title2.bold())
                    Text("可通过设置配置 Apple 系统过滤；是否运行取决于 entitlement、Bloom prefilter、PIR 服务和系统授权。").foregroundStyle(QingQiColors.secondary)
                    Text(model.message).font(.footnote).foregroundStyle(QingQiColors.secondary)
                    QingQiPrimaryButton("重新读取系统状态") { Task { await model.refresh() } }
                }
                QingQiCard {
                    Text("当前配置").font(.headline)
                    Text("系统状态：\(String(describing: model.snapshot.state))")
                    Text("规则版本：\(model.snapshot.appliedRuleVersion ?? "无")")
                }
                Text("真实版本需在 iOS 26+、签名 target 和普通真机上完成 G0 验证。").font(.footnote).foregroundStyle(QingQiColors.secondary)
            }
            .navigationTitle("轻启")
        }
    }
}

struct RulesView: View {
    var body: some View {
        NavigationStack {
            QingQiPage {
                Text("规则透明，使用才安心。").foregroundStyle(QingQiColors.secondary)
                QingQiCard {
                    Text("基础广告规则").font(.title2.bold())
                    Text("固定配置档的元数据演示，未接入真实 Bloom/PIR 数据。").foregroundStyle(QingQiColors.secondary)
                }
                ForEach(["ads.example.com", "media.example.net/ad/", "account.example.org"], id: \.self) { item in
                    QingQiCard {
                        Text("示例规则").font(.headline)
                        Text(item).font(.body.monospaced())
                        Text("未测试，不可发布").font(.footnote).foregroundStyle(QingQiColors.secondary)
                    }
                }
            }
            .navigationTitle("规则")
        }
    }
}

struct DiagnosticsView: View {
    @EnvironmentObject private var model: QingQiAppModel
    var body: some View {
        NavigationStack {
            QingQiPage {
                Text("先弄清问题，再调整设置。").foregroundStyle(QingQiColors.secondary)
                QingQiCard {
                    Label("受控自检尚未可用", systemImage: "stethoscope").font(.title2.bold())
                    Text("当前不会发送真实请求，也不会读取浏览记录。").foregroundStyle(QingQiColors.secondary)
                    QingQiPrimaryButton("重新读取配置") { Task { await model.refresh() } }.disabled(model.isBusy)
                }
                QingQiCard {
                    Text("检查项目").font(.headline)
                    Text("系统配置：\(model.stateTitle)")
                    Text("规则数据：示例，不代表生效")
                    Text("受控资源：未发送真实请求")
                    Text("PIR 服务：尚未接入")
                }
                if !model.events.isEmpty {
                    QingQiCard {
                        Text("配置事件").font(.headline)
                        ForEach(model.events.prefix(5)) { Text($0.name).font(.footnote).foregroundStyle(QingQiColors.secondary) }
                    }
                }
            }
            .navigationTitle("诊断")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var model: QingQiAppModel
    @AppStorage("appearance") private var appearance = 0
    @AppStorage("qingqi.pirServerURL") private var pirServerURL = ""
    @AppStorage("qingqi.pirAuthenticationToken") private var pirAuthenticationToken = ""
    @AppStorage("qingqi.shouldFailClosed") private var shouldFailClosed = true
    var body: some View {
        NavigationStack {
            QingQiPage {
                Text("简单设置，清楚掌控。").foregroundStyle(QingQiColors.secondary)
                QingQiCard {
                    Text("外观").font(.headline)
                    Picker("外观", selection: $appearance) {
                        Text("跟随系统").tag(0)
                        Text("浅色").tag(1)
                        Text("深色").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("外观模式")
                }
                QingQiCard {
                    Text("真实 URL Filter").font(.headline)
                    TextField("PIR 服务地址，例如 http://Mac局域网地址:8080", text: $pirServerURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    SecureField("PIR 认证 token", text: $pirAuthenticationToken)
                    Toggle("PIR 失败时阻止请求", isOn: $shouldFailClosed)
                    Text("需要 Apple URL Filter entitlement、官方 Bloom prefilter 和可访问的 PIR 服务；未配置时不会显示成功。")
                        .font(.footnote).foregroundStyle(QingQiColors.secondary)
                    QingQiPrimaryButton("保存并请求系统授权") { Task { await model.requestEnable() } }
                        .disabled(model.isBusy)
                    Button("关闭系统过滤") { Task { await model.disable() } }
                        .frame(minHeight: 44)
                    Button("移除系统过滤配置", role: .destructive) { Task { await model.removeConfiguration() } }
                        .frame(minHeight: 44)
                }
                QingQiCard {
                    Text("隐私与数据").font(.headline)
                    Text("浏览记录：不读取")
                    Text("诊断上传：默认不上报")
                    Text("正式 PIR 与规则分发的服务端数据流需在 G0 后实测披露。").foregroundStyle(QingQiColors.secondary)
                    Button("清除本地配置事件") { Task { await model.clearEvents() } }.frame(minHeight: 44)
                }
                QingQiCard {
                    Text("反馈草稿").font(.headline)
                    Text("问题类别：\(model.feedback.category.rawValue)")
                    Button("保存当前草稿") { Task { await model.saveFeedback() } }.frame(minHeight: 44)
                }
                QingQiCard { Text("帮助").font(.headline); Text("真实版本提供可验证的关闭与移除入口。") }
            }
            .navigationTitle("设置")
        }
    }
}
