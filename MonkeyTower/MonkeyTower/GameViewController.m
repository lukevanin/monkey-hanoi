//
//  ViewController.m
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/03.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//
#import <GameKit/GameKit.h>

#import "GameViewController.h"
#import "Factory.h"
#import "GameView.h"
#import "WinView.h"

#define POLE_COUNT 3

#define MONKEY_MIN_SIZE 60
#define MONKEY_MAX_SIZE 100
#define MONKEY_PADDING 5
#define MONKEY_SPACING 0.25
#define MONKEY_OFFSET 10

@interface GameViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) GameView * gameView;
@property (nonatomic, strong) WinView * winView;
@property (nonatomic, strong) NSArray * poles;
@property (nonatomic, strong) NSArray * monkeyViews;
@property (nonatomic, strong) UIView * selectedMonkeyView;
@property (nonatomic, assign) NSUInteger selectedMonkey;
@property (nonatomic, assign) CGPoint dragOffset;
@property (nonatomic, assign) NSUInteger totalMoves;
@property (nonatomic, assign) BOOL isGameOver;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSDate * startTime;
@property (nonatomic, strong) NSDate * endTime;
@property (nonatomic, assign) NSUInteger currentGhostPosition;
@property (nonatomic, strong) UIImageView * ghostView;
@property (nonatomic, assign) NSUInteger selectedPoleNumber;
@property (nonatomic, assign) NSTimeInterval offsetTime;
@property (nonatomic, assign) BOOL isPaused;

@end

@implementation GameViewController

