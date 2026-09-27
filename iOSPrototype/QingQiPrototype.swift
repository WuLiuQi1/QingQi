// QingQi: UI-only prototype. Does not install profiles or filter traffic.
// Create a new SwiftUI iOS app, remove its generated @main file, and add this file.
// Production Network Extension integration is intentionally NOT implemented here.

import SwiftUI
import Foundation

@main
@MainActor
struct QingQiPrototypeApp: App {
    @StateObject private var model = PrototypeModel()

    var body: some Scene {
        WindowGroup {
            PrototypeRoot()
                .environmentObject(model)
                .preferredColorScheme(model.appearance == 1 ? .light : model.appearance == 2 ? .dark : nil)
        }
    }
}

enum DemoFilterState {
    case notConfigured, requiresApproval, enabled, disabled
}

struct DemoRule: Identifiable {
    let id: String
    let title: String
    let key: String
    let detail: String

    static let examples: [DemoRule] = [
        .init(id: "domain", title: "广告域名示例", key: "ads.example.com",
              detail: "演示独立广告域名的说明方式。此保留域名不是实际广告规则，也没有接入系统过滤。"),
        .init(id: "url", title: "URL 组成项示例", key: "media.example.net/ad/",
              detail: "演示 URL 规则元数据。实际匹配必须遵守苹果 URL 解析与数据集规范，不能直接当作任意字符串前缀匹配。"),
        .init(id: "exception", title: "误拦截修复示例", key: "account.example.org",
              detail: "展示发布级误拦截修复。不是按 App 放行，也不代表个人白名单已实现。")
    ]
}

@MainActor
final class PrototypeModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var state: DemoFilterState = .notConfigured
    @Published var showSetup = false
    @Published var appearance = 0
    @Published var didCheck = false
    @Published var checkWasEnabled = false
    @Published var events: [String] = []
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false

    var isDemoEnabled: Bool { state == .enabled }

    var stateTitle: String {
        switch state {
        case .notConfigured: return "少一点广告，\n多一点直接。"
        case .requiresApproval: return "等待系统确认"
        case .enabled: return "配置已启用"
        case .disabled: return "过滤已关闭"
        }
    }

    var stateDetail: String {
        switch state {
        case .notConfigured: return "从一个清楚、可控的过滤配置开始。"
        case .requiresApproval: return "正式版需在系统中完成授权，再回到这里检查状态。"
        case .enabled: return "这是界面演示状态，没有过滤任何网络请求。"
        case .disabled: return "这是演示中的关闭状态，设备网络从未被修改。"
        }
    }

    var actionTitle: String {
        switch state {
        case .notConfigured: return "体验设置流程"
        case .requiresApproval: return "模拟授权完成"
        case .enabled: return "关闭演示过滤"
        case .disabled: return "重新体验设置"
        }
    }

    func mainAction() {
        switch state {
        case .notConfigured, .disabled:
            showSetup = true
        case .requiresApproval:
            state = .enabled
            events.insert("模拟配置已启用", at: 0)
        case .enabled:
            state = .disabled
            events.insert("模拟配置已关闭", at: 0)
        }
    }

    func beginSetupDemo() {
        showSetup = false
        state = .requiresApproval
        events.insert("模拟等待系统确认", at: 0)
    }

    func runDemoCheck() {
        didCheck = true
        checkWasEnabled = isDemoEnabled
        events.insert("运行演示自检，没有发送请求", at: 0)
    }

    func showInfo(_ title: String, _ message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

private extension Color {
    init(qingqiRGB: UInt32) {
        self.init(
            .sRGB,
            red: Double((qingqiRGB >> 16) & 255) / 255,
            green: Double((qingqiRGB >> 8) & 255) / 255,
            blue: Double(qingqiRGB & 255) / 255,
            opacity: 1
        )
    }
}

struct QingQiPalette {
    let scheme: ColorScheme
    var dark: Bool { scheme == .dark }
    var background: Color { Color(qingqiRGB: dark ? 0x101916 : 0xF4F6F3) }
    var surface: Color { Color(qingqiRGB: dark ? 0x1A2722 : 0xFFFFFF) }
    var ink: Color { Color(qingqiRGB: dark ? 0xF0F7F2 : 0x16352D) }
    var secondary: Color { Color(qingqiRGB: dark ? 0xAFC2B8 : 0x5B7067) }
    var accent: Color { Color(qingqiRGB: dark ? 0x83D9B6 : 0x086F5A) }
    var soft: Color { Color(qingqiRGB: dark ? 0x203E32 : 0xE5F2EB) }
    var buttonText: Color { dark ? Color(qingqiRGB: 0x16352D) : .white }
}

struct PrototypeRoot: View {
    @EnvironmentObject private var model: PrototypeModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        VStack(spacing: 0) {
            Text("交互演示 · 不会安装配置或拦截广告")
                .font(.caption)
                .foregroundStyle(p.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(p.soft)

            TabView(selection: $model.selectedTab) {
                NavigationStack { OverviewPage() }
                    .tabItem { Label("概览", systemImage: "leaf") }.tag(0)
                NavigationStack { RulesPage() }
                    .tabItem { Label("规则", systemImage: "line.3.horizontal.decrease.circle") }.tag(1)
                NavigationStack { DiagnosticsPage() }
                    .tabItem { Label("诊断", systemImage: "stethoscope") }.tag(2)
                NavigationStack { SettingsPage() }
                    .tabItem { Label("设置", systemImage: "gearshape") }.tag(3)
            }
            .tint(p.accent)
        }
        .sheet(isPresented: $model.showSetup) {
            SetupDemoSheet()
                .environmentObject(model)
        }
        .alert(model.alertTitle, isPresented: $model.showAlert) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(model.alertMessage)
        }
    }
}

