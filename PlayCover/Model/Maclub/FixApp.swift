import Foundation

struct FixApp: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String
    let logoName: String
    let description: String
    let tools: [FixTool]
    let downloadURL: URL?
    
    static func == (lhs: FixApp, rhs: FixApp) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
