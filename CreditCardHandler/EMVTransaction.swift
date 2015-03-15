//
//  EMVTransaction.swift
//  TestRBA-SDK
//
//  Created by Peter Qiu on 1/27/15.
//  Copyright (c) 2015 Peter Qiu. All rights reserved.
//

import Foundation

public class TransactionEMVInfoVO : NSObject
{
    var eMVTrack2Encrypted = ""
    var eMVApplicationIdentifierField = "" 
    var eMVIssuerScriptTemplate1Field = ""
    var eMVIssuerScriptTemplate2Field = ""
    var eMVApplicationInterchangeProfileField = "" 
    var eMVDedicatedFileNameField = "" 
    var eMVAuthorizationResponseCodeField = "" 
    var eMVIssuerAuthenticationDataField = "" 
    var eMVTerminalVerificationResultsField = "" 
    var eMVTransactionDateField = "" 
    var eMVTransactionStatusInformationField = "" 
    var eMVCryptogramTransactionTypeField = "" 
    var eMVIssuerCountryCodeField = "" 
    var eMVTransactionCurrencyCodeField = "" 
    var eMVTransactionAmountField = "" 
    var eMVApplicationUsageControlField = "" 
    var eMVApplicationVersionNumberField = "" 
    var eMVIssuerActionCodeDenialField = "" 
    var eMVIssuerActionCodeOnlineField = "" 
    var eMVIssuerActionCodeDefaultField = "" 
    var eMVIssuerApplicationDataField = "" 
    var eMVTerminalCountryCodeField = "" 
    var eMVInterfaceDeviceSerialNumberField = "" 
    var eMVApplicationCryptogramField = "" 
    var eMVCryptogramInformationDataField = "" 
    var eMVTerminalCapabilitiesField = "" 
    var eMVCardholderVerificationMethodResultsField = "" 
    var eMVTerminalTypeField = "" 
    var eMVApplicationTransactionCounterField = "" 
    var eMVUnpredictableNumberField = "" 
    var eMVTransactionSequenceCounterIDField = "" 
    var eMVApplicationCurrencyCodeField = "" 
    var eMVTransactionCategoryCodeField = "" 
    var eMVIssuerScriptResultsField = "" 
    var eMVPanSequenceNumber = "" 
    var eMVServiceCode = "" 
    var eMVShortFileIdentifier = "" 
    var nonEMVPinEntryRequired = "" 
    var nonEMVSignatureRequired = "" 
    var nonEMVConfirmationResponseCode = "" 
    var nonEMVTransactionType = "" 
    var nonEMVErrorResponseCode = "" 
    var nonEMVCardPaymentCode = "" 
    var nonEMVCardEntryCode = "" 

    public var EMVTrack2:String
    {
        get
        {
            return eMVTrack2Encrypted
        }
        set(newValue)
        {
            eMVTrack2Encrypted  = newValue
        }
    }
    
	public var EMVCardApplicationIdentifier:String
    {
		get
		{
			return eMVApplicationIdentifierField 
		}
		set(newValue)
		{
			eMVApplicationIdentifierField  = newValue
		}
    }

    public var EMVCardIssuerScriptTemplate1:String
    {
		get
		{
			return eMVIssuerScriptTemplate1Field 
		}
		set(newValue)
		{
			eMVIssuerScriptTemplate1Field  = newValue
		}
    }

    public var EMVCardIssuerScriptTemplate2:String
    {
		get
		{
			return eMVIssuerScriptTemplate2Field 
		}
		set(newValue)
		{
			eMVIssuerScriptTemplate2Field = newValue 
		}
    }

    public var EMVCardApplicationInterchangeProfile:String
	{
		get
		{
			return eMVApplicationInterchangeProfileField 
		}
		set(newValue)
		{
			eMVApplicationInterchangeProfileField = newValue 
		}
	}

    public var EMVCardDedicatedFileName:String
    {
		get
		{
			return eMVDedicatedFileNameField 
		}
		set(newValue)
		{
			eMVDedicatedFileNameField = newValue 
		}
    }

