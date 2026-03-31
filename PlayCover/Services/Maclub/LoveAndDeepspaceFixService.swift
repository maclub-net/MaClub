import Foundation

class LoveAndDeepspaceFixService {
    private let bundleIdentifier = "com.papegames.lysk"
    
    @MainActor
    func setResizableResolution() async -> (success: Bool, output: String, error: String) {
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到恋与深空，请确认游戏已通过Mac俱乐部客户端安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        if appSettings.settings.resolution == 6 {
            return (true, "分辨率已经设置为 Resizable，无需重复操作。", "")
        }
        
        appSettings.settings.resolution = 6
        appSettings.encode()
        
        let output = """
修复完成！

已将分辨率设置为 Resizable（可调整大小）。

此选项允许游戏窗口自由调整大小，解决画面显示不全的问题。

请重新启动游戏测试。
"""
        
        return (true, output, "")
    }
    
    @MainActor
    func disableKeyMapping() async -> (success: Bool, output: String, error: String) {
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到恋与深空，请确认游戏已通过Mac俱乐部客户端安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        if !appSettings.settings.keymapping {
            return (true, "按键映射布局已经禁用，无需重复操作。", "")
        }
        
        appSettings.settings.keymapping = false
        appSettings.encode()
        
        let output = """
修复完成！

已禁用按键映射布局。

重要提示：
登录完成后，请记得重新打开"按键映射布局"选项，以便在游戏中使用键盘鼠标操作。

请重新启动游戏测试。
"""
        
        return (true, output, "")
    }
}
