//
//  String+Bounds.swift
//  SwiftProject
//
//  Created by 廉鑫博 on 2020/7/26.
//  Copyright © 2020 廉鑫博. All rights reserved.
//

import Foundation

enum StringBoundsError:Error {
    case lowerBoundOut
    case upperBoundOut
}

extension String {
    private subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    private subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    
    func substring(_ bounds: CountableClosedRange<Int>) throws -> String
    {
        if bounds.lowerBound  < 0 {
            throw StringBoundsError.lowerBoundOut
        }
        
        if bounds.upperBound > count - 1{
            throw StringBoundsError.upperBoundOut
        }
        return self[bounds]
    }
    
    func substring(_ bounds: CountableRange<Int>) throws -> String
    {
        if bounds.lowerBound  < 0 {
            throw StringBoundsError.lowerBoundOut
        }
        
        if bounds.upperBound > count  {
            throw StringBoundsError.upperBoundOut
        }
        return self[bounds]
    }
    
    
    subscript(index: Int) -> Character
    {
        guard let index = self.index(startIndex, offsetBy: index, limitedBy: endIndex) else {
            fatalError("string index out of range")
        }
        return self[index]
    }
}
