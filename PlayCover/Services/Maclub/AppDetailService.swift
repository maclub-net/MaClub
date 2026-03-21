import Foundation

@MainActor
class AppDetailService: ObservableObject {
    @Published var appDetail: AppDetail?
    @Published var isLoading = false
    @Published var error: Error?
    
    func fetchAppDetail(id: String) async {
        isLoading = true
        error = nil
        
        let urlString = "https://www.maclub.net/api/software/\(id)"
        print("Fetching app detail for ID: \(id)")
        print("URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            error = NSError(domain: "AppDetailService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                error = NSError(domain: "AppDetailService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                isLoading = false
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("HTTP Error: \(httpResponse.statusCode)")
                error = NSError(domain: "AppDetailService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let appDetailResponse = try decoder.decode(AppDetailResponse.self, from: data)
            appDetail = appDetailResponse.data
            print("Successfully loaded app detail: \(appDetail?.appName ?? "Unknown")")
            
        } catch {
            print("Error fetching app detail: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key: \(key.stringValue), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type), path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            self.error = error
        }
        
        isLoading = false
    }
}
