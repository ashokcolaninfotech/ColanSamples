//
//  JSONReader.m
//  EventParking
//
//  Created by Tamil Arasan on 27/04/15.
//  Copyright (c) 2015 Tamil Arasan. All rights reserved.
//

#import "JSONReader.h"
#import "Common.h"


@implementation JSONReader

+(id)sharedJSONReaderInstance
{
    static JSONReader *sharedJsonObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedJsonObject = [[JSONReader alloc] init];
    });
    
    return sharedJsonObject;
}

- (id)init
{
    if(self = [super init])
    {
        
    }
    
    return self;
}

#pragma mark - JSON Create Methods

-(NSString *)getCashPaymentJSONString:(NSDictionary *)paymentDict
{
    NSMutableString *jsonStringBuilder = nil;
    NSString *jsonString = @"";
    
    @try
    {
        if (jsonStringBuilder == nil)
        {
            jsonStringBuilder = [[NSMutableString alloc] init];
        }
        
        [jsonStringBuilder appendFormat:@"{ \n"];
        
        [jsonStringBuilder appendFormat:@"     \"TenantId\": \"%@\",\n", [paymentDict objectForKey:@"TenantId"]];
        [jsonStringBuilder appendFormat:@"     \"PropertyId\": \"%@\",\n", [paymentDict objectForKey:@"PropertyId"]];
        [jsonStringBuilder appendFormat:@"     \"EventId\": \"%@\",\n", [paymentDict objectForKey:@"EventId"]];
        [jsonStringBuilder appendFormat:@"     \"RateID\": \"%@\",\n", [paymentDict objectForKey:@"RateID"]];
        
        [jsonStringBuilder appendFormat:@"     \"ModeofPayment\": \"%@\",\n", [paymentDict objectForKey:@"ModeofPayment"]];
        [jsonStringBuilder appendFormat:@"     \"Amount\": \"%@\",\n", [paymentDict objectForKey:@"Amount"]];
        [jsonStringBuilder appendFormat:@"     \"CreatedBy\": \"%@\",\n", [paymentDict objectForKey:@"CreatedBy"]];
        [jsonStringBuilder appendFormat:@"     \"Createdon\": \"%@\"\n", [paymentDict objectForKey:@"createdon"]];
        
        [jsonStringBuilder appendFormat:@"}"];
        
        jsonString = jsonStringBuilder;
    }
    @catch (NSException *exception)
    {
        jsonString = @"";
    }
    @finally
    {
        return jsonString;
    }
}


- (NSString *)getPaymentJSONString:(NSDictionary *)processPaymentDict
{
    NSMutableString *jsonStringBuilder = nil;
    NSString *jsonString = @"";
    
    @try
    {
        if (jsonStringBuilder == nil)
        {
            jsonStringBuilder = [[NSMutableString alloc] init];
        }
        
        [jsonStringBuilder appendFormat:@"{ \n"];
        
        [jsonStringBuilder appendFormat:@"     \"TenantId\": \"%@\",\n", [processPaymentDict objectForKey:@"TenantId"]];
        [jsonStringBuilder appendFormat:@"     \"PropertyId\": \"%@\",\n", [processPaymentDict objectForKey:@"PropertyId"]];
        [jsonStringBuilder appendFormat:@"     \"EventId\": \"%@\",\n", [processPaymentDict objectForKey:@"EventId"]];
        [jsonStringBuilder appendFormat:@"     \"RateID\": \"%@\",\n", [processPaymentDict objectForKey:@"RateID"]];
        [jsonStringBuilder appendFormat:@"     \"ModeofPayment\": \"%@\",\n", [processPaymentDict objectForKey:@"ModeofPayment"]];
        [jsonStringBuilder appendFormat:@"     \"CreatedBy\": \"%@\",\n", [processPaymentDict objectForKey:@"CreatedBy"]];
        [jsonStringBuilder appendFormat:@"     \"RequestDateTime\": \"%@\",\n", [processPaymentDict objectForKey:@"RequestDateTime"]];
        [jsonStringBuilder appendFormat:@"     \"createdon\": \"%@\",\n", [processPaymentDict objectForKey:@"createdon"]];
        
        
        [jsonStringBuilder appendFormat:@"     \"Amount\": \"%@\",\n", [processPaymentDict objectForKey:@"Amount"]];
        [jsonStringBuilder appendFormat:@"     \"CCName\": \"%@\",\n", [processPaymentDict objectForKey:@"CCName"]];
        [jsonStringBuilder appendFormat:@"     \"CCTrack2\": \"%@\",\n", [processPaymentDict objectForKey:@"CCTrack2"]];
        [jsonStringBuilder appendFormat:@"     \"CCZipCode\": \"%@\",\n", [processPaymentDict objectForKey:@"CCZipCode"]];
        [jsonStringBuilder appendFormat:@"     \"CCNumber\": \"%@\",\n", [processPaymentDict objectForKey:@"CCNumber"]];
        [jsonStringBuilder appendFormat:@"     \"CCExpDate\": \"%@\",\n", [processPaymentDict objectForKey:@"CCExpDate"]];
        [jsonStringBuilder appendFormat:@"     \"sMerchantID\": \"%@\",\n", [processPaymentDict objectForKey:@"sMerchantID"]];
        [jsonStringBuilder appendFormat:@"     \"sAPIPassword\": \"%@\",\n", [processPaymentDict objectForKey:@"sAPIPassword"]];
        [jsonStringBuilder appendFormat:@"     \"ConfigID\": \"%@\"\n", [processPaymentDict objectForKey:@"ConfigID"]];
        
        [jsonStringBuilder appendFormat:@"}"];
        
        jsonString = jsonStringBuilder;
    }
    @catch (NSException *exception)
    {
        jsonString = @"";
    }
    @finally
    {
        return jsonString;
    }
}