- (void)loadView
{
    [super loadView];
    
    CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = self.view.bounds.size;
    GameView * gameView = [[GameView alloc] initWithFrame:frame];
    [self.view addSubview:gameView];
    
    self.gameView = gameView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeGame];
    [self startGame:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.gameView.timeCaption.text = @"TIME";
    self.gameView.movesCaption.text = @"MOVES";
    
    [self.gameView.menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [self.gameView.menuButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.gameView.menuButton addTarget:self action:@selector(menuButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.gameView.restartButton setTitle:@"Restart" forState:UIControlStateNormal];
    [self.gameView.restartButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.gameView.restartButton addTarget:self action:@selector(restartButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateMoves];
    [self updateTime];
    
//    [self showWinView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutStumps];
}

- (void)menuButtonTapped
{
    [self.gameDelegate menu];
}

- (void)restartButtonTapped
{
//    [self startGame:NO];
    [self.gameDelegate startGame];
}

- (void)showWinView
{
    if (self.winView) {
        return;
    }
    
    [self.gameDelegate playWinSoundtrack];
    
    WinView * winView = [[WinView alloc] initWithFrame:self.view.bounds];

    [winView.scoresButton setTitle:@"Leaderboard" forState:UIControlStateNormal];
    [winView.scoresButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [winView.scoresButton addTarget:self action:@selector(scoresButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    [winView.menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [winView.menuButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [winView.menuButton addTarget:self action:@selector(menuButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [winView.replayButton setTitle:@"Play again" forState:UIControlStateNormal];
    [winView.replayButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [winView.replayButton addTarget:self action:@selector(restartButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    winView.titleLabel.text = @"You won!";
    winView.movesLabel.text = [NSString stringWithFormat:@"Moves: %d", self.totalMoves];
    winView.timeLabel.text = [NSString stringWithFormat:@"Time: %@", self.formattedTime];

    
    [self.view addSubview:winView];
    self.winView = winView;

    [self updateWinViewLeaderboardButton];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateWinViewLeaderboardButton)
                                                 name:GKPlayerAuthenticationDidChangeNotificationName
                                               object:nil];

    [winView showAnimated];
}

- (void)hideWinView
{
    if (!self.winView) {
        return;
    }
    
    [self.winView removeFromSuperview];
    self.winView = nil;
}

- (void)updateWinViewLeaderboardButton
{
    if (!self.winView) {
        return;
    }
    
    self.winView.showScores =  self.gameDelegate.hasLocalPlayer;
}

- (void)startGame:(BOOL)animated
{
    NSLog(@"Resetting game.");
    [self.gameDelegate playInGameSoundtrack];
    self.selectedMonkeyView = NULL;
    self.selectedMonkey = NSNotFound;
    self.totalMoves = 0;
    self.isGameOver = NO;
    self.offsetTime = 0;
    self.isPaused = NO;
    [self hideWinView];
    [self resetMonkeys:animated];
    [self startTimer];
    [self updateMoves];
    [self updateTime];
}

- (void)endGame
{
    if (self.isGameOver) {
        return;
    }
    
    self.isGameOver = YES;
    [self stopTimer];
    [self updateTime];
    
    [self.gameDelegate saveScoreForMonkeys:self.gameDelegate.numberOfMonkeys moves:self.totalMoves time:self.elapsedTime];
    [self showWinView];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self newGame];
    }
    else if (buttonIndex == 1) {
        [self startGame:NO];
    }
}

- (void)newGame
{
    NSLog(@"New game.");
    [self.gameDelegate endGame];
}

- (void)startTimer
{
    NSLog(@"Starting timer.");
    [self.timer invalidate];
    
    self.startTime = [NSDate date];
    [self updateTime];
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                       target:self
                                                     selector:@selector(timerEvent:)
                                                     userInfo:nil
                                                      repeats:YES];
    self.timer = timer;
}

- (void)stopTimer
{
    NSLog(@"Stopping timer.");
    self.endTime = [NSDate date];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)timerEvent:(NSTimer *)timer
{
    self.endTime = [NSDate date];
    [self updateTime];
}

- (void)updateTime
{
    self.gameView.timeLabel.text = self.formattedTime;
}

- (void)updateMoves
{
    self.gameView.movesLabel.text = [NSString stringWithFormat:@"%d", self.totalMoves];
}

- (void)updateGhostMonkey
{
    if (self.selectedMonkey == NSNotFound) {
        [self hideGhostMonkey];
        return;
    }
    
    NSUInteger toPoleNumber = [self closestPoleToView:self.selectedMonkeyView];
    
    if ([self canDropmonkey:self.selectedMonkey atPole:toPoleNumber]) {
        [self showGhostMonkeyAtPole:toPoleNumber canDrop:YES];
    }
    else {
        [self showGhostMonkeyAtPole:toPoleNumber canDrop:NO];
    }
}

- (void)hideGhostMonkey
{
    self.currentGhostPosition = NSNotFound;
    [self.ghostView removeFromSuperview];
    self.ghostView = nil;
}

- (void)showGhostMonkeyAtPole:(NSUInteger)poleNumber canDrop:(BOOL)canDrop
{
    if (poleNumber == self.currentGhostPosition) {
        return;
    }
    
    self.currentGhostPosition = poleNumber;
    
    if (!self.ghostView) {
        UIImageView * ghostView = [[UIImageView alloc] init];
        ghostView.alpha = 0.80;
        [self.view addSubview:ghostView];
        self.ghostView = ghostView;
    }
    
    self.ghostView.alpha = 0.00;
    
    UIImage * baseImage = nil;
    
    if (canDrop) {
        baseImage = [UIImage imageNamed:@"monkey-faded"];
    }
    else {
        baseImage = [UIImage imageNamed:@"monkey-invalid"];
    }
    
    UIImage * image = nil;
    
    if (self.selectedMonkey % 2) {
        image = [UIImage imageWithCGImage:baseImage.CGImage scale:2.0 orientation:UIImageOrientationUpMirrored];
    }
    else {
        image = [UIImage imageWithCGImage:baseImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
    }
    
    CGRect frame = self.selectedMonkeyView.frame;
    frame.origin = [self positionForTopMonkey:self.selectedMonkey atPole:poleNumber];
    frame.origin.x += MONKEY_PADDING;
    frame.origin.y += MONKEY_PADDING;
    frame.size.width -= MONKEY_PADDING * 2;
    frame.size.height -= MONKEY_PADDING * 2;
    self.ghostView.frame = frame;
    self.ghostView.image = image;

    [UIView animateWithDuration:0.25
                          delay:0.1
                        options:0
                     animations:^{
                         self.ghostView.alpha = 0.80;
                     }
                     completion: ^(BOOL completed){
                     }];
    
}

- (void)monkeyViewDidPan:(id)sender
{
    UIPanGestureRecognizer * panGesture = (UIPanGestureRecognizer *)sender;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        UIView * monkeyView = panGesture.view;
        [self pickupMonkey:monkeyView];
        [self updateGhostMonkey];
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [self updateGhostMonkey];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self hideGhostMonkey];
        [self dropMonkey];
    }
    
    if (!self.selectedMonkeyView) {
        return;
    }
    
    CGPoint point = [panGesture translationInView:self.view];
    point.x = self.dragOffset.x + point.x;
    point.y = self.dragOffset.y + point.y;

    CGRect frame = self.selectedMonkeyView.frame;
    frame.origin = point;
    self.selectedMonkeyView.frame = frame;
}

- (void)pickupMonkey:(UIView *)monkeyView
{
    NSUInteger monkeyNumber = [self.monkeyViews indexOfObject:monkeyView];
    
    if (monkeyNumber == NSNotFound) {
        NSLog(@"monkey not in collection.");
        return;
    }
    
    NSUInteger poleNumber = [self poleForMonkey:monkeyNumber];
    
    if (poleNumber == NSNotFound) {
        NSLog(@"Cannot get pole for monkey #%d", monkeyNumber);
        return;
    }
    
    NSMutableArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"No pole #%d", poleNumber);
    }
    
    NSNumber * i = pole.lastObject;
    
    if (!i) {
//        NSLog(@"No object on pole #%d", poleNumber);
        return;
    }
    
    NSUInteger topMonkeyNumber = [i unsignedIntegerValue];
    
    if (monkeyNumber != topMonkeyNumber) {
        NSLog(@"Selected monkey #%d is not the top-most monkey for pole #%d, topmost monkey is %d.", monkeyNumber, poleNumber, topMonkeyNumber);
        return;
    }
    
    [pole removeLastObject];
    
    self.selectedPoleNumber = poleNumber;
    self.selectedMonkey = monkeyNumber;
    self.selectedMonkeyView = monkeyView;
    self.dragOffset = self.selectedMonkeyView.frame.origin;
    NSLog(@"Start dragging monkey %d.", monkeyNumber);
}

- (void)dropMonkey
{
    if (self.selectedMonkey == NSNotFound) {
        NSLog(@"Cannot drop monkey, no monkey selected");
        return;
    }
    
    if (self.selectedPoleNumber == NSNotFound) {
        NSLog(@"Cannot drop monkey, no selected pole");
        return;
    }
    
    NSUInteger toPoleNumber = [self closestPoleToView:self.selectedMonkeyView];

    if ([self canDropmonkey:self.selectedMonkey atPole:toPoleNumber]) {
        if (toPoleNumber != self.selectedPoleNumber) {
            self.totalMoves ++;
            [self updateMoves];
        }
        
        [self dropMonkeyAtPole:toPoleNumber animated:YES];
    }
    else {
        [self dropMonkeyAtPole:self.selectedPoleNumber animated:YES];
    }
    
    NSLog(@"Ended dragging monkey %d, to pole %d", self.selectedMonkey, toPoleNumber);
    self.selectedPoleNumber = NSNotFound;
    self.selectedMonkey = NSNotFound;
    self.selectedMonkeyView = NULL;
}

- (void)dropMonkeyAtPole:(NSUInteger)poleNumber animated:(BOOL)animated
{
    NSMutableArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get pole at position: %d", poleNumber);
        return;
    }
    
    CGRect frame = self.selectedMonkeyView.frame;
    frame.origin = [self positionForTopMonkey:self.selectedMonkey atPole:poleNumber];
    
    [pole addObject:@(self.selectedMonkey)];

    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.selectedMonkeyView.frame = frame;
                         }
                         completion: ^(BOOL completed){
                             [self checkGameOver];
                         }];
    }
    else {
        self.selectedMonkeyView.frame = frame;
        [self checkGameOver];
    }
    
}

- (BOOL)canDropmonkey:(NSUInteger)monkeyNumber atPole:(NSUInteger)poleNumber
{
    NSUInteger topMonkeyNumber = [self topMonkeyForPole:poleNumber];
    
    if (topMonkeyNumber == NSNotFound) {
        return YES;
    }
    
    if (monkeyNumber > topMonkeyNumber) {
        return YES;
    }
    
    return NO;
}

- (NSUInteger)topMonkeyForPole:(NSUInteger)poleNumber
{
    NSMutableArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"No pole #%d", poleNumber);
    }
    
    NSNumber * i = pole.lastObject;
    
    if (!i) {
        NSLog(@"No object on pole #%d", poleNumber);
        return NSNotFound;
    }
    
    NSUInteger topMonkeyNumber = [i unsignedIntegerValue];
    return topMonkeyNumber;
}

