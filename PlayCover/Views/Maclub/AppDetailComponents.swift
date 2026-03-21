import SwiftUI
import Foundation

struct AppDetailHeaderView: View {
    let detail: AppDetailResponse
    @Binding var isFavorited: Bool
    @Binding var isSubscribed: Bool
    @Binding var isLoadingFreeDownload: Bool
    @Binding var isLoadingHighSpeed: Bool
    @Binding var isLoadingFavorite: Bool
    @Binding var isLoadingSubscribe: Bool
    @Binding var isLoadingCheckUpdate: Bool
    @Binding var isLoadingInstall: Bool
    @Binding var showDownloadPopup: Bool
    @Binding var showHighSpeedDownloadPopup: Bool
    @Binding var highSpeedDownloadLinks: [HighSpeedDownloadLink]
    let downloadService: DownloadService
    let highSpeedDownloadService: HighSpeedDownloadService
    let interactionService: InteractionService
    let authService: AuthService

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            AppIconView(iconUrl: detail.data.appIcon, size: 100)

            VStack(alignment: .leading, spacing: 12) {
                Text(detail.data.appName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                AppInfoTagsView(
                    version: detail.data.version,
                    size: detail.data.size,
                    downloadCount: detail.data.downloadCount
                )

                if !detail.data.tags.isEmpty {
                    AppTagsScrollView(tags: detail.data.tags)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            AppActionButtonsView(
                detail: detail,
                isFavorited: $isFavorited,
                isSubscribed: $isSubscribed,
                isLoadingFreeDownload: $isLoadingFreeDownload,
                isLoadingHighSpeed: $isLoadingHighSpeed,
                isLoadingFavorite: $isLoadingFavorite,
                isLoadingSubscribe: $isLoadingSubscribe,
                isLoadingCheckUpdate: $isLoadingCheckUpdate,
                isLoadingInstall: $isLoadingInstall,
                showDownloadPopup: $showDownloadPopup,
                showHighSpeedDownloadPopup: $showHighSpeedDownloadPopup,
                highSpeedDownloadLinks: $highSpeedDownloadLinks,
                downloadService: downloadService,
                highSpeedDownloadService: highSpeedDownloadService,
                interactionService: interactionService,
                authService: authService
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct AppIconView: View {
    let iconUrl: String
    let size: CGFloat

    var body: some View {
        AsyncImage(url: URL(string: iconUrl)) { phase in
            switch phase {
            case .empty:
                Image(systemName: "app.badge.fill")
                    .font(.system(size: size * 0.6))
                    .foregroundColor(.secondary)
                    .frame(width: size, height: size)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(16)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            case .failure:
                Image(systemName: "app.badge.fill")
                    .font(.system(size: size * 0.6))
                    .foregroundColor(.secondary)
                    .frame(width: size, height: size)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(16)
            @unknown default:
                Image(systemName: "app.badge.fill")
                    .font(.system(size: size * 0.6))
                    .foregroundColor(.secondary)
                    .frame(width: size, height: size)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(16)
            }
        }
    }
}

struct AppInfoTagsView: View {
    let version: String
    let size: String
    let downloadCount: Int

    var formattedSize: String {
        guard let bytes = Double(size) else { return size }
        let mb = bytes / (1024 * 1024)
        if mb >= 1024 {
            let gb = mb / 1024
            return String(format: "%.1f GB", gb)
        }
        return String(format: "%.1f MB", mb)
    }

    var body: some View {
        HStack(spacing: 8) {
            AppTagView(
                icon: "number.circle.fill",
                text: version,
                color: .blue
            )

            AppTagView(
                icon: "doc.fill",
                text: formattedSize,
                color: .green
            )

            AppTagView(
                icon: "arrow.down.to.line",
                text: "\(downloadCount)",
                color: .orange
            )
        }
    }
}

struct AppTagView: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}

struct AppTagsScrollView: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 12))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }
            }
        }
    }
}

struct AppActionButtonsView: View {
    let detail: AppDetailResponse
    @Binding var isFavorited: Bool
    @Binding var isSubscribed: Bool
    @Binding var isLoadingFreeDownload: Bool
    @Binding var isLoadingHighSpeed: Bool
    @Binding var isLoadingFavorite: Bool
    @Binding var isLoadingSubscribe: Bool
    @Binding var isLoadingCheckUpdate: Bool
    @Binding var isLoadingInstall: Bool
    @Binding var showDownloadPopup: Bool
    @Binding var showHighSpeedDownloadPopup: Bool
    @Binding var highSpeedDownloadLinks: [HighSpeedDownloadLink]
    let downloadService: DownloadService
    let highSpeedDownloadService: HighSpeedDownloadService
    let interactionService: InteractionService
    let authService: AuthService

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                InstallButton(
                    isLoading: $isLoadingInstall,
                    detail: detail,
                    highSpeedDownloadService: highSpeedDownloadService,
                    authService: authService
                )

