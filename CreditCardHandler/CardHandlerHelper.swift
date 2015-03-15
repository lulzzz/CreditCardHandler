//
//  CardHandlerHelper.swift
//  CreditCardHandler
//
//  Created by Peter Qiu on 3/3/15.
//  Copyright (c) 2015 Peter Qiu. All rights reserved.
//

import Foundation

public enum TransactionTypes:Int
{
    case Purchase = 1
    case Refund = 2
}

public enum LogLevel:Int
{
    case None = -1
    case Error = 0
    case Warning = 1
    case Info = 2
    case Trace = 3
    case Debug = 4
}

public struct EMVDeclineMessage {
    static let JapaneseYen = "JPY"
    static let SouthKoreanWon = "KRW"
    static let OfflineDataAuthNotPerformed = "Offline Data Authentication Not Performed"
    static let SDAFailed = "SDA Failed"
    static let DDAFailed = "DDA Failed"
    static let CDAFailed = "CDA Failed"
    static let ICCAndTerminalDifferentVersion = "ICC And Terminal has Different Version"
    static let ExpiredApp = "Application Expired"
    static let AppNotEffective = "Application is Not Effective"
    static let InvalidCardHolder = "Invalid Card Holder"
    static let PinTryLimitExceed = "Pin Try Limit Exceed"
    static let OnlinePinMode = "Online Pin Mode"
    static let FloorLimitExceed = "Floor Limit Exceed"
    static let UpperConsecutiveOfflineLimitExceeded = "Upper Consecutive Offline Limit Exceeded"
    static let ICCDataMissing = "ICC Data Missing"
    static let LowerConsecutiveOfflineLimitExceeded = "Lower Consecutive Offline Limit Exceeded"
    static let UpperandLowerConsecutiveOfflineLimitExceeded = "Upper and Lower Consecutive Offline Limit Exceeded"
    static let TransactionSelectedRandomlyforOnlineProcessing = "Transaction Selected Randomly for Online Processing"
}

extension String {
    
    /// Create NSData from hexadecimal string representation
    /// :returns: NSData represented by this hexadecimal string. Returns nil if string contains characters outside the 0-9 and a-f range.
    
        func dataFromHexadecimalString() -> NSData? {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        var error: NSError?
        let regex = NSRegularExpression(pattern: "^[0-9a-f]*$", options: .CaseInsensitive, error: &error)
        let found = regex?.firstMatchInString(trimmedString, options: nil, range: NSMakeRange(0, countElements(trimmedString)))
        if found == nil || found?.range.location == NSNotFound || countElements(trimmedString) % 2 != 0 {
            return nil
        }
        
        let data = NSMutableData(capacity: countElements(trimmedString) / 2)
        
        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = Byte(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [Byte], length: 1)
        }
        
        return data
    }
    
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}

extension String {
    
    /// Create NSData from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a String object from taht. Note, if the string has any spaces, those are removed. Also if the string started with a '<' or ended with a '>', those are removed, too.
    ///
    /// :param: encoding The NSStringCoding that indicates how the binary data represented by the hex string should be converted to a String.
    ///
    /// :returns: String represented by this hexadecimal string. Returns nil if string contains characters outside the 0-9 and a-f range or if a string cannot be created using the provided encoding
    
    func stringFromHexadecimalStringUsingEncoding(encoding: NSStringEncoding) -> String? {
        if let data = dataFromHexadecimalString() {
            return NSString(data: data, encoding: encoding) as? String
        }
        
        return nil
    }
    
    /// Create hexadecimal string representation of String object.
    ///
    /// :param: encoding The NSStringCoding that indicates how the string should be converted to NSData before performing the hexadecimal conversion.
    ///
    /// :returns: String representation of this String object.
    
    func hexadecimalStringUsingEncoding(encoding: NSStringEncoding) -> String? {
        let data = dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        return data?.hexadecimalString()
    }
}

extension NSData {
    
    /// Create hexadecimal string representation of NSData object.
    ///
    /// :returns: String representation of this NSData object.
    
    @objc func hexadecimalString() -> String {
        var string = NSMutableString(capacity: length * 2)
        var byte: Byte?
        
        for i in 0 ..< length {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte!)
        }
        
        return string
    }
}


