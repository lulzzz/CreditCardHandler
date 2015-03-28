//
//  IJCardHandler.swift
//  TestRBA-SDK
//
//  Created by Peter Qiu on 2/1/15.
//  Copyright (c) 2015 Peter Qiu. All rights reserved.
//

import Foundation
import Security

@objc public class IJCreditCardHandler: NSObject, RBA_SDK_Event_support, LogTrace_support
{
    var _log = Logger.defaultInstance()
    var _gi:GeneralInfoVO = GeneralInfoVO()   //from libPaymentService.a
    var _report:PaymentService = PaymentService()
    var _emv:TransactionEMVInfoVO = TransactionEMVInfoVO()
    //let _endOfCardProcessInput = NSCondition()
    var _amount = ""
    var _chipCard = false
    var _validCard = false
    var _track1 = ""
    var _track2 = ""
    var _track3 = ""
    var _port = "COM7"
    var _currency = ""
    var _seatNum = ""
    var _fareClass = ""
    var _ffStatus = ""
    var _itemId:CInt = 0
    var _hasDecimal = true
    var _type = TransactionTypes.Purchase
    var _cardSource = ""
    var _save = true
    var _transactionDone = false
    
    public var ComPort:String
    {
        get
        {
            return _port
        }
        set(newValue)
        {
            _port  = newValue
        }
    }
  
    public var EMVInfo:TransactionEMVInfoVO
    {
        get
        {
            return _emv
        }
    }

    public var Track1Data:String
    {
        get
        {
            return _track1
        }
    }
    
    public var TrackData2:String
    {
        get
        {
            return _track2
        }
    }
    
    public var TrackData3:String
    {
        get
        {
            return _track3
        }
    }

    public var IsChipPinCard:Bool
    {
        get
        {
            return _chipCard
        }
    }
    
    public var IsValidCreditCard:Bool
    {
        get
        {
            return _validCard
        }
    }
   
    public var GeneralInfomation:GeneralInfoVO
    {
        get
        {
            return _gi
        }
        set(newVal)
        {
            _gi = newVal
        }
    }
    
    public var CardSource:String
    {
        get
        {
            return _cardSource
        }
    }
 
    public var SaveTransaction:Bool
    {
        get
        {
            return _save
        }
        set(newVal)
        {
            _save = newVal
        }
    }
    
