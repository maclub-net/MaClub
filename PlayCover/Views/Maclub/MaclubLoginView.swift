import SwiftUI

struct MaclubLoginView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .background(Circle().fill(Color.white.opacity(0.8)))
                            .padding(4)
                    }
                    .buttonStyle(.plain)
                }
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.2))
                            .frame(width: 80, height: 80)
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color.accentColor)
                    }
                    
                    Text("登录到 Mac俱乐部")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 16)
                
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .center)
                        
                        TextField("邮箱地址", text: $email)
                            .font(.system(size: 16))
                            .disableAutocorrection(true)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                    
                    HStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .center)
                        
                        SecureField("密码", text: $password)
                            .font(.system(size: 16))
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.controlBackgroundColor))
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                    
                    if let error = authService.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    
                    Button(action: {
                        Task {
                            await authService.login(email: email, password: password)
                            if authService.isAuthenticated {
                                dismiss()
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            if authService.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text("登录")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundColor(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
                    .opacity((email.isEmpty || password.isEmpty || authService.isLoading) ? 0.7 : 1.0)
                }
                .padding(.horizontal, 48)
                
                VStack(spacing: 16) {
                    
                    Text("还没有账号？")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        if let url = URL(string: "https://www.maclub.net/register") {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        Text("立即注册")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.accentColor)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.accentColor, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 24)
            }
            .frame(width: 440)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.95)))
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
