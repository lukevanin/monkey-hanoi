//
//  ViewController.h
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/03.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameDelegate.h"

@interface GameViewController : UIViewController

@property (nonatomic, assign) id <GameDelegate> gameDelegate;
@property (nonatomic, assign) NSUInteger numberOfMonkeys;

@end
