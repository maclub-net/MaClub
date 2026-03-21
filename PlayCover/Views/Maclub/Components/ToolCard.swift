import SwiftUI

struct ToolCard: View {
    let tool: FixTool
    @State private var isHovered = false
    @State private var isPressed = false
    @State private var showDetail = false
    @StateObject private var fixService = FixService()
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        Button(action: {
            if authService.isAuthenticated {
                showDetail = true
            } else {
                NotificationCenter.default.post(name: .showLoginSheet, object: nil)
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: tool.icon)
                        .font(.title2)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 32, height: 32)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tool.name)
                            .font(.headline)
                        
                        Text(tool.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Text(tool.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(16)
            .background(Color(nsColor: isPressed ? .controlColor : .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHovered ? Color.accentColor.opacity(0.5) : Color.primary.opacity(0.1), lineWidth: 1)
            }
            .scaleEffect(isHovered && !isPressed ? 1.02 : (isPressed ? 0.98 : 1.0))
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.borderless)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .sheet(isPresented: $showDetail) {
            ToolDetailView(tool: tool, isPresented: $showDetail)
        }
    }
}

struct ToolDetailView: View {
    let tool: FixTool
    @Binding var isPresented: Bool
    @StateObject private var fixService = FixService()
    @StateObject private var authService = AuthService.shared
    @State private var isCloseButtonHovered = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: tool.icon)
                    .font(.title)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(tool.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(tool.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(isCloseButtonHovered ? .primary : .secondary)
                        .padding(8)
                        .background(isCloseButtonHovered ? Color(nsColor: .controlColor) : Color.clear)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isCloseButtonHovered = true
                        }
                        .onEnded { _ in
                            isCloseButtonHovered = false
                        }
                )
            }
            .padding(20)
            .background(Color(nsColor: .controlBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.primary.opacity(0.1))
                    .position(x: .infinity, y: .infinity)
            )
            
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        Text("详细说明")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(tool.detailedDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(8)
                        
                        if !fixService.lastOutput.isEmpty || !fixService.lastError.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("执行结果")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if !fixService.lastOutput.isEmpty {
                                    Text(fixService.lastOutput)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .padding(16)
                                        .background(Color(nsColor: .controlBackgroundColor))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                if !fixService.lastError.isEmpty {
                                    Text(fixService.lastError)
                                        .font(.body)
                                        .foregroundStyle(.red)
                                        .padding(16)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    if authService.canUseTools() {
                        Task {
                            await fixService.executeFix(tool: tool)
                        }
                    } else {
                        NotificationCenter.default.post(name: .showLoginSheet, object: nil)
                    }
                }) {
                    HStack(spacing: 8) {
                        if fixService.isExecuting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wrench.fill")
                                .font(.headline)
                        }
                        Text(fixService.isExecuting ? "执行中..." : authService.canUseTools() ? "使用工具" : "需要VIP")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(authService.canUseTools() ? Color.accentColor : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .disabled(fixService.isExecuting || !authService.canUseTools())
                }
                .buttonStyle(.plain)
                .padding(8)
                .background(Color(nsColor: .controlBackgroundColor))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.primary.opacity(0.1))
                        .position(x: .infinity, y: 0)
                )
            }
        }
        .frame(minWidth: 700, maxWidth: 700, maxHeight: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}