-(NSData *)toLoginJSONString:(NSDictionary *)userDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString  ==>%@",jsonString);
    
    return jsonData;
}


#pragma mark - JSON Parsing Methods

-(id)parseJSONData:(NSData *)jsonData
{
    
    id  theObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return theObject;
}

- (UserDetails *)getLogoutUserData:(NSDictionary *)logoutServerDict
{
    UserDetails *userData = nil;
    if(logoutServerDict)
    {
        BOOL isValid = FALSE;
        
        NSNumber *validUser = [logoutServerDict objectForKey:kWSIsValidUserKey];
        if(validUser && validUser != (id)[NSNull null])
            isValid  =[validUser boolValue];
        
        if(isValid)
        {
            userData = [[UserDetails alloc] init];
            [userData setIsValidUser:isValid];
            
            NSString *userID = [logoutServerDict objectForKey:kWSUserIdKey];
            if(userID && userID != (id)[NSNull null])
                [userData setUserID:userID];
            else
                [userData setUserID:kWSEmptyKey];
            
            NSString *errorMessage = [logoutServerDict objectForKey:kWSResultMessageKey];
            if(errorMessage && errorMessage != (id)[NSNull null])
                [userData setErrorMessage:errorMessage];
            else
                [userData setErrorMessage:kWSEmptyKey];
        }
    }
    
    return userData;
}

- (UserDetails *)getLoginUserData:(NSDictionary *)loginServerDict
{
    UserDetails *userData = nil;
    if(loginServerDict)
    {
        userData = [[UserDetails alloc] init];
        BOOL isValid = FALSE;
        
        NSNumber *validUser = [loginServerDict objectForKey:kWSIsValidUserKey];
        if(validUser && validUser != (id)[NSNull null])
            isValid  =[validUser boolValue];
        if(isValid)
        {
            
            [userData setIsValidUser:isValid];
            
            NSString *userID = [loginServerDict objectForKey:kWSUserIdKey];
            if(userID && userID != (id)[NSNull null])
                [userData setUserID:userID];
            else
                [userData setUserID:kWSEmptyKey];
            
            NSString *userNo = [loginServerDict objectForKey:kWSUserNoKey];
            if(userNo && userNo != (id)[NSNull null])
                [userData setUserNo:userNo];
            else
                [userData setUserNo:kWSEmptyKey];
            
            NSString *propertyID = [loginServerDict objectForKey:kWSPropertyIdKey];
            if(propertyID && propertyID != (id)[NSNull null])
                [userData setPropertyID:propertyID];
            else
                [userData setPropertyID:kWSEmptyKey];
            
            NSString *tennantID = [loginServerDict objectForKey:kWSTenantIdKey];
            
            
            if(tennantID && tennantID != (id)[NSNull null])
                [userData setTennentID:tennantID];
            else
                [userData setTennentID:kWSEmptyKey];
            
            NSString *userName = [loginServerDict objectForKey:kWSUsernameKey];
            
            if(userName && userName != (id)[NSNull null])
                [userData setUserNameStr:userName];
            else
                [userData setUserNameStr:kWSEmptyKey];
            
            NSString *userLoggedInId = [loginServerDict objectForKey:kWSUserLoggedInIdKey];
            if(userID && userID != (id)[NSNull null])
                [userData setUserLoggedInId:userLoggedInId];
            else
                [userData setUserLoggedInId:kWSEmptyKey];
            
         // Store loggedin user data into NSUserdefaults
            NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
            [userPref setValue:userID forKey:@"userid"];
            [userPref setValue:userLoggedInId forKey:@"userLoggedInId"];
            [userPref setValue:propertyID forKey:@"property"];
            [userPref setValue:tennantID forKey:@"tennent"];
            [userPref setValue:userName forKey:@"username"];
            [userPref setValue:userNo forKey:@"user_no"];
            [userPref synchronize];
        }
    }
    
    return userData;
}

