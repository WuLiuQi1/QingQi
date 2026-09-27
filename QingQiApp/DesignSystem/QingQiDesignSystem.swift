import SwiftUI

public enum QingQiColors {
    public static let background = Color(uiColor: .systemGroupedBackground)
    public static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    public static let ink = Color(uiColor: .label)
    public static let secondary = Color(uiColor: .secondaryLabel)
    public static let accent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.51, green: 0.85, blue: 0.71, alpha: 1)
            : UIColor(red: 0.03, green: 0.44, blue: 0.35, alpha: 1)
    })
    public static let soft = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.24, blue: 0.19, alpha: 1)
            : UIColor(red: 0.90, green: 0.95, blue: 0.92, alpha: 1)
    })
}

public struct QingQiCard<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View { VStack(alignment: .leading, spacing: 14) { content }.padding(20).frame(maxWidth: .infinity, alignment: .leading).background(QingQiColors.surface, in: RoundedRectangle(cornerRadius: 24)) }
}

public struct QingQiPrimaryButton: View {
    let title: String; let action: () -> Void
    public init(_ title: String, action: @escaping () -> Void) { self.title = title; self.action = action }
    public var body: some View { Button(title, action: action).font(.headline).frame(maxWidth: .infinity, minHeight: 52).foregroundStyle(.white).background(QingQiColors.accent, in: RoundedRectangle(cornerRadius: 17)).buttonStyle(.plain) }
}

public struct QingQiPage<Content: View>: View {
    private let content: Content
    public init(@ViewBuilder content: () -> Content) { self.content = content() }
    public var body: some View { ScrollView { VStack(alignment: .leading, spacing: 20) { content }.padding(20).frame(maxWidth: 640, alignment: .leading).frame(maxWidth: .infinity) }.background(QingQiColors.background.ignoresSafeArea()) }
}
