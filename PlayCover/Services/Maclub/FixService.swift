import Foundation

@MainActor
class FixService: ObservableObject {
    @Published var isExecuting: Bool = false
    @Published var lastOutput: String = ""
    @Published var lastError: String = ""
    @Published var lastExitCode: Int32 = 0
    
    private let shellService = ShellService.shared
    private let jkchessService = JkchessFixService()
    private let simcityService = SimCityFixService()
    private let fortniteService = FortniteFixService()
    private let azurLaneService = AzurLaneFixService()
    
    func executeFix(tool: FixTool) async -> Bool {
        isExecuting = true
        defer { isExecuting = false }
        
        lastOutput = ""
        lastError = ""
        
        switch tool.fixAction {
        case .shellCommand(let command):
            return await executeShellCommand(command)
        case .shellScript(let script):
            return await executeShellScript(script)
        case .custom(let identifier):
            return await executeCustomFix(identifier: identifier)
        }
    }
    
    private func executeShellCommand(_ command: String) async -> Bool {
        let result = await shellService.execute(command: command)
        
        var filteredError = result.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        lastOutput = result.output
        lastError = filteredError
        lastExitCode = result.exitCode
        return result.isSuccess
    }
    
    private func executeShellScript(_ scriptContent: String) async -> Bool {
        let tempDir = FileManager.default.temporaryDirectory
        let scriptPath = tempDir.appendingPathComponent("fix_script_\(UUID().uuidString).sh").path
        
        do {
            try scriptContent.write(toFile: scriptPath, atomically: true, encoding: .utf8)
            let chmodResult = await shellService.execute(command: "chmod +x '\(scriptPath)'")
            guard chmodResult.isSuccess else {
                lastError = "无法设置脚本执行权限"
                return false
            }
            
            let result = await shellService.execute(command: scriptPath)
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.exitCode
            
            try? FileManager.default.removeItem(atPath: scriptPath)
            return result.isSuccess
        } catch {
            lastError = "创建临时脚本失败: \(error.localizedDescription)"
            return false
        }
    }
    
    private func executeCustomFix(identifier: String) async -> Bool {
        switch identifier {
        case "jkchess_microphone":
            let result = await jkchessService.fixMicrophone()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        case "jkchess_orientation":
            let result = await jkchessService.fixOrientation()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        case "simcity_crash":
            let result = await simcityService.fixCrash()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        case "fortnite_entitlement_issue":
            let result = await fortniteService.fixEntitlementIssue()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        case "fortnite_memory_issue":
            let result = await fortniteService.fixMemoryIssue()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        case "fortnite_first_responder_issue":
            let result = await fortniteService.fixFirstResponderIssue()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        case "fortnite_download_issue":
            let result = await fortniteService.fixDownloadIssue()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        case "fortnite_mouse_issue":
            let result = await fortniteService.fixMouseIssue()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        case "azurlane_key_mapping_issue":
            let result = await azurLaneService.fixKeyMappingIssue()
            lastOutput = result.output
            lastError = result.error
            lastExitCode = result.success ? 0 : 1
            return result.success
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
}