    public var EMVCardAuthorizationResponseCode:String
    {
		get
		{
			return eMVAuthorizationResponseCodeField 
		}
		set(newValue)
		{
			eMVAuthorizationResponseCodeField = newValue 
		}
    }

    public var EMVCardIssuerAuthenticationData:String
    {
		get
		{
			return eMVIssuerAuthenticationDataField 
		}
		set(newValue)
		{
			eMVIssuerAuthenticationDataField = newValue 
		}
    }
    

    public var EMVCardTerminalVerificationResults:String
    {
		get
		{
			return eMVTerminalVerificationResultsField 
		}
		set(newValue)
		{
			eMVTerminalVerificationResultsField = newValue 
		}
    }

    public var EMVTransactionDate:String
    {
		get
		{
			return eMVTransactionDateField 
		}
		set(newValue)
		{
			eMVTransactionDateField = newValue 
		}
    }

    public var EMVTransactionStatusInformation:String
    {
		get
		{
			return eMVTransactionStatusInformationField 
		}
		set(newValue)
		{
			eMVTransactionStatusInformationField = newValue 
		}
    }

    public var EMVCryptogramTransactionType:String
    {
		get
		{
			return eMVCryptogramTransactionTypeField 
		}
		set(newValue)
		{
			eMVCryptogramTransactionTypeField = newValue 
		}
    }

    public var EMVIssuerCountryCode:String
    {
		get
		{
			return eMVIssuerCountryCodeField 
		}
		set(newValue)
		{
			eMVIssuerCountryCodeField = newValue 
		}
    }

    public var EMVTransactionCurrencyCode:String
    {
		get
		{
			return eMVTransactionCurrencyCodeField 
		}
		set(newValue)
		{
			eMVTransactionCurrencyCodeField = newValue 
		}
    }

    public var EMVTransactionAmount:String
    {
		get
		{
			return eMVTransactionAmountField 
		}
		set(newValue)
		{
			eMVTransactionAmountField = newValue 
		}
    }

    public var EMVApplicationUsageControl:String
    {
		get
		{
			return eMVApplicationUsageControlField 
		}
		set(newValue)
		{
			eMVApplicationUsageControlField = newValue 
		}
    }

    public var EMVApplicationVersionNumber:String
    {
		get
		{
			return eMVApplicationVersionNumberField 
		}
		set(newValue)
		{
			eMVApplicationVersionNumberField = newValue 
		}
    }

    public var EMVIssuerActionCodeDenial:String
    {
		get
		{
			return eMVIssuerActionCodeDenialField 
		}
		set(newValue)
		{
			eMVIssuerActionCodeDenialField = newValue 
		}
    }

    public var EMVIssuerActionCodeOnline:String
    {
		get
		{
			return eMVIssuerActionCodeOnlineField 
		}
		set(newValue)
		{
			eMVIssuerActionCodeOnlineField = newValue 
		}
    }

    public var EMVIssuerActionCodeDefault:String
    {
		get
		{
			return eMVIssuerActionCodeDefaultField 
		}
		set(newValue)
		{
			eMVIssuerActionCodeDefaultField = newValue 
		}
    }

    public var EMVIssuerApplicationData:String
    {
		get
		{
			return eMVIssuerApplicationDataField 
		}
		set(newValue)
		{
			eMVIssuerApplicationDataField = newValue 
		}
    }

    public var EMVTerminalCountryCode:String
    {
		get
		{
			return eMVTerminalCountryCodeField 
		}
		set(newValue)
		{
			eMVTerminalCountryCodeField = newValue 
		}
    }

    public var EMVInterfaceDeviceSerialNumber:String
    {
		get
		{
			return eMVInterfaceDeviceSerialNumberField 
		}
		set(newValue)
		{
			eMVInterfaceDeviceSerialNumberField = newValue 
		}
    }

    public var EMVApplicationCryptogram:String
    {
		get
		{
			return eMVApplicationCryptogramField 
		}
		set(newValue)
		{
			eMVApplicationCryptogramField = newValue 
		}
    }

    public var EMVCryptogramInformationData:String
    {
		get
		{
			return eMVCryptogramInformationDataField 
		}
		set(newValue)
		{
			eMVCryptogramInformationDataField = newValue 
		}
    }

