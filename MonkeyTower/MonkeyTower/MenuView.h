//
//  MenuView.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/31.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuView : UIView

//@property (nonatomic, strong) UIImageView * backgroundView;
@property (nonatomic, strong) UIImageView * titleView;
@property (nonatomic, strong) UIButton * startGameButton;
@property (nonatomic, strong) UIButton * scoresButton;
//@property (nonatomic, strong) UIButton * continueGameButton;
@property (nonatomic, strong) UIButton * aboutButton;
@property (nonatomic, strong) UIButton * helpButton;

@property (nonatomic, assign) BOOL showScores;

@end
