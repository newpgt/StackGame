//
//  RandomInt.swift
//  StackNeo
//
//  Created by NeoZ on 5/3/16.
//  Copyright © 2016年 NeoZ. All rights reserved.
//

import Foundation
import UIKit

extension Int{
    static func random(range: Range<Int> ) -> Int{
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}