    public func ProcessPinPadParameters(messageId: Int)
    {
        let msg = String(format: "Received Message %d",messageId)
        var code:String = ""
        //_log.error(msg)
        NSLog(msg)
        switch messageId
        {
			case Int(M23_CARD_READ.value):
                var status = ""

                _cardSource = RBA_SDK.GetParam(Int(P23_RES_CARD_SOURCE.value))
                if(_cardSource == "C")
                {
                    _cardSource = "Contactless"
                }
                else if(_cardSource == "M")
                {
                    _cardSource = "MSR"
                }
				RBA_SDK.SetParam(Int(P29_REQ_VARIABLE_ID.value), data: "000413")    //service code
				RBA_SDK.ProcessMessage(Int(M29_GET_VARIABLE.value))
				sleep(1)
				status = RBA_SDK.GetParam(Int(P29_RES_STATUS.value))
                if (status == "2")
                {
                    code = RBA_SDK.GetParam(Int(P29_RES_VARIABLE_DATA.value))
                }
                _validCard = true
                _chipCard = false
                let len = countElements(code)   //utf16count crash here
                if (len > 0)
                {
                    if (code == "000")
                    {
                        _validCard = false
                    }
                    if (code.hasPrefix("2") || code.hasPrefix("6"))
                    {
                        _chipCard = true
                    }
                }
                else
                {
                    _validCard = false
                }

                if (!_validCard || _chipCard)
                {

                    StopTransaction()
                    return
                }
				let exitType = RBA_SDK.GetParam(Int(P23_RES_EXIT_TYPE.value))
            
				if (exitType == "0")
				{
					_track1 = RBA_SDK.GetParam(Int(P23_RES_TRACK1.value))
					_track2 = RBA_SDK.GetParam(Int(P23_RES_TRACK2.value))
					_track3 = RBA_SDK.GetParam(Int(P23_RES_TRACK3.value))
                    //_log.error(TrackData3)
                    //NSLog(_track3)
                    if(_save)
                    {
                        AddSwipedToPaymentReport()
                    }
				}
				StopTransaction()
				break
			case Int(M33_02_EMV_TRANSACTION_PREPARATION_RESPONSE.value):
				GetParams(Int(P33_02_RES_EMV_TAG.value))
				RBA_SDK.SetParam(Int(P04_REQ_FORCE_PAYMENT_TYPE.value), data:"0")
				RBA_SDK.SetParam(Int(P04_REQ_PAYMENT_TYPE.value), data:"B")
				RBA_SDK.SetParam(Int(P04_REQ_AMOUNT.value), data:"000")
				RBA_SDK.ProcessMessage(Int(M04_SET_PAYMENT_TYPE.value))
				sleep(1)
				RBA_SDK.SetParam(Int(P13_REQ_AMOUNT.value), data:_amount)
				RBA_SDK.ProcessMessage(Int(M13_AMOUNT.value))
				RBA_SDK.ResetParam(Int(P_ALL_PARAMS.value))
				break
			case Int(M33_03_EMV_AUTHORIZATION_REQUEST.value):
				RBA_SDK.SetParam(Int(P33_04_RES_STATUS.value), data:"00")
				RBA_SDK.SetParam(Int(P33_04_RES_EMVH_CURRENT_PACKET_NBR.value), data:"0")
				RBA_SDK.SetParam(Int(P33_04_RES_EMVH_PACKET_TYPE.value), data:"0")
				RBA_SDK.AddTagParam(Int(M33_04_EMV_AUTHORIZATION_RESPONSE.value), tagid: 0x1004, string: "0")
				RBA_SDK.AddTagParam(Int(M33_04_EMV_AUTHORIZATION_RESPONSE.value), tagid: 0x8A, string: "00")
				RBA_SDK.ProcessMessage(Int(M33_04_EMV_AUTHORIZATION_RESPONSE.value))
            
				RBA_SDK.ResetParam(Int(P_ALL_PARAMS.value))
				break
			case Int(M33_05_EMV_AUTHORIZATION_CONFIRMATION.value):
				GetParams(Int(P33_05_RES_EMV_TAG.value))
                _emv.EMVApplicationCurrencyCode = _emv.EMVTransactionCurrencyCode   //IJ not supprot yet
				RBA_SDK.ResetParam(Int(P_ALL_PARAMS.value))
                //A = Approve (purchase or refund).
                //D = Decline (purchase or refund).
                //C = Completed (refund).
                //E = Error or incompletion (purchase or refund).
                if (_emv.NonEMVConfirmationResponseCode == "A")  //Offline Apporved
                {
                    if(_save)
                    {
                        AddEMVToPaymentReport()
                    }
                }
                _cardSource = "EMV"
                StopTransaction()
				break
			default:
				break
            
        }
    }
 
    public func LogTraceOut(line: String)
    {
        let filePath = SetupLoggingPath("RBA.log")
        if (!NSFileManager.defaultManager().fileExistsAtPath(filePath))
        {
            NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
        }
        else
        {
            let attributes:NSDictionary = NSFileManager.defaultManager().attributesOfItemAtPath(filePath, error: nil)!
            var fileSystemSizeInMB : Double = Double(attributes.fileSize())/1000000
            if(fileSystemSizeInMB > 10) //delete over 10 MB
            {
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
                NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
            }
        }
        let outputStream:NSOutputStream = NSOutputStream(toFileAtPath: filePath, append: true)!

        outputStream.open()
        outputStream.write(line, maxLength: line.utf16Count)
        outputStream.close()
        NSLog(line)
    }
    
    public func StopTransaction()
    {
        _transactionDone = true
        //_endOfCardProcessInput.unlock()
        MessageOffline()
    }

    public func GetErrorDescription(errorCode:String) -> String
    {
        var error = ""
        switch (errorCode)
        {
            case "ARSF":
                error = "Authorization Request Sent Failed."
                break
            case "ARRT":
                error = "Authorization Response Received Timeout."
                break
            case "CAN":
                error = "Transaction cancelled."
                break
            case "CRSF":
                error = "Confirmation Response Sent Failed."
                break
            case "CDIV":
                error = "Card Data Invalid."
                break
            case "CDIVN":
                error = "Card Data Invalid but EMV fallback not permitted for Interac transaction."
                break
            case "CABLK":
                error = "Card/Application Blocked."
                break
            case "T2CF":
                error = "Track 2 Consistency Check Failed."
                break
            case "FATAL":
                error = "Fatal Error."
                break
            case "UITMO":
                error = "User Interface Timeout."
                break
            case "CRPRE":
                error = "Card Removed Prematurely."
                break
            case "CNSUP":
                error = "Card Not Supported."
                break
            case "TPSF":
                error = "Transaction Preparation Sent Failed."
                break
            default:
                break
        }
        return error
    }
    
