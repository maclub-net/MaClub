import SwiftUI
import Foundation

struct HighSpeedDownloadPopupView: View {
    @Binding var isPresented: Bool
    let downloadLinks: [HighSpeedDownloadLink]
    let appName: String
    let appVersion: String
    let appIcon: String?
    @ObservedObject var downloadService: HighSpeedDownloadService
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 24) {
                    Text("选择高速下载通道")
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
                
                VStack(spacing: 12) {
                    ForEach(downloadLinks, id: \.channel) { link in
                        Button(action: {
                            var record = DownloadRecord(
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
                            downloadService.downloadRecords.append(record)
                            downloadService.saveDownloadRecords()
                            downloadService.startDownload(record: record)
                            
                            isPresented = false
                            NotificationCenter.default.post(name: .showDownloadManager, object: nil)
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
                                Image(systemName: "chevron.right")
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
}
