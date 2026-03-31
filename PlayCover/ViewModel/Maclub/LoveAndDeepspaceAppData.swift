import Foundation

class LoveAndDeepspaceAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01JGFE9PDBA0SQNH87WDQQDQME",
            name: "恋与深空",
            bundleIdentifier: "com.papegames.lysk",
            description: "恋与深空，由叠纸游戏开发的3D沉浸互动恋爱手游",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "loveanddeepspace_display_fix",
                name: "画面显示不全修复",
                description: "修复游戏画面显示不全的问题",
                detailedDescription: """
常见表现：
- 游戏画面只显示部分内容
- 窗口大小不正确
- UI元素被裁切

原因分析：
游戏默认分辨率与Mac屏幕不兼容。

解决方法：
将分辨率设置为 Resizable（可调整大小），允许游戏窗口自由调整。

修复后请重新启动游戏测试。
""",
                icon: "display",
                category: .display,
                fixAction: .custom("loveanddeepspace_display_fix")
            ),
            FixTool(
                id: "loveanddeepspace_login_fix",
                name: "登录界面输入修复",
                description: "修复登录界面无法输入的问题",
                detailedDescription: """
常见表现：
- 登录界面无法输入账号密码
- 键盘输入无响应

原因分析：
按键映射布局与登录界面的输入框冲突。

解决方法：
临时禁用按键映射布局。

重要提示：
登录完成后，请记得重新打开"按键映射布局"选项，以便在游戏中使用键盘鼠标操作。

修复后请重新启动游戏测试。
""",
                icon: "keyboard",
                category: .permission,
                fixAction: .custom("loveanddeepspace_login_fix")
            )
        ]
    }
}
