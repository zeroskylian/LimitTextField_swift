//
//  LimitTextField.swift
//  SwiftProject
//
//  Created by 廉鑫博 on 2020/7/26.
//  Copyright © 2020 廉鑫博. All rights reserved.
//

import UIKit

struct RegexHelper {
    let regex: NSRegularExpression
    
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern,
                                        options: .caseInsensitive)
    }
    
    func match(_ input: String) -> Bool {
        let matches = regex.matches(in: input,
                                    options: [],
                                    range: NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
}

enum LimitInputType {
    case none
    case number
    case character
    case decimalNumber
    case dotDecimalNumber(Int)
    case numberAndCharater
    
    var rawValue: String
    {
        switch self {
        case .none:
            return "^.*$"
        case .number:
            return "^[\\d]*$"
        case .character:
            return "^[a-zA-Z]*$"
        case .decimalNumber:
            return "^[\\d]*\\.[\\d]*$|^[\\d]*$"
        case .dotDecimalNumber(let dot):
            return "^[\\d]{1,}\\.[\\d]{0,\(dot)}$|^[\\d]*$"
        case .numberAndCharater:
            return "^[a-zA-Z0-9]*$"
        }
    }
}


enum LimitLength {
    case length
    case byte
}

protocol LimitTextFieldDelegate : class {
    func limitTextfieldTextChange(text:String)
    
    func limitTextfieldEndEditing(text:String?)
    
}
class LimitTextField: UITextField {
    
    var maxLength : Int = Int.max
    
    var lengthType : LimitLength
    
    var inputType : LimitInputType = .none
    
    weak var limitDelegate : LimitTextFieldDelegate?
    
    lazy var regular: RegexHelper = try! RegexHelper(self.inputType.rawValue)
    
    
    init(frame: CGRect , maxLength :Int = Int.max ,lengthType:LimitLength = .length ,inputType: LimitInputType = .none) {
        self.maxLength = maxLength
        self.lengthType = lengthType
        self.inputType = inputType
        super.init(frame: frame)
        delegate = self
        addTarget(self, action: #selector(textDidChange(textfield:)), for: .editingChanged)
        
    }
    
    required init?(coder: NSCoder) {
        maxLength = Int.max
        lengthType = .length
        inputType = .none
        super.init(coder: coder)
    }
    
    @objc func textDidChange(textfield:UITextField) {
        if let currentString = textfield.text {
            if let selectedRange = textfield.markedTextRange , let newText = textfield.text(in: selectedRange)  ,newText.count > 0{
                
            }else
            {
                var currentLen = 0
                switch lengthType {
                case .length:
                    currentLen = currentString.count
                case .byte:
                    currentLen = currentString.getStringLengthOfBytes()
                }
                if currentLen > maxLength
                {
                    switch lengthType {
                    case .length:
                        textfield.text = try? currentString.substring(0..<maxLength)
                    case .byte:
                        textfield.text = currentString.subBytesOfstringTo(index: maxLength)
                    }
                }
            }
            limitDelegate?.limitTextfieldTextChange(text: currentString)
        }
    }
}

extension LimitTextField :UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField) {
        limitDelegate?.limitTextfieldEndEditing(text: textField.text)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        undoManager?.removeAllActions()
        let full = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let numberOfMatches = regular.match(full)
        return numberOfMatches;
    }
}

extension String
{
    func getStringLengthOfBytes() -> Int
    {
        var length = 0
        for char in self
        {
            if char.validateChineseChar()
            {
                length += 2
            }else
            {
                length += 1
            }
        }
        return length
    }
    
    func subBytesOfstringTo(index :Int) -> String?
    {
        var length = 0
        var chineseNum = 0
        var otherNum = 0
        for char in self
        {
            if char.validateChineseChar()
            {
                if (length + 2 > index){
                    return try? self.substring(0 ..< chineseNum + otherNum)
                }
                length += 2
                chineseNum += 1
            }else{
                if (length + 1 > index){
                    return try? self.substring(0 ..< chineseNum + otherNum)
                }
                length += 1
                otherNum += 1
            }
        }
        return try? self.substring(0 ..< index)
    }
}

extension Character
{
    func validateChineseChar() -> Bool
    {
        return isMatchesRegularExp(regex: "(^[\\u4e00-\\u9fa5]+$)")
    }
    
    
    func isMatchesRegularExp(regex :String) -> Bool
    {
        let pre = NSPredicate(format: "SELF MATCHES %@", regex)
        return pre.evaluate(with: String(self))
    }
}

