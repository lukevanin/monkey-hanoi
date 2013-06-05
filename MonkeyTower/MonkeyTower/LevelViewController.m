//
//  LevelViewController.m
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/07.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "LevelViewController.h"
#import "Factory.h"
#import "LevelView.h"

//#define MONKEY_OFFSET_Y 475

@interface LevelViewController ()

@property (nonatomic, strong) LevelView * levelView;
@property (nonatomic, assign, readonly) NSUInteger monkeyCount;
@property (nonatomic, strong) UIView * arrowView;
@property (nonatomic, assign) CGPoint arrowDragOffset;
@property (nonatomic, assign) BOOL isDraggingArrow;

@end

@implementation LevelViewController

@synthesize monkeyCount = _monkeyCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.minMonkey = 3;
        
        if ([UIScreen mainScreen].bounds.size.height > 480) {
            self.maxMonkey = 7;
        }
        else {
            self.maxMonkey = 5;
        }
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self createLevelView];
    [self createArrows];
    [self createMonkeys];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isDraggingArrow = NO;

    self.levelView.instructionLabel.text = @"How many monkeys do you want to play with?";
    [self.levelView.menuButton setTitle:@"Menu" forState:UIControlStateNormal];
    [self.levelView.startButton setTitle:@"Start" forState:UIControlStateNormal];

    [self.levelView.menuButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.levelView.menuButton addTarget:self action:@selector(menuButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.levelView.startButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.levelView.startButton addTarget:self action:@selector(startButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(arrowPanned:)];
    [self.arrowView addGestureRecognizer:panGesture];

    [self setMonkeyCount:self.gameDelegate.numberOfMonkeys animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.gameDelegate playMenuSoundtrack];
    [self updateMonkeyCount:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateArrow:NO];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)arrowPanned:(id)sender
{
    UIPanGestureRecognizer * panGesture = (UIPanGestureRecognizer *)sender;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.isDraggingArrow = YES;
        self.arrowDragOffset = self.arrowView.frame.origin;
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
    
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        self.isDraggingArrow = NO;
        [self updateArrow:YES];
        return;
    }
    
    UIView * bottomMonkey = self.levelView.monkeyViews[self.minMonkey - 1];
    UIView * topMonkey = self.levelView.monkeyViews[self.maxMonkey - 1];

    CGFloat arrowThickness = self.arrowView.frame.size.height * 0.5;
    CGFloat min = topMonkey.frame.origin.y - arrowThickness;
    CGFloat max = bottomMonkey.frame.origin.y + bottomMonkey.frame.size.height - arrowThickness;

    CGPoint point = [panGesture translationInView:self.view];

    CGFloat y = self.arrowDragOffset.y + point.y;
    y = fminf(y, max);
    y = fmaxf(y, min);

    point.y = y;

    CGRect frame = self.arrowView.frame;
    frame.origin.y = y;
    self.arrowView.frame = frame;
    
    NSUInteger monkey = [self getMonkeyIndexAtPosition:y + arrowThickness];
    
    if (monkey == NSNotFound) {
        NSLog(@"No monkey at position %2f", y);
        return;
    }
    
    [self setMonkeyCount:(monkey + 1) animated:YES];
}

- (void)menuButtonTapped
{
    NSLog(@"Menu button tapped");
    [self.gameDelegate menu];
}

- (void)startButtonTapped
{
    NSLog(@"Start tapped, number of monkeys: %d", self.monkeyCount);
    self.gameDelegate.numberOfMonkeys = self.monkeyCount;
    [self.gameDelegate beginGame];
}

- (NSUInteger)getMonkeyIndexAtPosition:(CGFloat)position
{
    for (NSUInteger i = 0; i < self.levelView.monkeyViews.count; i++) {
        UIView * monkeyView = self.levelView.monkeyViews[i];
        CGRect frame = monkeyView.frame;
        CGFloat top = frame.origin.y;
        CGFloat bottom = frame.origin.y + frame.size.height;
        
        if ((position >= top) && (position < bottom)) {
            return i;
        }
    }
    
    return NSNotFound;
}

- (UIView *)monkeyViewForPoint:(CGPoint)location
{
    for (UIView * monkeyView in self.levelView.monkeyViews) {
        CGRect frame = monkeyView.frame;
        
        if (CGRectContainsPoint(frame, location)) {
            return monkeyView;
        }
    }
    
    return nil;
}

