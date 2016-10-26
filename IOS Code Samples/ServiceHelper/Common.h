//
//  Common.h
//  EventParking
//
//  Created by Muthu Rajan on 28/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#ifndef EventParking_Common_h
#define EventParking_Common_h

#endif

#pragma mark - ISL Parameter Keys

#define kWSUserLoggedInIdKey            @"UserLoggedInId"
#define kWSIsValidUserKey               @"IsValidUser"
#define kWSUserIdKey                    @"UserId"
#define kWSUserNoKey                    @"UserNo"

#define kWSPropertyIdKey                @"PropertyId"
#define kWSPropertyNo                   @"UniquePropertyId"
#define kWSTenantIdKey                  @"TenantId"
#define kWSRateIdKey                    @"RateId"
#define kWSEventIdKey                   @"EventId"
#define kWSEventNoKey                   @"EventNo"


#define kWSRateAmountKey                @"RateAmount"
#define kWSUsernameKey                  @"UserName"
#define kWSEmptyKey                     @""
#define kWSDeleteStatusKey              @"DeleteStatus"
#define kWSPropertyDescKey              @"PropertyDesc"
#define kWSRateDescKey                  @"RateDesc"

#define kWSEventDescKey                 @"EventDesc"
#define kWSEventStartDateKey            @"StartDate"
#define kWSEventEndDateKey              @"EndDate"

#define kWSEventStartTimeKey            @"StartTime"
#define kWSEventEndTimeKey              @"EndTime"

#define kWSLatitudeKey                  @"Latitude"
#define kWSLongitudeKey                 @"Longitude"
#define kWSResultMessageKey             @"Message"
#define kWSForgotSuccessMsgKey          @"Email sent successfully."


#define kWSResultSuccessKey             @"success"
#define kWSPropertyUpdateSuccessMsgKey  @"Property updated successfully."

#define kCreditCardSuccessMsgKey        @"Credit Payment successful."
#define kCreditCardFailedMsgKey         @"Credit card payment failed."
#define kCashPaymentSuccessMsgKey       @"Cash Payment successful."
#define kCashPaymentFailedMsgKey        @"Cash Payment Failed."

#define kNoTransactionMsgKey            @"No transactions are done yet."
#define kNoRatesFoundMsgkey             @"No Rates found for selected event"

#define kWSTransactionIDKey             @"TransactionId"
#define kWSTransactionUniqueKey         @"UniqueKey"
#define kWSCardTypeKey                  @"CardType"

#pragma mark - iDynamo Keys

#define kDynamoProtocolKey                              @"com.magtek.idynamo"
#define kDynamoMSRNotification                          @"DynamoMSRNotification"
#define kDynamoTrackCardNotification                    @"trackDataReadyNotification"
#define kDynamoTrackDecodeStatusKey                     @"DynamoTrackDecodeStatus"
#define kDynamoEncryptionStatusKey                      @"DynamoEncryptionStatus"
#define kDynamoTrack1MaskedKey                          @"DynamoTrack1Masked"
#define kDynamoTrack2MaskedKey                          @"DynamoTrack2Masked"
#define kDynamoTrack3MaskedKey                          @"DynamoTrack3Masked"
#define kDynamoTrack1Key                                @"DynamoTrack1"
#define kDynamoTrack2Key                                @"DynamoTrack2"
#define kDynamoTrack3Key                                @"DynamoTrack3"
#define kDynamoCardINKey                                @"DynamoCardIN"
#define kDynamoCardNameKey                              @"DynamoCardName"
#define kDynamoCardLast4Key                             @"DynamoCardLast4"
#define kDynamoCardExpiredDateKey                       @"DynamoCardExpiredDate"



#pragma mark - Linea Pro keys

#define kValetAppNotifications							@"com.sts.valet.notifications"
#define kLineaBarcodeDataNotification					@"LineaBarcodeDataNotification"
#define kLineaCreditCardDataNotification                @"LineaCreditCardDataNotification"

#define kLineaBarcodeTypeKey							@"LineaBarcodeType"
#define kLineaBarcodeTypeTextKey						@"LineaBarcodeTypeText"
#define kLineaBarcodeKey								@"LineaBarcode"
#define kLineaCreditCardKey								@"LineaCreditCard"

//Card Details
#define kLineaCreditCardNameKey							@"cardholderName"
#define kLineaCreditCardNumberKey						@"accountNumber"
#define kLineaCreditCardExpireMonthKey					@"expirationMonth"
#define kLineaCreditCardExpireYearKey					@"expirationYear"
#define kLineaCreditCardTrack2Key						@"CCTrack2"


#pragma mark - Request Keys

//#define kServerBaseURLKey               @"http://liveurl.com/"  //Live URL



#define kServerBaseURLKey                @"http://devurl.com/" // Dev URL



#define kRequestLoginISLKey             @"EventParking/ValidateUser"
#define kGetPropertiesISLKey            @"EventParkingProperty/GetPropertiesByUserId"
#define kGetRatesISLKey                 @"EventParkingRate/GetAllRatesByEventId"
#define KProcessCashPayment             @"EventParkingTransaction/ProcessCashPayment"
#define KProcessCreditCardPayment       @"EventParkingTransaction/ProcessCreditCardPayment"
#define kRequestLogoutISLKey            @"EventParking/Logout"
#define kRequestForgotPasswordISLKey    @"EventParkingUser/ForgotPassword"
#define kRequestLoggedPropertyISLKey    @"EventParkingUser/UpdateUserLoggedProperty"
#define kGetAllEventsISLKey             @"EventParkingEvent/GetAllEventsByPropertyID"
#define kGetPaymentTypeISLKey           @"EventParkingProperty/GetPropertyById"



#define kPrefsSelectedDynaMaxDictKey                    @"SelectedDynaMAXPeripheral"
#define kPrefsDynaMaxNameKey                            @"DynaMaxName"
#define kPrefsDynaMaxUUIDStringKey                      @"DynaMaxUUIDString"




#pragma mark - Frequent Constants

#define kExpiryDateDuration 30

#pragma mark - Devices

#define is_iOS8 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0


typedef enum
{
    JF_LEFT            = 0,
    JF_CENTER          = 1,
    JF_RIGHT           = 2
}JUSTIFICATIONS;

typedef enum
{
    e_defaultErrorAlert = 1000,
    e_loginAlert,
    e_logoutAlert,
    e_propertyErrorAlert,
    e_ratesErrorAlert,
    e_noRatesErrorAlert,
    e_zeroProcessPayment,
    e_rateZeroProcessSuccess,
    e_rateZeroProcessFailed,
    e_cashPaymentSuccessAlert,
    e_cashPaymentFailureAlert,
    e_creditPaymentSucccessAlert,
    e_creditPaymentFailureAlert,
    e_swipeCreditPaymentSuccess,
    e_swipeCreditPaymentFailure,
    e_swipeCreditCardAlert,
    
    
    
}ALERT_TYPE;
