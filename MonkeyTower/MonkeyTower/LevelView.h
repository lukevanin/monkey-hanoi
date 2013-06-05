//
//  LevelView.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/29.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelView : UIView

//@property (nonatomic, strong) UIImageView * backgroundView;
@property (nonatomic, strong) UIImageView * bottomBarView;
@property (nonatomic, strong) UIButton * menuButton;
@property (nonatomic, strong) UIButton * startButton;
@property (nonatomic, strong) UILabel * instructionLabel;
@property (nonatomic, strong) UIImageView * stumpView;
@property (nonatomic, strong, readonly) NSArray * monkeyViews;

- (void)setMonkeyViews:(NSArray *)monkeyViews;

@end
