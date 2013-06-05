//
//  ViewController.m
//  HanoiPrototype
//
//  Created by Luke Van In on 2013/05/03.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "GameViewController.h"

#define DISPLAY_WIDTH 320
#define DISPLAY_HEIGHT 568

#define POLE_BOTTOM 80
#define POLE_COUNT 3

#define STUMP_OFFSET -10

#define DISK_MIN_SIZE 60
#define DISK_MAX_SIZE 100
#define DISK_PADDING 5
#define DISK_SPACING 0.25

@interface GameViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray * poles;
@property (nonatomic, strong) NSArray * diskViews;
@property (nonatomic, strong) UIView * selectedDiskView;
@property (nonatomic, assign) NSUInteger selectedDisk;
@property (nonatomic, assign) CGPoint dragOffset;
@property (nonatomic, assign) NSUInteger totalMoves;
@property (nonatomic, assign) BOOL isGameOver;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSDate * startTime;
@property (nonatomic, strong) NSDate * endTime;
@property (nonatomic, strong) NSArray * imageNames;

@property (nonatomic, strong) UILabel * movesLabel;
@property (nonatomic, strong) UILabel * timeLabel;
@property (nonatomic, strong) UIButton * restartButton;

@end

@implementation GameViewController

- (void)loadView
{
    [super loadView];
    [self createBackground];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageNames = @[@"monkey-blue", @"monkey-green", @"monkey-purple", @"monkey-red", @"monkey-turquoise"];
    [self createStumps];
    [self initializeGame:self.numberOfMonkeys];
    [self initializeMovesLabel];
    [self initializeTimeLabel];
    [self initializeRestartButton];
    [self initializeNewGameButton];
    [self startGame:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)restartTapped
{
    [self startGame:YES];
}

- (void)newGameTapped
{
    [self newGame];
}

- (void)startGame:(BOOL)animated
{
    NSLog(@"Resetting game.");
    self.selectedDiskView = NULL;
    self.selectedDisk = NSNotFound;
    self.totalMoves = 0;
    self.isGameOver = NO;
    [self resetDisks:animated];
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
    NSString * message = [NSString stringWithFormat:@"Congratulations! You took %d moves. Your time was %@.", self.totalMoves, self.formattedTime];
    [[[UIAlertView alloc] initWithTitle:@"You won!"
                                message:message
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"New Game", @"Replay", nil] show];
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
    [self.gameDelegate exitGame];
}

- (void)startTimer
{
    NSLog(@"Starting timer.");
    [self.timer invalidate];
    
    self.startTime = [NSDate date];
    [self updateTime];
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.066
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

- (NSTimeInterval)elapsedTime
{
    NSTimeInterval output = [self.endTime timeIntervalSinceDate:self.startTime];
    return output;
}

- (NSString *)formattedTime
{
    NSTimeInterval interval = [self elapsedTime];
    NSString * s = [self formatTimeInterval:interval];
    return s;
}

- (void)updateTime
{
    self.timeLabel.text = [NSString stringWithFormat:@"Time %@", self.formattedTime];
}

- (void)updateMoves
{
    self.movesLabel.text = [NSString stringWithFormat:@"Moves %d", self.totalMoves];
}

- (void)diskViewDidPan:(id)sender
{
    UIPanGestureRecognizer * panGesture = (UIPanGestureRecognizer *)sender;
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        UIView * diskView = panGesture.view;
        [self pickupDisk:diskView];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [self dropDisk];
    }
    
    if (!self.selectedDiskView) {
        return;
    }
    
    CGPoint point = [panGesture translationInView:self.view];
    point.x = self.dragOffset.x + point.x;
    point.y = self.dragOffset.y + point.y;

    CGRect frame = self.selectedDiskView.frame;
    frame.origin = point;
    self.selectedDiskView.frame = frame;
}

- (void)pickupDisk:(UIView *)diskView
{
    NSUInteger diskNumber = [self.diskViews indexOfObject:diskView];
    
    if (diskNumber == NSNotFound) {
        NSLog(@"Disk not in collection.");
        return;
    }
    
    NSUInteger poleNumber = [self poleForDisk:diskNumber];
    
    if (poleNumber == NSNotFound) {
        NSLog(@"Cannot get pole for disk #%d", diskNumber);
        return;
    }
    
    NSUInteger topDiskNumber = [self topDiskForPole:poleNumber];
    
    if (diskNumber != topDiskNumber) {
        NSLog(@"Selected disk #%d is not the top-most disk for pole #%d, topmost disk is %d.", diskNumber, poleNumber, topDiskNumber);
        return;
    }
    
    self.selectedDisk = diskNumber;
    self.selectedDiskView = diskView;
    self.dragOffset = self.selectedDiskView.frame.origin;
    NSLog(@"Start dragging disk %d.", diskNumber);

}

- (void)dropDisk
{
    if (self.selectedDisk == NSNotFound) {
        return;
    }
    
    NSUInteger toPoleNumber = [self closestPoleToView:self.selectedDiskView];

    NSUInteger fromPoleNumber = [self poleForDisk:self.selectedDisk];
    
    if (fromPoleNumber == NSNotFound) {
        NSLog(@"Cannot get pole for selected disk #%d.", self.selectedDisk);
        abort();
    }

    if ([self canDropDisk:self.selectedDisk atPole:toPoleNumber]) {
        if (fromPoleNumber == toPoleNumber) {
            NSLog(@"Ignoring moving disk #%d to same pole #%d.", self.selectedDisk, fromPoleNumber);
            return;
        }
        
        NSUInteger removedDiskNumber = [self removeDiskFromPole:fromPoleNumber animated:NO];
        
        if (removedDiskNumber != self.selectedDisk) {
            NSLog(@"Removed incorrect disk #%d from pole #%d, expected %d.", removedDiskNumber, fromPoleNumber, self.selectedDisk);
            abort();
        }
        
        [self addDisk:self.selectedDisk toPole:toPoleNumber animated:YES];
        
        self.totalMoves ++;
        [self updateMoves];
    }
    else {
        [self updatePole:fromPoleNumber animated:YES];
    }
    
    NSLog(@"Ended dragging disk %d, to pole %d", self.selectedDisk, toPoleNumber);
    self.selectedDisk = NSNotFound;
    self.selectedDiskView = NULL;
}

- (BOOL)canDropDisk:(NSUInteger)diskNumber atPole:(NSUInteger)poleNumber
{
    NSUInteger topDiskNumber = [self topDiskForPole:poleNumber];
    
    if (topDiskNumber == NSNotFound) {
        return YES;
    }
    
    if (diskNumber > topDiskNumber) {
        return YES;
    }
    
    return NO;
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

- (NSUInteger)topDiskForPole:(NSUInteger)poleNumber
{
    NSArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"No pole #%d", poleNumber);
        return NSNotFound;
    }
    
    NSNumber * i = pole.lastObject;
    
    if (!i) {
        return NSNotFound;
    }
    
    return [i unsignedIntegerValue];
}