- (NSUInteger)closestPoleToView:(UIView *)inputView
{
    CGRect frame = inputView.frame;
    CGFloat x = frame.origin.x + (frame.size.width / 2);
    CGFloat distance = CGFLOAT_MAX;
    NSUInteger selectedPoleNumber = NSNotFound;
    
    for (NSUInteger i = 0; i < self.poles.count; i++) {
        CGPoint polePosition = [self positionForPole:i];
        CGFloat poleDistance = fabs(polePosition.x - x);
        
        if (poleDistance < distance) {
            distance = poleDistance;
            selectedPoleNumber = i;
        }
    }
    
    return selectedPoleNumber;
}

- (BOOL)canMoveMonkey:(NSUInteger)monkeyNumber
{
    NSUInteger poleNumber = [self poleForMonkey:monkeyNumber];
    NSLog(@"Moving monkey %d from pole %d", monkeyNumber, poleNumber);
    NSArray * pole = self.poles[poleNumber];
    NSNumber * topmonkey = pole.lastObject;
    
    if (monkeyNumber == topmonkey.unsignedIntegerValue) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSUInteger)poleForMonkey:(NSUInteger)monkeyNumber
{
    for (NSUInteger i = 0; i < self.poles.count; i++) {
        NSArray * pole = self.poles[i];
        
        for (NSUInteger j = 0; j < pole.count; j++) {
            NSNumber * d = pole[j];
            if (monkeyNumber == d.unsignedIntegerValue) {
                return i;
            }
        }
    }
    
    return NSNotFound;
}

