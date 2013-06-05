//
//  LoadingViewController.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/05.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

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
    
    NSString * imageName = nil;
    
    if (SCREEN_HEIGHT > 480) {
        imageName = @"Default-568h";
    }
    else {
        imageName = @"Default";
    }
    
    UIImage * image = [UIImage imageNamed:imageName];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
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