    public func GetDeclineReasons(result:String) -> String
    {
        let reasons = StringBuilder()
        var str = ""
        
        str = GetByteResult(result[0...1], idx: 1)
        if (str.utf16Count > 0)
        {
            reasons.Append(str + "")
        }
        str = GetByteResult(result[2...3], idx: 2)
        if (str.utf16Count > 0)
        {
            reasons.Append(str + "")
        }
        str = GetByteResult(result[4...5], idx:3)
        if (str.utf16Count > 0)
        {
            reasons.Append(str + "")
        }
        str = GetByteResult(result[6...7], idx:4)
        if (str.utf16Count > 0)
        {
            reasons.Append(str + "")
        }
        str = GetByteResult(result[8...9], idx:5)
        if (str.utf16Count > 0)
        {
            reasons.Append(str)
        }

        str = reasons.ToString()
        if (str[str.utf16Count - 1] == "")
        {
            
            str = str[0..<str.utf16Count]
        }

        return str
    }

    public func initializeSDK(level:Int) -> Bool
    {
        var loglvl:LOG_LEVEL = LTL_NONE
        
        switch LogLevel(rawValue: level)!
        {
            case .Info:
                loglvl = LTL_INFO
            case .Error:
                loglvl = LTL_ERROR
            case .Trace:
                loglvl = LTL_TRACE
            case .Warning:
                loglvl = LTL_WARNING
            default:
                loglvl = LTL_NONE
        }
        //LoggingSetup() objective C does not like it.
        LogTrace.SetDelegate(self)
        LogTrace.SetTraceOutputFormatOption(LOFO_NO_DATE)
        LogTrace.SetTraceOutputFormatOption(LOFO_NO_INSTANCE_ID)
        LogTrace.SetDefaultLogLevel(loglvl)
        let result = RBA_SDK.Initialize()
        if( result != Int(RESULT_SUCCESS) )
        {
            let msg = String(format: "Initializel Fail. Result code: %d",result)
            //_log.error(msg)
            return false
        }
        RBA_SDK.SetDelegate(self)
        //for Objective C. Otherwise, file not created.
        _report = PaymentService()
        _log = Logger.defaultInstance()
        return true
    }
    
    public func StartSwipedTransaction() ->Bool
    {
        let type = TransactionTypes.Purchase
        let amt = "0"
        let currency = ""
        let itemId:CInt = 0
        let seatNum = ""
        let fareClass = ""
        let ffStatus = ""
        return StartMagnaticTransaction(false, type:type, amt: amt, currency: currency, itemId: itemId, seatNum:seatNum, fareClass:fareClass, ffStatus:ffStatus)
    }

    public func StartNFCTransaction() ->Bool
    {
        let type = TransactionTypes.Purchase
        let amt = "0"
        let currency = ""
        let itemId:CInt = 0
        let seatNum = ""
        let fareClass = ""
        let ffStatus = ""
        return StartMagnaticTransaction(true, type:type, amt: amt, currency: currency, itemId: itemId, seatNum:seatNum, fareClass:fareClass, ffStatus:ffStatus)
    }
    
    public func StartSwipedTransaction(type:Int, amt:String, currency:String, itemId:CInt, seatNum:String, fareClass:String,ffStatus:String) ->Bool
    {
        return StartMagnaticTransaction(false, type:TransactionTypes(rawValue: type)!, amt: amt, currency: currency, itemId: itemId, seatNum:seatNum, fareClass:fareClass, ffStatus:ffStatus)
    }
    
    public func StartNFCTransaction(type:Int, amt:String, currency:String, itemId:CInt, seatNum:String, fareClass:String,ffStatus:String) ->Bool
    {
        return StartMagnaticTransaction(true, type:TransactionTypes(rawValue: type)!, amt: amt, currency: currency, itemId: itemId, seatNum:seatNum, fareClass:fareClass, ffStatus:ffStatus)
    }
    
    public func StartEMVTransaction(type:Int, amt:String, currency:String) -> Bool
        
    {
        SetVariables(type, currency:currency, itemId:0,  seatNum:"", fareClass:"",ffStatus:"")
        return StartChipPinTransaction(amt)
    }
    
    public func StartEMVTransaction(type:Int, amt:String, currency:String, itemId:CInt,  seatNum:String, fareClass:String,ffStatus:String) -> Bool