- (void)createLevelView
{
    CGRect frame = CGRectMake(0, 0, 0, 0);
    frame.size = self.view.bounds.size;
    LevelView * levelView = [[LevelView alloc] initWithFrame:frame];
    [self.view addSubview:levelView];
    self.levelView = levelView;
}

- (void)createArrows
{
    CGRect bounds = self.view.bounds;
    
    UIImageView * leftArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-left"]];
    CGRect leftArrowFrame = leftArrowView.frame;
    leftArrowFrame.origin.x = 15;
    leftArrowView.frame = leftArrowFrame;
    
    UIImageView * rightArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-right"]];
    CGRect rightArrowFrame = rightArrowView.frame;
    rightArrowFrame.origin.x = bounds.size.width - rightArrowFrame.size.width - 15;
    rightArrowView.frame = rightArrowFrame;
    
    CGRect frame = CGRectMake(0, 0, bounds.size.width, 41);
    UIView * arrowView = [[UIView alloc] initWithFrame:frame];
    [arrowView addSubview:leftArrowView];
    [arrowView addSubview:rightArrowView];
    [self.view addSubview:arrowView];
    self.arrowView = arrowView;
}

- (void)createMonkeys
{
    NSMutableArray * monkeyViews = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < self.maxMonkey; i++) {
        UIImageView * imageView = [[UIImageView alloc] init];
        UIView * monkeyView = [[UIView alloc] initWithFrame:imageView.frame];
        [monkeyView addSubview:imageView];
        [self.view addSubview:monkeyView];
        [monkeyViews addObject:monkeyView];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(monkeyTapped:)];
        [monkeyView addGestureRecognizer:tapGesture];
    }
    
    [self.levelView setMonkeyViews:monkeyViews];
}

- (void)monkeyTapped:(UITapGestureRecognizer *)sender
{
    NSUInteger index = [self.levelView.monkeyViews indexOfObject:sender.view];
    
    if (index == NSNotFound) {
        NSLog(@"Cannot select monkey, unknown monkey view tapped -> %@", sender.view);
        return;
    }
    
    [self setMonkeyCount:(index + 1) animated:YES];
}

- (void)updateMonkeyCount:(BOOL)animated
{
    UIImage * disabledImage = [UIImage imageNamed:@"monkey-faded"];
    UIImage * enabledImage = [UIImage imageNamed:@"monkey"];
    
    for (NSUInteger i = 0; i < self.levelView.monkeyViews.count; i++) {
        UIView * monkeyView = self.levelView.monkeyViews[i];
        UIImageView * imageView = monkeyView.subviews[0];
        UIImage * image = nil;
        
        if (i >= self.monkeyCount) {
            imageView.alpha = 0.8;
            image = disabledImage;
        }
        else {
            imageView.alpha = 1.0;
            image = enabledImage;
        }
        
        if (i % 2) {
            imageView.image = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUpMirrored];
        }
        else {
            imageView.image = [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUp];
        }
    }
}

- (void)setMonkeyCount:(NSUInteger)monkeyCount animated:(BOOL)animated
{
    monkeyCount = MAX(monkeyCount, self.minMonkey);
    monkeyCount = MIN(monkeyCount, self.maxMonkey);
    
    if (monkeyCount == _monkeyCount) {
        return;
    }
    
    NSLog(@"Selecting monkey %d", monkeyCount);
    
    if (animated) {
        [self.gameDelegate playButtonSoundEffect];
    }
    
    _monkeyCount = monkeyCount;
    [self updateMonkeyCount:animated];
    [self updateArrow:animated];
}

- (NSUInteger)monkeyCount
{
    return _monkeyCount;
}

- (void)updateArrow:(BOOL)animated
{
    if (self.isDraggingArrow) {
        NSLog(@"Skipping arrow update, arrow is being dragged.");
        return;
    }
    
    if (!self.monkeyCount) {
        NSLog(@"Cannot set arrow, no monkeys selected.");
        return;
    }
    
    UIView * monkeyView = self.levelView.monkeyViews[self.monkeyCount - 1];
    CGRect monkeyFrame = monkeyView.frame;
    CGRect arrowFrame = self.arrowView.frame;
    arrowFrame.origin.x = 0;
    arrowFrame.origin.y = monkeyFrame.origin.y + (monkeyFrame.size.height * 0.5) - (self.arrowView.frame.size.height * 0.5);
    
    if (animated) {
        [UIView animateWithDuration:0.125 animations:^{
            self.arrowView.frame = arrowFrame;
        }];
    }
    else {
        self.arrowView.frame = arrowFrame;
    }
}

@end
