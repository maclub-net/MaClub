import Foundation

class TorchlightAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01J87BJYT35BXPHYBAF6MFG5BR",
            name: "火炬之光：无限",
            bundleIdentifier: "com.xindong.torchlight",
            description: "火炬之光：无限，由心动网络开发的动作角色扮演游戏",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "torchlight_startup_fix",
                name: "启动闪退修复",
                description: "修复游戏启动时闪退的问题",
                detailedDescription: """
常见表现：
- 游戏启动后立即闪退
- 无法正常进入游戏

原因分析：
游戏数据目录结构异常，导致无法正确读取游戏数据。

解决方法：
删除错误的目录结构，创建正确的符号链接。

执行的操作：
1. 删除旧的目录/符号链接
2. 创建正确的目录结构
3. 创建符号链接指向正确的数据目录

修复后请重新启动游戏测试。
""",
                icon: "exclamationmark.triangle.fill",
                category: .crash,
                fixAction: .custom("torchlight_startup_fix")
            ),
            FixTool(
                id: "torchlight_mouse_fix",
                name: "鼠标点击异常修复",
                description: "修复游戏鼠标点击异常的问题",
                detailedDescription: """
常见表现：
- 鼠标点击无响应
- 点击位置偏移
- 无法正常操作游戏界面

原因分析：
游戏内置的鼠标处理与 macOS 系统冲突。

解决方法：
启用"disableBuiltinMouse"选项，禁用内置鼠标处理。

修复后请重新启动游戏测试。
""",
                icon: "cursorarrow.click",
                category: .display,
                fixAction: .custom("torchlight_mouse_fix")
            )
        ]
    }
}
