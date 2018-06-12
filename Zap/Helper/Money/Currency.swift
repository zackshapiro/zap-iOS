//
//  Zap
//
//  Created by Otto Suess on 31.03.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

protocol Currency: Localizable {
    var symbol: String { get }
    
    // format the native value. (1000.53 -> "$1,000.53")
    func format(value: NSDecimalNumber) -> String?
    
    // format satoshis. (1253 -> "$0.10")
    func format(satoshis: Satoshi) -> String?
    
    // string without localization stuff (1002523) -> "10025.23"
    func stringValue(satoshis: Satoshi) -> String?
    
    func satoshis(from: String) -> Satoshi?
    
    func value(satoshis: Satoshi) -> NSDecimalNumber?
}