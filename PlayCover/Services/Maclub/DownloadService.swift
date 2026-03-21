import Foundation

class DownloadService: ObservableObject {
    @Published var downloadLinks: [DownloadLink] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    func getDownloadLinks(versionId: Int) async {
        isLoading = true
        error = nil
        
        let urlString = "https://www.maclub.net/appstore/dl/\(versionId)/free"
        
        guard let url = URL(string: urlString) else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                error = "Invalid response"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(DownloadResponse.self, from: data)
            
            if result.code == 200 {
                downloadLinks = result.data
            } else {
                error = result.message
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}