    {
        SetVariables(type, currency:currency, itemId:itemId,  seatNum:seatNum, fareClass:fareClass,ffStatus:ffStatus)
        return StartChipPinTransaction(amt)
    }
    
    func SetVariables(type:Int, currency:String, itemId:CInt, seatNum:String, fareClass:String,ffStatus:String)
    {
        _seatNum = seatNum
        _fareClass = fareClass
        _ffStatus = ffStatus
        _type = TransactionTypes(rawValue: type)!
        _itemId = itemId
        _emv = TransactionEMVInfoVO()
        _emv.EMVCardIssuerAuthenticationData = ""
        _emv.EMVCardIssuerScriptTemplate1 = ""
        _emv.EMVCardIssuerScriptTemplate2 = ""
        _emv.EMVShortFileIdentifier = "00"
        _emv.EMVServiceCode = "201"
        _currency = currency
    }
    
    func StartChipPinTransaction(amt:String) -> Bool
    {
        if (!EnableSmartCard())
        {
            return false
        }
        DisableKeyedIn()
        MessageOnline()
        
        _transactionDone = false
        RBA_SDK.SetParam(Int(P14_REQ_TXN_TYPE.value), data:"01")
        RBA_SDK.ProcessMessage(Int(M14_SET_TXN_TYPE.value))
        sleep(5)
        
        var sa = split(amt) {$0 == "."}
        var strAmt:String = ""
        //let dec = sa[1].substringFromIndex(advance(sa[0].startIndex,2))
        if (sa.count == 2)
        {
            strAmt = sa[0] + sa[1]
        }
        else
        {
            strAmt = sa[0] + "00"
        }
        _amount = strAmt
        RBA_SDK.SetParam(Int(P13_REQ_AMOUNT.value), data:strAmt)
        RBA_SDK.ProcessMessage(Int(M13_AMOUNT.value))
        let date = NSDate(timeIntervalSinceNow: 5) //seconds
        while(!_transactionDone)
        {
            NSRunLoop.currentRunLoop().runUntilDate(date)
        }
        StopTransaction()
        return true
    }
    
    func connect() -> Bool
    {
        let ip:SETTINGS_IP = SETTINGS_IP(IPAddress: (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16),Port: (1,2,3,4,5,6))
        
        let serial:SETTINGS_RS232 = SETTINGS_RS232( ComPort: (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40),
            AutoDetect: AutoDetectON, BaudRate: BaudRate_115200, DataBits: DataBits8, Parity: ParityNone, StopBits: StopBits1, FlowControl: FlowCtrl_None)
        
        let usb:SETTINGS_USB_HID = SETTINGS_USB_HID(autoDetect: AutoDetectON, vendor_id: 1, product_id: 1)
        
        let bt:SETTINGS_BT = SETTINGS_BT(DeviceName: (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21))
        
        let settings : SETTINGS_COMMUNICATION = SETTINGS_COMMUNICATION(interface_id: ACCESSORY_INTERFACE,ip_config: ip, rs232_config: serial, usbhid_config: usb, bt_config: bt)
        
        let result = RBA_SDK.Connect(settings)
        if(result == Int(RESULT_SUCCESS) )
        {
            return true
        }
        else
        {
            let msg = String(format: "Connect Fail. Result code: %d",result)
            //_log.error(msg)
            return false
        }
    }
    
    func MessageOnline() -> Bool
    {
        RBA_SDK.SetParam(Int(P01_REQ_APPID.value), data: "0000")
        RBA_SDK.SetParam(Int(P01_REQ_PARAMID.value), data: "0000")
        let result = RBA_SDK.ProcessMessage(Int(M01_ONLINE.value))
        if( result == Int(RESULT_SUCCESS) )
        {
            return true
        }
        return false
    }
    
    func MessageOffline() -> Bool
    {
        let result = RBA_SDK.ProcessMessage(Int(M00_OFFLINE.value))
        if( result == Int(RESULT_SUCCESS) )
        {
            return true
        }
        return false
    }
    