- (BOOL)canMoveDisk:(NSUInteger)diskNumber
{
    NSUInteger poleNumber = [self poleForDisk:diskNumber];
    NSLog(@"Moving disk %d from pole %d", diskNumber, poleNumber);
    NSArray * pole = self.poles[poleNumber];
    NSNumber * topDisk = pole.lastObject;
    
    if (diskNumber == topDisk.unsignedIntegerValue) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSUInteger)poleForDisk:(NSUInteger)diskNumber
{
    for (NSUInteger i = 0; i < self.poles.count; i++) {
        NSArray * pole = self.poles[i];
        
        for (NSUInteger j = 0; j < pole.count; j++) {
            NSNumber * d = pole[j];
            if (diskNumber == d.unsignedIntegerValue) {
                return i;
            }
        }
    }
    
    return NSNotFound;
}

- (void)addDisk:(NSUInteger)diskNumber toPole:(NSUInteger)poleNumber animated:(BOOL)animated
{
    NSMutableArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get pole at position: %d", poleNumber);
        return;
    }
    
    [pole addObject:@(diskNumber)];
    [self updatePoles:animated];
}

- (NSUInteger)removeDiskFromPole:(NSUInteger)poleNumber animated:(BOOL)animated
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

- (void)updatePoles:(BOOL)animated
{
    for (NSUInteger i = 0; i < self.poles.count; i++) {
        [self updatePole:i animated:animated];
    }
}

