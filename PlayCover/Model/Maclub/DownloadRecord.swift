import Foundation

struct DownloadRecord: Identifiable, Codable {
    let id: UUID
    let appName: String
    let appVersion: String
    let downloadUrl: String
    let channel: String
    var appIcon: String?
    var downloadPath: String?
    var fileSize: Int64
    var downloadedSize: Int64
    var status: DownloadStatus
    let startTime: Date
    var endTime: Date?
    var downloadSpeed: Double = 0.0
    var lastUpdateTime: Date?
    
    enum DownloadStatus: String, Codable {
        case pending
        case downloading
        case completed
        case failed
        case paused
    }
    
    var progress: Double {
        guard fileSize > 0 else { return 0 }
        return Double(downloadedSize) / Double(fileSize)
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    var channelDisplayName: String {
        if let channelInfo = DownloadConfig.downloadChannel[channel] {
            return channelInfo.name
        }
        
        switch channel {
        case "vip":
            return "VIP高速通道"
        case "normal":
            return "普通下载"
        case "cdn":
            return "CDN加速"
        default:
            return channel
        }
    }
    
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: startTime)
    }
}

struct HighSpeedDownloadResponse: Codable {
    let code: Int
    let message: String
    let data: [HighSpeedDownloadLink]
}

struct HighSpeedDownloadLink: Codable {
    let url: String
    let channel: String
}
