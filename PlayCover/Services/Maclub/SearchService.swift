import Foundation

@MainActor
class SearchService: ObservableObject {
    static let shared = SearchService()
    
    @Published var searchText: String = ""
    @Published var searchResults: [SearchApp] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var totalResults: Int = 0
    
    private let api = MaclubBaseService.shared
    
    private init() {}
    
    func search(keyword: String, page: Int = 1, perPage: Int = 20) async {
        guard !keyword.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? keyword
        let endpoint = "/search/software/\(encodedKeyword)?page=\(page)&per_page=\(perPage)"
        
        do {
            let response: SearchResponse = try await api.request(
                endpoint: endpoint,
                method: "GET",
                requiresAuth: false
            )
            
            if page == 1 {
                searchResults = response.data
            } else {
                searchResults.append(contentsOf: response.data)
            }
            currentPage = response.meta.currentPage
            totalPages = response.meta.lastPage
            totalResults = response.meta.total
        } catch {
            if let apiError = error as? MaclubAPIError {
                errorMessage = apiError.errorDescription
            } else {
                errorMessage = "搜索失败，请稍后重试"
            }
            print("搜索错误: \(error)")
        }
        
        isLoading = false
    }
    
    func loadMore(keyword: String) async {
        guard currentPage < totalPages else { return }
        await search(keyword: keyword, page: currentPage + 1)
    }
    
    func clearResults() {
        searchResults = []
        currentPage = 1
        totalPages = 1
        totalResults = 0
        errorMessage = nil
        isLoading = false
    }
}