struct QingQiPage<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    let content: Content

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { content }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(20)
                .frame(maxWidth: .infinity)
        }
        .background(QingQiPalette(scheme: scheme).background)
    }
}

struct QingQiCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    let content: Content

    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                QingQiPalette(scheme: scheme).surface,
                in: RoundedRectangle(cornerRadius: 24)
            )
    }
}

struct QingQiPrimaryButton: View {
    @Environment(\.colorScheme) private var scheme
    let title: String
    let action: () -> Void

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
                .padding(.horizontal, 12)
                .foregroundStyle(p.buttonText)
                .background(p.accent, in: RoundedRectangle(cornerRadius: 17))
        }
        .buttonStyle(.plain)
    }
}

struct QingQiInfoRow: View {
    @Environment(\.colorScheme) private var scheme
    let label: String
    let value: String

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        HStack(alignment: .top, spacing: 16) {
            Text(label).foregroundStyle(p.secondary)
            Spacer(minLength: 8)
            Text(value).foregroundStyle(p.ink).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}

struct QingQiNote: View {
    @Environment(\.colorScheme) private var scheme
    let title: String
    let text: String
    var symbol = "info.circle"

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol).foregroundStyle(p.accent).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(p.ink)
                Text(text).font(.footnote).foregroundStyle(p.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(p.soft, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct OverviewPage: View {
    @EnvironmentObject private var model: PrototypeModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        QingQiPage {
            Text("让每一次打开，更轻一点。")
                .font(.subheadline).foregroundStyle(p.secondary)

            QingQiCard {
                HStack {
                    Image(systemName: model.isDemoEnabled ? "checkmark.seal" : "leaf")
                        .font(.system(size: 31, weight: .medium))
                        .frame(width: 65, height: 65)
                        .foregroundStyle(p.accent)
                        .background(p.soft, in: RoundedRectangle(cornerRadius: 22))
                        .accessibilityHidden(true)
                    Spacer()
                    Text("演示状态")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(p.accent)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(p.soft, in: Capsule())
                }
                Text(model.stateTitle)
                    .font(.largeTitle.bold()).foregroundStyle(p.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(model.stateDetail)
                    .font(.subheadline).foregroundStyle(p.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                QingQiPrimaryButton(title: model.actionTitle, action: model.mainAction)
            }

            QingQiCard {
                Text("当前配置").font(.headline).foregroundStyle(p.ink)
                QingQiInfoRow(label: "过滤方式", value: "原生 URL 过滤 · 计划")
                Divider()
                QingQiInfoRow(label: "规则版本", value: "示例 v0.1")
                Divider()
                QingQiInfoRow(label: "最近自检", value: model.didCheck ? "仅有演示结果" : "尚未运行")
            }

            QingQiNote(
                title: "减少广告，不承诺万能",
                text: "正式版只覆盖系统支持的请求。内置、缓存广告和倒计时可能仍然存在。"
            )

            Button {
                model.selectedTab = 2
            } label: {
                Label("检查配置与网络", systemImage: "stethoscope")
                    .font(.subheadline.weight(.semibold)).frame(minHeight: 44)
            }
        }
        .navigationTitle("轻启")
    }
}

struct RulesPage: View {
    @EnvironmentObject private var model: PrototypeModel
    @Environment(\.colorScheme) private var scheme
    @State private var search = ""

    private var visibleRules: [DemoRule] {
        if search.isEmpty { return DemoRule.examples }
        return DemoRule.examples.filter {
            $0.title.localizedCaseInsensitiveContains(search) ||
            $0.key.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        QingQiPage {
            Text("规则透明，使用才安心。").font(.subheadline).foregroundStyle(p.secondary)

            QingQiCard {
                Label("基础广告规则", systemImage: "line.3.horizontal.decrease.circle")
                    .font(.title3.weight(.semibold)).foregroundStyle(p.ink)
                Text("优先减少误拦截，而不是盲目增加规则数量。")
                    .font(.subheadline).foregroundStyle(p.secondary)
                QingQiInfoRow(label: "本页内容", value: "3 条说明示例")
                QingQiInfoRow(label: "应用状态", value: "未接入真实规则")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("规则说明").font(.headline).foregroundStyle(p.ink)
                if visibleRules.isEmpty {
                    QingQiNote(title: "没有匹配的示例", text: "尝试搜索 example 或规则名称。")
                }
                ForEach(visibleRules) { rule in
                    NavigationLink {
                        RuleDetailPage(rule: rule)
                    } label: {
                        QingQiCard {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(rule.title).font(.headline).foregroundStyle(p.ink)
                                    Text(rule.key).font(.footnote.monospaced()).foregroundStyle(p.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer(minLength: 4)
                                Image(systemName: "chevron.right").font(.footnote).foregroundStyle(p.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            QingQiNote(title: "暂不提供按 App 放行",
                       text: "规则的应用说明不等于系统能识别请求来源。正式版先使用一个经过验证的固定配置档。")
        }
        .navigationTitle("规则")
        .searchable(text: $search, prompt: "搜索示例规则")
    }
}

struct RuleDetailPage: View {
    @Environment(\.colorScheme) private var scheme
    let rule: DemoRule

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        QingQiPage {
            QingQiCard {
                Text(rule.title).font(.title2.bold()).foregroundStyle(p.ink)
                Text(rule.key).font(.body.monospaced()).foregroundStyle(p.accent)
                    .textSelection(.enabled)
                Text(rule.detail).font(.body).foregroundStyle(p.secondary)
                Divider()
                QingQiInfoRow(label: "来源", value: "设计示例")
                QingQiInfoRow(label: "验证状态", value: "未测试，不可发布")
            }
            QingQiNote(title: "正式规则需要证据",
                       text: "规则详情将记录来源、许可、验证日期、测试版本与已知影响。这里没有编造兼容性或成功率。")
        }
        .navigationTitle("规则详情").navigationBarTitleDisplayMode(.inline)
    }
}

struct DiagnosticsPage: View {
    @EnvironmentObject private var model: PrototypeModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        QingQiPage {
            Text("先弄清问题，再调整设置。").font(.subheadline).foregroundStyle(p.secondary)
            QingQiCard {
                Image(systemName: "stethoscope")
                    .font(.system(size: 36, weight: .medium)).foregroundStyle(p.accent)
                    .accessibilityHidden(true)
                Text("给配置做个自检").font(.title2.bold()).foregroundStyle(p.ink)
                Text("正式版仅检查受控资源，不扫描 App，也不读取浏览记录。")
                    .font(.subheadline).foregroundStyle(p.secondary)
                QingQiPrimaryButton(title: "运行演示自检", action: model.runDemoCheck)
            }
            QingQiCard {
                Text("检查项目").font(.headline).foregroundStyle(p.ink)
                QingQiInfoRow(label: "配置状态", value: model.didCheck ? (model.checkWasEnabled ? "模拟已启用" : "模拟未启用") : "未检查")
                Divider()
                QingQiInfoRow(label: "规则数据", value: model.didCheck ? "示例数据，不代表生效" : "未检查")
                Divider()
                QingQiInfoRow(label: "受控资源", value: "未发送真实请求")
                Divider()
                QingQiInfoRow(label: "PIR 服务", value: "尚未接入")
            }
            QingQiNote(title: "请求失败不等于拦截成功",
                       text: "断网、服务故障和过滤阻止必须分开判断。证据不足时，正式版会显示“无法判断”。")
            if !model.events.isEmpty {
                QingQiCard {
                    Text("本次演示事件").font(.headline).foregroundStyle(p.ink)
                    ForEach(Array(model.events.prefix(5).enumerated()), id: \.offset) { item in
                        Text(item.element).font(.footnote).foregroundStyle(p.secondary)
                    }
                }
            }
        }
        .navigationTitle("诊断")
    }
}

struct SettingsPage: View {
    @EnvironmentObject private var model: PrototypeModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        QingQiPage {
            Text("简单设置，清楚掌控。").font(.subheadline).foregroundStyle(p.secondary)

            QingQiCard {
                Label("外观", systemImage: "circle.lefthalf.filled")
                    .font(.headline).foregroundStyle(p.ink)
                Picker("外观", selection: $model.appearance) {
                    Text("系统").tag(0)
                    Text("浅色").tag(1)
                    Text("深色").tag(2)
                }
                .pickerStyle(.segmented)
            }

            QingQiCard {
                Text("隐私与数据").font(.headline).foregroundStyle(p.ink)
                QingQiInfoRow(label: "浏览记录", value: "原型不读取")
                Divider()
                QingQiInfoRow(label: "诊断上传", value: "原型不联网")
                Divider()
                Button("清除本次演示事件") {
                    model.events.removeAll()
                    model.didCheck = false
                    model.showInfo("已清除演示事件", "只清理了当前原型内存中的事件，没有修改系统配置。")
                }
                .font(.subheadline).frame(minHeight: 44)
            }

            QingQiCard {
                Text("帮助").font(.headline).foregroundStyle(p.ink)
                Button("覆盖范围与限制") {
                    model.showInfo("覆盖范围", "计划采用 iOS 26 官方 URL Filter。WebKit / URLSession 以外且未参与的请求不保证覆盖；缓存广告和倒计时可能保留。")
                }.frame(minHeight: 44)
                Divider()
                Button("服务端与隐私") {
                    model.showInfo("不是零服务器方案", "正式架构需要规则分发与 PIR 隐私查询服务，不转发完整业务流量。费用与生产隐私配置需先做技术验证。")
                }.frame(minHeight: 44)
                Divider()
                Button("功能异常时怎么办") {
                    model.showInfo("恢复与反馈", "正式版首先提供清楚、可验证的关闭入口，再由用户主动提交脱敏反馈。原型不会修改任何网络设置。")
                }.frame(minHeight: 44)
            }
            QingQiNote(title: "轻启 · 设计原型 V1",
                       text: "Swift + SwiftUI。没有 Network Extension、广告拦截、PIR 服务或真实规则更新功能。",
                       symbol: "leaf")
        }
        .navigationTitle("设置")
    }
}

struct SetupDemoSheet: View {
    @EnvironmentObject private var model: PrototypeModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = QingQiPalette(scheme: scheme)
        NavigationStack {
            QingQiPage {
                Text("先了解，再开启").font(.largeTitle.bold()).foregroundStyle(p.ink)
                QingQiNote(title: "这是流程演示",
                           text: "接下来的操作不会弹出真实系统授权，也不会安装过滤配置。")
                QingQiCard {
                    Label("不自动点击其他 App", systemImage: "hand.tap")
                    Label("不转发完整业务流量", systemImage: "arrow.triangle.branch")
                    Label("正式版需要 PIR 服务", systemImage: "server.rack")
                    Label("不保证所有广告都消失", systemImage: "info.circle")
                }
                Text("正式版将调用系统接口，由 iOS 展示实际授权流程。用户返回后，App 会重新读取配置，而不是直接显示成功。")
                    .font(.body).foregroundStyle(p.secondary)
                QingQiPrimaryButton(title: "模拟进入等待确认", action: model.beginSetupDemo)
            }
            .navigationTitle("设置说明").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }
}

@MainActor
struct QingQiPrototypePreview: PreviewProvider {
    static var previews: some View {
        PrototypeRoot().environmentObject(PrototypeModel())
    }
}
