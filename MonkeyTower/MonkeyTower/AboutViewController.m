//
//  AboutViewController.m
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/01.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutView.h"
#import "Factory.h"

@interface AboutViewController ()

@property (nonatomic, strong) AboutView * aboutView;

@end

@implementation AboutViewController

- (void)loadView
{
    [super loadView];
    
    AboutView * aboutView = [[AboutView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:aboutView];
    self.aboutView = aboutView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.aboutView.closeButton addTarget:self.gameDelegate action:@selector(playButtonSoundEffect) forControlEvents:UIControlEventTouchDown];
    [self.aboutView.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initializeContent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.aboutView.scrollView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeButtonTapped
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)initializeContent
{
    NSArray * items = @[
                        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title-small"]],
                        [self createSpace],
                        [self createCaption:@"Programming & Graphics"],
                        [self createText:@"Luke Van In"],
                        [self createSpace],
                        [self createCaption:@"QA & Testing"],
                        [self createText:@"Angelique Bannau"],
                        [self createSpace],
                        [self createCaption:@"Music"],
                        [self createText:@"\"Game Forest\""],
                        [self createText:@"DST"],
                        [self createText:@"CC-BY"],
                        [self createText:@"www.nosoapradio.us"],
                        [self createSpace],
                        [self createText:@"\"Puzzle\""],
                        [self createText:@"Rezoner"],
                        [self createText:@"CC-BY"],
                        [self createText:@"rezoner.net"],
                        [self createSpace],
                        [self createText:@"\"Choro Bavario\""],
                        [self createText:@"CC-BY-SA"],
                        [self createText:@"Copyright 2009 MSTR"],
                        [self createText:@"http://www.jamendo.com/en/\nartist/349242/mstr"],
                        [self createSpace],                        
                        [self createCaption:@"License"],
                        [self createText:@"The software and source code is released under Creative Commons Attribution-Sharealike 3.0 Unported license."],
                        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"by-sa.png"]],
                        [self createText:@"http://creativecommons.org/licenses/by-sa/3.0/"],
                        [self createSpace],
                        [self createText:@"Source code for this software is available."],
                        [self createText:@"https://github.com/lukevanin/monkey-hanoi"],
                        ];
    
    for (UIView * item in items) {
        [self.aboutView.scrollView addSubview:item];
    }
}

- (UILabel *)createCaption:(NSString *)text
{
    UILabel * output = [Factory createCaptionWithFontSize:18];
    output.numberOfLines = 1;
    output.text = text;
    [output sizeToFit];
    return output;
}

- (UILabel *)createText:(NSString *)text
{
    UILabel * output = [Factory createLabelWithFontSize:17];
    output.numberOfLines = 0;
    output.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    output.text = text;
    CGRect frame = output.frame;
    frame.size.width = 260;
    output.frame = frame;
    [output sizeToFit];
    return output;
}

- (UIView *)createSpace
{
    UIView * output = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    return output;
}

@end
