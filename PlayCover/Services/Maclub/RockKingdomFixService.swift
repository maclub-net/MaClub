import Foundation

@MainActor
class RockKingdomFixService {
    private let bundleIdentifier = "com.tencent.nrc"
    
    func enableBlockSleepSpamming() async -> (success: Bool, output: String, error: String) {
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到洛克王国：世界，请确认游戏已通过Mac俱乐部客户端安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        if appSettings.settings.blockSleepSpamming {
            return (true, "blockSleepSpamming 选项已经启用，无需重复操作。", "")
        }
        
        appSettings.settings.blockSleepSpamming = true
        appSettings.encode()
        
        let output = """
修复完成！

已为洛克王国：世界启用 blockSleepSpamming 选项。

此选项会阻止游戏频繁调用 usleep() 系统调用，解决短暂运行后闪退的问题。

请重新启动游戏测试。
"""
        
        return (true, output, "")
    }
    
    func enableDisableBuiltinMouse() async -> (success: Bool, output: String, error: String) {
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到洛克王国：世界，请确认游戏已通过Mac俱乐部客户端安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        if appSettings.settings.disableBuiltinMouse {
            return (true, "disableBuiltinMouse 选项已经启用，无需重复操作。", "")
        }
        
        appSettings.settings.disableBuiltinMouse = true
        appSettings.encode()
        
        let output = """
修复完成！

已为洛克王国：世界启用 disableBuiltinMouse 选项。

此选项会禁用游戏内置的鼠标处理，解决鼠标点击异常的问题。

请重新启动游戏测试。
"""
        
        return (true, output, "")
    }
    
    func enableCheckMicPermissionSync() async -> (success: Bool, output: String, error: String) {
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到洛克王国：世界，请确认游戏已通过Mac俱乐部客户端安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        if appSettings.settings.checkMicPermissionSync {
            return (true, "checkMicPermissionSync 选项已经启用，无需重复操作。", "")
        }
        
        appSettings.settings.checkMicPermissionSync = true
        appSettings.encode()
        
        let output = """
修复完成！

已为洛克王国：世界启用 checkMicPermissionSync 选项。

此选项会修复麦克风权限检测问题。

请重新启动游戏测试。

注意：如果同时通过Sideloadly、Mac俱乐部客户端和PlayCover安装了游戏，麦克风的授权记录可能会出现错乱的情况。

解决方法：三个都卸载干净，再通过Mac俱乐部客户端重新安装一次即可解决问题。
"""
        
        return (true, output, "")
    }
}
