import Foundation

extension String {
    
    init(_ type: AnyClass) {
        self.init(describing: type)
    }
    
    init(_ key: FetchingStringKeys) {
        let string = key.rawValue
        self = string
    }
    
    init(_ key: ParsingStringKeys) {
        let string = key.rawValue
        self = string
    }
    
    init(_ key: StorageKey) {
        let string = key.rawValue
        self = string
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