- (NSDictionary *)getPaymentResponse:(NSDictionary *)paymentDict
{
    NSMutableDictionary *paymentResponseDic = nil;
    if(paymentDict)
    {
        paymentResponseDic = [[NSMutableDictionary alloc] init];
        
        NSString *message = [paymentDict objectForKey:kWSResultMessageKey];
        if(message && message != (id)[NSNull null])
            [paymentResponseDic setObject:message forKey:kWSResultMessageKey];
        else
            [paymentResponseDic setObject:@"Transaction failed." forKey:kWSResultMessageKey];
        
        NSString *transactionID = [paymentDict objectForKey:kWSTransactionIDKey];
        if(transactionID && transactionID != (id)[NSNull null])
            [paymentResponseDic setObject:transactionID forKey:kWSTransactionIDKey];
        else
            [paymentResponseDic setObject:@"" forKey:kWSTransactionIDKey];
        
        NSNumber *uniqueKey = [paymentDict objectForKey:kWSTransactionUniqueKey];
        if(uniqueKey && uniqueKey != (id)[NSNull null])
        {
            NSString *uniqueVal = [NSString stringWithFormat:@"%d",[uniqueKey intValue]];
            [paymentResponseDic setObject:uniqueVal forKey:kWSTransactionUniqueKey];
        }
        else
            [paymentResponseDic setObject:@"" forKey:kWSTransactionUniqueKey];
        
        NSString *cardType = [paymentDict objectForKey:kWSCardTypeKey];
        if(cardType && cardType != (id)[NSNull null])
            [paymentResponseDic setObject:cardType forKey:kWSCardTypeKey];
        else
            [paymentResponseDic setObject:@"Cash" forKey:kWSCardTypeKey];
    }
    
    return paymentResponseDic;
}

- (NSMutableArray *)getPropertyDetailsData:(NSArray *)propertyList
{
    NSMutableArray *propertyArray;
    PropertyDetails *propertyData =nil;
    
    if(propertyList != nil && [propertyList count] > 0)
    {
        if(propertyArray == nil)
        {
            propertyArray = [[NSMutableArray alloc] init];
        }
        
        for(NSDictionary *propertyDict in propertyList)
        {
            BOOL isDeleteStatus = FALSE;
            NSNumber *deleteStatus = [propertyDict objectForKey:kWSDeleteStatusKey];
            if(deleteStatus && deleteStatus != (id)[NSNull null])
                isDeleteStatus  =[deleteStatus boolValue];
            
            NSString *propertyDesc = [propertyDict objectForKey:kWSPropertyDescKey];
            if(propertyDesc && propertyDesc != (id)[NSNull null])
                propertyDesc = [propertyDesc stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceCharacterSet]];
            else
                propertyDesc = @"";
            
            if(isDeleteStatus == FALSE && [propertyDesc length] > 0)
            {
                propertyData = [[PropertyDetails alloc]init];
                [propertyData setIsDeleteStatus:isDeleteStatus];
                
                NSString *propertyID = [propertyDict objectForKey:kWSPropertyIdKey];
                if(propertyID && propertyID != (id)[NSNull null])
                    [propertyData setPropertyID:propertyID];
                else
                    [propertyData setPropertyID:kWSEmptyKey];
                
                NSString *tennentid = [propertyDict objectForKey:kWSTenantIdKey];
                if(tennentid && tennentid != (id)[NSNull null])
                    [propertyData setTennentID:tennentid];
                else
                    [propertyData setTennentID:kWSEmptyKey];
                
                NSString *latitude = [propertyDict objectForKey:kWSLatitudeKey];
                if(latitude && latitude != (id)[NSNull null])
                    [propertyData setLatitude:latitude];
                else
                    [propertyData setLatitude:kWSEmptyKey];
                
                NSString *longtitude = [propertyDict objectForKey:kWSLongitudeKey];
                if(longtitude && longtitude != (id)[NSNull null])
                    [propertyData setLongitude:longtitude];
                else
                    [propertyData setLongitude:kWSEmptyKey];
                
                NSString *propertyNo = [propertyDict objectForKey:kWSPropertyNo];
                if (propertyNo && propertyNo != (id)[NSNull null]) {
                    [propertyData setPropertyNo:propertyNo];
                } else {
                    [propertyData setPropertyNo:kWSEmptyKey];
                }
                
                [propertyData setPropertyDesc:propertyDesc];
                
                [propertyArray addObject:propertyData];
            }
        }
    }
    
    return propertyArray;
}

