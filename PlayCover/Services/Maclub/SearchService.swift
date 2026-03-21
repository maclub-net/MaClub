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
    
    private let baseURL = "https://www.maclub.net/api"
    
    private init() {}
    
    func search(keyword: String, page: Int = 1, perPage: Int = 20) async {
        guard !keyword.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? keyword
        guard let url = URL(string: "\(baseURL)/search/software/\(encodedKeyword)?page=\(page)&per_page=\(perPage)") else {
            errorMessage = "无效的搜索URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(SearchResponse.self, from: data)
                if page == 1 {
                    searchResults = response.data
                } else {
                    searchResults.append(contentsOf: response.data)
                }
                currentPage = response.meta.currentPage
                totalPages = response.meta.lastPage
                totalResults = response.meta.total
            } catch {
                print("解码错误详情: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("缺少键: \(key.stringValue), 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .typeMismatch(let type, let context):
                        print("类型不匹配: \(type), 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .valueNotFound(let type, let context):
                        print("值不存在: \(type), 路径: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                    case .dataCorrupted(let context):
                        print("数据损坏: \(context.debugDescription)")
                    @unknown default:
                        print("未知错误")
                    }
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    errorMessage = message
                } else {
                    errorMessage = "搜索失败，请稍后重试"
                }
            }
        } catch {
            print("网络错误: \(error)")
            errorMessage = "网络错误: \(error.localizedDescription)"
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
