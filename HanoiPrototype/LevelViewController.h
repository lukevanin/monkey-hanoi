//
//  LevelViewController.h
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/07.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"

@interface LevelViewController : UIViewController

@property (nonatomic, assign) id <GameDelegate> gameDelegate;

@end
