//
//  GameView.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/26.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameView : UIView

@property (nonatomic, strong) UIView * topBarView;
@property (nonatomic, strong) UIView * bottomBarView;
@property (nonatomic, strong) NSArray * stumpViews;
@property (nonatomic, strong) UIView * timeBackgroundView;
@property (nonatomic, strong) UIView * movesBackgroundView;
@property (nonatomic, strong) UILabel * timeCaption;
@property (nonatomic, strong) UILabel * movesCaption;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UILabel * movesLabel;
@property (nonatomic, strong) UIButton * menuButton;
@property (nonatomic, strong) UIButton * restartButton;

@end
