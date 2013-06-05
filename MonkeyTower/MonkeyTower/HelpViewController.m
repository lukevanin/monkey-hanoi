//
//  HelpViewController.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/05/31.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "HelpViewController.h"
#import "HelpView.h"

#define NUM_PAGES 6

@interface HelpViewController ()

@property (nonatomic, strong) HelpView * helpView;

@end

@implementation HelpViewController

- (void)loadView
{
    [super loadView];
    
    HelpView * helpView = [[HelpView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:helpView];
    self.helpView = helpView;
    
    self.helpView.pageControl.numberOfPages = NUM_PAGES;
    
    for (NSUInteger i = 0; i < NUM_PAGES; i++) {
        NSString * name = [NSString stringWithFormat:@"help-%d", i];
        UIImage * image = [UIImage imageNamed:name];
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        [self.helpView.scrollView addSubview:imageView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.helpView.closeButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.helpView.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)closeButtonTapped
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