- (void)addMonkey:(NSUInteger)monkeyNumber toPole:(NSUInteger)poleNumber animated:(BOOL)animated
{
    NSMutableArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get pole at position: %d", poleNumber);
        return;
    }
    
    [pole addObject:@(monkeyNumber)];
    [self updatePoles:animated];
}

- (NSUInteger)removeMonkeyFromPole:(NSUInteger)poleNumber animated:(BOOL)animated
{
    NSMutableArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get pole at position: %d", poleNumber);
        return NSNotFound;
    }
    
    NSNumber * output = pole.lastObject;
    [pole removeLastObject];
    [self updatePoles:animated];
    
    if (output) {
        return output.unsignedIntegerValue;
    }
    else {
        return NSNotFound;
    }
}

- (CGPoint)positionForTopMonkey:(NSUInteger)monkeyNumber atPole:(NSUInteger)poleNumber
{
    CGPoint output = CGPointMake(0.0, 0.0);
    CGFloat size = [self measurePole:poleNumber];

    UIView * monkeyView = self.monkeyViews[monkeyNumber];
    
    if (!monkeyView) {
        NSLog(@"Cannot find monkey view #%d.", monkeyNumber);
        return output;
    }
    
    CGRect monkeyFrame = monkeyView.frame;
    
    if (size) {
        size -= monkeyFrame.size.height * MONKEY_SPACING;
    }
    
    size += monkeyFrame.size.height;
    
    CGPoint polePosition = [self positionForPole:poleNumber];
    output.x = polePosition.x - (monkeyFrame.size.width / 2);
    output.y = polePosition.y + MONKEY_OFFSET - size;
    
    return output;
}

