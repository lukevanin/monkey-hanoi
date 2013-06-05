//
//  MenuView.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/31.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "MenuView.h"
#import "Factory.h"

#define SPACING 10
#define BUTTON_WIDTH 240
#define BUTTON_HEIGHT 46

@implementation MenuView

@synthesize showScores = _showScores;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleView];
        [self addSubview:self.startGameButton];
        [self addSubview:self.scoresButton];
        [self createAboutButton];
        [self createHelpButton];
    }
    return self;
}

- (UIImageView *)titleView
{
    if (_titleView) {
        return _titleView;
    }
    
    UIImage * image = [UIImage imageNamed:@"title"];
    _titleView = [[UIImageView alloc] initWithImage:image];
    return _titleView;
}

- (UIButton *)startGameButton
{
    if (_startGameButton) {
        return _startGameButton;
    }
    
    _startGameButton = [Factory createButton];
    return _startGameButton;
}

- (UIButton *)scoresButton
{
    if (_scoresButton) {
        return _scoresButton;
    }
    
    _scoresButton = [Factory createButton];
    return _scoresButton;
}

- (void)createAboutButton
{
    UIButton * button = [Factory createButton];
    [self addSubview:button];
    self.aboutButton = button;
}

- (void)createHelpButton
{
    UIButton * button = [Factory createButton];
    [self addSubview:button];
    self.helpButton = button;
}

- (void)setShowScores:(BOOL)showScores
{
    if (_showScores == showScores) {
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
    
    NSInteger titleOffset;
    NSInteger buttonsOffset;

    if (SCREEN_HEIGHT > 480) {
        titleOffset = 40;
        buttonsOffset = 40;
    }
    else {
        titleOffset = 20;
        buttonsOffset = 20;
    }

    CGRect titleFrame = self.titleView.frame;
    titleFrame.origin.x = (self.bounds.size.width * 0.5) - (titleFrame.size.width * 0.5);
    titleFrame.origin.y = titleOffset;
    self.titleView.frame = titleFrame;

    NSMutableArray * buttons = [NSMutableArray array];
    [buttons addObject:self.startGameButton];
    
    if (self.showScores) {
        [self.scoresButton setHidden:NO];
        [buttons addObject:self.scoresButton];
    }
    else {
        [self.scoresButton setHidden:YES];
    }

    [buttons addObject:self.helpButton];
    [buttons addObject:self.aboutButton];
    
    CGRect frame = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
    frame.origin.x = (self.bounds.size.width * 0.5) - (BUTTON_WIDTH * 0.5);
    frame.origin.y = self.bounds.size.height - ((BUTTON_HEIGHT + SPACING) * buttons.count) - buttonsOffset;

    for (UIButton * button in buttons) {
        button.frame = frame;
        frame.origin.y += frame.size.height + SPACING;
    }
}

@end
