import Foundation

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let tokenKey = "auth_token"
    private let userKey = "cached_user"
    private let baseURL = "https://www.maclub.net/api"
    
    private init() {
        loadCachedUser()
    }
    
    private func loadCachedUser() {
        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let userData = UserDefaults.standard.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
            Task {
                await refreshUserInfo()
            }
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            errorMessage = "无效的URL"
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        let parameters = [
            ["key": "email", "value": email, "type": "text"],
            ["key": "password", "value": password, "type": "text"]
        ] as [[String: Any]]
        
        for param in parameters {
            guard let paramName = param["key"] as? String else { continue }
            body += Data("--\(boundary)\r\n".utf8)
            body += Data("Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n".utf8)
            if let paramValue = param["value"] as? String {
                body += Data("\(paramValue)\r\n".utf8)
            }
        }
        body += Data("--\(boundary)--\r\n".utf8)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let response = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                if response.success, let authData = response.data {
                    self.currentUser = authData.user
                    self.isAuthenticated = true
                    
                    if let token = authData.token {
                        UserDefaults.standard.set(token, forKey: tokenKey)
                    }
                    
                    if let userData = try? JSONEncoder().encode(authData.user) {
                        UserDefaults.standard.set(userData, forKey: userKey)
                    }
                    
                    errorMessage = nil
                } else {
                    errorMessage = response.message ?? "登录失败"
                }
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    errorMessage = message
                } else {
                    errorMessage = "登录失败，请检查邮箱和密码"
                }
            }
        } catch {
            errorMessage = "网络错误: \(error.localizedDescription)"
        }
    }
    
    func refreshUserInfo() async {
        guard let token = UserDefaults.standard.string(forKey: tokenKey) else { return }
        
        guard let url = URL(string: "\(baseURL)/auth/me") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let response = try? JSONDecoder().decode(UserResponse.self, from: data),
               response.success {
                self.currentUser = response.data?.user
                
                if let userData = try? JSONEncoder().encode(response.data?.user) {
                    UserDefaults.standard.set(userData, forKey: userKey)
                }
            }
        } catch {
            print("刷新用户信息失败: \(error)")
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    func canUseTools() -> Bool {
        guard let user = currentUser else { return false }
        return user.isVIPValid
    }
    
    func getVIPStatusMessage() -> String {
        guard let user = currentUser else {
            return "请先登录"
        }
        
        if !user.isVip {
            return "您还不是VIP用户"
        }
        
        guard let expiresAt = user.vipExpiresAt else {
            return "VIP状态异常"
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let expiresDate = formatter.date(from: expiresAt) {
            if expiresDate < Date() {
                return "VIP已过期"
            } else {
                let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: expiresDate).day ?? 0
                return "VIP剩余\(daysRemaining)天"
            }
        }
        
        return "VIP状态正常"
    }
}