- (void)updatePole:(NSUInteger)poleNumber animated:(BOOL)animated
{
    NSArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot update pole #%d, pole not found.", poleNumber);
        return;
    }

    CGPoint polePosition = [self positionForPole:poleNumber];
    CGFloat size = 0;
    
    for (NSUInteger i = 0; i < pole.count; i++) {
        NSNumber * disk = pole[i];
        NSUInteger diskNumber = disk.unsignedIntegerValue;
        UIView * diskView = self.diskViews[diskNumber];
        
        if (!diskView) {
            NSLog(@"Cannot find disk view #%d.", diskNumber);
            return;
        }
        
        CGRect diskFrame = diskView.frame;
        size += diskFrame.size.height;
        
        if (i > 0) {
            size -= diskFrame.size.height * DISK_SPACING;
        }

        diskFrame.origin.x = polePosition.x - (diskFrame.size.width / 2);
        diskFrame.origin.y = (DISPLAY_HEIGHT - POLE_BOTTOM) - size;
        
        if (animated) {
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 diskView.frame = diskFrame;
                             }
                             completion: ^(BOOL completed){
                                 [self checkGameOver];
                             }];
        }
        else {
            diskView.frame = diskFrame;
            [self checkGameOver];
        }
    }
}

- (void)checkGameOver
{
    if (self.isGameOver) {
        return;
    }
    
    NSUInteger count = [self countForPole:self.poles.count - 1];
    
    if (count == self.numberOfMonkeys) {
        NSLog(@"Game is complete, number of disks on last pole (#%d) vs. total number of disks (#%d).", count, self.numberOfMonkeys);
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

- (NSUInteger)positionForDisk:(NSUInteger)diskNumber onPole:(NSUInteger)poleNumber
{
    NSArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get pole #%d.", poleNumber);
        return NSNotFound;
    }
    
    for (NSUInteger i = 0; i < pole.count; i++) {
        NSNumber * d = pole[i];
        
        if (d.unsignedIntegerValue == diskNumber) {
            return i;
        }
    }
    
    return NSNotFound;
}

- (CGPoint)positionForPole:(NSUInteger)poleNumber
{
    int cellWidth = DISPLAY_WIDTH / POLE_COUNT;
    CGPoint output;
    output.x = (cellWidth * poleNumber) + (cellWidth / 2);
    output.y = DISPLAY_HEIGHT - POLE_BOTTOM;
    return output;
}

- (void)initializeMovesLabel
{
    CGRect frame = CGRectMake(0, 0, 100, 30);
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:17];
    label.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:label];
    self.movesLabel = label;
}

- (void)initializeTimeLabel
{
    CGRect frame = CGRectMake(0, 30, 200, 30);
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.font = [UIFont systemFontOfSize:17];
    label.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:label];
    self.timeLabel = label;
}