- (CGFloat)measurePole:(NSUInteger)poleNumber
{
    NSArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot measure pole #%d, pole not found.", poleNumber);
        return -1;
    }
    
    CGFloat size = 0;
    
    for (NSUInteger i = 0; i < pole.count; i++) {
        NSNumber * monkey = pole[i];
        NSUInteger monkeyNumber = monkey.unsignedIntegerValue;
        UIView * monkeyView = self.monkeyViews[monkeyNumber];
        
        if (!monkeyView) {
            NSLog(@"Cannot find monkey view #%d.", monkeyNumber);
            return 0;
        }
        
        CGFloat monkeyHeight = monkeyView.frame.size.height;

        if (i > 0) {
            monkeyHeight -= monkeyView.frame.size.height * MONKEY_SPACING;
        }

        size += monkeyHeight;
    }
    
    return size;
}

- (void)updatePoles:(BOOL)animated
{
    for (NSUInteger i = 0; i < self.poles.count; i++) {
        [self updatePole:i animated:animated];
    }
}

- (CGFloat)updatePole:(NSUInteger)poleNumber animated:(BOOL)animated
{
    NSArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot update pole #%d, pole not found.", poleNumber);
        return -1;
    }

    CGPoint polePosition = [self positionForPole:poleNumber];
    CGFloat size = 0;
    
    for (NSUInteger i = 0; i < pole.count; i++) {
        NSNumber * monkey = pole[i];
        NSUInteger monkeyNumber = monkey.unsignedIntegerValue;
        UIView * monkeyView = self.monkeyViews[monkeyNumber];
        
        if (!monkeyView) {
            NSLog(@"Cannot find monkey view #%d.", monkeyNumber);
            return -1;
        }
        
        CGRect monkeyFrame = monkeyView.frame;
        size += monkeyFrame.size.height;
        
        if (i > 0) {
            size -= monkeyFrame.size.height * MONKEY_SPACING;
        }

        monkeyFrame.origin.x = polePosition.x - (monkeyFrame.size.width / 2);
        monkeyFrame.origin.y = polePosition.y + MONKEY_OFFSET - size;
        
        if (animated) {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 monkeyView.frame = monkeyFrame;
                             }];
        }
        else {
            monkeyView.frame = monkeyFrame;
            [self checkGameOver];
        }
    }
    
    return size;
}

- (void)checkGameOver
{
    if (self.isGameOver) {
        return;
    }
    
    NSUInteger count = [self countForPole:self.poles.count - 1];
    
    if (count == self.gameDelegate.numberOfMonkeys) {
        NSLog(@"Game is complete, number of monkeys on last pole (#%d) vs. total number of monkeys (#%d).", count, self.gameDelegate.numberOfMonkeys);
        [self endGame];
    }
}

- (NSUInteger)countForPole:(NSUInteger)poleNumber
{
    NSArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get count for pole #%d.", poleNumber);
        return NSNotFound;
    }
    
    return pole.count;
}

- (NSUInteger)positionForMonkey:(NSUInteger)monkeyNumber onPole:(NSUInteger)poleNumber
{
    NSArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get pole #%d.", poleNumber);
        return NSNotFound;
    }
    
    for (NSUInteger i = 0; i < pole.count; i++) {
        NSNumber * d = pole[i];
        
        if (d.unsignedIntegerValue == monkeyNumber) {
            return i;
        }
    }
    
    return NSNotFound;
}

- (void)initializeGame
{
    self.currentGhostPosition = NSNotFound;
    self.selectedPoleNumber = NSNotFound;
    [self initializePoles:POLE_COUNT];
    [self initializeMonkeyViews];
    [self resetMonkeys:NO];
}

- (void)resetMonkeys:(BOOL)animated
{
    NSUInteger i = 0;
    
    for (i = 0; i < self.poles.count; i++) {
        NSMutableArray * pole = self.poles[i];
        [pole removeAllObjects];
    }
    
    for (i = 0; i < self.gameDelegate.numberOfMonkeys; i++) {
        [self addMonkey:[NSNumber numberWithUnsignedInt:i] toPole:0];
    }
    
    [self updatePoles:animated];
}

