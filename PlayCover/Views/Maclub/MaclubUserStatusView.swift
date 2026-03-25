import SwiftUI

struct MaclubUserStatusView: View {
    @ObservedObject var authService: AuthService
    @Binding var showLoginSheet: Bool
    @Binding var showUserProfile: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if let user = authService.currentUser {
                AsyncImage(url: URL(string: user.profilePhotoURL ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        if user.isVIPValid {
                            Image(systemName: "crown.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("VIP")
                                .font(.caption2)
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.red)
                            Text("非VIP")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }
                
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("未登录")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("点击登录")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if authService.isAuthenticated {
                showUserProfile = true
            } else {
                showLoginSheet = true
            }
        }
    }
}
