import Foundation

struct AppDetailResponse: Codable {
    let data: AppDetail
}

struct AppDetail: Codable, Identifiable {
    let id: String
    let appstoreId: String
    let appIcon: String
    let appName: String
    let region: String
    let bundleId: String
    let categoryId: String
    let categoryName: String
    let status: Int
    let isFavorited: Bool
    let isSubscribed: Bool
    let platforms: String
    let platformVersions: String
    let versions: [AppVersion]
    let version: String
    let size: String
    let releaseAt: String
    let downloadCount: Int
    let images: [String]
    let tags: [String]
    let description: String
    let language: String
    let userId: String
    let content: String?
    let comments: [Comment]
    let topics: [Topic]
    let articles: [Article]
    let createdAt: String
    let updatedAt: String

    var formattedSize: String {
        guard let bytes = Double(size) else { return size }
        let mb = bytes / (1024 * 1024)
        if mb >= 1024 {
            let gb = mb / 1024
            return String(format: "%.1f GB", gb)
        }
        return String(format: "%.1f MB", mb)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case appstoreId = "appstore_id"
        case appIcon = "app_icon"
        case appName = "app_name"
        case region
        case bundleId = "bundle_id"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case status
        case isFavorited = "is_favorited"
        case isSubscribed = "is_subscribed"
        case platforms
        case platformVersions = "platform_versions"
        case versions
        case version
        case size
        case releaseAt = "release_at"
        case downloadCount = "download_count"
        case images
        case tags
        case description
        case language
        case userId = "user_id"
        case content
        case comments
        case topics
        case articles
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct AppVersion: Codable, Identifiable {
    let id: Int
    let softwareId: String
    let version: String
    let size: String
    let state: Int
    let releaseNotes: String?
    let deletedAt: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case softwareId = "software_id"
        case version
        case size
        case state
        case releaseNotes = "release_notes"
        case deletedAt = "deleted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Comment: Codable, Identifiable {
    let id: String
    let content: String
    let userId: String
    let status: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case userId = "user_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Topic: Codable, Identifiable {
    let id: Int
    let title: String
    let content: String
    let topicableId: String
    let topicableType: String
    let userId: String
    let status: Int
    let views: Int
    let deletedAt: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case topicableId = "topicable_id"
        case topicableType = "topicable_type"
        case userId = "user_id"
        case status
        case views
        case deletedAt = "deleted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Article: Codable, Identifiable {
    let id: String
    let title: String
    let content: String
    let userId: String
    let status: Int
    let views: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case userId = "user_id"
        case status
        case views
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
