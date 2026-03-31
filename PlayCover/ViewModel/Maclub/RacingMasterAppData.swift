import Foundation

class RacingMasterAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01J81PX1MWHT56V0D7VYGZSBHS",
            name: "巅峰极速",
            bundleIdentifier: "com.netease.rc",
            description: "巅峰极速，由网易开发的高拟真赛车手游",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "racingmaster_startup_lag_fix",
                name: "启动阶段卡顿修复",
                description: "修复游戏启动阶段异常卡顿的问题",
                detailedDescription: """
常见表现：
- 游戏启动阶段异常卡顿
- 加载时间过长

重要提示：
请确保已下载完最开始的200MB资源后再使用本工具！

原因分析：
游戏数据目录结构异常，导致无法正确读取游戏数据。

解决方法：
创建正确的符号链接，使游戏能够正确访问数据目录。

执行的操作：
1. 创建 Documents 目录下的符号链接
2. 创建 Library 目录下的符号链接

修复后请重新启动游戏测试。
""",
                icon: "timer",
                category: .performance,
                fixAction: .custom("racingmaster_startup_lag_fix")
            ),
            FixTool(
                id: "racingmaster_graphics_quality_fix",
                name: "画质限制修复",
                description: "修复提示“设备不支持更高画质”的问题",
                detailedDescription: """
常见表现：
- 提示“设备不支持更高画质”
- 无法选择高画质选项

原因分析：
游戏检测到设备内存不足，限制了画质选项。

解决方法：
修改 _os_proc_available_memory 函数返回值，绕过内存检测。

执行的操作：
1. 定位 g112 中的 _os_proc_available_memory 函数地址
2. 写入修正指令
3. 重新签名框架

修复后请重新启动游戏测试。
""",
                icon: "display",
                category: .display,
                fixAction: .custom("racingmaster_graphics_quality_fix")
            )
        ]
    }
}
