import Foundation

class NikkeFixService {
    private let shellService = ShellService.shared
    private let bundleIdentifier = "com.proximabeta.nikke"
    
    func fixStartup() async -> (success: Bool, output: String, error: String) {
        let executable = "~/Library/Containers/io.playcover.PlayCover/Applications/com.proximabeta.nikke.app/Frameworks/UnityFramework.framework/UnityFramework"
        let expandedPath = await shellService.expandPath(executable)
        
        let exists = await shellService.checkFileExists(at: expandedPath)
        guard exists else {
            return (false, "", "未找到UnityFramework文件，请确认NIKKE已通过Mac俱乐部客户端安装")
        }
        
        let otoolResult = await shellService.execute(command: "otool -oV '\(expandedPath)'")
        guard otoolResult.isSuccess else {
            return (false, "", "otool 执行失败: \(otoolResult.error)")
        }
        
        let funcAddr = parseOtoolOutput(otoolResult.output,
                                        className: "INTLUtilsIOS",
                                        methodName: "swizzlingOriginalClass:swizzledClass:originalSEL:swizzledSEL:")
        
        guard let addr = funcAddr else {
            let error = """
无法定位目标函数地址

可能的原因：
1. 游戏版本已更新，补丁不再适用
2. 补丁已经被应用过
"""
            return (false, "", error)
        }
        
        let ddResult = await shellService.execute(command: "printf '\\xC0\\x03\\x5F\\xD6' | dd of='\(expandedPath)' bs=1 seek=\(addr) conv=notrunc")
        
        guard ddResult.isSuccess else {
            return (false, "", "补丁应用失败: \(ddResult.error)")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(expandedPath)'")
        
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        if codesignResult.isSuccess {
            let output = """
启动卡死修复完成！

已执行的操作：
1. 定位 UnityFramework 中的目标函数地址
2. 写入 RET 指令
3. 重新签名框架

请重新启动Mac俱乐部客户端并启动游戏测试。
"""
            return (true, output, filteredError)
        }
        
        return (false, codesignResult.output, filteredError)
    }
    
    func fixDisplay() async -> (success: Bool, output: String, error: String) {
        let executable = "~/Library/Containers/io.playcover.PlayCover/Applications/com.proximabeta.nikke.app/Frameworks/UnityFramework.framework/UnityFramework"
        let expandedPath = await shellService.expandPath(executable)
        
        let exists = await shellService.checkFileExists(at: expandedPath)
        guard exists else {
            return (false, "", "未找到UnityFramework文件，请确认NIKKE已通过Mac俱乐部客户端安装")
        }
        
        let otoolResult = await shellService.execute(command: "otool -oV '\(expandedPath)'")
        guard otoolResult.isSuccess else {
            return (false, "", "otool 执行失败: \(otoolResult.error)")
        }
        
        let funcAddr = parseOtoolOutput(otoolResult.output,
                                        className: "UnityDefaultViewController",
                                        methodName: "supportedInterfaceOrientations")
        
        guard let addr = funcAddr else {
            let error = """
无法定位目标函数地址

可能的原因：
1. 游戏版本已更新，补丁不再适用
2. 补丁已经被应用过
"""
            return (false, "", error)
        }
        
        let ddResult = await shellService.execute(command: "printf '\\x00\\x03\\x80\\xD2\\xC0\\x03\\x5F\\xD6' | dd of='\(expandedPath)' bs=1 seek=\(addr) conv=notrunc")
        
        guard ddResult.isSuccess else {
            return (false, "", "补丁应用失败: \(ddResult.error)")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(expandedPath)'")
        
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        if codesignResult.isSuccess {
            let output = """
画面显示不全修复完成！

已执行的操作：
1. 定位 UnityFramework 中的 supportedInterfaceOrientations 函数地址
2. 写入修正指令
3. 重新签名框架

请重新启动Mac俱乐部客户端并启动游戏测试。
"""
            return (true, output, filteredError)
        }
        
        return (false, codesignResult.output, filteredError)
    }
    
    @MainActor
    func enableLimitMotionUpdateFrequency() async -> (success: Bool, output: String, error: String) {
        let apps = AppsVM.shared.apps
        guard let app = apps.first(where: { $0.info.bundleIdentifier == bundleIdentifier }) else {
            return (false, "", "未找到NIKKE，请确认游戏已通过Mac俱乐部客户端安装\n\nBundle ID: \(bundleIdentifier)")
        }
        
        let appSettings = app.settings
        
        if appSettings.settings.limitMotionUpdateFrequency {
            return (true, "limitMotionUpdateFrequency 选项已经启用，无需重复操作。", "")
        }
        
        appSettings.settings.limitMotionUpdateFrequency = true
        appSettings.encode()
        
        let output = """
修复完成！

已为NIKKE启用 limitMotionUpdateFrequency 选项。

此选项会限制运动传感器的更新频率，解决CPU占用异常偏高的问题。

请重新启动游戏测试。
"""
        
        return (true, output, "")
    }
    
    private func parseOtoolOutput(_ output: String, className: String, methodName: String) -> Int? {
        var foundClass = false
        var foundMethod = false
        
        for line in output.components(separatedBy: "\n") {
            if line.contains(className) {
                foundClass = true
            }
            if foundClass && line.contains(methodName) {
                foundMethod = true
            }
            if foundMethod && line.contains("imp") {
                if let range = line.range(of: "0x[0-9A-Fa-f]+", options: .regularExpression) {
                    let hexString = String(line[range])
                    let cleanAddrStr = hexString.replacingOccurrences(of: "0x", with: "")
                    return Int(cleanAddrStr, radix: 16)
                }
            }
        }
        
        return nil
    }
}