    func GetByteResult(inStr:String, idx:Int) -> String
    {
        var result = ""
    
        switch (inStr)
        {
            case "80":
                switch (idx)
                {
                    case 1:
                        result = EMVDeclineMessage.OfflineDataAuthNotPerformed
                        break
                    case 2:
                        result = EMVDeclineMessage.ICCAndTerminalDifferentVersion
                        break
                    case 3:
                        result = EMVDeclineMessage.InvalidCardHolder
                        break
                    case 4:
                        result = EMVDeclineMessage.FloorLimitExceed
                        break
                    default:
                        break
                }
                break
            case "60":
                switch (idx)
                {
                    case 4:
                        result = EMVDeclineMessage.UpperandLowerConsecutiveOfflineLimitExceeded
                        break
                    default:
                        break
                }
                break
            case "40":
                switch (idx)
                {
                    case 1:
                        result = EMVDeclineMessage.SDAFailed
                        break
                    case 2:
                        result = EMVDeclineMessage.ExpiredApp
                        break
                    case 4:
                        result = EMVDeclineMessage.LowerConsecutiveOfflineLimitExceeded
                        break
                    default:
                        break
                }
                break
            case "42":
                switch (idx)
                {
                    case 1:
                        result = EMVDeclineMessage.SDAFailed
                        break
                    case 2:
                        result = EMVDeclineMessage.ExpiredApp
                        break
                    case 4:
                        result = EMVDeclineMessage.LowerConsecutiveOfflineLimitExceeded
                        break
                    default:
                        break
                }
                break
            case "20":
                switch (idx)
                {
                    case 1:
                        result = EMVDeclineMessage.ICCDataMissing
                        break
                    case 2:
                        result = EMVDeclineMessage.AppNotEffective
                        break
                    case 3:
                        result = EMVDeclineMessage.PinTryLimitExceed
                        break
                    case 4:
                        result = EMVDeclineMessage.UpperConsecutiveOfflineLimitExceeded
                        break
                    default:
                        break
                }
                break
            case "10":
                switch (idx)
                {
                    case 4:
                        result = EMVDeclineMessage.TransactionSelectedRandomlyforOnlineProcessing
                        break
                    default:
                        break
                }
                break
            case "08":
                switch (idx)
                {
                    case 1:
                        result = EMVDeclineMessage.DDAFailed
                        break
                    default:
                        break
               }
                break
            case "04":
                switch (idx)
                {
                    case 1:
                        result = EMVDeclineMessage.CDAFailed
                        break
                    case 3:
                        result = EMVDeclineMessage.OnlinePinMode
                        break
                    default:
                        break
              }
                break
            default:
                break
        }
        return result
    }
    
    func GetParams(tag:Int) -> Int
    {
        let tagparam = ""
        let i = 1
        
        while(true)
        {
            if(RBA_SDK.GetParamLen(tag) <= 0)
            {
                break
            }
            let tagparam = RBA_SDK.GetParam(tag)
            SetParam(tagparam)
        }
        return 1
    }
    
