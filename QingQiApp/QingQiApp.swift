import SwiftUI

@main
struct QingQiApp: App {
    @StateObject private var model: QingQiAppModel

    init() {
        // V2 当前主线是短信过滤与来电目录；URL Filter 保留在研究 target，
        // 不在 Release 主 App 中伪装成已启用的广告拦截能力。
        _model = StateObject(wrappedValue: QingQiAppModel())
    }

    var body: some Scene { WindowGroup { QingQiRootView(model: model) } }
}

struct QingQiRootView: View {
    @StateObject private var model: QingQiAppModel
    @AppStorage("appearance") private var appearance = 0
    @State private var tab = 0
    init(model: QingQiAppModel) {
        _model = StateObject(wrappedValue: model)
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("短信与来电保护 · 广告拦截暂缓").font(.caption).foregroundStyle(QingQiColors.accent).frame(maxWidth: .infinity).padding(9).background(QingQiColors.soft)
            TabView(selection: $tab) {
                OverviewView().environmentObject(model).tabItem { Label("概览", systemImage: "leaf") }.tag(0)
                RulesView().tabItem { Label("规则", systemImage: "line.3.horizontal.decrease.circle") }.tag(1)
                DiagnosticsView().environmentObject(model).tabItem { Label("诊断", systemImage: "stethoscope") }.tag(2)
                SettingsView().environmentObject(model).tabItem { Label("设置", systemImage: "gearshape") }.tag(3)
            }.tint(QingQiColors.accent)
        }
        .task { await model.loadLocalData(); await model.refresh() }
        .preferredColorScheme(appearance == 1 ? .light : appearance == 2 ? .dark : nil)
    }
}
