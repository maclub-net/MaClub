import Foundation

@MainActor
class AppDetailService: ObservableObject {
    @Published var appDetail: AppDetail?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let api = MaclubBaseService.shared
    
    func fetchAppDetail(id: String) async {
        isLoading = true
        error = nil
        
        print("Fetching app detail for ID: \(id)")
        
        do {
            let response: AppDetailResponse = try await api.request(
                endpoint: "/software/\(id)",
                method: "GET",
                requiresAuth: api.isAuthenticated
            )
            
            appDetail = response.data
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