    func SetParam(tagParam:String)
    {
        let sa = tagParam.componentsSeparatedByString(":")
        if (sa.count != 3)
        {
            return
        }
        let tmp1 = sa[0]
        let index = advance(tmp1.startIndex, 1)
        let tag = tmp1.substringFromIndex(index)
        let tmp2 = sa[2]
        let idx = advance(tmp2.startIndex, 1)
        let sData = tmp2.substringFromIndex(idx)
        let hexData:String = String()
        
        switch (tag)
        {
        case "1001":    //Pin entry Required Flag. 0: Not required, 1: required
            _emv.NonEMVPinEntryRequired = sData
            break
        case "1002":    //Signature Required Flag. 0: Not r equired, 1: required
            _emv.NonEMVSignatureRequired = sData
            break
        case "1003":
            _emv.NonEMVConfirmationResponseCode = sData
            break
        case "1005":    //Transaction type. 00 = Purchase. 01 = refund.
            _emv.NonEMVTransactionType = sData
            break
        case "1010":
            _emv.NonEMVErrorResponseCode = sData
            break
        case "9000":    //Card Payment Type. A = Debit. B = Credit.
            _emv.NonEMVCardPaymentCode = sData
            break
        case "9001":    //Card Entry Mode. C = Chip entry. D = Contactless EMV entry.
            _emv.NonEMVCardEntryCode = sData
            break
        case "8A":
            _emv.EMVCardAuthorizationResponseCode = GetARC(sData)
            break
        case "95":
            _emv.EMVCardTerminalVerificationResults = sData
            break
        case "4F":
            _emv.EMVCardApplicationIdentifier = sData
            break
        case "82":
            _emv.EMVCardApplicationInterchangeProfile = sData
            break
        case "84":
            _emv.EMVCardDedicatedFileName = sData
            break
        case "9A":
            _emv.EMVTransactionDate = sData
            break
        case "9B":
            _emv.EMVTransactionStatusInformation = sData
            break
        case "9C":
            _emv.EMVCryptogramTransactionType = sData
            break
        case "5F28":
            _emv.EMVIssuerCountryCode = sData
            break
        case "5F2A":
            _emv.EMVTransactionCurrencyCode = sData
            break
        case "5F34":
            _emv.EMVPanSequenceNumber = sData
            break
        case "9F02":
            _emv.EMVTransactionAmount = sData
            break
        case "9F07":
            _emv.EMVApplicationUsageControl = sData
            break
        case "9F08":
            _emv.EMVApplicationVersionNumber = sData
            break
        case "9F0D":
            _emv.EMVIssuerActionCodeDefault = sData
            break
        case "9F0E":
            _emv.EMVIssuerActionCodeDenial = sData
            break
        case "9F0F":
            _emv.EMVIssuerActionCodeOnline = sData
            break
        case "9F10":
            _emv.EMVIssuerApplicationData = sData
            break
        case "9F1A":
            _emv.EMVTerminalCountryCode = sData
            break
        case "9F1E":
            //let hexData = StringToHexString(sData)
            _emv.EMVInterfaceDeviceSerialNumber = sData
            break
        case "9F26":
            _emv.EMVApplicationCryptogram = sData
            break
        case "9F27":
            _emv.EMVCryptogramInformationData = sData
            break
        case "9F33":
            _emv.EMVTerminalCapabilities = sData
            break
        case "9F34":
            _emv.EMVCardholderVerificationMethodResults = sData
            break
        case "9F35":
            _emv.EMVTerminalType = sData
            break
        case "9F36":
            _emv.EMVApplicationTransactionCounter = sData
            break
        case "9F37":
            _emv.EMVUnpredictableNumber = sData
            break
        case "9F41":
            _emv.EMVTransactionSequenceCounterID = sData
            break
        case "9F42":    //not support yet
            _emv.EMVApplicationCurrencyCode = sData
            break
        case "9F53":
            _emv.EMVTransactionCategoryCode = sData
            break
        case "FF1F":
            _emv.EMVTrack2 = sData
            break
        default:
            break
        }
    }
    
