//
//  MenuViewController.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/22.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <GameKit/GameKit.h>

#import "MenuViewController.h"
#import "MenuView.h"

@interface MenuViewController ()

@property (nonatomic, strong) MenuView * menuView;

@end

@implementation MenuViewController

- (void)loadView
{
    [super loadView];
    
    MenuView * menuView = [[MenuView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:menuView];
    self.menuView = menuView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.menuView.startGameButton setTitle:@"New Game" forState:UIControlStateNormal];
    [self.menuView.startGameButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.menuView.startGameButton addTarget:self action:@selector(startGameButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView.scoresButton setTitle:@"Leaderboard" forState:UIControlStateNormal];
    [self.menuView.scoresButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.menuView.scoresButton addTarget:self action:@selector(scoresButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.menuView.helpButton setTitle:@"How to Play" forState:UIControlStateNormal];
    [self.menuView.helpButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.menuView.helpButton addTarget:self action:@selector(helpGameButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.menuView.aboutButton setTitle:@"About" forState:UIControlStateNormal];
    [self.menuView.aboutButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.menuView.aboutButton addTarget:self action:@selector(aboutButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    [self updateScoresButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateScoresButton) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.gameDelegate playMenuSoundtrack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateScoresButton
{
    if (self.gameDelegate.hasLocalPlayer) {
        self.menuView.showScores = YES;
    }
    else {
        self.menuView.showScores = NO;
    }
}

#pragma mark - Button actions

- (void)startGameButtonTapped
{
    NSLog(@"Start game button tapped");
    [self.gameDelegate startGame];
}

- (void)scoresButtonTapped
{
    NSLog(@"Scores");
    [self.gameDelegate showScores];
}

- (void)helpGameButtonTapped
{
    NSLog(@"Help button tapped");
    [self.gameDelegate help];
}

- (void)aboutButtonTapped
{
    NSLog(@"About button tapped");
    [self.gameDelegate about];
}

@end
