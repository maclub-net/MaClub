import Foundation

class AppDataManager {
    static let shared = AppDataManager()
    
    let apps: [FixApp]
    
    private init() {
        self.apps = Self.createApps()
    }
    
    private static func createApps() -> [FixApp] {
        return [
            JkchessAppData.createApp(),
            SimCityAppData.createApp(),
            FortniteAppData.createApp(),
            AzurLaneAppData.createApp(),
            RockKingdomAppData.createApp(),
            NeteasePartyAppData.createApp(),
            EndfieldAppData.createApp(),
            NikkeAppData.createApp(),
            NikkeCNAppData.createApp(),
            BlueArchiveAppData.createApp(),
            TowerOfFantasyAppData.createApp(),
            LoveAndDeepspaceAppData.createApp(),
            Persona5XAppData.createApp(),
            TorchlightAppData.createApp(),
            RacingMasterAppData.createApp()
        ]
    }
}
