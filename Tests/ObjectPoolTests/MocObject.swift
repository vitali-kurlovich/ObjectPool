//
//  Created by vkurlovich on 15.02.24.
//

import Foundation

final class MocObject: Equatable {
    var intValue: Int
    var stringValue: String

    init(intValue: Int, stringValue: String) {
        self.intValue = intValue
        self.stringValue = stringValue
    }

    static func == (lhs: MocObject, rhs: MocObject) -> Bool {
        lhs.intValue == rhs.intValue && lhs.stringValue == rhs.stringValue
    }
}
