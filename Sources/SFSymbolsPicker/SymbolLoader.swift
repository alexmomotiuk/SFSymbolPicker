import Foundation

struct SFSymbolInfo {
    let name: String
    let searchTokens: [String]
}

extension SFSymbolInfo: Identifiable {
    var id: String { name }
}

class SymbolLoader {
    
    static var isAvailable: Bool {
        guard
            let bundle = Bundle(identifier: "com.apple.CoreGlyphs"),
            let _ = bundle.path(forResource: "name_availability", ofType: "plist"),
            let _ = bundle.path(forResource: "symbol_order", ofType: "plist"),
            let _ = bundle.path(forResource: "symbol_search", ofType: "plist")
        else { return false }
        return true
    }
    
    
    private static var cache = [SFSymbolInfo]()
    // Loads all symbols from the plist file
    static func getAllSymbols() async -> [SFSymbolInfo] {
        if !cache.isEmpty { return cache }
        
        guard
            let bundle = Bundle(identifier: "com.apple.CoreGlyphs"),
            let namesPath = bundle.path(forResource: "name_availability", ofType: "plist"),
            let orderPath = bundle.path(forResource: "symbol_order", ofType: "plist"),
            let searchPaths = bundle.path(forResource: "symbol_search", ofType: "plist"),
            let namesPlist = NSDictionary(contentsOfFile: namesPath),
            let orderPlist = NSArray(contentsOfFile: orderPath),
            let searchPlist = NSDictionary(contentsOfFile: searchPaths),
            let namesKeys = (namesPlist["symbols"] as? [String: String])?.keys,
            let orderedNames = Array(orderPlist) as? [String],
            let searchKeys = searchPlist as? [String: [String]]
        else { return [] }
        let notInOrder = Set(namesKeys).subtracting(Set(orderedNames))
        let allSymbols = orderedNames + notInOrder
        let symbolModels = allSymbols.map {
            SFSymbolInfo(name: $0, searchTokens: searchKeys[$0] ?? [])
        }
        cache = symbolModels
        return cache
    }
}
