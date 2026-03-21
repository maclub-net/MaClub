import SwiftUI
import Foundation

struct MaclubAppDetailView: View {
    let detail: AppDetailResponse
    @State private var selectedImageIndex: Int? = nil
    @StateObject private var authService = AuthService.shared
    @StateObject private var downloadService = DownloadService()
    @StateObject private var highSpeedDownloadService = HighSpeedDownloadService()
    @StateObject private var interactionService = InteractionService()
    @State private var showDownloadPopup = false
    @State private var showHighSpeedDownloadPopup = false
    @State private var highSpeedDownloadLinks: [HighSpeedDownloadLink] = []
    @State private var isLoadingHighSpeed = false
    @State private var isLoadingFreeDownload = false
    @State private var isLoadingInstall = false
    @State private var isLoadingFavorite = false
    @State private var isLoadingSubscribe = false
    @State private var isLoadingCheckUpdate = false
    @State private var isFavorited: Bool
    @State private var isSubscribed: Bool

    init(detail: AppDetailResponse) {
        self.detail = detail
        _isFavorited = State(initialValue: detail.data.isFavorited)
        _isSubscribed = State(initialValue: detail.data.isSubscribed)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 24) {
                    AppDetailHeaderView(
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

                    AppDescriptionView(description: detail.data.description)

                    AppToolsView(appId: detail.data.id)

                    if !detail.data.images.isEmpty {
                        AppImagesScrollView(
                            images: detail.data.images,
                            selectedImageIndex: $selectedImageIndex
                        )
                    }
                }
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.windowBackgroundColor))

            if let selectedIndex = selectedImageIndex, selectedIndex < detail.data.images.count {
                ImageFullScreenView(
                    images: detail.data.images,
                    selectedIndex: selectedIndex,
                    onClose: { selectedImageIndex = nil }
                )
            }

            if showDownloadPopup {
                DownloadPopupView(
                    isPresented: $showDownloadPopup,
                    downloadLinks: downloadService.downloadLinks
                )
            }

            if showHighSpeedDownloadPopup {
                HighSpeedDownloadPopupView(
                    isPresented: $showHighSpeedDownloadPopup,
                    downloadLinks: highSpeedDownloadLinks,
                    appName: detail.data.appName,
                    appVersion: detail.data.version,
                    appIcon: detail.data.appIcon,
                    downloadService: highSpeedDownloadService
                )
            }
        }
    }
}