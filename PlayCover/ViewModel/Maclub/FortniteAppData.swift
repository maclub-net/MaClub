import Foundation

class FortniteAppData {
    static func createApp() -> FixApp {
        let tools = createTools()
        return FixApp(
            id: "01KHTCFFKQFK7TGFC2M470A1ZM",
            name: "Fortnite堡垒之夜",
            bundleIdentifier: "com.epicgames.FortniteGame",
            logoName: "fortnite",
            description: "Epic Games出品的多人在线射击游戏",
            tools: tools,
            downloadURL: URL(string: "https://www.maclub.net/appstore/01KHTCFFKQFK7TGFC2M470A1ZM")
        )
    }
    
    private static func createTools() -> [FixTool] {
        return [
            FixTool(
                id: "fortnite_entitlement_issue",
                name: "启动闪退1 ISSUE-009",
                description: "修复虚幻引擎缺少Entitlement导致的启动闪退",
                detailedDescription: """
常见表现：
- 启动闪退，无崩溃报告
- 通过终端运行游戏，日志停留在"Mobile Provision not found"

原因分析：
虚幻引擎会检查是否有对应的Entitlement，如果没有的话，会触发UE_LOG(Fatal)直接闪退。

解决方法：
虚幻引擎会先从可执行文件中读取Entitlement，然后尝试读取应用本体内的embedded.mobileprovision文件。此工具将Entitlements目录中的plist文件拷贝并重命名为embedded.mobileprovision。
""",
                icon: "exclamationmark.triangle.fill",
                category: .crash,
                fixAction: .custom("fortnite_entitlement_issue")
            ),
            FixTool(
                id: "fortnite_memory_issue",
                name: "启动闪退2 ISSUE-011",
                description: "修复内存检测API返回错误结果的问题",
                detailedDescription: """
常见表现：
- 游戏提示"设备性能不达标"
- 游戏采用最保守的内存管理策略，导致渲染距离极低、材质质量极低

原因分析：
PlayCover中的应用以Mac Catalyst模式运行。iOS上查询可用运行内存的函数os_proc_available_memory在Mac Catalyst环境下总是返回0。

解决方法：
修改_os_proc_available_memory函数，固定返回4GB的可用运行内存。

Tip: 将指令中第一个字节\\x20改为\\x40，即可变为8GB。
""",
                icon: "memorychip",
                category: .performance,
                fixAction: .custom("fortnite_memory_issue")
            ),
            FixTool(
                id: "fortnite_first_responder_issue",
                name: "启动闪退3",
                description: "修复非主线程调用becomeFirstResponder导致的闪退",
                detailedDescription: """
原因分析：
游戏在非主线程调用becomeFirstResponder导致闪退。

解决方法：
修改可执行文件中的相关代码，避免在非主线程调用becomeFirstResponder。

Warning:
【不稳定的指令】该指令可能在下版本失效，请留意下版本是否有更新指令。
""",
                icon: "exclamationmark.triangle.fill",
                category: .crash,
                fixAction: .custom("fortnite_first_responder_issue")
            ),
            FixTool(
                id: "fortnite_download_issue",
                name: "下载进度条回退/下载失败 ISSUE-001",
                description: "修复下载进度条回退和下载失败的问题",
                detailedDescription: """
通过删除并重建数据目录的符号链接来解决下载进度条回退和下载失败的问题。
""",
                icon: "arrow.down.to.line",
                category: .crash,
                fixAction: .custom("fortnite_download_issue")
            ),
            FixTool(
                id: "fortnite_mouse_issue",
                name: "鼠标点击异常 ISSUE-003",
                description: "解决鼠标点击异常的问题",
                detailedDescription: """
使用PlayCover Nightly版，右键游戏图标 - 设置 - 键盘映射设置，启用"disableBuiltinMouse"选项。
""",
                icon: "hand.tap",
                category: .permission,
                fixAction: .custom("fortnite_mouse_issue")
            )
        ]
    }
}
