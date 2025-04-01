


import UIKit

extension UserDefaults {
    static let favoriteTracksKey = "favoriteTracksKey"
    
    func savedTracks() -> [SearchViewModel.Cell] {
        let userDefaults = UserDefaults.standard
        
        guard let savedData = userDefaults.data(forKey: UserDefaults.favoriteTracksKey) else { return [] }
        
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: savedData)
            unarchiver.requiresSecureCoding = false
            let decodedTracks = unarchiver.decodeObject(of: [NSArray.self, SearchViewModel.Cell.self], forKey: NSKeyedArchiveRootObjectKey) as? [SearchViewModel.Cell] ?? []
            return decodedTracks
        } catch {
            print("Decoding error:", error)
            return []
        }
    }
}
