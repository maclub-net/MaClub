import Foundation

class AzurLaneFixService {
    private let shellService = ShellService.shared
    
    func fixKeyMappingIssue() async -> (success: Bool, output: String, error: String) {
        let executable = "~/Library/Containers/io.playcover.PlayCover/Applications/com.bilibili.azurlane.app/Frameworks/UnityFramework.framework/UnityFramework"
        let expandedPath = await shellService.expandPath(executable)
        
        let exists = await shellService.checkFileExists(at: expandedPath)
        guard exists else {
            return (false, "", "未找到UnityFramework框架文件，请确认碧蓝航线已通过Mac俱乐部安装")
        }
        
        let awkCommand = "otool -oV '\(expandedPath)' | awk '/SessionProvider/{found=1} found && /init/{f=1} f && /imp/{print $2; exit}'"
        let funcAddrResult = await shellService.execute(command: awkCommand)
        
        let rawOutput = funcAddrResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let regex = try? NSRegularExpression(pattern: "0x[0-9A-Fa-f]+") else {
            return (false, "", "无法创建正则表达式")
        }
        let range = NSRange(rawOutput.startIndex..., in: rawOutput)
        let matches = regex.matches(in: rawOutput, options: [], range: range)
        
        guard let match = matches.first else {
            let output = "函数地址查询结果: '\(rawOutput)'"
            let error = "无法定位SessionProvider.init函数地址\n输出内容: '\(rawOutput)'"
            return (false, output, error)
        }
        
        let hexString = String(rawOutput[Range(match.range, in: rawOutput)!])
        let cleanAddrStr = hexString.replacingOccurrences(of: "0x", with: "")
        let output = "函数地址查询结果: \(hexString)\n原始输出: '\(rawOutput)'"
        
        guard let funcAddr = Int(cleanAddrStr, radix: 16) else {
            return (false, output, "无法将十六进制地址转换为整数: \(hexString)")
        }
        
        let offset1 = funcAddr + 0x1C4
        let ddResult1 = await shellService.execute(command: "printf '\\x1F\\x20\\x03\\xD5' | dd of='\(expandedPath)' bs=1 seek=\(offset1) conv=notrunc")
        guard ddResult1.isSuccess else {
            return (false, output, "在偏移+0x1C4处应用补丁失败: \(ddResult1.error)")
        }
        
        let offset2 = funcAddr + 0x374
        let ddResult2 = await shellService.execute(command: "printf '\\x1F\\x20\\x03\\xD5' | dd of='\(expandedPath)' bs=1 seek=\(offset2) conv=notrunc")
        guard ddResult2.isSuccess else {
            return (false, output, "在偏移+0x374处应用补丁失败: \(ddResult2.error)")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(expandedPath)'")
        
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        let successOutput = "修复ISSUE-014完成！\n已在SessionProvider.init函数的两个位置写入NOP指令\n\n函数地址: \(hexString)\n补丁位置: +0x1C4, +0x374\n\n请重启PlayCover并启动游戏测试。"
        return (codesignResult.isSuccess, successOutput, filteredError)
    }
}
