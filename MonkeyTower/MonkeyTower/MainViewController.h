//
//  MainViewController.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/04.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, strong, readonly) UIViewController * content;

- (void)setContent:(UIViewController *)viewController animated:(BOOL)animated;

@end
