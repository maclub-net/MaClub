import Foundation

class SimCityFixService {
    private let shellService = ShellService.shared
    
    func fixCrash() async -> (success: Bool, output: String, error: String) {
        let appPath = "~/Library/Containers/io.playcover.PlayCover/Applications/com.ea.simcitymobile.bv.app"
        let frameworkPath = "~/Library/Containers/io.playcover.PlayCover/Applications/com.ea.simcitymobile.bv.app/Frameworks/anzu.sdk.framework/anzu.sdk"
        
        let expandedAppPath = await shellService.expandPath(appPath)
        let expandedFrameworkPath = await shellService.expandPath(frameworkPath)
        
        let frameworkExists = await shellService.checkFileExists(at: expandedFrameworkPath)
        guard frameworkExists else {
            return (false, "", "未找到anzu.sdk框架文件，请确认美区版SimCity已通过PlayCover安装\n\n注意：国区版本（com.gamecomb.simcity）不需要此修复")
        }
        
        let backupPath = "\(expandedFrameworkPath).backup"
        let backupResult = await shellService.execute(command: "cp '\(expandedFrameworkPath)' '\(backupPath)'")
        guard backupResult.isSuccess else {
            return (false, "", "备份失败: \(backupResult.error)")
        }
        
        let removeIosCmd = """
        vtool -remove-build-version ios -replace '\(expandedFrameworkPath)' \
        -o '\(expandedFrameworkPath)' 2>&1 || \
        vtool -remove-build-version iphoneos -replace '\(expandedFrameworkPath)' \
        -o '\(expandedFrameworkPath)' 2>&1 || true
        """
        let removeIosResult = await shellService.execute(command: removeIosCmd)
        
        let setMacResult = await shellService.execute(command: "vtool -set-build-version maccatalyst 11.0 14.0 -replace '\(expandedFrameworkPath)' -o '\(expandedFrameworkPath)'")
        guard setMacResult.isSuccess else {
            return (false, "", "设置平台声明失败: \(setMacResult.error)")
        }
        
        let codesignFramework = await shellService.execute(command: "codesign -f -s - '\(expandedFrameworkPath)'")
        guard codesignFramework.isSuccess else {
            var filteredError = codesignFramework.error
            if filteredError.contains("replacing existing signature") {
                filteredError = ""
            }
            return (false, "", "签名框架失败: \(filteredError)")
        }
        
        let frameworkDir = (expandedFrameworkPath as NSString).deletingLastPathComponent
        let codesignFrameworkDir = await shellService.execute(command: "codesign -f -s - '\(frameworkDir)'")
        guard codesignFrameworkDir.isSuccess else {
            var filteredError = codesignFrameworkDir.error
            if filteredError.contains("replacing existing signature") {
                filteredError = ""
            }
            return (false, "", "签名框架目录失败: \(filteredError)")
        }
        
        let codesignApp = await shellService.execute(command: "codesign -f -s - '\(expandedAppPath)'")
        
        var filteredError = codesignApp.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        let output = "SimCity闪退修复完成！\n备份文件位置: \(backupPath)\n\n请重启PlayCover并启动游戏测试。"
        return (codesignApp.isSuccess, output, filteredError)
    }
}
