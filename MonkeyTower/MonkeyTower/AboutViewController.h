//
//  AboutViewController.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/01.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"

@interface AboutViewController : UIViewController

@property (nonatomic, weak) id <GameDelegate> gameDelegate;

@end
