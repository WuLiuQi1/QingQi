import SwiftUI

@main
struct QingQiApp: App {
    var body: some Scene { WindowGroup { QingQiRootView() } }
}

struct QingQiRootView: View {
    @StateObject private var model = QingQiAppModel()
    @State private var tab = 0
    var body: some View {
        VStack(spacing: 0) {
            Text("交互演示 · 真实 URL Filter 尚未接入").font(.caption).foregroundStyle(QingQiColors.accent).frame(maxWidth: .infinity).padding(9).background(QingQiColors.soft)
            TabView(selection: $tab) {
                OverviewView().environmentObject(model).tabItem { Label("概览", systemImage: "leaf") }.tag(0)
                RulesView().tabItem { Label("规则", systemImage: "line.3.horizontal.decrease.circle") }.tag(1)
                DiagnosticsView().environmentObject(model).tabItem { Label("诊断", systemImage: "stethoscope") }.tag(2)
                SettingsView().environmentObject(model).tabItem { Label("设置", systemImage: "gearshape") }.tag(3)
            }.tint(QingQiColors.accent)
        }
        .task { await model.loadLocalData(); await model.refresh() }
    }
}
