import Foundation

@MainActor
class InteractionService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api = MaclubBaseService.shared
    
    func toggleFavorite(softwareId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let requestBody: [String: String] = [
            "favoriteable_type": "software",
            "favoriteable_id": softwareId
        ]
        
        guard let bodyData = try? JSONEncoder().encode(requestBody) else {
            errorMessage = "数据编码失败"
            return false
        }
        
        do {
            let response = try await api.requestJSON(
                endpoint: "/favorite/toggle",
                method: "POST",
                body: bodyData,
                requiresAuth: true
            )
            
            if let code = response["code"] as? Int, code == 200 {
                return true
            } else {
                errorMessage = response["message"] as? String ?? "操作失败"
                return false
            }
        } catch {
            if let apiError = error as? MaclubAPIError {
                errorMessage = apiError.errorDescription
            } else {
                errorMessage = "网络错误: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func toggleSubscribe(softwareId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let requestBody: [String: String] = [
            "software_id": softwareId
        ]
        
        guard let bodyData = try? JSONEncoder().encode(requestBody) else {
            errorMessage = "数据编码失败"
            return false
        }
        
        do {
            let response = try await api.requestJSON(
                endpoint: "/subscribe/toggle",
                method: "POST",
                body: bodyData,
                requiresAuth: true
            )
            
            if let code = response["code"] as? Int, code == 200 || code == 201 {
                return true
            } else {
                errorMessage = response["message"] as? String ?? "操作失败"
                return false
            }
        } catch {
            if let apiError = error as? MaclubAPIError {
                errorMessage = apiError.errorDescription
            } else {
                errorMessage = "网络错误: \(error.localizedDescription)"
            }
            return false
        }
    }
    
    func checkUpdate(softwareId: String) async -> (success: Bool, message: String) {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard api.isAuthenticated else {
            errorMessage = "用户未登录"
            return (false, "用户未登录")
        }
        
        do {
            let response = try await api.requestJSON(
                endpoint: "/decrypt/check/\(softwareId)",
                method: "POST",
                requiresAuth: true
            )
            
            let code = response["code"] as? Int ?? 0
            let message = response["message"] as? String ?? "未知消息"
            
            if code == 200 || code == 201 {
                return (true, message)
            } else {
                errorMessage = message
                return (false, message)
            }
        } catch {
            if let apiError = error as? MaclubAPIError {
                errorMessage = apiError.errorDescription
                return (false, apiError.errorDescription ?? "未知错误")
            } else {
                errorMessage = "网络错误: \(error.localizedDescription)"
                return (false, "网络错误: \(error.localizedDescription)")
            }
        }
    }
}
