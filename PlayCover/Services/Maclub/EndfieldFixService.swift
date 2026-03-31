import Foundation

@MainActor
class EndfieldFixService {
    func enableBlockSleepSpamming() async -> (success: Bool, output: String, error: String) {
        let bundleIdentifier = "com.hypergryph.endfield"
        
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到明日方舟：终末地，请确认游戏已通过PlayCover安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        let currentValue = appSettings.settings.blockSleepSpamming
        print("当前 blockSleepSpamming 值: \(currentValue)")
        
        if currentValue {
            return (true, "blockSleepSpamming 选项已经启用，无需重复操作。", "")
        }
        
        appSettings.settings.blockSleepSpamming = true
        appSettings.encode()
        
        let output = """
修复完成！

已为明日方舟：终末地启用 blockSleepSpamming 选项。

此选项会阻止游戏频繁调用 usleep() 系统调用，解决短暂运行后闪退的问题。

请重新启动游戏测试。
"""
        
        return (true, output, "")
    }
}
