//
//  CustomIndicator.h
//  Kiosh
//
//  Created by Muthu on 04/10/14.
//  Copyright (c) 2014 CIPL253-IOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomIndicator : UIView
{
    UIActivityIndicatorView *activityView;
    UIView *myview;
    UIView *loadingView;
    
    NSString *orientationStatus;
    BOOL isOrientationChecked;

}

+ (id)sharedCustomIndicator;

// Loader Methods
- (void)startLoadAnimation:(id)contorller;
- (void)stopLoadAnimation:(id)contorller;



@end
