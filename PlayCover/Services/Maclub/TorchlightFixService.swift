import Foundation

class TorchlightFixService {
    private let bundleIdentifier = "com.xindong.torchlight"
    
    func fixStartupCrash() async -> (success: Bool, output: String, error: String) {
        let username = NSUserName()
        let containerPath = "/Users/\(username)/Library/Containers/com.xindong.torchlight/Data"
        let libraryPath = "/Users/\(username)/Library/Containers/com.xindong.torchlight/Data/Library/Users/\(username)/Library/Containers/com.xindong.torchlight/Data"
        
        let fileManager = FileManager.default
        
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: libraryPath, isDirectory: &isDirectory) {
            do {
                try fileManager.removeItem(atPath: libraryPath)
            } catch {
                return (false, "", "删除旧目录/符号链接失败: \(error.localizedDescription)")
            }
        }
        
        let libraryDir = "/Users/\(username)/Library/Containers/com.xindong.torchlight/Data/Library/Users/\(username)/Library/Containers/com.xindong.torchlight"
        do {
            try fileManager.createDirectory(atPath: libraryDir, withIntermediateDirectories: true)
        } catch {
            return (false, "", "创建目录结构失败: \(error.localizedDescription)")
        }
        
        do {
            try fileManager.createSymbolicLink(atPath: libraryPath, withDestinationPath: containerPath)
        } catch {
            return (false, "", "创建符号链接失败: \(error.localizedDescription)")
        }
        
        let output = """
启动闪退修复完成！

已执行的操作：
1. 删除旧的目录/符号链接
2. 创建正确的目录结构
3. 创建符号链接指向正确的数据目录

请重新启动Mac俱乐部客户端并启动游戏测试。
"""
        
        return (true, output, "")
    }
    
    @MainActor
    func enableDisableBuiltinMouse() async -> (success: Bool, output: String, error: String) {
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到火炬之光：无限，请确认游戏已通过Mac俱乐部客户端安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        if appSettings.settings.disableBuiltinMouse {
            return (true, "disableBuiltinMouse 选项已经启用，无需重复操作。", "")
        }
        
        appSettings.settings.disableBuiltinMouse = true
        appSettings.encode()
        
        let output = """
修复完成！

已为火炬之光：无限启用 disableBuiltinMouse 选项。

此选项会禁用内置鼠标处理，解决鼠标点击异常的问题。

请重新启动游戏测试。
"""
        
        return (true, output, "")
    }
}
