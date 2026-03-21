import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let emailVerifiedAt: String?
    let profilePhotoURL: String?
    let createdAt: String?
    let isVip: Bool
    let vipExpiresAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email
        case emailVerifiedAt = "email_verified_at"
        case profilePhotoURL = "profile_photo_url"
        case createdAt = "created_at"
        case isVip = "is_vip"
        case vipExpiresAt = "vip_expires_at"
    }
    
    var isVIPValid: Bool {
        guard isVip else { return false }
        guard let expiresAtString = vipExpiresAt else { return false }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let expiresAt = formatter.date(from: expiresAtString) else { return false }
        return expiresAt > Date()
    }
}

struct AuthResponse: Codable {
    let success: Bool
    let message: String?
    let data: AuthData?
}

struct AuthData: Codable {
    let user: User
    let token: String?
    let tokenType: String?
    
    enum CodingKeys: String, CodingKey {
        case user, token
        case tokenType = "token_type"
    }
}

struct UserResponse: Codable {
    let success: Bool
    let data: UserData?
}

struct UserData: Codable {
    let user: User
}
