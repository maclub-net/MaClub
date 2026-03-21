import Foundation

struct FixTool: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let detailedDescription: String
    let icon: String
    let category: ToolCategory
    let fixAction: FixAction
    
    static func == (lhs: FixTool, rhs: FixTool) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum ToolCategory: String, CaseIterable {
    case permission = "权限修复"
    case display = "显示修复"
    case crash = "崩溃修复"
    case performance = "性能优化"
    
    var icon: String {
        switch self {
        case .permission: return "lock.shield"
        case .display: return "display"
        case .crash: return "bolt.triangle"
        case .performance: return "gauge"
        }
    }
}

enum FixAction: Hashable {
    case shellCommand(String)
    case shellScript(String)
    case custom(String)
    
    static func == (lhs: FixAction, rhs: FixAction) -> Bool {
        switch (lhs, rhs) {
        case (.shellCommand(let lhsCmd), .shellCommand(let rhsCmd)):
            return lhsCmd == rhsCmd
        case (.shellScript(let lhsScript), .shellScript(let rhsScript)):
            return lhsScript == rhsScript
        case (.custom(let lhsId), .custom(let rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .shellCommand(let cmd):
            hasher.combine("shellCommand")
            hasher.combine(cmd)
        case .shellScript(let script):
            hasher.combine("shellScript")
            hasher.combine(script)
        case .custom(let identifier):
            hasher.combine("custom")
            hasher.combine(identifier)
        }
    }
}
