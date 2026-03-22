import Foundation

class JkchessFixService {
    private let shellService = ShellService.shared
    
    func fixMicrophone() async -> (success: Bool, output: String, error: String) {
        let executable = "~/Library/Containers/io.playcover.PlayCover/Applications/com.tencent.jkchess.app/jkchess"
        let expandedPath = await shellService.expandPath(executable)
        
        let exists = await shellService.checkFileExists(at: expandedPath)
        guard exists else {
            return (false, "", "未找到金铲铲之战可执行文件，请确认游戏已通过PlayCover安装")
        }
        
        let patterns = [
            "\\x7F\\x0A\\x00\\x71\\x93\\x02\\x88\\x1A\\xE0\\x03\\x13\\xAA",
            "\\x7F\\x0A\\x00\\x71\\x93\\x02\\x88\\x1A\\xE0\\x03\\x14\\xAA"
        ]
        
        var patched = false
        for pattern in patterns {
            let perlCommand = """
            perl -e 'open F, "+<:raw", $ARGV[0] or die $!; local $/; my $d = <F>; \
            my $i = index($d, "\(pattern)"); exit 1 if $i < 0; \
            seek F, $i + 8, 0; print F "\\x20\\x00\\x80\\xD2"; close F;' '\(expandedPath)'
            """
            
            let perlResult = await shellService.execute(command: perlCommand)
            if perlResult.isSuccess {
                patched = true
                break
            }
        }
        
        guard patched else {
            let error = """
补丁应用失败: 未找到目标字节序列

可能的原因：
1. 游戏版本已更新，补丁不再适用
2. 补丁已经被应用过

替代方案：
请使用 PlayCover 开发版，右键游戏图标 → 设置 → 绕过设置，启用 "checkMicPermissionSync" 选项。

PlayCover 开发版下载地址：
https://www.maclub.net/appstore/01KJ4XB1N268SF2J14GKQ3TVFS
"""
            return (false, "", error)
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(expandedPath)' --deep --preserve-metadata=entitlements")
        
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        return (codesignResult.isSuccess, codesignResult.output, filteredError)
    }
    
    func fixOrientation() async -> (success: Bool, output: String, error: String) {
        let executable = "~/Library/Containers/io.playcover.PlayCover/Applications/com.tencent.jkchess.app/Frameworks/MSDKWebView.framework/MSDKWebView"
        let expandedPath = await shellService.expandPath(executable)
        
        let exists = await shellService.checkFileExists(at: expandedPath)
        guard exists else {
            return (false, "", "未找到MSDKWebView框架文件，请确认游戏已通过PlayCover安装")
        }
        
        let awkCommand = "otool -oV '\(expandedPath)' | awk '/MSDKBaseWebViewController/{found=1} found && /supportedInterfaceOrientations/{f=1} f && /imp/{print $2; exit}'"
        let funcAddrResult = await shellService.execute(command: awkCommand)
        
        let rawOutput = funcAddrResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let regex = try? NSRegularExpression(pattern: "0x[0-9A-Fa-f]+") else {
            return (false, "", "无法创建正则表达式")
        }
        let range = NSRange(rawOutput.startIndex..., in: rawOutput)
        let matches = regex.matches(in: rawOutput, options: [], range: range)
        
        guard let match = matches.first else {
            let output = "函数地址查询结果: '\(rawOutput)'"
            let error = "无法定位supportedInterfaceOrientations函数地址\n输出内容: '\(rawOutput)'"
            return (false, output, error)
        }
        
        let hexString = String(rawOutput[Range(match.range, in: rawOutput)!])
        let cleanAddrStr = hexString.replacingOccurrences(of: "0x", with: "")
        let output = "函数地址查询结果: \(hexString)\n原始输出: '\(rawOutput)'"
        
        guard let funcAddr = Int(cleanAddrStr, radix: 16) else {
            return (false, output, "无法将十六进制地址转换为整数: \(hexString)")
        }
        
        let ddCommand = "printf '\\x00\\x03\\x80\\xD2\\xC0\\x03\\x5F\\xD6' | dd of='\(expandedPath)' bs=1 seek=\(funcAddr) conv=notrunc"
        let ddResult = await shellService.execute(command: ddCommand)
        
        guard ddResult.isSuccess else {
            return (false, output, "补丁应用失败: \(ddResult.error)")
        }
        
        let codesignResult = await shellService.execute(command: "codesign -fs- '\(expandedPath)'")
        
        var filteredError = codesignResult.error
        if filteredError.contains("replacing existing signature") {
            filteredError = ""
        }
        
        return (codesignResult.isSuccess, codesignResult.output, filteredError)
    }
}
