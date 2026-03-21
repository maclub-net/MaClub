import Foundation

class JkchessAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01HSACVCTS7DR867TASMYXP3GG",
            name: "金铲铲之战",
            bundleIdentifier: "com.tencent.jkchess",
            logoName: "jkchess",
            description: "腾讯自研英雄策略对战手游",
            tools: tools,
            downloadURL: URL(string: "https://www.maclub.net/appstore/01HSACVCTS7DR867TASMYXP3GG")
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "jkchess_microphone",
                name: "开启麦克风功能",
                description: "修复游戏提示\"您拒绝了麦克风权限\"的问题",
                detailedDescription: """
游戏通过UnityEngine.Application.HasUserAuthorization查询麦克风权限，但该接口返回结果总是false。

此工具通过补丁强制HasUserAuthorization()返回true，解决麦克风权限问题。

执行的操作：
1. 对游戏可执行文件应用二进制补丁
2. 重新签名应用

注意：如果同时通过Sideloadly和PlayCover安装了游戏，麦克风的授权记录可能会出现错乱。建议两边都卸载干净，再通过PlayCover重新安装。

替代方案：
如果补丁应用失败，请使用 PlayCover 开发版，右键游戏图标 → 设置 → 绕过设置，启用 "checkMicPermissionSync" 选项。

PlayCover 开发版下载地址：
https://www.maclub.net/appstore/01KJ4XB1N268SF2J14GKQ3TVFS
""",
                icon: "mic.fill",
                category: .permission,
                fixAction: .custom("jkchess_microphone")
            ),
            FixTool(
                id: "jkchess_orientation",
                name: "阵容推荐屏幕方向修复",
                description: "修复阵容推荐界面屏幕方向错误的问题",
                detailedDescription: """
阵容推荐界面可能只显示竖屏，或者supportedInterfaceOrientations第一次返回的值仅包含竖屏。

Mac上运行的iOS应用受限于supportedInterfaceOrientations第一次返回的值，如果第一次返回的值不包含横屏，就永远无法切换成横屏显示。

此工具强制supportedInterfaceOrientations返回UIInterfaceOrientationMaskLandscape (24)，解决屏幕方向问题。

执行的操作：
1. 定位MSDKWebView框架中的supportedInterfaceOrientations函数
2. 应用补丁强制返回横屏方向
3. 重新签名框架
""",
                icon: "rectangle.landscape.rotate",
                category: .display,
                fixAction: .custom("jkchess_orientation")
            )
        ]
    }
}