- (NSDictionary *)getRateDetailsData:(NSDictionary *)rateDict
{
    NSMutableArray *ratesArray = nil;
    RateDetails *rateModelData = nil;
    NSArray *rateList = nil;
    BOOL isSuccess;
    
    NSMutableDictionary *rateResponseDict = nil;
    
    if(rateDict != nil)
    {
        rateResponseDict = [[NSMutableDictionary alloc] init];
        
        NSString *serverStatus =  [rateDict objectForKey:@"Status"];
        NSString *message      =  [rateDict objectForKey:@"Message"];
        
        if([[serverStatus lowercaseString] isEqualToString:@"success"])
        {
            rateList = [rateDict objectForKey:@"RatesModelList"];
            isSuccess = TRUE;
        }
        else
            isSuccess = FALSE;
        
        if(rateList != nil && [rateList count] > 0)
        {
            if(ratesArray == nil)
            {
                ratesArray = [[NSMutableArray alloc] init];
            }
            
            for(NSDictionary *rateDict in rateList)
            {
                BOOL isValid = TRUE;
                
                NSNumber *deleteStatus = [rateDict objectForKey:kWSDeleteStatusKey];
                if(deleteStatus && deleteStatus != (id)[NSNull null])
                    isValid  =[deleteStatus boolValue];
                
                if(isValid == FALSE)
                {
                    rateModelData = [[RateDetails alloc]init];
                    [rateModelData setIsRateDeleteStatus:isValid];
                    
                    NSString *tennentid = [rateDict objectForKey:kWSTenantIdKey];
                    if(tennentid && tennentid != (id)[NSNull null])
                        [rateModelData setRateTennentID:tennentid];
                    else
                        [rateModelData setRateTennentID:kWSEmptyKey];
                    
                    NSString *rateID = [rateDict objectForKey:kWSRateIdKey];
                    if(rateID && rateID != (id)[NSNull null])
                        [rateModelData setRateID:rateID];
                    else
                        [rateModelData setRateID:kWSEmptyKey];
                    
                    NSString *rateDesc = [rateDict objectForKey:kWSRateDescKey];
                    if(rateDesc && rateDesc != (id)[NSNull null])
                        [rateModelData setRateDesc:rateDesc];
                    else
                        [rateModelData setRateDesc:kWSEmptyKey];
                    
                    //Get RateAmount
                    NSNumber *rateAmountNumber  = [rateDict objectForKey:kWSRateAmountKey];
                    if(rateAmountNumber && rateAmountNumber != (id)[NSNull null])
                    {
                        NSString *rateAmount = [NSString stringWithFormat:@"%.2f",[rateAmountNumber doubleValue]];
                        
                       // Separate the floating point value
                        NSString *rateVal;
                        NSArray *digitArray = [rateAmount componentsSeparatedByString:@"."];
                        if([digitArray count] >= 1)
                        {
                            int digit =  [[digitArray objectAtIndex:1] intValue];
                            if(digit == 0)
                                rateVal = [digitArray objectAtIndex:0];
                            else
                                rateVal = rateAmount;
                        }
                        
                        rateVal = (rateVal && [rateVal length] > 0) ? rateVal : @"0";
                        [rateModelData setRateAmount:rateVal];
                    }
                    else
                        [rateModelData setRateAmount:@"0"];
                    
                    [ratesArray addObject:rateModelData];
                }
            }
        }
        
        [rateResponseDict setObject:message forKey:@"Message"];
        [rateResponseDict setObject:[NSNumber numberWithBool:isSuccess] forKey:@"Status"];
        if(ratesArray)
            [rateResponseDict setObject:ratesArray forKey:@"RatesModelList"];
    }
    
    return rateResponseDict;
}

