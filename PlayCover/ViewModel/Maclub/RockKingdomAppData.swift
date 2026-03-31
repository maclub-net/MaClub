import Foundation

class RockKingdomAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01KMCQ82MNTZPNNB3RA2DED868",
            name: "洛克王国：世界",
            bundleIdentifier: "com.tencent.nrc",
            description: "腾讯魔方工作室群自研的开放世界精灵捕捉游戏",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "rockkingdom_init_fix",
                name: "修复初始化失败",
                description: "修复游戏启动时提示\"初始化失败\"的问题",
                detailedDescription: """
游戏启动时可能会提示"初始化失败"，这是由于游戏容器目录下的 Documents 目录结构异常导致的。

此工具会：
1. 删除异常的 Documents 目录结构
2. 创建正确的符号链接

执行的操作：
rm -rf /Users/$USER/Library/Containers/com.tencent.nrc/Data/Documents/Users/$USER/Library/Containers/com.tencent.nrc/Data
ln -sf /Users/$USER/Library/Containers/com.tencent.nrc/Data /Users/$USER/Library/Containers/com.tencent.nrc/Data/Documents/Users/$USER/Library/Containers/com.tencent.nrc/Data
""",
                icon: "arrow.clockwise",
                category: .crash,
                fixAction: .shellCommand("""
                    rm -rf /Users/$USER/Library/Containers/com.tencent.nrc/Data/Documents/Users/$USER/Library/Containers/com.tencent.nrc/Data && \
                    ln -sf /Users/$USER/Library/Containers/com.tencent.nrc/Data /Users/$USER/Library/Containers/com.tencent.nrc/Data/Documents/Users/$USER/Library/Containers/com.tencent.nrc/Data
                    """)
            ),
            FixTool(
                id: "rockkingdom_block_sleep_spamming",
                name: "闪退修复",
                description: "修复游戏短暂运行后闪退的问题",
                detailedDescription: """
常见表现：
- 游戏启动后短暂运行即闪退
- 无法正常进行游戏

原因分析：
游戏可能频繁调用 usleep() 系统调用，导致资源耗尽而闪退。

解决方法：
启用"blockSleepSpamming"选项，阻止游戏频繁调用 usleep() 系统调用。

修复后请重新启动游戏测试。
""",
                icon: "exclamationmark.triangle.fill",
                category: .crash,
                fixAction: .custom("rockkingdom_block_sleep_spamming")
            ),
            FixTool(
                id: "rockkingdom_disable_builtin_mouse",
                name: "鼠标点击异常修复",
                description: "修复游戏内鼠标点击异常的问题",
                detailedDescription: """
常见表现：
- 鼠标点击无响应或点击位置偏移
- 无法正常进行游戏操作

解决方法：
启用"disableBuiltinMouse"选项，禁用游戏内置的鼠标处理。

修复后请重新启动游戏测试。
""",
                icon: "cursorarrow.click.badge.clock",
                category: .display,
                fixAction: .custom("rockkingdom_disable_builtin_mouse")
            ),
            FixTool(
                id: "rockkingdom_check_mic_permission",
                name: "麦克风权限修复",
                description: "修复游戏提示\"您拒绝了麦克风权限\"的问题",
                detailedDescription: """
常见表现：
- 游戏提示"您拒绝了麦克风权限"
- 无法使用语音功能

解决方法：
启用"checkMicPermissionSync"选项，修复麦克风权限检测问题。

修复后请重新启动游戏测试。

注意：如果同时通过Sideloadly、Mac俱乐部客户端和PlayCover安装了游戏，麦克风的授权记录可能会出现错乱的情况。

解决方法：三个都卸载干净，再通过Mac俱乐部客户端重新安装一次即可解决问题。
""",
                icon: "mic.fill",
                category: .permission,
                fixAction: .custom("rockkingdom_check_mic_permission")
            )
        ]
    }
}