                FreeDownloadButton(
                    isLoading: $isLoadingFreeDownload,
                    showDownloadPopup: $showDownloadPopup,
                    detail: detail,
                    downloadService: downloadService,
                    authService: authService
                )

                HighSpeedDownloadButton(
                    isLoading: $isLoadingHighSpeed,
                    showPopup: $showHighSpeedDownloadPopup,
                    highSpeedDownloadLinks: $highSpeedDownloadLinks,
                    detail: detail,
                    authService: authService
                )
            }

            if detail.data.platforms == "ios" {
                HStack(spacing: 8) {
                    FavoriteButton(
                        isFavorited: $isFavorited,
                        isLoading: $isLoadingFavorite,
                        softwareId: detail.data.id,
                        interactionService: interactionService,
                        authService: authService
                    )
                    
                    SubscribeButton(
                        isSubscribed: $isSubscribed,
                        isLoading: $isLoadingSubscribe,
                        softwareId: detail.data.id,
                        interactionService: interactionService,
                        authService: authService
                    )

                    CheckUpdateButton(
                        isLoading: $isLoadingCheckUpdate,
                        softwareId: detail.data.id,
                        interactionService: interactionService,
                        authService: authService
                    )
                }
            }
        }
    }
}

struct FreeDownloadButton: View {
    @Binding var isLoading: Bool
    @Binding var showDownloadPopup: Bool
    let detail: AppDetailResponse
    let downloadService: DownloadService
    let authService: AuthService

