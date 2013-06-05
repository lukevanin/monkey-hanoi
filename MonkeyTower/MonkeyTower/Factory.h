//
//  Factory.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/26.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Factory : NSObject

+ (UILabel *)createLabel;
+ (UILabel *)createLabelWithFontSize:(CGFloat)fontSize;
+ (UITextView *)createTextView;
+ (UITextView *)createTextViewWithFontSize:(CGFloat)fontSize;
+ (UILabel *)createCaptionWithFontSize:(CGFloat)fontSize;
+ (UIButton *)createButtonWithTitle:(NSString *)title;
+ (UIButton *)createButton;
+ (UIImageView *)createTextBackground;
+ (UIButton *)createCloseButton;
+ (UIImageView *)createBackgroundImageView;

@end