    public var EMVTerminalCapabilities:String
    {
		get
		{
			return eMVTerminalCapabilitiesField 
		}
		set(newValue)
		{
			eMVTerminalCapabilitiesField = newValue 
		}
    }

    public var EMVCardholderVerificationMethodResults:String
    {
		get
		{
			return eMVCardholderVerificationMethodResultsField 
		}
		set(newValue)
		{
			eMVCardholderVerificationMethodResultsField = newValue 
		}
    }

    public var EMVTerminalType:String
    {
		get
		{
			return eMVTerminalTypeField 
		}
		set(newValue)
		{
			eMVTerminalTypeField = newValue 
		}
    }

    public var EMVApplicationTransactionCounter:String
    {
		get
		{
			return eMVApplicationTransactionCounterField 
		}
		set(newValue)
		{
			eMVApplicationTransactionCounterField = newValue 
		}
    }

    public var EMVUnpredictableNumber:String
    {
		get
		{
			return eMVUnpredictableNumberField 
		}
		set(newValue)
		{
			eMVUnpredictableNumberField = newValue 
		}
    }

    public var EMVTransactionSequenceCounterID:String
    {
		get
		{
			return eMVTransactionSequenceCounterIDField 
		}
		set(newValue)
		{
			eMVTransactionSequenceCounterIDField = newValue 
		}
    }

    public var EMVApplicationCurrencyCode:String
    {
		get
		{
			return eMVApplicationCurrencyCodeField 
		}
		set(newValue)
		{
			eMVApplicationCurrencyCodeField = newValue 
		}
    }

    public var EMVTransactionCategoryCode:String
    {
		get
		{
			return eMVTransactionCategoryCodeField 
		}
		set(newValue)
		{
			eMVTransactionCategoryCodeField = newValue 
		}
    }

    public var EMVIssuerScriptResults:String
    {
		get
		{
			return eMVIssuerScriptResultsField 
		}
		set(newValue)
		{
			eMVIssuerScriptResultsField = newValue 
		}
    }

    public var EMVPanSequenceNumber:String
    {
		get
		{
			return eMVPanSequenceNumber 
		}
		set(newValue)
		{
			eMVPanSequenceNumber = newValue 
		}
    }

    public var EMVServiceCode:String
    {
		get
		{
			return eMVServiceCode 
		}
		set(newValue)
		{
			eMVServiceCode = newValue 
		}
    }
    
    public var EMVShortFileIdentifier:String
    {
		get
		{
			return eMVShortFileIdentifier 
		}
		set(newValue)
		{
			eMVShortFileIdentifier = newValue 
		}
    }
    
    public var NonEMVPinEntryRequired:String
    {
		get
		{
			return nonEMVPinEntryRequired 
		}
		set(newValue)
		{
			nonEMVPinEntryRequired = newValue 
		}
    }
    
    public var NonEMVSignatureRequired:String
    {
		get
		{
			return nonEMVSignatureRequired 
		}
		set(newValue)
		{
			nonEMVSignatureRequired = newValue 
		}
    }
    
    public var NonEMVConfirmationResponseCode:String
    {
		get
		{
			return nonEMVConfirmationResponseCode 
		}
		set(newValue)
		{
			nonEMVConfirmationResponseCode = newValue 
		}
    }
    
    public var NonEMVTransactionType:String
    {
		get
		{
			return nonEMVTransactionType 
		}
		set(newValue)
		{
			nonEMVTransactionType = newValue 
		}
    }
    
    public var NonEMVCardPaymentCode:String
    {
		get
		{
			return nonEMVCardPaymentCode 
		}
		set(newValue)
		{
			nonEMVCardPaymentCode = newValue 
		}
    }
    
    public var NonEMVCardEntryCode:String
    {
		get
		{
			return nonEMVCardEntryCode 
		}
		set(newValue)
		{
			nonEMVCardEntryCode = newValue 
		}
    }
    
    public var NonEMVErrorResponseCode:String
    {
		get
		{
			return nonEMVErrorResponseCode 
		}
		set(newValue)
		{
			nonEMVErrorResponseCode = newValue 
		}
    }
    
}