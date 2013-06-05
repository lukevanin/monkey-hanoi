//
//  GameDelegate.h
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/08.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GameDelegate <NSObject>

- (void)exitGame;
- (void)startGame:(NSUInteger)numberOfMonkeys;

@end
