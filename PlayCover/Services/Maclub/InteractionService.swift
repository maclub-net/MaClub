import Foundation

@MainActor
class InteractionService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://www.maclub.net/api"
    
    func toggleFavorite(softwareId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/favorite/toggle") else {
            errorMessage = "无效的URL"
            return false
        }
        
        let requestBody: [String: String] = [
            "favoriteable_type": "software",
            "favoriteable_id": softwareId
        ]
        
        guard let bodyData = try? JSONEncoder().encode(requestBody) else {
            errorMessage = "数据编码失败"
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = bodyData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let code = response["code"] as? Int ?? 0
                if code == 200 {
                    return true
                } else {
                    errorMessage = response["message"] as? String ?? "操作失败"
                    return false
                }
            } else {
                errorMessage = "无效的响应格式"
                return false
            }
        } catch {
            errorMessage = "网络错误: \(error.localizedDescription)"
            return false
        }
    }
    
    func toggleSubscribe(softwareId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/subscribe/toggle") else {
            errorMessage = "无效的URL"
            return false
        }
        
        let requestBody: [String: String] = [
            "software_id": softwareId
        ]
        
        guard let bodyData = try? JSONEncoder().encode(requestBody) else {
            errorMessage = "数据编码失败"
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = bodyData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let code = response["code"] as? Int ?? 0
                if code == 200 || code == 201 {
                    return true
                } else {
                    errorMessage = response["message"] as? String ?? "操作失败"
                    return false
                }
            } else {
                errorMessage = "无效的响应格式"
                return false
            }
        } catch {
            errorMessage = "网络错误: \(error.localizedDescription)"
            return false
        }
    }
    
    func checkUpdate(softwareId: String) async -> (success: Bool, message: String) {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/decrypt/check/\(softwareId)") else {
            errorMessage = "无效的URL"
            return (false, "无效的URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "用户未登录"
            return (false, "用户未登录")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let code = responseDict["code"] as? Int ?? 0
                let message = responseDict["message"] as? String ?? "未知消息"
                
                if code == 200 || code == 201 {
                    return (true, message)
                } else {
                    errorMessage = message
                    return (false, message)
                }
            } else {
                errorMessage = "无效的响应格式"
                return (false, "无效的响应格式")
            }
        } catch {
            errorMessage = "网络错误: \(error.localizedDescription)"
            return (false, "网络错误: \(error.localizedDescription)")
        }
    }
}