    func AddEMVToPaymentReport()
    {
        let tranemv:TransactionVO = TransactionVO()   //from libPaymentService.a

        if (_emv.EMVTransactionCurrencyCode == "392" && _emv.EMVTransactionCurrencyCode == "410")
        {
            tranemv.amount = NSDecimalNumber(double: (_emv.EMVTransactionAmount as NSString).doubleValue)
        }
        else
        {
            var amount:NSString = _emv.EMVTransactionAmount[0..._emv.EMVTransactionAmount.utf16Count-3] + "." + _emv.EMVTransactionAmount[_emv.EMVTransactionAmount.utf16Count-2..._emv.EMVTransactionAmount.utf16Count-1]
            tranemv.amount = NSDecimalNumber(double: amount.doubleValue)
        }

        tranemv.ffStatus = _ffStatus
        tranemv.fareClass = _fareClass
        tranemv.seatNumber = _seatNum
        tranemv.track = _emv.EMVTrack2
        tranemv.currency = _currency
        tranemv.itemId = _itemId
        tranemv.paymentType = _type == TransactionTypes.Purchase ? "Charge" : "Refund"
        tranemv.uniqueTransactionId = NSUUID().UUIDString

        tranemv.eMVApplicationCryptogramField = _emv.EMVApplicationCryptogram
        tranemv.eMVApplicationCurrencyCodeField = _emv.EMVApplicationCurrencyCode
        tranemv.eMVApplicationIdentifierField = _emv.EMVCardApplicationIdentifier
        tranemv.eMVApplicationInterchangeProfileField = _emv.EMVCardApplicationInterchangeProfile
        tranemv.eMVApplicationTransactionCounterField = _emv.EMVApplicationTransactionCounter
        tranemv.eMVApplicationUsageControlField = _emv.EMVApplicationUsageControl
        tranemv.eMVApplicationVersionNumberField = _emv.EMVApplicationVersionNumber
        tranemv.eMVAuthorizationResponseCodeField = _emv.EMVCardAuthorizationResponseCode
        tranemv.eMVCardholderVerificationMethodResultsField = _emv.EMVCardholderVerificationMethodResults
        tranemv.eMVCardSequenceNumberField = _emv.EMVPanSequenceNumber
        tranemv.eMVCryptogramInformationDataField = _emv.EMVCryptogramInformationData
        tranemv.eMVDedicatedFileNameField = _emv.EMVCardDedicatedFileName
        tranemv.eMVInterfaceDeviceSerialNumberField = _emv.EMVInterfaceDeviceSerialNumber
        tranemv.eMVIssuerActionCodeDefaultField = _emv.EMVIssuerActionCodeDefault
        tranemv.eMVIssuerActionCodeDenialField = _emv.EMVIssuerActionCodeDenial
        tranemv.eMVIssuerActionCodeOnlineField = _emv.EMVIssuerActionCodeOnline
        tranemv.eMVIssuerApplicationDataField = _emv.EMVIssuerApplicationData
        tranemv.eMVIssuerAuthenticationDataField = _emv.EMVCardIssuerAuthenticationData
        tranemv.eMVIssuerCountryCodeField = _emv.EMVIssuerCountryCode
        tranemv.eMVIssuerScriptTemplate1Field = _emv.EMVCardIssuerScriptTemplate1
        tranemv.eMVIssuerScriptTemplate2Field = _emv.EMVCardIssuerScriptTemplate2
        tranemv.eMVPanSequenceNumber = _emv.eMVPanSequenceNumber
        tranemv.eMVTerminalCapabilitiesField = _emv.EMVTerminalCapabilities
        tranemv.eMVTerminalCountryCodeField = _emv.EMVTerminalCountryCode
        tranemv.eMVTerminalTypeField = _emv.EMVTerminalType
        tranemv.eMVTerminalVerificationResultsField = _emv.EMVCardTerminalVerificationResults
        tranemv.eMVTransactionAmountField = _emv.EMVTransactionAmount
        tranemv.eMVTransactionCategoryCodeField = _emv.EMVTransactionCategoryCode
        tranemv.eMVTransactionCurrencyCodeField = _emv.EMVTransactionCurrencyCode
        tranemv.eMVTransactionDateField = _emv.EMVTransactionDate
        tranemv.eMVTransactionSequenceCounterIDField = _emv.EMVTransactionSequenceCounterID
        tranemv.eMVTransactionStatusInformationField = _emv.EMVTransactionStatusInformation
        tranemv.eMVTransactionTypeField = _emv.EMVCryptogramTransactionType
        tranemv.eMVUnpredictableNumberField = _emv.EMVUnpredictableNumber
        tranemv.eMVShortFileIdentifier = _emv.EMVShortFileIdentifier
        tranemv.eMVCryptogramTransactionTypeField = _emv.EMVCryptogramTransactionType
        tranemv.eMVIssuerScriptResultsField = _emv.EMVIssuerScriptResults
        tranemv.eMVServiceCode = _emv.EMVServiceCode
        _report.InsertTransaction(tranemv, _gi)
        NSLog("EMV Transaction Added to file!")
   }
 
    func AddSwipedToPaymentReport()
    {
        let tr:TransactionVO = TransactionVO()   //from libPaymentService.a
        var uuid = NSUUID().UUIDString
        tr.amount = NSDecimalNumber(double: (_amount as NSString).doubleValue)
        tr.track = _track3
        tr.currency = _currency
        tr.itemId = _itemId
        tr.fareClass = _fareClass
        tr.ffStatus = _ffStatus
        tr.seatNumber = _seatNum

        tr.paymentType = _type == TransactionTypes.Purchase ? "Charge" : "Refund"
        tr.uniqueTransactionId = uuid
        //let output = String(format:"%@ %@ %@ %@ %@", _gi.deviceId, _gi.FlightNum, _gi.OriginatingAirport, _gi.DestinationAirport, "\(_gi.DepartureTime)")
        //NSLog(output)
        _report.InsertTransaction(tr, _gi)
        NSLog("Magnetic Transaction Added to file!")
    }
    
