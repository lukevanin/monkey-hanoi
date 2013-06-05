//
//  LevelView.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/29.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "LevelView.h"
#import "Factory.h"

#define MONKEY_SIZE_MIN 55
#define MONKEY_SIZE_MAX 80

#define MONKEY_INSET 0.15

@implementation LevelView

@synthesize monkeyViews = _monkeyViews;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self addSubview:self.backgroundView];
        [self addSubview:self.stumpView];
        [self addSubview:self.bottomBarView];
        [self addSubview:self.menuButton];
        [self addSubview:self.startButton];
        [self addSubview:self.instructionLabel];
    }
    return self;
}

- (UIImageView *)stumpView
{
    if (_stumpView) {
        return _stumpView;
    }
    
    UIImage * image = [UIImage imageNamed:@"stump"];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    _stumpView = imageView;
    return _stumpView;
}

- (UIImageView *)bottomBarView
{
    if (_bottomBarView) {
        return _bottomBarView;
    }
    
    UIImage * image = [UIImage imageNamed:@"menubar-bottom"];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    _bottomBarView = imageView;
    return _bottomBarView;
}

- (UIButton *)startButton
{
    if (_startButton) {
        return _startButton;
    }
    
    _startButton = [Factory createButton];
    return _startButton;
}

- (UIButton *)menuButton
{
    if (_menuButton) {
        return _menuButton;
    }
    
    _menuButton = [Factory createButton];
    return _menuButton;
}

- (UILabel *)instructionLabel
{
    if (_instructionLabel) {
        return _instructionLabel;
    }
    
    UILabel * label = [Factory createCaptionWithFontSize:24];
    label.numberOfLines = 0;
    _instructionLabel = label;
    return _instructionLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.stumpView sizeToFit];
    CGRect stumpFrame = self.stumpView.frame;
    stumpFrame.origin.x = (self.bounds.size.width * 0.5) - (stumpFrame.size.width * 0.5);
    stumpFrame.origin.y = self.bounds.size.height - 90;
    self.stumpView.frame = stumpFrame;

    [self.bottomBarView sizeToFit];
    CGRect bottomBarFrame = self.bottomBarView.frame;
    bottomBarFrame.origin.y = self.bounds.size.height - bottomBarFrame.size.height;
    self.bottomBarView.frame = bottomBarFrame;
    
    self.menuButton.frame = CGRectMake(10, self.bounds.size.height - 50, 145, 44);
    self.startButton.frame = CGRectMake(165, self.bounds.size.height - 50, 145, 44);

    CGRect instructionLabelFrame = self.instructionLabel.frame;
    instructionLabelFrame.size.width = self.bounds.size.width - 30;
    instructionLabelFrame.origin.x = 15;
    instructionLabelFrame.origin.y = 10;
    self.instructionLabel.frame = instructionLabelFrame;
    [self.instructionLabel sizeToFit];
    instructionLabelFrame = self.instructionLabel.frame;

//    [self.countLabel sizeToFit];
//    CGRect countLabelFrame = self.countLabel.frame;
//    countLabelFrame.origin.x = 0;
//    countLabelFrame.origin.y = instructionLabelFrame.origin.y + instructionLabelFrame.size.height + 5;
//    countLabelFrame.size.width = self.bounds.size.width;
//    self.countLabel.frame = countLabelFrame;
    
    [self layoutMonkeys];
}


- (void)layoutMonkeys
{
    CGFloat offset = 0;
    CGFloat n = self.monkeyViews.count;
    
    for (NSUInteger i = 0; i < n; i++) {
        UIView * monkeyView = self.monkeyViews[i];
        UIImageView * imageView = monkeyView.subviews[0];
        UIImage * image = imageView.image;
        CGSize size = image.size;
        CGFloat aspect = size.width / size.height;
        
//        CGFloat r = (CGFloat)(n - i - 1) / self.maxMonkey;
        CGFloat r = (CGFloat)(n - i) / n;
        NSLog(@"Monkey ratio %.2f", r);
        CGFloat width = MONKEY_SIZE_MIN + ((MONKEY_SIZE_MAX - MONKEY_SIZE_MIN) * r);
        CGFloat height = width / aspect;
        offset += height;
        
        if (i) {
            offset -= height * MONKEY_INSET;
        }
        
        CGRect frame;
        frame.origin.x = (self.bounds.size.width * 0.5) - (width * 0.5);
        frame.origin.y = self.stumpView.frame.origin.y + 8 - offset;
        //        frame.origin.y = MONKEY_OFFSET_Y - offset;
        frame.size.width = width;
        frame.size.height = height;
        
        monkeyView.frame = frame;
        imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
}

- (void)setMonkeyViews:(NSArray *)monkeyViews
{
    _monkeyViews = [monkeyViews copy];
    
    for (UIView * monkeyView in monkeyViews) {
        [self addSubview:monkeyView];
    }
}

@end
