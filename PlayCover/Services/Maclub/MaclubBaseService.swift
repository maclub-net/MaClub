import Foundation

enum MaclubAPIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error)
    case networkError(Error)
    case serverError(message: String?)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .unauthorized:
            return "登录状态已过期，请重新登录"
        case .httpError(let statusCode, let message):
            return message ?? "HTTP错误: \(statusCode)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .serverError(let message):
            return message ?? "服务器错误"
        }
    }
}

struct MaclubAPIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String?
    let data: T?
}

struct MaclubCodeResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String?
    let data: T?
}

@MainActor
class MaclubBaseService {
    static let shared = MaclubBaseService()
    
    let baseURL = "https://www.maclub.net/api"
    private let tokenKey = "auth_token"
    private let userKey = "cached_user"
    
    private init() {}
    
    var currentToken: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }
    
    var isAuthenticated: Bool {
        currentToken != nil
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false,
        contentType: String = "application/json"
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw MaclubAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = currentToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw MaclubAPIError.unauthorized
            }
        }
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MaclubAPIError.serverError(message: "无效的响应类型")
            }
            
            if httpResponse.statusCode == 401 {
                handleUnauthorized()
                throw MaclubAPIError.unauthorized
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorMessage = try? extractErrorMessage(from: data)
                throw MaclubAPIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw MaclubAPIError.decodingError(error)
            }
        } catch let error as MaclubAPIError {
            throw error
        } catch {
            throw MaclubAPIError.networkError(error)
        }
    }
    
    func requestWithResponse<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false,
        contentType: String = "application/json"
    ) async throws -> (data: T, statusCode: Int) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw MaclubAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = currentToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MaclubAPIError.serverError(message: "无效的响应类型")
            }
            
            if httpResponse.statusCode == 401 {
                handleUnauthorized()
                throw MaclubAPIError.unauthorized
            }
            
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(T.self, from: data)
                return (data: decoded, statusCode: httpResponse.statusCode)
            } catch {
                throw MaclubAPIError.decodingError(error)
            }
        } catch let error as MaclubAPIError {
            throw error
        } catch {
            throw MaclubAPIError.networkError(error)
        }
    }
    
    func requestJSON(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false,
        contentType: String = "application/json"
    ) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw MaclubAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = currentToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                throw MaclubAPIError.unauthorized
            }
        }
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MaclubAPIError.serverError(message: "无效的响应类型")
            }
            
            if httpResponse.statusCode == 401 {
                handleUnauthorized()
                throw MaclubAPIError.unauthorized
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorMessage = try? extractErrorMessage(from: data)
                throw MaclubAPIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw MaclubAPIError.decodingError(NSError(domain: "MaclubAPI", code: 0, userInfo: [NSLocalizedDescriptionKey: "无法解析JSON"]))
            }
            
            return json
        } catch let error as MaclubAPIError {
            throw error
        } catch {
            throw MaclubAPIError.networkError(error)
        }
    }
    
    func multipartRequest<T: Decodable>(
        endpoint: String,
        parameters: [[String: Any]],
        requiresAuth: Bool = false
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw MaclubAPIError.invalidURL
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
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
        
        if requiresAuth {
            if let token = currentToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MaclubAPIError.serverError(message: "无效的响应类型")
            }
            
            if httpResponse.statusCode == 401 {
                handleUnauthorized()
                throw MaclubAPIError.unauthorized
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorMessage = try? extractErrorMessage(from: data)
                throw MaclubAPIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw MaclubAPIError.decodingError(error)
            }
        } catch let error as MaclubAPIError {
            throw error
        } catch {
            throw MaclubAPIError.networkError(error)
        }
    }
    
    private func handleUnauthorized() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        
        Task { @MainActor in
            AuthService.shared.handleSessionExpired()
        }
    }
    
    private func extractErrorMessage(from data: Data) throws -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["message"] as? String {
            return message
        }
        return nil
    }
    
    func clearAuthData() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
    }
    
    func requestWithURL<T: Decodable>(
        urlString: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false,
        contentType: String = "application/json"
    ) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw MaclubAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = currentToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MaclubAPIError.serverError(message: "无效的响应类型")
            }
            
            if httpResponse.statusCode == 401 {
                handleUnauthorized()
                throw MaclubAPIError.unauthorized
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                let errorMessage = try? extractErrorMessage(from: data)
                throw MaclubAPIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw MaclubAPIError.decodingError(error)
            }
        } catch let error as MaclubAPIError {
            throw error
        } catch {
            throw MaclubAPIError.networkError(error)
        }
    }
    
    func requestWithURLRaw(
        urlString: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false,
        contentType: String = "application/json"
    ) async throws -> (data: Data, statusCode: Int) {
        guard let url = URL(string: urlString) else {
            throw MaclubAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = currentToken {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MaclubAPIError.serverError(message: "无效的响应类型")
            }
            
            if httpResponse.statusCode == 401 {
                handleUnauthorized()
                throw MaclubAPIError.unauthorized
            }
            
            return (data: data, statusCode: httpResponse.statusCode)
        } catch let error as MaclubAPIError {
            throw error
        } catch {
            throw MaclubAPIError.networkError(error)
        }
    }
}
