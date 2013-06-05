//
//  GameDelegate.h
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/08.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define localPlayerDidChangeNotification @"localPlayerDidChange"

@protocol GameDelegate <NSObject>

@property (nonatomic, assign) NSUInteger numberOfMonkeys;

- (void)playMenuSoundtrack;
- (void)playInGameSoundtrack;
- (void)playWinSoundtrack;

- (void)playButtonSoundEffect;

- (void)menu;
- (void)startGame;
- (void)help;
- (void)about;
- (void)beginGame;
- (void)endGame;

- (void)pauseGame;
- (void)resumeGame;

- (BOOL)hasLocalPlayer;
- (void)showScores;

- (void)showTimeLeaderboard:(NSUInteger)numberOfMonkeys;
- (void)showMovesLeaderboard:(NSUInteger)numberOfMonkeys;
- (void)saveScoreForMonkeys:(NSUInteger)numberOfMonkeys moves:(NSUInteger)moves time:(NSTimeInterval)timeInterval;

@end
