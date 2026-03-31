import Foundation

class Persona5XAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01JE3A0CPA7KK2WM0STRSGX0ND",
            name: "女神异闻录：夜幕魅影",
            bundleIdentifier: "com.pwrd.persona5x.pw",
            description: "女神异闻录：夜幕魅影，由完美世界开发的P5IP衍生手游",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "persona5x_startup_fix",
                name: "启动闪退修复",
                description: "修复游戏启动时闪退的问题",
                detailedDescription: """
常见表现：
- 游戏启动后立即闪退
- 无法正常进入游戏

原因分析：
KeyboardDelegate 的 Initialize 方法导致启动崩溃。

解决方法：
通过修改 UnityFramework 中的特定函数，使其直接返回，绕过崩溃代码。

执行的操作：
1. 定位 UnityFramework 中的 KeyboardDelegate Initialize 函数地址
2. 写入 RET 指令
3. 重新签名框架

修复后请重新启动游戏测试。
""",
                icon: "exclamationmark.triangle.fill",
                category: .crash,
                fixAction: .custom("persona5x_startup_fix")
            ),
            FixTool(
                id: "persona5x_limit_motion",
                name: "CPU占用异常修复",
                description: "修复游戏CPU占用异常偏高的问题",
                detailedDescription: """
常见表现：
- 游戏运行时CPU占用过高
- 风扇噪音大，设备发热严重

原因分析：
游戏频繁请求运动传感器数据，导致CPU负载过高。

解决方法：
启用"limitMotionUpdateFrequency"选项，限制运动传感器的更新频率。

修复后请重新启动游戏测试。
""",
                icon: "gauge",
                category: .performance,
                fixAction: .custom("persona5x_limit_motion")
            )
        ]
    }
}
