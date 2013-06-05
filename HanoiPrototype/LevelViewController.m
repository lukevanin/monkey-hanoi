//
//  LevelViewController.m
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/07.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "LevelViewController.h"

#define MONKEYS_MIN 3
#define MONKEYS_MAX 7

#define MONKEY_SIZE_MIN 44
#define MONKEY_SIZE_MAX 90

#define MONKEY_INSET 0.10
#define MONKEY_OFFSET_Y 480

@interface LevelViewController ()

@property (nonatomic, strong) NSArray * monkeyViews;
@property (nonatomic, assign, readonly) NSUInteger monkeyCount;
@property (nonatomic, strong) NSArray * difficulties;

@property (nonatomic, strong) UILabel * countLabel;

@end

@implementation LevelViewController

@synthesize monkeyCount = _monkeyCount;

- (void)loadView
{
    [super loadView];
    [self createBackground];
    [self createMonkeys];
    [self createInstructionLabel];
    [self createCountLabel];
    [self createStartButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutMonkeys];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.difficulties = @[
                      @"Very easy",
                      @"Easy",
                      @"Medium",
                      @"Hard",
                      @"Very hard",
                      @"Super hard",
                      ];
    [self setMonkeyCount:0 animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startButtonTapped
{
//    [[[UIAlertView alloc] initWithTitle:nil message:@"Start game" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    NSLog(@"Start tapped, number of monkeys: %d", self.monkeyCount);
    [self.gameDelegate startGame:self.monkeyCount];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    for (UITouch * touch in touches) {
        [self handleTouch:touch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    for (UITouch * touch in touches) {
        [self handleTouch:touch];
    }
}

- (void)handleTouch:(UITouch *)touch
{
    CGPoint location = [touch locationInView:self.view];
    UIView * monkeyView = [self monkeyViewForPoint:location];
    
    if (!monkeyView) {
        NSLog(@"No monkey view at location %@", NSStringFromCGPoint(location));
        return;
    }
    
    NSUInteger i = [self.monkeyViews indexOfObject:monkeyView] + 1;
    [self setMonkeyCount:i animated:YES];
}

- (UIView *)monkeyViewForPoint:(CGPoint)location
{
    for (UIView * monkeyView in self.monkeyViews) {
        CGRect frame = monkeyView.frame;
        
        if (CGRectContainsPoint(frame, location)) {
            return monkeyView;
        }
    }
    
    return nil;
}

- (void)createStartButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Start" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    CGRect frame;
    frame.size.width = 88;
    frame.size.height = 44;
    frame.origin.x = self.view.bounds.size.width - frame.size.width;
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    button.frame = frame;
}

- (void)createInstructionLabel
{
    UILabel * instructionLabel = [[UILabel alloc] init];
    instructionLabel.frame = CGRectMake(0, 0, 320, 60);
    instructionLabel.font = [UIFont systemFontOfSize:20];
    instructionLabel.backgroundColor = [UIColor cyanColor];
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.numberOfLines = 2;
    instructionLabel.text = @"How many monkeys do you want to play with?";
    [self.view addSubview:instructionLabel];
}

- (void)createCountLabel
{
    UILabel * countLabel = [[UILabel alloc] init];
    countLabel.font = [UIFont systemFontOfSize:20];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.numberOfLines = 2;
    countLabel.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:countLabel];
    self.countLabel = countLabel;
}

- (void)updateCountLabel
{
    NSString * difficulty = self.difficulties[self.monkeyCount - 3];
    self.countLabel.text = [NSString stringWithFormat:@"%d Monkeys!\n%@", self.monkeyCount, difficulty];
    [self.countLabel sizeToFit];
    CGRect frame = self.countLabel.frame;
    frame.origin.x = (self.view.bounds.size.width * 0.5) - (frame.size.width * 0.5);
    frame.origin.y = self.view.bounds.size.height - frame.size.height - 30;
    self.countLabel.frame = frame;
}

- (void)createBackground
{
    UIImage * image = [UIImage imageNamed:@"background"];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
}

- (void)createMonkeys
{
    NSMutableArray * monkeyViews = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < MONKEYS_MAX; i++) {
        UIImage * image = [UIImage imageNamed:@"monkey"];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        [self.view addSubview:imageView];
//        [self.view sendSubviewToBack:imageView];
        [monkeyViews addObject:imageView];
    }
    
    self.monkeyViews = [monkeyViews copy];
}

- (void)layoutMonkeys
{
    CGFloat offset = 0;
    CGFloat n = self.monkeyViews.count;
    
    for (NSUInteger i = 0; i < n; i++) {
        UIImageView * monkeyView = self.monkeyViews[i];
        UIImage * image = monkeyView.image;
        CGSize size = image.size;
        CGFloat aspect = size.width / size.height;
        
        CGFloat r = (CGFloat)(n - i - 1) / MONKEYS_MAX;
        CGFloat width = MONKEY_SIZE_MIN + ((MONKEY_SIZE_MAX - MONKEY_SIZE_MIN) * r);
        CGFloat height = width / aspect;
        offset += (height - (height * MONKEY_INSET));
        
        CGRect frame;
        frame.origin.x = (self.view.bounds.size.width * 0.5) - (width * 0.5);
        frame.origin.y = MONKEY_OFFSET_Y - offset;
        frame.size.width = width;
        frame.size.height = height;
        
        monkeyView.frame = frame;
    }
}

- (void)updateMonkeyCount:(BOOL)animated
{
    for (NSUInteger i = 0; i < self.monkeyViews.count; i++) {
        UIView * monkeyView = self.monkeyViews[i];
        CGFloat alpha;
        
        if (i >= self.monkeyCount) {
            alpha = 0.5;
        }
        else {
            alpha = 1.0;
        }
        
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                monkeyView.alpha = alpha;
            }];
        }
        else {
            monkeyView.alpha = alpha;
        }
    }
}

- (void)setMonkeyCount:(NSUInteger)monkeyCount animated:(BOOL)animated
{
    monkeyCount = MAX(monkeyCount, MONKEYS_MIN);
    monkeyCount = MIN(monkeyCount, MONKEYS_MAX);
    
    if (monkeyCount == _monkeyCount) {
        return;
    }
    
    _monkeyCount = monkeyCount;
    [self updateMonkeyCount:animated];
    [self updateCountLabel];
}

- (NSUInteger)monkeyCount
{
    return _monkeyCount;
}

@end
