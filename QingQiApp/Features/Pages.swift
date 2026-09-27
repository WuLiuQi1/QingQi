import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var model: QingQiAppModel

    var body: some View {
        NavigationStack {
            QingQiPage {
                Text("先把骚扰短信和来电，安静地挡在外面。")
                    .foregroundStyle(QingQiColors.secondary)
                QingQiCard {
                    Label("短信过滤", systemImage: "message.badge.filled.fill")
                        .font(.title2.bold())
                    Text("面向未知发送者的 SMS / MMS。正式版将由 iOS Messages 调用短信过滤扩展。")
                        .foregroundStyle(QingQiColors.secondary)
                    Text(model.message)
                        .font(.footnote)
                        .foregroundStyle(QingQiColors.secondary)
                    QingQiPrimaryButton("重新读取系统状态") { Task { await model.refresh() } }
                }
                QingQiCard {
                    Label("来电过滤", systemImage: "phone.badge.waveform.fill")
                        .font(.title2.bold())
                    Text("正式版将通过 Call Directory 提供号码识别与拦截。")
                        .foregroundStyle(QingQiColors.secondary)
                    Text("当前状态：准备接入系统扩展")
                        .font(.footnote)
                        .foregroundStyle(QingQiColors.secondary)
                }
                QingQiCard {
                    Label("广告拦截", systemImage: "shield.lefthalf.filled")
                        .font(.headline)
                    Text("暂缓。保留 URL Filter 技术验证记录，不作为当前版本承诺。")
                        .foregroundStyle(QingQiColors.secondary)
                }
                Text("短信和来电能力也必须经过系统设置启用与真机验证。")
                    .font(.footnote)
                    .foregroundStyle(QingQiColors.secondary)
            }
            .navigationTitle("轻启")
        }
    }
}

struct RulesView: View {
    var body: some View {
        NavigationStack {
            QingQiPage {
                Text("规则透明，使用才安心。")
                    .foregroundStyle(QingQiColors.secondary)
                QingQiCard {
                    Text("短信规则")
                        .font(.title2.bold())
                    Text("垃圾、营销、诈骗等分类由短信过滤扩展返回给 Messages。")
                        .foregroundStyle(QingQiColors.secondary)
                    Text("当前：规则编辑与系统扩展尚未接入")
                        .font(.footnote)
                        .foregroundStyle(QingQiColors.secondary)
                }
                ForEach(["营销短信 · promotion", "诈骗短信 · fraud", "骚扰短信 · junk"], id: \.self) { item in
                    QingQiCard {
                        Text(item).font(.headline)
                        Text("规划中 · 需要数据源、误报复核和系统扩展")
                            .foregroundStyle(QingQiColors.secondary)
                    }
                }
                QingQiCard {
                    Text("来电规则")
                        .font(.headline)
                    Text("号码识别与拦截目录必须按号码升序批量提供给 Call Directory。")
                    Text("规划中 · 未接入系统扩展")
                        .font(.footnote)
                        .foregroundStyle(QingQiColors.secondary)
                }
                QingQiCard {
                    Text("广告拦截规则")
                        .font(.headline)
                    Text("暂不发布 URL Filter 规则。待 entitlement、PIR 服务和真机证据完整后重新评估。")
                        .foregroundStyle(QingQiColors.secondary)
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
                Text("先弄清问题，再调整设置。")
                    .foregroundStyle(QingQiColors.secondary)
                QingQiCard {
                    Label("系统能力自检", systemImage: "stethoscope")
                        .font(.title2.bold())
                    Text("短信过滤：待用户在系统设置中启用扩展")
                        .foregroundStyle(QingQiColors.secondary)
                    Text("来电过滤：待用户在电话设置中启用扩展")
                        .foregroundStyle(QingQiColors.secondary)
                    Text("广告拦截：暂缓，不发送 URL 请求")
                        .foregroundStyle(QingQiColors.secondary)
                    QingQiPrimaryButton("重新读取配置") { Task { await model.refresh() } }
                        .disabled(model.isBusy)
                }
                QingQiCard {
                    Text("检查项目").font(.headline)
                    Text("短信扩展：未安装")
                    Text("来电扩展：未安装")
                    Text("广告 URL Filter：暂缓")
                    Text("诊断上传：默认不上报")
                }
                if !model.events.isEmpty {
                    QingQiCard {
                        Text("配置事件").font(.headline)
                        ForEach(model.events.prefix(5)) { event in
                            Text(event.name)
                                .font(.footnote)
                                .foregroundStyle(QingQiColors.secondary)
                        }
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

    var body: some View {
        NavigationStack {
            QingQiPage {
                Text("简单设置，清楚掌控。")
                    .foregroundStyle(QingQiColors.secondary)
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
                    Text("短信与来电过滤").font(.headline)
                    Text("正式版将在这里提供规则开关、数据源和系统扩展启用状态。当前仅展示产品结构。")
                        .foregroundStyle(QingQiColors.secondary)
                    Label("短信过滤扩展：待接入", systemImage: "message")
                        .frame(minHeight: 44, alignment: .leading)
                    Label("来电识别与拦截：待接入", systemImage: "phone")
                        .frame(minHeight: 44, alignment: .leading)
                }
                QingQiCard {
                    Text("隐私与数据").font(.headline)
                    Text("短信过滤扩展不能直接访问网络；来电目录需要系统批量加载。")
                    Text("诊断上传：默认不上报")
                    Text("广告拦截：暂缓，不安装 URL Filter 配置")
                        .foregroundStyle(QingQiColors.secondary)
                    Button("清除本地配置事件") { Task { await model.clearEvents() } }
                        .frame(minHeight: 44)
                }
                QingQiCard {
                    Text("反馈草稿").font(.headline)
                    Text("问题类别：\(model.feedback.category.rawValue)")
                    Button("保存当前草稿") { Task { await model.saveFeedback() } }
                        .frame(minHeight: 44)
                }
                QingQiCard {
                    Text("帮助").font(.headline)
                    Text("系统过滤扩展需要在 iPhone 设置中单独启用。")
                }
            }
            .navigationTitle("设置")
        }
    }
}
