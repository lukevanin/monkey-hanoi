//
//  WinView.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/01.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "WinView.h"
#import "Factory.h"

#define BUTTON_WIDTH 240
#define BUTTON_HEIGHT 46
#define BUTTON_SPACING 10

@implementation WinView

@synthesize showScores = _showScores;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.movesLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.scoresButton];
        [self addSubview:self.menuButton];
        [self addSubview:self.replayButton];
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
        imageName = @"win-568h";
    }
    else {
        imageName = @"win";
    }
    
    UIImage * image = [UIImage imageNamed:imageName];
    _backgroundView = [[UIImageView alloc] initWithImage:image];
    return _backgroundView;
}

- (UIButton *)scoresButton
{
    if (_scoresButton) {
        return _scoresButton;
    }
    
    _scoresButton = [Factory createButton];
    return _scoresButton;
}

- (UIButton *)menuButton
{
    if (_menuButton) {
        return _menuButton;
    }
    
    _menuButton = [Factory createButton];
    return _menuButton;
}

- (UIButton *)replayButton
{
    if (_replayButton) {
        return _replayButton;
    }
    
    _replayButton = [Factory createButton];
    return _replayButton;
}

- (UILabel *)movesLabel
{
    if (_movesLabel) {
        return _movesLabel;
    }
    
    _movesLabel = [Factory createCaptionWithFontSize:24];
    return _movesLabel;
}

- (UILabel *)timeLabel
{
    if (_timeLabel) {
        return _timeLabel;
    }
    
    _timeLabel = [Factory createCaptionWithFontSize:24];
    return _timeLabel;
}

- (UILabel *)titleLabel
{
    if (_titleLabel) {
        return _titleLabel;
    }
    
    _titleLabel = [Factory createCaptionWithFontSize:35];
    return _titleLabel;
}

- (void)setShowScores:(BOOL)showScores
{
    if (showScores == _showScores) {
        return;
    }
    
    _showScores = showScores;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (BOOL)showScores
{
    return _showScores;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect backgroundFrame = self.backgroundView.frame;
    backgroundFrame.origin.x = (self.bounds.size.width * 0.5) - (backgroundFrame.size.width * 0.5);
    backgroundFrame.origin.y = (self.bounds.size.height * 0.5) - (backgroundFrame.size.height * 0.5);
    self.backgroundView.frame = backgroundFrame;
    
    [self.titleLabel sizeToFit];
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin.x = (self.bounds.size.width * 0.5) - (titleFrame.size.width * 0.5);
    titleFrame.origin.y = (SCREEN_HEIGHT > 480) ? 40 : 50;
    self.titleLabel.frame = titleFrame;
    
    NSArray * labels = @[
                        self.movesLabel,
                        self.timeLabel
                        ];
    
    CGFloat offset = titleFrame.origin.y + 50;
    
    for (UILabel * label in labels) {
        [label sizeToFit];
        CGRect labelFrame = label.frame;
        labelFrame.origin.y = offset;
        labelFrame.origin.x = (self.bounds.size.width * 0.5) - (labelFrame.size.width * 0.5);
        label.frame = labelFrame;
        offset += labelFrame.size.height;
    }
    
    NSMutableArray * buttons = [NSMutableArray array];
    [buttons addObject:self.replayButton];
    
    if (self.showScores) {
        [self.scoresButton setHidden:NO];
        [buttons addObject:self.scoresButton];
    }
    else {
        [self.scoresButton setHidden:YES];
    }

    [buttons addObject:self.menuButton];
    
    CGRect frame = CGRectMake(40, 400, BUTTON_WIDTH, BUTTON_HEIGHT);
    frame.origin.x = (self.bounds.size.width * 0.5) - (frame.size.width * 0.5);
    frame.origin.y = self.bounds.size.height - ((BUTTON_HEIGHT + BUTTON_SPACING) * buttons.count) - 30;
    
    for (UIButton * button in buttons) {
        button.frame = frame;
        frame.origin.y += BUTTON_HEIGHT + BUTTON_SPACING;
    }
}

- (void)showAnimated
{
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    
    [self.titleLabel setHidden:YES];
    [self.movesLabel setHidden:YES];
    [self.timeLabel setHidden:YES];
    self.scoresButton.alpha = 0;
    [self.menuButton setHidden:YES];
    [self.replayButton setHidden:YES];

    CGRect backgroundFrame = self.backgroundView.frame;
    self.backgroundView.frame = CGRectInset(backgroundFrame, backgroundFrame.size.width * 0.25, backgroundFrame.size.height * 0.25);
    self.backgroundView.alpha = 0.0;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.backgroundView.frame = backgroundFrame;
                         self.backgroundView.alpha = 1.0;
                         self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
                     }
                     completion:^(BOOL finished) {
                         [self.titleLabel setHidden:NO];
                         [self.movesLabel setHidden:NO];
                         [self.timeLabel setHidden:NO];
                         self.scoresButton.alpha = 1;
                         [self.menuButton setHidden:NO];
                         [self.replayButton setHidden:NO];
                     }];
}

@end
