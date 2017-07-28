//
//  Coor.swift
//  Digit Recognition
//
//  Created by Edward Huang on 7/26/17.
//  Copyright © 2017 Eddie Huang. All rights reserved.
//

import Foundation


class Coor: Hashable, Equatable {
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    var x: Int
    var y: Int
    
    var hashValue: Int {
        return x ^ y
    }
    
    static func == (lhs: Coor, rhs: Coor) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
}
