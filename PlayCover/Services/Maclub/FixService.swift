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
    private let neteasePartyService = NeteasePartyFixService()
    private let endfieldService = EndfieldFixService()
    private let rockKingdomService = RockKingdomFixService()
    private let nikkeService = NikkeFixService()
    private let nikkeCNService = NikkeCNFixService()
    private let blueArchiveService = BlueArchiveFixService()
    private let towerOfFantasyService = TowerOfFantasyFixService()
    private let loveAndDeepspaceService = LoveAndDeepspaceFixService()
    private let persona5XService = Persona5XFixService()
    private let torchlightService = TorchlightFixService()
    private let racingMasterService = RacingMasterFixService()
    
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
    
    private func updateResult(_ result: (success: Bool, output: String, error: String)) -> Bool {
        lastOutput = result.output
        lastError = result.error
        lastExitCode = result.success ? 0 : 1
        return result.success
    }
    
    private func executeCustomFix(identifier: String) async -> Bool {
        if identifier.hasPrefix("jkchess_") {
            return await executeJkchessFix(identifier: identifier)
        }
        if identifier.hasPrefix("simcity_") {
            return await executeSimcityFix(identifier: identifier)
        }
        if identifier.hasPrefix("fortnite_") {
            return await executeFortniteFix(identifier: identifier)
        }
        if identifier.hasPrefix("azurlane_") {
            return await executeAzurLaneFix(identifier: identifier)
        }
        if identifier.hasPrefix("danzai_") {
            return await executeNeteasePartyFix(identifier: identifier)
        }
        if identifier.hasPrefix("endfield_") {
            return await executeEndfieldFix(identifier: identifier)
        }
        if identifier.hasPrefix("rockkingdom_") {
            return await executeRockKingdomFix(identifier: identifier)
        }
        if identifier.hasPrefix("nikke_") {
            return await executeNikkeFix(identifier: identifier)
        }
        if identifier.hasPrefix("nikkecn_") {
            return await executeNikkeCNFix(identifier: identifier)
        }
        if identifier.hasPrefix("bluearchive_") {
            return await executeBlueArchiveFix(identifier: identifier)
        }
        if identifier.hasPrefix("toweroffantasy_") {
            return await executeTowerOfFantasyFix(identifier: identifier)
        }
        if identifier.hasPrefix("loveanddeepspace_") {
            return await executeLoveAndDeepspaceFix(identifier: identifier)
        }
        if identifier.hasPrefix("persona5x_") {
            return await executePersona5XFix(identifier: identifier)
        }
        if identifier.hasPrefix("torchlight_") {
            return await executeTorchlightFix(identifier: identifier)
        }
        if identifier.hasPrefix("racingmaster_") {
            return await executeRacingMasterFix(identifier: identifier)
        }
        
        lastError = "未知的修复类型: \(identifier)"
        return false
    }
    
    private func executeJkchessFix(identifier: String) async -> Bool {
        switch identifier {
        case "jkchess_microphone":
            return updateResult(await jkchessService.fixMicrophone())
        case "jkchess_orientation":
            return updateResult(await jkchessService.fixOrientation())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeSimcityFix(identifier: String) async -> Bool {
        switch identifier {
        case "simcity_crash":
            return updateResult(await simcityService.fixCrash())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeFortniteFix(identifier: String) async -> Bool {
        switch identifier {
        case "fortnite_entitlement_issue":
            return updateResult(await fortniteService.fixEntitlementIssue())
        case "fortnite_memory_issue":
            return updateResult(await fortniteService.fixMemoryIssue())
        case "fortnite_first_responder_issue":
            return updateResult(await fortniteService.fixFirstResponderIssue())
        case "fortnite_download_issue":
            return updateResult(await fortniteService.fixDownloadIssue())
        case "fortnite_mouse_issue":
            return updateResult(await fortniteService.fixMouseIssue())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeAzurLaneFix(identifier: String) async -> Bool {
        switch identifier {
        case "azurlane_key_mapping_issue":
            return updateResult(await azurLaneService.fixKeyMappingIssue())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeNeteasePartyFix(identifier: String) async -> Bool {
        switch identifier {
        case "danzai_crash_fix":
            return updateResult(await neteasePartyService.fixCrash())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeEndfieldFix(identifier: String) async -> Bool {
        switch identifier {
        case "endfield_block_sleep_spamming":
            return updateResult(await endfieldService.enableBlockSleepSpamming())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeRockKingdomFix(identifier: String) async -> Bool {
        switch identifier {
        case "rockkingdom_block_sleep_spamming":
            return updateResult(await rockKingdomService.enableBlockSleepSpamming())
        case "rockkingdom_disable_builtin_mouse":
            return updateResult(await rockKingdomService.enableDisableBuiltinMouse())
        case "rockkingdom_check_mic_permission":
            return updateResult(await rockKingdomService.enableCheckMicPermissionSync())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeNikkeFix(identifier: String) async -> Bool {
        switch identifier {
        case "nikke_startup_fix":
            return updateResult(await nikkeService.fixStartup())
        case "nikke_display_fix":
            return updateResult(await nikkeService.fixDisplay())
        case "nikke_limit_motion":
            return updateResult(await nikkeService.enableLimitMotionUpdateFrequency())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeNikkeCNFix(identifier: String) async -> Bool {
        switch identifier {
        case "nikkecn_display_fix":
            return updateResult(await nikkeCNService.fixDisplay())
        case "nikkecn_redeem_code_fix":
            return updateResult(await nikkeCNService.fixRedeemCode())
        case "nikkecn_limit_motion":
            return updateResult(await nikkeCNService.enableLimitMotionUpdateFrequency())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeBlueArchiveFix(identifier: String) async -> Bool {
        switch identifier {
        case "bluearchive_limit_motion":
            return updateResult(await blueArchiveService.enableLimitMotionUpdateFrequency())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeTowerOfFantasyFix(identifier: String) async -> Bool {
        switch identifier {
        case "toweroffantasy_character_rendering_fix":
            return updateResult(await towerOfFantasyService.fixCharacterRendering())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeLoveAndDeepspaceFix(identifier: String) async -> Bool {
        switch identifier {
        case "loveanddeepspace_display_fix":
            return updateResult(await loveAndDeepspaceService.setResizableResolution())
        case "loveanddeepspace_login_fix":
            return updateResult(await loveAndDeepspaceService.disableKeyMapping())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executePersona5XFix(identifier: String) async -> Bool {
        switch identifier {
        case "persona5x_startup_fix":
            return updateResult(await persona5XService.fixStartupCrash())
        case "persona5x_limit_motion":
            return updateResult(await persona5XService.enableLimitMotionUpdateFrequency())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeTorchlightFix(identifier: String) async -> Bool {
        switch identifier {
        case "torchlight_startup_fix":
            return updateResult(await torchlightService.fixStartupCrash())
        case "torchlight_mouse_fix":
            return updateResult(await torchlightService.enableDisableBuiltinMouse())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
    
    private func executeRacingMasterFix(identifier: String) async -> Bool {
        switch identifier {
        case "racingmaster_startup_lag_fix":
            return updateResult(await racingMasterService.fixStartupLag())
        case "racingmaster_graphics_quality_fix":
            return updateResult(await racingMasterService.fixGraphicsQuality())
        default:
            lastError = "未知的修复类型: \(identifier)"
            return false
        }
    }
}
