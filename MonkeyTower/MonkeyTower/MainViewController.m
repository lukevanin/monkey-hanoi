//
//  MainViewController.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/04.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "MainViewController.h"
#import "Factory.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize content = _content;

- (void)setContent:(UIViewController *)content animated:(BOOL)animated
{
    if (_content) {
        UIViewController * oldContent = _content;
        [UIView animateWithDuration:0.25
                         animations:^{
                             oldContent.view.alpha = 0.0;
                         }
                         completion:^(BOOL completed) {
                             [oldContent removeFromParentViewController];
                             [oldContent.view removeFromSuperview];
                         }
         ];
    }
    
    _content = content;
    content.view.alpha = 0.0;

    [self addChildViewController:content];
    [self.view addSubview:content.view];
    
    [UIView animateWithDuration:0.25 animations:^{
        content.view.alpha = 1.0;
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    UIView * backgroundView = [Factory createBackgroundImageView];
    [self.view addSubview:backgroundView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
