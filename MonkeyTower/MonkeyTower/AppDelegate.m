//
//  AppDelegate.m
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/03.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>

#import "AppDelegate.h"
#import "GameDelegate.h"
#import "LoadingViewController.h"
#import "GameViewController.h"
#import "LevelViewController.h"
#import "MenuViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "MainViewController.h"

@interface AppDelegate () <GameDelegate, AVAudioPlayerDelegate, GKGameCenterControllerDelegate>

@property (nonatomic, strong) MainViewController * mainViewController;
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;
@property (nonatomic, assign) SystemSoundID buttonSoundID;
//@property (nonatomic, strong) UINavigationController * navigationController;
@property (nonatomic, strong) LoadingViewController * loadingViewController;

@end

@implementation AppDelegate

//@synthesize navigationController = _navigationController;
@synthesize numberOfMonkeys = _numberOfMonkeys;
//@synthesize isGameInProgress = _isGameInProgress;
//@synthesize isGamePaused = _isGamePaused;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // FIXME: store monkey count between invocations
    self.numberOfMonkeys = 3;
    
    NSURL * buttonSoundURL = [[NSBundle mainBundle] URLForResource:@"tap" withExtension:@"aif"];
    SystemSoundID buttonSoundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)buttonSoundURL, &buttonSoundID);
    self.buttonSoundID = buttonSoundID;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.mainViewController;
    [self menu];
    [self showLoading];
    [self authenticateLocalPlayer];
    [self.window makeKeyAndVisible];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self pauseGame];
    [self showLoading];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self showLoading];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//- (UINavigationController *)navigationController
//{
//    if (_navigationController) {
//        return _navigationController;
//    }
//    
//    _navigationController = [[UINavigationController alloc] init];
//    return _navigationController;
//}

- (void)setSoundtrackURL:(NSURL *)url
{
    if (!url || !self.audioPlayer) {
        [self playSoundtrack:url];
        return;
    }
    
    if ([url isEqual:self.audioPlayer.url]) {
        return;
    }
    
    [self playSoundtrack:url];
}

- (void)playSoundtrack:(NSURL *)url
{
    if (!url) {
        NSLog(@"Stopping soundtrack");
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        return;
    }
    
    NSLog(@"Playing soundtrack -> %@", url);
    
    NSError * error = nil;
    AVAudioPlayer * audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if (error) {
        NSLog(@"Cannot initialize audio player -> %@", error);
    }
    
    audioPlayer.delegate = self;
    BOOL isAudioReady = [audioPlayer prepareToPlay];
    
    if (!isAudioReady) {
        NSLog(@"Cannot initialize audio");
    }
    
    audioPlayer.numberOfLoops = -1;

    [self.audioPlayer stop];
    self.audioPlayer = audioPlayer;
    [self.audioPlayer play];
}

- (MainViewController *)mainViewController
{
    if (_mainViewController) {
        return _mainViewController;
    }
    
    _mainViewController = [[MainViewController alloc] init];
    return _mainViewController;
}

#pragma mark - GameDelegate

- (void)menu
{
    NSLog(@"Game -> menu");
    MenuViewController * viewController = [[MenuViewController alloc] init];
    viewController.gameDelegate = self;
    [self setContent:viewController animated:YES];
}

- (void)startGame
{
    NSLog(@"Game -> start");
    [self showSelectLevel];
}

- (void)help
{
    NSLog(@"Game -> help");
    HelpViewController * viewController = [[HelpViewController alloc] init];
    [self showPopupViewController:viewController];
}

- (void)about
{
    NSLog(@"Game -> about");
    AboutViewController * viewController = [[AboutViewController alloc] init];
    [self showPopupViewController:viewController];
}

- (void)beginGame
{
    NSLog(@"Game -> play");
    [self showGame];
}

- (void)endGame
{
    NSLog(@"Game -> exit");
    [self showSelectLevel];
}

- (void)showSelectLevel
{
    LevelViewController * viewController = [[LevelViewController alloc] init];
    viewController.gameDelegate = self;
    [self setContent:viewController animated:YES];
}

- (void)showGame
{
    GameViewController * viewController = [[GameViewController alloc] init];
    viewController.gameDelegate = self;
    [self setContent:viewController animated:YES];
}

- (void)pauseGame
{
    if (![self.window.rootViewController isKindOfClass:[GameViewController class]]) {
        return;
    }

    NSLog(@"Pausing game");
    GameViewController * viewController = (GameViewController *)self.window.rootViewController;
    [viewController pauseGame];
}

- (void)resumeGame
{
    if (![self.window.rootViewController isKindOfClass:[GameViewController class]]) {
        return;
    }
    
    NSLog(@"Resuming game");
    GameViewController * viewController = (GameViewController *)self.window.rootViewController;
    [viewController resumeGame];
}

- (void)showPopupViewController:(UIViewController *)viewController;
{
    UIView * view = viewController.view;
    [self.window.rootViewController addChildViewController:viewController];
    [self.window.rootViewController.view addSubview:view];
    
    view.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        view.alpha = 1.0;
    }];
}

- (void)setContent:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.mainViewController setContent:viewController animated:animated];
}

#pragma mark - Sound

