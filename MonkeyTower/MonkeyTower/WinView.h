//
//  WinView.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/01.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WinView : UIView

@property (nonatomic, strong) UIImageView * backgroundView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * movesLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * menuButton;
@property (nonatomic, strong) UIButton * replayButton;
@property (nonatomic, strong) UIButton * scoresButton;
@property (nonatomic, assign) BOOL showScores;

- (void)showAnimated;

@end
