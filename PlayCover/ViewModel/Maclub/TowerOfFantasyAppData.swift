import Foundation

class TowerOfFantasyAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01JM6Z8YCJ3FATZVZ1FSTJ87WF",
            name: "幻塔",
            bundleIdentifier: "com.pwrd.huanta",
            description: "幻塔，由Hotta Studio开发的开放世界动作RPG",
            tools: tools
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "toweroffantasy_character_rendering_fix",
                name: "角色建模渲染修复",
                description: "修复游戏角色建模渲染异常的问题",
                detailedDescription: """
常见表现：
- 角色建模显示异常
- 角色模型出现闪烁或缺失
- 贴图加载错误

原因分析：
游戏中的 _os_proc_available_memory 函数返回值异常，导致渲染逻辑出错。

解决方法：
修改该函数使其返回固定值，绕过异常逻辑。

执行的操作：
1. 定位 QRSL 中的 _os_proc_available_memory 函数地址
2. 写入修正指令
3. 重新签名框架

修复后请重新启动游戏测试。
""",
                icon: "person.crop.rectangle.fill",
                category: .display,
                fixAction: .custom("toweroffantasy_character_rendering_fix")
            )
        ]
    }
}
