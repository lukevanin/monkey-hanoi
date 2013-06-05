//
//  HelpView.h
//  MonkeyTower
//
//  Created by Luke Van In on 2013/06/01.
//  Copyright (c) 2013 Luke Van In. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpView : UIView

@property (nonatomic, strong) UIImageView * backgroundView;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIButton * closeButton;
@property (nonatomic, strong) UIPageControl * pageControl;

- (void)scrollToPage:(NSUInteger)pageNumber animated:(BOOL)animated;

@end
