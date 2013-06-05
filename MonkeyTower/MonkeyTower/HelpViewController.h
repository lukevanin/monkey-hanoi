//
//  HelpViewController.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/31.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"

@interface HelpViewController : UIViewController

@property (nonatomic, weak) id <GameDelegate> gameDelegate;

@end
