//
//  PanPacificValidation.h
//  PanPacific
//
//  Created by Idumban on 11/06/14.
//  Copyright (c) 2014 Bala Subramaniyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validation : NSObject

// Basic Validators
+ (BOOL) validateAlphaSpaces: (NSString *) candidate;
+ (BOOL) validateNumeric: (NSString *) candidate;
+ (BOOL) validateAlphanumericDash: (NSString *) candidate;
+ (BOOL) validateStringInCharacterSet: (NSString *) string characterSet: (NSMutableCharacterSet *) characterSet;
+ (BOOL) validateNotEmpty: (NSString *) candidate;
+ (BOOL) validateEmail: (NSString *) candidate;
+ (BOOL) validateUrl: (NSString *) candidate;
+ (BOOL) validateUSPhoneNumber: (NSString *) candidate;


@end