- (void)initializeRestartButton
{
    self.restartButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.restartButton.frame = CGRectMake(0, DISPLAY_HEIGHT - 44, 90, 44);
    [self.restartButton setTitle:@"Restart" forState:UIControlStateNormal];
    [self.restartButton addTarget:self action:@selector(restartTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.restartButton];
}

- (void)initializeNewGameButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(90, DISPLAY_HEIGHT - 44, 90, 44);
    [button setTitle:@"New Game" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(newGameTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)initializeGame:(NSUInteger)count
{
    self.numberOfMonkeys = count;
    [self initializePoles:POLE_COUNT];
    [self initializeDiskViews:self.numberOfMonkeys];
    [self resetDisks:NO];
}

- (void)resetDisks:(BOOL)animated
{
    NSUInteger i = 0;
    
    for (i = 0; i < self.poles.count; i++) {
        NSMutableArray * pole = self.poles[i];
        [pole removeAllObjects];
    }
    
    for (i = 0; i < self.numberOfMonkeys; i++) {
        [self addDisk:[NSNumber numberWithUnsignedInt:i] toPole:0];
    }
    
    [self updatePoles:animated];
}

- (void)initializeDiskViews:(NSUInteger)count
{
    NSMutableArray * diskViews = [NSMutableArray array];
    
    int delta = DISK_MAX_SIZE - DISK_MIN_SIZE;
    
    for (NSUInteger i = 0; i < count; i++) {
        UIImage * image = [self randomMonkeyImage];
        CGFloat aspect = image.size.width / image.size.height;
        
        double r = (double)(count - i - 1) / (double)count;
        int width = DISK_MIN_SIZE + (r * delta);
        int height = width / aspect;
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRect imageFrame = CGRectMake(DISK_PADDING, DISK_PADDING, width, height);
        imageView.frame = imageFrame;
        
        CGRect diskFrame = CGRectMake(0, 0, width + DISK_PADDING * 2, height + DISK_PADDING * 2);
        
        UIView * diskView = [[UIView alloc] initWithFrame:diskFrame];
        [diskView addSubview:imageView];
        
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(diskViewDidPan:)];
        [diskView addGestureRecognizer:panGesture];
        
        [diskViews addObject:diskView];
        [self.view addSubview:diskView];
    }
    
    self.diskViews = [diskViews copy];
}

- (UIImage *)randomMonkeyImage
{
    static int lastIndex = -1;
    int nameIndex = 0;

    do {
        nameIndex = ((double)rand() / (double)RAND_MAX) * (self.imageNames.count - 1);
    } while (nameIndex == lastIndex);
    
    lastIndex = nameIndex;
    
    NSString * imageName = self.imageNames[nameIndex];
    NSLog(@"Image #%d : %@", nameIndex, imageName);
    UIImage * image = [UIImage imageNamed:imageName];
    return image;
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

- (void)createBackground
{
    UIImage * backgroundImage = [UIImage imageNamed:@"background"];
    UIImageView * backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [self.view addSubview:backgroundImageView];
}

- (void)createStumps
{
    for (NSUInteger i = 0; i < POLE_COUNT; i++) {
        CGPoint polePosition = [self positionForPole:i];
        UIImage * image = [UIImage imageNamed:@"stump"];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        [self.view addSubview:imageView];
        CGRect frame = imageView.frame;
        frame.origin.x = polePosition.x - (image.size.width * 0.5);
        frame.origin.y = polePosition.y + STUMP_OFFSET;
        imageView.frame = frame;
        NSLog(@"Creating stump #%d, position: %@", i, NSStringFromCGPoint(polePosition));
    }
}

- (void)addDisk:(NSNumber *)diskNumber toPole:(NSUInteger)poleNumber
{
    NSMutableArray * pole = self.poles[poleNumber];
    
    if (!pole) {
        NSLog(@"Cannot get pole number #%d", poleNumber);
        return;
    }

    [pole addObject:diskNumber];
}

- (NSString *)formatTimeInterval:(NSTimeInterval)interval
{
    double minutes = interval / 60;
    int ms = ((double)interval - (int)interval) * 1000;
    int m = minutes;
    int s = (minutes - (double)m) * 60;
    NSString * output = [NSString stringWithFormat:@"%02d:%02d.%03d", m, s, ms];
    return output;
}

@end
