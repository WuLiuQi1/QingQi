import SwiftUI

public enum QingQiColors {
    public static let background = Color(red: 0.957, green: 0.965, blue: 0.953)
    public static let surface = Color.white
    public static let ink = Color(red: 0.086, green: 0.208, blue: 0.176)
    public static let secondary = Color(red: 0.357, green: 0.439, blue: 0.404)
    public static let accent = Color(red: 0.031, green: 0.435, blue: 0.353)
    public static let soft = Color(red: 0.898, green: 0.949, blue: 0.922)
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
