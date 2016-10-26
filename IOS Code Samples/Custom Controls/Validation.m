//
//  PanPacificValidation.m
//  PanPacific
//
//  Created by Idumban on 11/06/14.
//  Copyright (c) 2014 Bala Subramaniyan. All rights reserved.
//

#import "Validation.h"

@implementation Validation


// ======================
// = Validation Methods =
// ======================

+ (BOOL) validateAlphaSpaces: (NSString *) candidate {
    
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet letterCharacterSet];
    [characterSet addCharactersInString:@" "];
    return [self validateStringInCharacterSet:candidate characterSet:characterSet];
}

+ (BOOL) validateAlphanumericDash: (NSString *) candidate {
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"-  ./_&"];
    return [self validateStringInCharacterSet:candidate characterSet:characterSet];
}

+ (BOOL) validateName: (NSString *) candidate {
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"'- "];
    return [self validateStringInCharacterSet:candidate characterSet:characterSet];
}

+ (BOOL) validateStringInCharacterSet: (NSString *) string characterSet: (NSMutableCharacterSet *) characterSet {
    // Since we invert the character set if it is == NSNotFound then it is in the character set.
    return ([string rangeOfCharacterFromSet:[characterSet invertedSet]].location != NSNotFound) ? NO : YES;
}

+ (BOOL) validateNumeric: (NSString *) candidate
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    BOOL isDecimal = [nf numberFromString:candidate] != nil;
    
    return isDecimal;
}

+ (BOOL) validateUrl: (NSString *) candidate {
    
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

+ (BOOL) validateUSPhoneNumber: (NSString *) candidate
{
    NSString *trimmedString = [candidate stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    // validate forrmat 123-123-1234
    NSString *urlRegEx = @"^(\\d{3}-\\d{3}-\\d{4})*$";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    BOOL isValidForrmat1 = [urlTest evaluateWithObject:trimmedString];
    
    // validate forrmat (123)123-1234
    urlRegEx = @"\\(?(\\d{3})\\)?-?(\\d{3})-(\\d{4})";
    urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    BOOL isValidForrmat2 = [urlTest evaluateWithObject:trimmedString];
    
    // validate forrmat (123) 123-1234
    urlRegEx = @"^([\\(]{1}[0-9]{3}[\\)]{1}[ |\\-]{0,1}|^[0-9]{3}[\\-| ])?[0-9]{3}(\\-| ){1}[0-9]{4}$";
    urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    BOOL isValidForrmat3 = [urlTest evaluateWithObject:trimmedString];
    
    // validate forrmat 123 123 1234
    urlRegEx = @"^(\\d{3} \\d{3} \\d{4})*$";
    urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    
    BOOL isValidForrmat4 = [urlTest evaluateWithObject:trimmedString];
    
    if (isValidForrmat1 || isValidForrmat2 || isValidForrmat3 || isValidForrmat4)
    {
        return YES;
    }
    return NO;
}

+ (BOOL) validateNotEmpty: (NSString *) candidate {
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [candidate stringByTrimmingCharactersInSet:whitespace];
    
    return ([trimmed length] == 0) ? NO : YES ;
}

+ (BOOL) validateEmail: (NSString *) candidate {
    
    BOOL isvalid = NO;
    
    if (candidate.length != 0)
    {
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        isvalid =  [emailTest evaluateWithObject:candidate];
    }
    else
    {
        isvalid = YES;
    }
    return isvalid;
}

@end
