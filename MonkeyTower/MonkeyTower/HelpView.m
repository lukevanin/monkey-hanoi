//
//  HelpView.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/01.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "HelpView.h"
#import "Factory.h"

@interface HelpView () <UIScrollViewDelegate>

@end

@implementation HelpView 

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
        [self createPageControl];
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
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)createCloseButton
{
    UIButton * closeButton = [Factory createCloseButton];
    [self addSubview:closeButton];
    self.closeButton = closeButton;
}

- (void)createPageControl
{
    UIPageControl * pageControl = [[UIPageControl alloc] init];
    pageControl.defersCurrentPageDisplay = YES;
    [pageControl addTarget:self action:@selector(pageControlChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect backgroundFrame = self.backgroundView.frame;
    backgroundFrame.origin.x = (self.bounds.size.width * 0.5) - (backgroundFrame.size.width * 0.5);
    backgroundFrame.origin.y = (self.bounds.size.height * 0.5) - (backgroundFrame.size.height * 0.5);
    self.backgroundView.frame = backgroundFrame;
    
    CGRect scrollFrame = CGRectMake(12, 13, self.bounds.size.width - 24, self.bounds.size.height - 26);
    self.scrollView.frame = scrollFrame;
    
    CGRect closeButtonFrame = self.closeButton.frame;
    closeButtonFrame.origin.x = self.bounds.size.width - closeButtonFrame.size.width - 5;
    closeButtonFrame.origin.y = 5;
    self.closeButton.frame = closeButtonFrame;
    
    [self.pageControl sizeToFit];
    CGRect pageControlFrame = self.pageControl.frame;
    pageControlFrame.origin.y = self.bounds.size.height - 13 - pageControlFrame.size.height;
    self.pageControl.frame = pageControlFrame;
    
    CGFloat offset = 0;
    
    for (UIView * contentView in self.scrollView.subviews) {
        CGRect contentFrame = contentView.frame;
        contentFrame.origin.x = offset;
        contentFrame.origin.y = (scrollFrame.size.height * 0.5) - (contentFrame.size.height * 0.5);
        contentView.frame = contentFrame;
        offset += scrollFrame.size.width;
    }
    
    self.scrollView.contentSize = CGSizeMake(offset, scrollFrame.size.height);
}

- (void)scrollToPage:(NSUInteger)pageNumber animated:(BOOL)animated
{
    UIView * pageView = self.scrollView.subviews[pageNumber];
    CGRect frame = pageView.frame;
    [self.scrollView scrollRectToVisible:frame animated:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updatePageControl];
}

- (void)pageControlChanged
{
    [self scrollToPage:self.pageControl.currentPage animated:YES];
}

- (void)updatePageControl
{
    CGFloat x = self.scrollView.contentOffset.x + (self.scrollView.frame.size.width * 0.5);
    CGFloat width = self.scrollView.contentSize.width;
    NSInteger page = (x / width) * self.pageControl.numberOfPages;
    self.pageControl.currentPage = page;
}

@end
