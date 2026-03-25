import SwiftUI

struct MaclubUserProfileView: View {
    @StateObject private var authService = AuthService.shared
    @State private var isRefreshing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            if let user = authService.currentUser {
                AsyncImage(url: URL(string: user.profilePhotoURL ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                    
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        if user.isVIPValid {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("VIP会员")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text(authService.getVIPStatusMessage())
                                .foregroundColor(.red)
                        }
                    }
                    .font(.subheadline)
                    .padding(.top, 4)
                }
                
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: {
                        Task {
                            isRefreshing = true
                            await authService.refreshUserInfo()
                            isRefreshing = false
                        }
                    }) {
                        HStack {
                            if isRefreshing {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("刷新")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isRefreshing)
                    
                    Button(action: {
                        authService.logout()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("退出登录")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                
                if !user.isVIPValid {
                    VStack(spacing: 8) {
                        Text("VIP可以使用更多工具")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            if let url = URL(string: "https://www.maclub.net/my/vip") {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            Text("购买VIP")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding()
        .frame(width: 280)
    }
}
