import Foundation

class DownloadService: ObservableObject {
    @Published var downloadLinks: [DownloadLink] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let api = MaclubBaseService.shared
    
    func getDownloadLinks(versionId: Int) async {
        isLoading = true
        error = nil
        
        let urlString = "https://www.maclub.net/appstore/dl/\(versionId)/free"
        
        do {
            let result: DownloadResponse = try await api.requestWithURL(
                urlString: urlString,
                method: "GET",
                requiresAuth: api.isAuthenticated
            )
            
            if result.code == 200 {
                downloadLinks = result.data
            } else {
                error = result.message
            }
        } catch let err {
            if let apiError = err as? MaclubAPIError {
                error = apiError.errorDescription
            } else {
                error = err.localizedDescription
            }
        }
        
        isLoading = false
    }
}
