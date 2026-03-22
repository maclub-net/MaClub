import SwiftUI

struct FixButton: View {
    let title: String
    let isExecuting: Bool
    let action: () async -> Void
    
    @State private var isHovered = false
    @StateObject private var authService = AuthService.shared
    @State private var showVipAlert = false
    
    init(title: String = "执行修复", isExecuting: Bool = false, action: @escaping () async -> Void) {
        self.title = title
        self.isExecuting = isExecuting
        self.action = action
    }
    
    var body: some View {
        Button {
            if !authService.canUseTools() {
                showVipAlert = true
                return
            }
            
            Task {
                await action()
            }
        } label: {
            HStack(spacing: 8) {
                if isExecuting {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image(systemName: "wrench.and.screwdriver")
                }
                
                Text(isExecuting ? "执行中..." : title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isExecuting ? Color.secondary : Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .disabled(isExecuting)
        .animation(.easeInOut(duration: 0.2), value: isExecuting)
        .alert("开通VIP", isPresented: $showVipAlert) {
            if !authService.isAuthenticated {
                Button("取消", role: .cancel) {}
                Button("登录") {
                    showVipAlert = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: .showLoginSheet, object: nil)
                    }
                }
            } else {
                Button("取消", role: .cancel) {}
                Button("去开通") {
                    if let url = URL(string: "https://www.maclub.net") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        } message: {
            Text(authService.isAuthenticated ? "您的VIP已过期或未激活，请续费或购买VIP服务" : "请先登录并购买VIP服务以使用修复工具")
        }
    }
}

extension Notification.Name {
    static let showLoginSheet = Notification.Name("showLoginSheet")
    static let showSearchAppDetail = Notification.Name("showSearchAppDetail")
    static let showToolAppDetail = Notification.Name("showToolAppDetail")
    static let closeAppDetail = Notification.Name("closeAppDetail")
    static let showDownloadManager = Notification.Name("showDownloadManager")
}
