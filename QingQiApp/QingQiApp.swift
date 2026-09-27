import SwiftUI

@main
struct QingQiApp: App {
    @StateObject private var model: QingQiAppModel

    init() {
        #if canImport(NetworkExtension)
        if #available(iOS 26.0, *) {
            _model = StateObject(wrappedValue: QingQiAppModel(engine: NativeURLFilterEngine()))
        } else {
            _model = StateObject(wrappedValue: QingQiAppModel())
        }
        #else
        _model = StateObject(wrappedValue: QingQiAppModel())
        #endif
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
            Text("原生 URL Filter · 需要系统授权与 PIR 配置").font(.caption).foregroundStyle(QingQiColors.accent).frame(maxWidth: .infinity).padding(9).background(QingQiColors.soft)
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