- (void)initializeMonkeyViews
{
    NSMutableArray * monkeyViews = [NSMutableArray array];
    
    int delta = MONKEY_MAX_SIZE - MONKEY_MIN_SIZE;
    int count = self.gameDelegate.numberOfMonkeys;
    UIImage * baseImage = [UIImage imageNamed:@"monkey"];
    
    for (NSInteger i = 0; i < count; i++) {
        UIImage * image = nil;
        
        if (i % 2) {
            image = [UIImage imageWithCGImage:baseImage.CGImage scale:2.0 orientation:UIImageOrientationUpMirrored];
        }
        else {
            image = [UIImage imageWithCGImage:baseImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
        }
        
        CGFloat aspect = image.size.width / image.size.height;
        
        double r = (double)(count - i - 1) / (double)count;
        int width = MONKEY_MIN_SIZE + (r * delta);
        int height = width / aspect;
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRect imageFrame = CGRectMake(MONKEY_PADDING, MONKEY_PADDING, width, height);
        imageView.frame = imageFrame;
        
        CGRect monkeyFrame = CGRectMake(0, 0, width + MONKEY_PADDING * 2, height + MONKEY_PADDING * 2);
        
        UIView * monkeyView = [[UIView alloc] initWithFrame:monkeyFrame];
        [monkeyView addSubview:imageView];
        
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(monkeyViewDidPan:)];
        [monkeyView addGestureRecognizer:panGesture];
        
        [monkeyViews addObject:monkeyView];
    }
    
    for (NSInteger i = (count - 1); i >= 0; i--) {
        UIView * monkeyView = monkeyViews[i];
        [self.view addSubview:monkeyView];
    }
    
    self.monkeyViews = [monkeyViews copy];
}

- (void)initializePoles:(NSUInteger)count
{
    NSMutableArray * poles = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSMutableArray * pole = [NSMutableArray array];
        [poles addObject:pole];
    }
    
    self.poles = [poles copy];
}

- (void)addMonkey:(NSNumber *)monkeyNumber toPole:(NSUInteger)poleNumber
{
    NSMutableArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get pole number #%d", poleNumber);
        return;
    }

    [pole addObject:monkeyNumber];
}

- (void)layoutStumps
{
    for (NSUInteger i = 0; i < POLE_COUNT; i++) {
        UIView * stumpView = self.gameView.stumpViews[i];
        CGPoint polePosition = [self positionForPole:i];
        
        CGRect frame = stumpView.frame;
        frame.origin.x = polePosition.x - (frame.size.width * 0.5);
        frame.origin.y = polePosition.y;
        stumpView.frame = frame;
    }
}

- (CGPoint)positionForPole:(NSUInteger)poleNumber
{
    int cellWidth = self.view.bounds.size.width / POLE_COUNT;
    CGPoint output;
    output.x = (cellWidth * poleNumber) + (cellWidth / 2);
    output.y = self.view.bounds.size.height - 90;
    return output;
}

- (NSString *)formattedTime
{
    NSTimeInterval interval = [self elapsedTime];
    NSString * s = [self formatTimeInterval:interval];
    return s;
}

- (NSTimeInterval)elapsedTime
{
    NSTimeInterval output = self.offsetTime + self.totalTime;
    return output;
}

- (NSTimeInterval)totalTime
{
    NSTimeInterval output = [self.endTime timeIntervalSinceDate:self.startTime];
    return output;
}

- (NSString *)formatTimeInterval:(NSTimeInterval)interval
{
    double minutes = interval / 60;
    int m = minutes;
    int s = (minutes - (double)m) * 60;
    NSString * output = [NSString stringWithFormat:@"%02d:%02d", m, s];
    return output;
}

- (void)scoresButtonTapped
{
    [self.gameDelegate showTimeLeaderboard:self.gameDelegate.numberOfMonkeys];
}

- (void)pauseGame
{
    if (self.isPaused) {
        return;
    }
    
    self.isPaused = YES;
    self.offsetTime = self.elapsedTime;
    [self stopTimer];
}

- (void)resumeGame
{
    if (!self.isPaused) {
        return;
    }
    
    self.isPaused = NO;
    [self startTimer];
}

@end
