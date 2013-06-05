//
//  GameView.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/26.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "GameView.h"
#import "Factory.h"

#define POLE_COUNT 3

@implementation GameView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self addSubview:self.backgroundView];
        
        for (UIView * stumpView in self.stumpViews) {
            [self addSubview:stumpView];
        }
        
        [self addSubview:self.topBarView];
        [self addSubview:self.bottomBarView];
        [self addSubview:self.timeBackgroundView];
        [self addSubview:self.movesBackgroundView];
        [self addSubview:self.timeCaption];
        [self addSubview:self.movesCaption];
        [self addSubview:self.timeLabel];
        [self addSubview:self.movesLabel];
//        [self addSubview:self.scoresButton];
        [self addSubview:self.menuButton];
        [self addSubview:self.restartButton];
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

- (UIView *)topBarView
{
    if (_topBarView) {
        return _topBarView;
    }
    
    UIImage * image = [UIImage imageNamed:@"menubar-top"];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    _topBarView = imageView;
    return _topBarView;
}

- (UIView *)bottomBarView
{
    if (_bottomBarView) {
        return _bottomBarView;
    }
    
    UIImage * image = [UIImage imageNamed:@"menubar-bottom"];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    _bottomBarView = imageView;
    return _bottomBarView;
}

- (NSArray *)stumpViews
{
    if (_stumpViews) {
        return _stumpViews;
    }
    
    NSMutableArray * views = [NSMutableArray array];

    for (NSUInteger i = 0; i < POLE_COUNT; i++) {
        UIImage * image = [UIImage imageNamed:@"stump"];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        [views addObject:imageView];
    }

    _stumpViews = [views copy];
    return _stumpViews;
}

- (UIView *)timeBackgroundView
{
    if (_timeBackgroundView) {
        return _timeBackgroundView;
    }
    
    _timeBackgroundView = [Factory createTextBackground];
    return _timeBackgroundView;
}

- (UIView *)movesBackgroundView
{
    if (_movesBackgroundView) {
        return _movesBackgroundView;
    }
    
    _movesBackgroundView = [Factory createTextBackground];
    return _movesBackgroundView;
}

- (UILabel *)timeCaption
{
    if (_timeCaption) {
        return _timeCaption;
    }
    
    _timeCaption = [Factory createCaptionWithFontSize:14];
    return _timeCaption;
}

- (UILabel *)movesCaption
{
    if (_movesCaption) {
        return _movesCaption;
    }
    
    _movesCaption = [Factory createCaptionWithFontSize:14];
    return _movesCaption;
}

- (UILabel *)timeLabel
{
    if (_timeLabel) {
        return _timeLabel;
    }
    
    _timeLabel = [Factory createLabel];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    return _timeLabel;
}

- (UILabel *)movesLabel
{
    if (_movesLabel) {
        return _movesLabel;
    }
    
    _movesLabel = [Factory createLabel];
    _movesLabel.textAlignment = NSTextAlignmentCenter;
    return _movesLabel;
}

//- (UIButton *)scoresButton
//{
//    if (_scoresButton) {
//        return _scoresButton;
//    }
//    
//    _scoresButton = [Factory createButton];
//    return _scoresButton;
//}

- (UIButton *)menuButton
{
    if (_menuButton) {
        return _menuButton;
    }
    
    _menuButton = [Factory createButton];
    return _menuButton;
}

- (UIButton *)restartButton
{
    if (_restartButton) {
        return _restartButton;
    }
    
    _restartButton = [Factory createButton];
    return _restartButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame;

    [self.topBarView sizeToFit];
    [self.bottomBarView sizeToFit];
    
    frame = self.bottomBarView.frame;
    frame.origin.y = self.bounds.size.height - frame.size.height;
    self.bottomBarView.frame = frame;

    for (UIView * stumpView in self.stumpViews) {
        [stumpView sizeToFit];
    }
    
    self.menuButton.frame = CGRectMake(10, self.bounds.size.height - 50, 145, 44);
    self.restartButton.frame = CGRectMake(165, self.bounds.size.height - 50, 145, 44);

    CGRect timeBackgroundFrame = CGRectMake(10, 20, 140, 35);
    self.timeBackgroundView.frame = timeBackgroundFrame;

    [self.timeLabel sizeToFit];
    CGRect timeLabelFrame = self.timeLabel.frame;
    timeLabelFrame.size.width = timeBackgroundFrame.size.width;
    timeLabelFrame.origin.x = timeBackgroundFrame.origin.x;
    timeLabelFrame.origin.y = timeBackgroundFrame.origin.y + 6;
    self.timeLabel.frame = timeLabelFrame;
    
    CGRect movesBackgroundFrame = CGRectMake(170, 20, 140, 35);
    self.movesBackgroundView.frame = movesBackgroundFrame;

    [self.movesLabel sizeToFit];
    CGRect movesLabelFrame = self.movesLabel.frame;
    movesLabelFrame.origin.x = movesBackgroundFrame.origin.x;
    movesLabelFrame.origin.y = movesBackgroundFrame.origin.y + 6;
    movesLabelFrame.size.width = movesBackgroundFrame.size.width;
    self.movesLabel.frame = movesLabelFrame;
    
    [self.timeCaption sizeToFit];
    CGRect timeCaptionFrame = self.timeCaption.frame;
    timeCaptionFrame.origin.x = timeBackgroundFrame.origin.x + (timeLabelFrame.size.width * 0.5) - (timeCaptionFrame.size.width * 0.5);
    timeCaptionFrame.origin.y = 5;
    self.timeCaption.frame = timeCaptionFrame;
    
    [self.movesCaption sizeToFit];
    CGRect movesCaptionFrame = self.movesCaption.frame;
    movesCaptionFrame.origin.x = movesLabelFrame.origin.x + (movesLabelFrame.size.width * 0.5) - (movesCaptionFrame.size.width * 0.5);
    movesCaptionFrame.origin.y = 5;
    self.movesCaption.frame = movesCaptionFrame;
}

@end