    var body: some View {
        Button(action: {
            guard !isLoading else { return }

            if authService.isAuthenticated {
                if let latestVersion = detail.data.versions.last {
                    isLoading = true
                    Task {
                        await downloadService.getDownloadLinks(versionId: latestVersion.id)
                        isLoading = false

                        if downloadService.error == nil && !downloadService.downloadLinks.isEmpty {
                            showDownloadPopup = true
                        } else {
                            showErrorAlert(message: downloadService.error ?? "无法获取下载链接")
                        }
                    }
                }
            } else {
                NotificationCenter.default.post(name: .showLoginSheet, object: nil)
            }
        }) {
            ActionButtonContent(
                icon: "arrow.down.to.line",
                text: isLoading ? "获取中..." : "免费下载",
                isLoading: isLoading,
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.2, green: 0.6, blue: 1.0), Color(red: 0.1, green: 0.5, blue: 0.9)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct HighSpeedDownloadButton: View {
    @Binding var isLoading: Bool
    @Binding var showPopup: Bool
    @Binding var highSpeedDownloadLinks: [HighSpeedDownloadLink]
    let detail: AppDetailResponse
    let authService: AuthService

    var body: some View {
        Button(action: {
            guard !isLoading else { return }

            if authService.isAuthenticated {
                if let latestVersion = detail.data.versions.last {
                    isLoading = true
                    Task {
                        await fetchHighSpeedLinks(versionId: latestVersion.id)
                    }
                }
            } else {
                NotificationCenter.default.post(name: .showLoginSheet, object: nil)
            }
        }) {
            ActionButtonContent(
                icon: "bolt.fill",
                text: isLoading ? "获取中..." : "高速下载",
                isLoading: isLoading,
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color(red: 1.0, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.5, blue: 0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    private func fetchHighSpeedLinks(versionId: Int) async {
        let urlString = "https://www.maclub.net/appstore/dl/\(versionId)/vip"
        guard let url = URL(string: urlString) else {
            isLoading = false
            showErrorAlert(message: "无效的下载链接")
            return
        }

        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                isLoading = false
                showErrorAlert(message: "服务器返回异常")
                return
            }

            let decoder = JSONDecoder()
            let result = try decoder.decode(HighSpeedDownloadResponse.self, from: data)

            isLoading = false

            if result.code == 200 && !result.data.isEmpty {
                highSpeedDownloadLinks = result.data
                showPopup = true
            } else {
                showErrorAlert(message: result.message ?? "没有可用的下载链接")
            }
        } catch {
            isLoading = false
            showErrorAlert(message: "网络请求失败: \(error.localizedDescription)")
        }
    }
}

struct FavoriteButton: View {
    @Binding var isFavorited: Bool
    @Binding var isLoading: Bool
    let softwareId: String
    let interactionService: InteractionService
    let authService: AuthService

    var body: some View {
        Button(action: {
            guard !isLoading else { return }

            if authService.isAuthenticated {
                isLoading = true
                Task {
                    let success = await interactionService.toggleFavorite(softwareId: softwareId)
                    isLoading = false

                    if success {
                        isFavorited.toggle()
                        showSuccessAlert(message: isFavorited ? "收藏成功" : "已取消收藏")
                    } else {
                        showErrorAlert(message: interactionService.errorMessage ?? "操作失败")
                    }
                }
            } else {
                NotificationCenter.default.post(name: .showLoginSheet, object: nil)
            }
        }) {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 14, height: 14)
                } else {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .font(.system(size: 14, weight: .medium))
                }
                Text(isLoading ? "操作中..." : (isFavorited ? "取消收藏" : "收藏应用"))
                    .font(.system(size: 12, weight: .semibold))
            }
            .frame(width: 90)
            .padding(.vertical, 8)
            .background(
                isFavorited ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 1.0, green: 0.8, blue: 0.2), Color(red: 1.0, green: 0.7, blue: 0.1)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.98, green: 0.92, blue: 0.7), Color(red: 0.95, green: 0.85, blue: 0.5)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
            )
            .foregroundColor(isFavorited ? .white : .primary)
            .cornerRadius(8)
            .shadow(color: isFavorited ? .black.opacity(0.15) : .black.opacity(0.05), radius: isFavorited ? 6 : 4, x: 0, y: isFavorited ? 3 : 2)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct SubscribeButton: View {
    @Binding var isSubscribed: Bool
    @Binding var isLoading: Bool
    let softwareId: String
    let interactionService: InteractionService
    let authService: AuthService

    var body: some View {
        Button(action: {
            guard !isLoading else { return }

            if authService.isAuthenticated {
                isLoading = true
                Task {
                    let success = await interactionService.toggleSubscribe(softwareId: softwareId)
                    isLoading = false

                    if success {
                        isSubscribed.toggle()
                        showSuccessAlert(message: isSubscribed ? "订阅成功" : "已取消订阅")
                    } else {
                        showErrorAlert(message: interactionService.errorMessage ?? "操作失败")
                    }
                }
            } else {
                NotificationCenter.default.post(name: .showLoginSheet, object: nil)
            }
        }) {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 14, height: 14)
                } else {
                    Image(systemName: isSubscribed ? "calendar.badge.minus" : "calendar.badge.plus")
                        .font(.system(size: 14, weight: .medium))
                }
                Text(isLoading ? "操作中..." : (isSubscribed ? "取消订阅" : "添加订阅"))
                    .font(.system(size: 12, weight: .semibold))
            }
            .frame(width: 90)
            .padding(.vertical, 8)
            .background(
                isSubscribed ?
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 0.3), Color(red: 0.1, green: 0.6, blue: 0.2)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [Color(red: 0.7, green: 0.95, blue: 0.8), Color(red: 0.6, green: 0.9, blue: 0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
            )
            .foregroundColor(isSubscribed ? .white : .primary)
            .cornerRadius(8)
            .shadow(color: isSubscribed ? .black.opacity(0.15) : .black.opacity(0.05), radius: isSubscribed ? 6 : 4, x: 0, y: isSubscribed ? 3 : 2)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct CheckUpdateButton: View {
    @Binding var isLoading: Bool
    let softwareId: String
    let interactionService: InteractionService
    let authService: AuthService

    var body: some View {
        Button(action: {
            guard !isLoading else { return }

            if authService.isAuthenticated {
                isLoading = true
                Task {
                    let (success, message) = await interactionService.checkUpdate(softwareId: softwareId)
                    isLoading = false

                    showSuccessAlert(message: success ? message : interactionService.errorMessage ?? "操作失败")
                }
            } else {
                NotificationCenter.default.post(name: .showLoginSheet, object: nil)
            }
        }) {
            ActionButtonContent(
                icon: "bell",
                text: isLoading ? "操作中..." : "提醒更新",
                isLoading: isLoading,
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 0.9)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct InstallButton: View {
    @Binding var isLoading: Bool
    let detail: AppDetailResponse
    let highSpeedDownloadService: HighSpeedDownloadService
    let authService: AuthService
    @State private var showChannelSelection = false
    @State private var downloadLinks: [HighSpeedDownloadLink] = []

    var body: some View {
        Button(action: {
            guard !isLoading else { return }

            if authService.isAuthenticated {
                if let latestVersion = detail.data.versions.last {
                    isLoading = true
                    Task {
                        downloadLinks = await highSpeedDownloadService.getHighSpeedDownloadLinks(versionId: latestVersion.id)
                        isLoading = false

                        if !downloadLinks.isEmpty {
                            showChannelSelection = true
                        } else {
                            showErrorAlert(message: "无法获取下载链接")
                        }
                    }
                }
            } else {
                NotificationCenter.default.post(name: .showLoginSheet, object: nil)
            }
        }) {
            ActionButtonContent(
                icon: "arrow.down.to.line",
                text: isLoading ? "安装中..." : "立即安装",
                isLoading: isLoading,
                gradient: LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.2, green: 0.7, blue: 0.3), Color(red: 0.1, green: 0.6, blue: 0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .sheet(isPresented: $showChannelSelection) {
            ChannelSelectionView(
                isPresented: $showChannelSelection,
                downloadLinks: downloadLinks,
                appName: detail.data.appName,
                appVersion: detail.data.version,
                appIcon: detail.data.appIcon,
                highSpeedDownloadService: highSpeedDownloadService
            )
        }
    }
}

struct ChannelSelectionView: View {
    @Binding var isPresented: Bool
    let downloadLinks: [HighSpeedDownloadLink]
    let appName: String
    let appVersion: String
    let appIcon: String?
    let highSpeedDownloadService: HighSpeedDownloadService

    var body: some View {
        ZStack(alignment: .center) {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                headerView
                
                VStack(spacing: 12) {
                    ForEach(downloadLinks, id: \.channel) { link in
                        Button(action: {
                            let record = DownloadRecord(
                                id: UUID(),
                                appName: appName,
                                appVersion: appVersion,
                                downloadUrl: link.url,
                                channel: link.channel,
                                appIcon: appIcon,
                                downloadPath: nil,
                                fileSize: 0,
                                downloadedSize: 0,
                                status: .pending,
                                startTime: Date(),
                                endTime: nil
                            )
                            highSpeedDownloadService.downloadRecords.append(record)
                            highSpeedDownloadService.saveDownloadRecords()
                            highSpeedDownloadService.startDownload(record: record)
                            isPresented = false
                        }) {
                            HStack(spacing: 12) {
                                if let channelInfo = DownloadConfig.downloadChannel[link.channel] {
                                    AsyncImage(url: URL(string: channelInfo.icon)) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 28, height: 28)
                                        } else {
                                            Image(systemName: "bolt.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Text(channelInfo.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                } else {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.blue)
                                    Text(link.channel)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .background(Color(.windowBackgroundColor))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            .frame(maxWidth: 400)
            .padding(40)
        }
    }

    private var headerView: some View {
        HStack(alignment: .center, spacing: 24) {
            Text("选择下载通道")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.controlBackgroundColor))
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .overlay(
            Rectangle()
                .fill(Color(.separatorColor))
                .frame(height: 0.5)
                .alignmentGuide(.bottom) { $0[.bottom] },
            alignment: .bottom
        )
    }
}



struct ActionButtonContent: View {
    let icon: String
    let text: String
    let isLoading: Bool
    let gradient: LinearGradient

    var body: some View {
        HStack(spacing: 6) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 14, height: 14)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
            }
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .frame(width: 90)
        .padding(.vertical, 8)
        .background(gradient)
        .foregroundColor(.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
    }
}

struct AppImagesScrollView: View {
    let images: [String]
    @Binding var selectedImageIndex: Int?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(images.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: images[index])) { phase in
                        switch phase {
                        case .empty:
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                                .frame(width: 240, height: 160)
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(8)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 240, height: 160)
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        case .failure:
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                                .frame(width: 240, height: 160)
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(8)
                        @unknown default:
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                                .frame(width: 240, height: 160)
                                .background(Color(.controlBackgroundColor))
                                .cornerRadius(8)
                        }
                    }
                    .onTapGesture {
                        selectedImageIndex = index
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
        }
        .frame(height: 160)
    }
}

struct ImageFullScreenView: View {
    let images: [String]
    let selectedIndex: Int
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }

            AsyncImage(url: URL(string: images[selectedIndex])) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(.white)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(40)
                case .failure:
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(40)
                @unknown default:
                    Image(systemName: "photo")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .padding(40)
                }
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding(16)
                }
                Spacer()
            }
        }
    }
}

struct AppDescriptionView: View {
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("应用介绍")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .lineSpacing(8)
        }
    }
}

struct AppToolsView: View {
    let appId: String

    var body: some View {
        let apps = AppDataManager.shared.apps
        let fixApp = apps.first(where: { $0.id == appId })

        if let app = fixApp {
            VStack(alignment: .leading, spacing: 16) {
                Text("可用工具")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(app.tools, id: \.id) { tool in
                        ToolCard(tool: tool)
                    }
                }
            }
        }
    }
}

private func showErrorAlert(message: String) {
    let alert = NSAlert()
    alert.messageText = "下载失败"
    alert.informativeText = message
    alert.addButton(withTitle: "确定")
    alert.runModal()
}

private func showSuccessAlert(message: String) {
    let alert = NSAlert()
    alert.messageText = message
    alert.addButton(withTitle: "确定")
    alert.runModal()
}