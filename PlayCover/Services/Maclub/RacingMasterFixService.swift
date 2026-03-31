import Foundation

class RacingMasterFixService {
    private let shellService = ShellService.shared
    private let bundleIdentifier = "com.netease.rc"
    
    func fixStartupLag() async -> (success: Bool, output: String, error: String) {
        let username = NSUserName()
        let containerPath = "/Users/\(username)/Library/Containers/\(bundleIdentifier)/Data"
        
        let linkPath1 = "/Users/\(username)/Library/Containers/\(bundleIdentifier)/Data/Library/Users/\(username)/Documents/Containers/\(bundleIdentifier)/Data"
        let linkPath2 = "/Users/\(username)/Library/Containers/\(bundleIdentifier)/Data/Library/Users/\(username)/Library/Containers/\(bundleIdentifier)/Data"
        
        let fileManager = FileManager.default
        
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: linkPath1, isDirectory: &isDirectory) {
            do {
                try fileManager.removeItem(atPath: linkPath1)
            } catch {
                return (false, "", "删除旧目录/符号链接失败: \(error.localizedDescription)")
            }
        }
        
        let linkDir1 = "/Users/\(username)/Library/Containers/\(bundleIdentifier)/Data/Library/Users/\(username)/Documents/Containers/\(bundleIdentifier)"
        do {
            try fileManager.createDirectory(atPath: linkDir1, withIntermediateDirectories: true)
        } catch {
            return (false, "", "创建目录结构失败: \(error.localizedDescription)")
        }
        
        do {
            try fileManager.createSymbolicLink(atPath: linkPath1, withDestinationPath: containerPath)
        } catch {
            return (false, "", "创建符号链接失败: \(error.localizedDescription)")
        }
        
        if fileManager.fileExists(atPath: linkPath2, isDirectory: &isDirectory) {
            do {
                try fileManager.removeItem(atPath: linkPath2)
            } catch {
                return (false, "", "删除旧目录/符号链接失败: \(error.localizedDescription)")
            }
        }
        
        let linkDir2 = "/Users/\(username)/Library/Containers/\(bundleIdentifier)/Data/Library/Users/\(username)/Library/Containers/\(bundleIdentifier)"
        do {
            try fileManager.createDirectory(atPath: linkDir2, withIntermediateDirectories: true)
        } catch {
            return (false, "", "创建目录结构失败: \(error.localizedDescription)")
        }
        
        do {
            try fileManager.createSymbolicLink(atPath: linkPath2, withDestinationPath: containerPath)
        } catch {
            return (false, "", "创建符号链接失败: \(error.localizedDescription)")
        }
        
        let output = """
启动阶段卡顿修复完成！

已执行的操作：
1. 创建 Documents 目录下的符号链接
2. 创建 Library 目录下的符号链接

请重新启动Mac俱乐部客户端并启动游戏测试。
"""
        
        return (true, output, "")
    }
    
    func fixGraphicsQuality() async -> (success: Bool, output: String, error: String) {
        let executable = "~/Library/Containers/io.playcover.PlayCover/Applications/com.netease.rc.app/g112"
        let expandedPath = await shellService.expandPath(executable)
        
        let exists = await shellService.checkFileExists(at: expandedPath)
        guard exists else {
            return (false, "", "未找到g112文件，请确认巅峰极速已通过Mac俱乐部客户端安装")
        }
        
        let otoolResult = await shellService.execute(command: "otool -Iv '\(expandedPath)'")
        guard otoolResult.isSuccess else {
            return (false, "", "otool 执行失败: \(otoolResult.error)")
        }
        
        let funcAddr = parseOtoolOutput(otoolResult.output)
        
        guard let addr = funcAddr else {
            let error = """
无法定位目标函数地址

可能的原因：
1. 游戏版本已更新，补丁不再适用
2. 补丁已经被应用过
"""
            return (false, "", error)
        }
        
        let adjustedAddr = addr - 0x100000000
        let ddResult = await shellService.execute(command: "printf '\\x20\\x00\\xC0\\xD2\\xC0\\x03\\x5F\\xD6' | dd of='\(expandedPath)' bs=1 seek=\(adjustedAddr) conv=notrunc")
        
        guard ddResult.isSuccess else {
            return (false, "", "补丁应用失败: \(ddResult.error)")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(expandedPath)' --deep --preserve-metadata=entitlements")
        
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        if codesignResult.isSuccess {
            let output = """
画质限制修复完成！

已执行的操作：
1. 定位 g112 中的 _os_proc_available_memory 函数地址
2. 写入修正指令
3. 重新签名框架

请重新启动Mac俱乐部客户端并启动游戏测试。
"""
            return (true, output, filteredError)
        }
        
        return (false, codesignResult.output, filteredError)
    }
    
    private func parseOtoolOutput(_ output: String) -> Int? {
        for line in output.components(separatedBy: "\n") {
            if line.contains("_os_proc_available_memory") {
                let parts = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                if let firstPart = parts.first,
                   let addr = Int(firstPart, radix: 16) {
                    return addr
                }
            }
        }
        
        return nil
    }
}
