//
//  AboutView.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/01.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "AboutView.h"
#import "Factory.h"

@implementation AboutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
        
        [self addSubview:self.backgroundView];
        [self createScrollView];
        [self createCloseButton];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIImageView *)backgroundView
{
    if (_backgroundView) {
        return _backgroundView;
    }
    
    NSString * imageName = nil;
    
    if (SCREEN_HEIGHT > 480) {
        imageName = @"help-background-568h";
    }
    else {
        imageName = @"help-background";
    }
    
    UIImage * image = [UIImage imageNamed:imageName];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:imageView];
    _backgroundView = imageView;
    return _backgroundView;
}

- (void)createScrollView
{
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)createCloseButton
{
    UIButton * closeButton = [Factory createCloseButton];
    [self addSubview:closeButton];
    self.closeButton = closeButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect backgroundFrame = self.backgroundView.frame;
    backgroundFrame.origin.x = (self.bounds.size.width * 0.5) - (backgroundFrame.size.width * 0.5);
    backgroundFrame.origin.y = (self.bounds.size.height * 0.5) - (backgroundFrame.size.height * 0.5) + 1.5;
    self.backgroundView.frame = backgroundFrame;
    
    CGRect closeButtonFrame = self.closeButton.frame;
    closeButtonFrame.origin.x = self.bounds.size.width - closeButtonFrame.size.width - 5;
    closeButtonFrame.origin.y = 5;
    self.closeButton.frame = closeButtonFrame;

    CGRect scrollFrame = CGRectMake(13, 13, self.bounds.size.width - 26, self.bounds.size.height - 26);
    CGFloat contentSize = 0;
    
    for (UIView * item in self.scrollView.subviews) {
        CGRect frame = item.frame;
        frame.origin.x = (scrollFrame.size.width * 0.5) - (frame.size.width * 0.5);
        frame.origin.y = contentSize;
        item.frame = frame;
        contentSize += frame.size.height;
    }
    
    self.scrollView.contentSize = CGSizeMake(scrollFrame.size.width, contentSize);
    self.scrollView.frame = scrollFrame;
}

@end
