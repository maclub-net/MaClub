import SwiftUI

struct MaclubAppDetailLoaderView: View {
    let appId: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appDetailService = AppDetailService()
    
    var body: some View {
        ZStack {
            if appDetailService.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("加载中...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = appDetailService.appDetail {
                MaclubAppDetailView(detail: AppDetailResponse(data: detail))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("关闭") {
                                dismiss()
                            }
                        }
                    }
            } else if let error = appDetailService.error {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text("加载失败")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("关闭") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            Task {
                await appDetailService.fetchAppDetail(id: appId)
            }
        }
    }
}
