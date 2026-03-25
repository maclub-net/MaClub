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
    private let api = MaclubBaseService.shared
    
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
        
        let parameters: [[String: Any]] = [
            ["key": "email", "value": email, "type": "text"],
            ["key": "password", "value": password, "type": "text"]
        ]
        
        do {
            let response: AuthResponse = try await api.multipartRequest(
                endpoint: "/auth/login",
                parameters: parameters,
                requiresAuth: false
            )
            
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
        } catch {
            if let apiError = error as? MaclubAPIError {
                errorMessage = apiError.errorDescription
            } else {
                errorMessage = "网络错误: \(error.localizedDescription)"
            }
        }
    }
    
    func refreshUserInfo() async {
        guard api.currentToken != nil else { return }
        
        do {
            let response: UserResponse = try await api.request(
                endpoint: "/auth/me",
                method: "GET",
                requiresAuth: true
            )
            
            if response.success {
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
    
    func handleSessionExpired() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = "登录状态已过期，请重新登录"
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