- (NSMutableArray *)getAllEvents:(NSArray *)eventsList
{
    NSMutableArray *eventsArray = nil;
    EventsDetails *eventData = nil;
    
    if(eventsList != nil && [eventsList count] > 0)
    {
        if(eventsArray == nil)
        {
            eventsArray = [[NSMutableArray alloc] init];
        }
        
        for(NSDictionary *eventDict in eventsList)
        {
            BOOL isDeleted = FALSE;
            
            NSNumber *deleteStatus = [eventDict objectForKey:kWSDeleteStatusKey];
            if(deleteStatus && deleteStatus != (id)[NSNull null])
                isDeleted  =[deleteStatus boolValue];
            
            if(isDeleted == FALSE)
            {
                eventData   = [[EventsDetails alloc]init];
                [eventData setIsDeleteStatus:isDeleted];
                
                NSString *eventID   = [eventDict objectForKey:kWSEventIdKey];
                if(eventID && eventID != (id)[NSNull null])
                    [eventData setEventsID:eventID];
                else
                    [eventData setEventsID:kWSEmptyKey];
                
                NSString *eventNo   = [eventDict objectForKey:kWSEventNoKey];
                if(eventNo && eventNo != (id)[NSNull null])
                    [eventData setEventNo:eventNo];
                else
                    [eventData setEventNo:kWSEmptyKey];
                
                NSString *eventDesc  = [eventDict objectForKey:kWSEventDescKey];
                if(eventDesc && eventDesc != (id)[NSNull null])
                    [eventData setEventsDesc:eventDesc];
                else
                    [eventData setEventsDesc:kWSEmptyKey];
                
             //Reterive Start Date & Time
                NSMutableString *startDateTime = [[NSMutableString alloc] init];
                NSString *startDate  = [eventDict objectForKey:kWSEventStartDateKey];
                if(startDate && startDate != (id)[NSNull null])
                {
                    NSArray *dateList = [startDate componentsSeparatedByString:@"T"];
                    if([dateList count] > 0)
                    {
                        NSString *date = [self getEventDateFormat:[dateList objectAtIndex:0]];
                        [startDateTime appendString:date];
                    }
                }
                
                NSString *startTime  = [eventDict objectForKey:kWSEventStartTimeKey];
                if(startTime && startTime != (id)[NSNull null])
                    [startDateTime appendFormat:@" %@",startTime];
                
                if([startDateTime length] > 0)
                    [eventData setStartDate:startDateTime];
                else
                    [eventData setStartDate:@""];
                
             //Reterive End Date & Time
                NSMutableString *endDateTime = [[NSMutableString alloc] init];
                NSString *endDate  = [eventDict objectForKey:kWSEventEndDateKey];
                if(endDate && endDate != (id)[NSNull null])
                {
                    NSArray *dateList = [endDate componentsSeparatedByString:@"T"];
                    if([dateList count] > 0)
                    {
                        NSString *date = [self getEventDateFormat:[dateList objectAtIndex:0]];
                        [endDateTime appendString:date];
                    }
                }
                
                NSString *endTime  = [eventDict objectForKey:kWSEventEndTimeKey];
                if(endTime && endTime != (id)[NSNull null])
                    [endDateTime appendFormat:@" %@",endTime];
                
                if([endDateTime length] > 0)
                    [eventData setEndDate:endDateTime];
                else
                    [eventData setEndDate:@""];
                
                [eventsArray addObject:eventData];
            }
        }
    }
    
    return eventsArray;
}

-(NSString *)getEventDateFormat:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-mm-dd"];
    
    NSDate *eventDate = [dateFormatter dateFromString:dateString];
    [dateFormatter setDateFormat:@"mm/dd/yyyy"];
    NSString *parseDate = [dateFormatter stringFromDate:eventDate];
    
    return parseDate;
}


- (NSMutableArray *)getPaymentType:(NSDictionary *)paymentTypeDict
{
    NSMutableArray *paymentTypeArray = nil;
    
    if(paymentTypeDict)
    {
        NSArray *paymentType = [paymentTypeDict objectForKey:@"PaymentTypeIds"];
        paymentTypeArray = [NSMutableArray arrayWithArray:paymentType];
        
        BOOL isPaymentEncrypt;
        NSNumber *encryptionNumber = [paymentTypeDict objectForKey:@"Encryption"];
        if(encryptionNumber && encryptionNumber != (id)[NSNull null])
            isPaymentEncrypt  =[encryptionNumber boolValue];
        else
            isPaymentEncrypt = FALSE;
        
        NSUserDefaults *userPref = [NSUserDefaults standardUserDefaults];
        [userPref setObject:[NSNumber numberWithBool:isPaymentEncrypt] forKey:@"Encryption"];
        [userPref synchronize];
    }
    
    
    return paymentTypeArray;
}

@end
