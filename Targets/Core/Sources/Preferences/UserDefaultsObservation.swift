//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

class UserDefaultsObservation: NSObject {
    let key: Key
    private var onChange: (Any, Any) -> Void

    init(key: Key, onChange: @escaping (Any, Any) -> Void) {
        self.onChange = onChange
        self.key = key
        super.init()
        UserDefaults.standard.addObserver(self, forKeyPath: key.rawValue, options: [.old, .new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change, object != nil, keyPath == key.rawValue else { return }
        onChange(change[.oldKey] as Any, change[.newKey] as Any)
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: key.rawValue, context: nil)
    }
}
