import Foundation

struct SearchResponse: Codable {
    let data: [SearchApp]
    let meta: SearchMeta
    
    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }
}

struct SearchMeta: Codable {
    let currentPage: Int
    let from: Int
    let lastPage: Int
    let perPage: Int
    let to: Int
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to
        case total
    }
}

struct SearchApp: Codable, Identifiable, Hashable {
    let id: String
    let appIcon: String
    let appName: String
    let platforms: String
    let version: String
    let size: String
    let releaseAt: String
    let tags: [String]
    let description: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case appIcon = "app_icon"
        case appName = "app_name"
        case platforms
        case version
        case size
        case releaseAt = "release_at"
        case tags
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        appIcon = try container.decode(String.self, forKey: .appIcon)
        appName = try container.decode(String.self, forKey: .appName)
        platforms = try container.decode(String.self, forKey: .platforms)
        version = try container.decode(String.self, forKey: .version)
        size = try container.decode(String.self, forKey: .size)
        releaseAt = try container.decode(String.self, forKey: .releaseAt)
        
        if let tagsArray = try? container.decode([String].self, forKey: .tags) {
            tags = tagsArray
        } else if let tagsString = try? container.decode(String.self, forKey: .tags) {
            tags = tagsString.isEmpty ? [] : [tagsString]
        } else {
            tags = []
        }
        
        description = try container.decode(String.self, forKey: .description)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(appIcon, forKey: .appIcon)
        try container.encode(appName, forKey: .appName)
        try container.encode(platforms, forKey: .platforms)
        try container.encode(version, forKey: .version)
        try container.encode(size, forKey: .size)
        try container.encode(releaseAt, forKey: .releaseAt)
        try container.encode(tags, forKey: .tags)
        try container.encode(description, forKey: .description)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    var formattedSize: String {
        guard let bytes = Double(size) else { return size }
        let mb = bytes / (1024 * 1024)
        if mb >= 1024 {
            let gb = mb / 1024
            return String(format: "%.1f GB", gb)
        }
        return String(format: "%.1f MB", mb)
    }
    
    init(
        id: String,
        appIcon: String,
        appName: String,
        platforms: String = "ios",
        version: String = "",
        size: String = "0",
        releaseAt: String = "",
        tags: [String] = [],
        description: String = "",
        createdAt: String = "",
        updatedAt: String = ""
    ) {
        self.id = id
        self.appIcon = appIcon
        self.appName = appName
        self.platforms = platforms
        self.version = version
        self.size = size
        self.releaseAt = releaseAt
        self.tags = tags
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
