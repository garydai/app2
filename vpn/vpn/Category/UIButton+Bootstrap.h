//
//  UIButton+Bootstrap.h
//  UIButton+Bootstrap
//
//  Created by Oskar Groth on 2013-09-29.
//  Copyright (c) 2013 Oskar Groth. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NSString+FontAwesome.h"
#import "UIColor+expanded.h"
typedef enum {
    StrapBootstrapStyle = 0,
    StrapDefaultStyle,
    StrapPrimaryStyle,
    StrapSuccessStyle,
    StrapInfoStyle,
    StrapWarningStyle,
    StrapDangerStyle,
    blueStyle,
    whiteStyle,
    focusStyle
} StrapButtonStyle;

@interface UIButton (Bootstrap)
//- (void)addAwesomeIcon:(FAIcon)icon beforeTitle:(BOOL)before;
-(void)bootstrapStyle;
-(void)defaultStyle;
-(void)primaryStyle;
-(void)successStyle;
-(void)infoStyle;
-(void)warningStyle;
-(void)dangerStyle;
-(void)blueStyle;
-(void)whiteStyle;
-(void)focusStyle;
- (UIImage *) buttonImageFromColor:(UIColor *)color ;
+ (UIButton *)buttonWithStyle:(StrapButtonStyle)style andTitle:(NSString *)title andFrame:(CGRect)rect target:(id)target action:(SEL)selector;






@end