    func StringToHexString(value:String) ->String
    {
        return value.hexadecimalStringUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func HexStringToString(value:String) ->String
    {
        return value.stringFromHexadecimalStringUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func IsConfigSettingEnabled(group:String, index:String) ->Bool
    {
        RBA_SDK.SetParam(Int(P61_REQ_GROUP_NUM.value), data: group)
        RBA_SDK.SetParam(Int(P61_REQ_INDEX_NUM.value), data: index)
        RBA_SDK.ProcessMessage(Int(M61_CONFIGURATION_READ.value))
        
        let Group = RBA_SDK.GetParam(Int(P61_RES_GROUP_NUM.value))
        let Index = RBA_SDK.GetParam(Int(P61_RES_INDEX_NUM.value))
        let Data = RBA_SDK.GetParam(Int(P61_RES_DATA_CONFIG_PARAMETER.value))
        if (Data == "1")
        {
            return true
        }
        return false
    }
    
    func EnableCardSource()
    {
        MessageOffline()
        if (IsConfigSettingEnabled("13", index: "14"))
        {
            return
        }
        RBA_SDK.SetParam(Int(P60_REQ_GROUP_NUM.value), data: "13")
        RBA_SDK.SetParam(Int(P60_REQ_INDEX_NUM.value), data: "14")
        RBA_SDK.SetParam(Int(P60_REQ_DATA_CONFIG_PARAM.value), data: "1")
        RBA_SDK.ProcessMessage(Int(M60_CONFIGURATION_WRITE.value))
    }
    
    func EnableSmartCard() ->Bool
    {
        if( RBA_SDK.GetConnectionStatus() != Int(CONNECTED.value) )
        {
            if(!connect())
            {
                return false
            }
        }
        if (IsConfigSettingEnabled("19", index: "1"))
        {
            return true
        }
        MessageOffline()  //if wrong port is connected, this will fail.

        RBA_SDK.SetParam(Int(P60_REQ_GROUP_NUM.value), data: "19")
        RBA_SDK.SetParam(Int(P60_REQ_INDEX_NUM.value), data: "1")
        RBA_SDK.SetParam(Int(P60_REQ_DATA_CONFIG_PARAM.value), data: "1")
        RBA_SDK.ProcessMessage(Int(M60_CONFIGURATION_WRITE.value))
        
        let status = RBA_SDK.GetParam(Int(P60_RES_STATUS.value))
        return true
    }
    
    func DisableKeyedIn()
    {
        if(IsConfigSettingEnabled("7", index: "29"))
        {
            MessageOffline()            
            RBA_SDK.SetParam(Int(P60_REQ_GROUP_NUM.value), data: "7")
            RBA_SDK.SetParam(Int(P60_REQ_INDEX_NUM.value), data: "29")
            RBA_SDK.SetParam(Int(P60_REQ_DATA_CONFIG_PARAM.value), data: "0")
            RBA_SDK.ProcessMessage(Int(M60_CONFIGURATION_WRITE.value))
            
            RBA_SDK.GetParam(Int(P60_RES_STATUS.value))
        }
    }
    
    func StartMagnaticTransaction(isNFC:Bool, type:TransactionTypes, amt:String, currency:String, itemId:CInt, seatNum:String, fareClass:String,ffStatus:String) ->Bool
    {
        if( RBA_SDK.GetConnectionStatus() != Int(CONNECTED.value) )
        {
            if(!connect())
            {
                return false
            }
        }
        _chipCard = false
        _validCard = true
        _cardSource = ""
        EnableCardSource()
        DisableKeyedIn()
        if(isNFC)
        {
            RBA_SDK.SetParam(Int(P23_REQ_PROMPT_INDEX.value), data: "Please tap card")
        }
        else
        {
            RBA_SDK.SetParam(Int(P23_REQ_PROMPT_INDEX.value), data: "Please slide card")
        }

        RBA_SDK.ProcessMessage(Int(M23_CARD_READ.value))
        _type = type
        _itemId = itemId
        _currency = currency
        _seatNum = seatNum
        _fareClass = fareClass
        _ffStatus = ffStatus
        _amount = amt
        _transactionDone = false

        let date = NSDate(timeIntervalSinceNow: 5) //seconds
        while(!_transactionDone)
        {
            NSRunLoop.currentRunLoop().runUntilDate(date)
        }
        StopTransaction()

        return true
    }
    
    func SetupLoggingPath(fileName:String) ->String
    {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var logPath = paths.stringByAppendingPathComponent("/Log")
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(logPath))
        {
            NSFileManager.defaultManager().createDirectoryAtPath(logPath, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        
        return logPath.stringByAppendingPathComponent(fileName)
    }
    
    func LoggingSetup()
    {
        let filePath = SetupLoggingPath("LogFile.txt")
        _log.setup(logLevel: .Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: filePath)

    }
    
    func GetARC(data:String) -> String
    {
        var code = ""
        switch (data)
        {
            case "Y1":
                code = "5931"
                break
            case "Y3":
                code = "5933"
                break
            case "Z1":
                    code = "5A31"
                break
            case "Z3":
                    code = "5A33"
                break
            default:
                code = data
                break
        }
        return code
    }
    
}