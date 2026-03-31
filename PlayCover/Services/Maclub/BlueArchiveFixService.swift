import Foundation

class BlueArchiveFixService {
    private let bundleIdentifier = "com.RoamingStar.BlueArchive"
    
    @MainActor
    func enableLimitMotionUpdateFrequency() async -> (success: Bool, output: String, error: String) {
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到蔚蓝档案，请确认游戏已通过Mac俱乐部客户端安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        if appSettings.settings.limitMotionUpdateFrequency {
            return (true, "limitMotionUpdateFrequency 选项已经启用，无需重复操作。", "")
        }
        
        appSettings.settings.limitMotionUpdateFrequency = true
        appSettings.encode()
        
        let output = """
修复完成！

已为蔚蓝档案启用 limitMotionUpdateFrequency 选项。

此选项会限制运动传感器的更新频率，解决CPU占用异常偏高的问题。

请重新启动游戏测试。
"""
        
        return (true, output, "")
    }
}
