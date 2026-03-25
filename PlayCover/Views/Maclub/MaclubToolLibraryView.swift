import SwiftUI

struct MaclubToolLibraryView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showLoginSheet = false
    @State private var showUserProfile = false
    
    private var apps: [FixApp] {
        AppDataManager.shared.apps
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(apps) { app in
                    Button(action: {
                        AppDetailWindowManager.shared.openAppDetail(appId: app.id, title: app.name)
                    }) {
                        ToolAppCard(app: app)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .navigationTitle("工具库")
        .sheet(isPresented: $showLoginSheet) {
            MaclubLoginView()
        }
        .sheet(isPresented: $showUserProfile) {
            MaclubUserProfileView()
        }
    }
}

struct ToolAppCard: View {
    let app: FixApp
    
    private var iconURL: URL? {
        URL(string: "https://www.maclub.net/api/software/icon/\(app.id)")
    }
    
    var body: some View {
        VStack(spacing: 12) {
            AsyncImage(url: iconURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure, .empty:
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                @unknown default:
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                }
            }
            .frame(width: 80, height: 80)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(16)
            
            VStack(spacing: 4) {
                Text(app.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(app.tools.count) 个工具")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(.textBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
