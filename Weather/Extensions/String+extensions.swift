import Foundation

extension String {
    
    init(_ instance: AnyClass) {
        self.init(describing: type(of: instance))
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