- (void)playMenuSoundtrack
{
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"theme-1" withExtension:@"mp3"];
    [self setSoundtrackURL:url];
}

- (void)playInGameSoundtrack
{
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"puzzle-1-b" withExtension:@"mp3"];
    [self setSoundtrackURL:url];
}

- (void)playWinSoundtrack
{
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"win-2" withExtension:@"mp3"];
    [self setSoundtrackURL:url];
}

- (void)playButtonSoundEffect
{
    AudioServicesPlaySystemSound(self.buttonSoundID);
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (!flag) {
        NSLog(@"Cannot play audio");
        return;
    }
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"Audio interrupted");
    // FIXME: pause game
    // FIXME: store playback sound and position - resume when game resumes
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    NSLog(@"Audio resumed");
    // FIXME: keep game paused
}

#pragma mark - Game Center

- (BOOL)hasLocalPlayer
{
    return [GKLocalPlayer localPlayer].authenticated;
}

- (void)showScores
{
    if (!self.hasLocalPlayer) {
        NSLog(@"Cannot show scores -> local player unavailable");
        return;
    }
    
    GKGameCenterViewController * viewController = [[GKGameCenterViewController alloc] init];
    viewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    
    if (!viewController) {
        NSLog(@"Cannot initialise game center");
        return;
    }
    
    viewController.gameCenterDelegate = self;
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)showTimeLeaderboard:(NSUInteger)numberOfMonkeys
{
    [self showLeaderboard:[self timeLeaderboard:numberOfMonkeys]];
}

- (void)showMovesLeaderboard:(NSUInteger)numberOfMonkeys
{
    [self showLeaderboard:[self movesLeaderboard:numberOfMonkeys]];
}

- (void)showLeaderboard:(NSString *)leaderboardCategory
{
    if (!self.hasLocalPlayer) {
        NSLog(@"Cannot show leaderboard -> local player unavailable");
        return;
    }
    
    GKGameCenterViewController * viewController = [[GKGameCenterViewController alloc] init];
    viewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    viewController.leaderboardTimeScope = GKLeaderboardTimeScopeToday;
    viewController.leaderboardCategory = leaderboardCategory;
    
    if (!viewController) {
        NSLog(@"Cannot initialise game center");
        return;
    }
    
    viewController.gameCenterDelegate = self;
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer * localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController)
        {
            NSLog(@"Showing game center authentication view controller");
            [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
            return;
        }
    
        NSLog(@"Local player authentication changed -> %@", @(self.hasLocalPlayer));
        [self hideLoading];
        [self resumeGame];
    };
}

- (void)saveScoreForMonkeys:(NSUInteger)numberOfMonkeys moves:(NSUInteger)moves time:(NSTimeInterval)time
{
    if (!self.hasLocalPlayer) {
        NSLog(@"Cannot save score, local player not available");
        return;
    }

    NSLog(@"Sending scores -> monkeys:%d time: %.2f moves:%d", numberOfMonkeys, time, moves);

    NSArray * scores = @[
               [self scoreForMoves:moves forMonkeys:numberOfMonkeys],
               [self scoreForTime:time forMonkeys:numberOfMonkeys]
               ];
    
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Cannot report scores -> %@", error);
            return;
        }
        
        NSLog(@"Sent scores -> monkeys:%d time: %.2f moves:%d", numberOfMonkeys, time, moves);
    }];
}

- (GKScore *)scoreForMoves:(NSUInteger)moves forMonkeys:(NSUInteger)numberOfMonkeys
{
    NSString * category = [self movesLeaderboard:numberOfMonkeys];
    GKScore * score = [[GKScore alloc] initWithCategory:category];
    score.value = moves;
    score.context = 0;
    return score;
}

- (GKScore *)scoreForTime:(NSTimeInterval)time forMonkeys:(NSUInteger)numberOfMonkeys
{
    NSString * category = [self timeLeaderboard:numberOfMonkeys];
    GKScore * score = [[GKScore alloc] initWithCategory:category];
    score.value = (NSUInteger)(time * 100);
    score.context = 0;
    return score;
}

- (NSString *)movesLeaderboard:(NSUInteger)numberOfMonkeys
{
    return [NSString stringWithFormat:@"com.lukevanin.monkeyhanoi.monkeys_%d.moves", numberOfMonkeys];
}

- (NSString *)timeLeaderboard:(NSUInteger)numberOfMonkeys
{
    return [NSString stringWithFormat:@"com.lukevanin.monkeyhanoi.monkeys_%d.time", numberOfMonkeys];
}

- (void)showLoading
{
    if (self.loadingViewController) {
        return;
    }
    
    NSLog(@"Game -> show loading");
    LoadingViewController * viewController = [[LoadingViewController alloc] init];
    [self.mainViewController addChildViewController:viewController];
    [self.mainViewController.view addSubview:viewController.view];
    self.loadingViewController = viewController;
}

- (void)hideLoading
{
    if (!self.loadingViewController) {
        return;
    }
    
    NSLog(@"Game -> hide loading");
    [self.loadingViewController.view removeFromSuperview];
    [self.loadingViewController.parentViewController removeFromParentViewController];
    self.loadingViewController = nil;
}

@end
