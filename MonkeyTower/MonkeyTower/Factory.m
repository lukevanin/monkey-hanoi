//
//  Factory.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/26.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "Factory.h"

#define UI_FONT @"JungleFever"
#define UI_TEXT_COLOR UIColorFromRGB(0x555555)
#define BUTTON_ENABLED_TEXT_COLOR UIColorFromRGB(0x555555)
#define BUTTON_DISABLED_TEXT_COLOR UIColorFromRGB(0x999999)

@implementation Factory

+ (UILabel *)createLabel
{
    return [self createLabelWithFontSize:24];
}

+ (UILabel *)createLabelWithFontSize:(CGFloat)fontSize
{
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:UI_FONT size:fontSize];
    label.textColor = UI_TEXT_COLOR;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

+ (UITextView *)createTextView
{
    return [self createTextViewWithFontSize:24];
}

+ (UITextView *)createTextViewWithFontSize:(CGFloat)fontSize
{
    UITextView * textView = [[UITextView alloc] init];
    textView.font = [UIFont fontWithName:UI_FONT size:24];
    textView.textColor = UI_TEXT_COLOR;
    textView.textAlignment = NSTextAlignmentCenter;
    textView.backgroundColor = [UIColor clearColor];
    return textView;
}

+ (UILabel *)createCaptionWithFontSize:(CGFloat)fontSize
{
    UILabel * label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:UI_FONT size:fontSize];
    label.textColor = UI_TEXT_COLOR;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, 1);
    return label;
}

+ (UIButton *)createButtonWithTitle:(NSString *)title
{
    UIButton * output = [Factory createButton];
    [output setTitle:title forState:UIControlStateNormal];
    return output;
}

+ (UIButton *)createButton
{
    UIImage * buttonNormalImage = [[UIImage imageNamed:@"button-normal"]
                                   resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0) resizingMode:UIImageResizingModeStretch];
    UIImage * buttonPressedImage = [[UIImage imageNamed:@"button-pressed"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0) resizingMode:UIImageResizingModeStretch];
    UIFont * buttonFont = [UIFont fontWithName:UI_FONT size:24];
    
    UIButton * output = [UIButton buttonWithType:UIButtonTypeCustom];
    output.titleLabel.font = buttonFont;
    [output setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, 0)];
    [output setTitleColor:BUTTON_ENABLED_TEXT_COLOR forState:UIControlStateNormal];
    [output setTitleColor:BUTTON_DISABLED_TEXT_COLOR forState:UIControlStateDisabled];
    [output setBackgroundImage:buttonNormalImage forState:UIControlStateNormal];
    [output setBackgroundImage:buttonPressedImage forState:UIControlStateHighlighted];

    return output;
}

+ (UIImageView *)createTextBackground
{
    UIImage * image = [[UIImage imageNamed:@"textfield"]
                       resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 12.0, 0.0, 12.0) resizingMode:UIImageResizingModeStretch];

    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    return imageView;
}

+ (UIButton *)createCloseButton
{
    UIImage * normalImage = [UIImage imageNamed:@"close-button-normal"];
    UIImage * pressedImage = [UIImage imageNamed:@"close-button-pressed"];
    
    CGRect frame;
    frame.size = normalImage.size;
    
    UIButton * closeButton = [[UIButton alloc] initWithFrame:frame];
    [closeButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [closeButton setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
    return closeButton;
}

+ (UIImageView *)createBackgroundImageView
{
    NSString * imageName = nil;
    
    if (SCREEN_HEIGHT > 480) {
        imageName = @"background-568h";
    }
    else {
        imageName = @"background";
    }
    
    UIImage * backgroundImage = [UIImage imageNamed:imageName];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:backgroundImage];
    return imageView;
}

@end
