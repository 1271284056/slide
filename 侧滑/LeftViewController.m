//
//  LeftViewController.m
//  侧滑
//
//  Created by jiangdong on 2018/3/28.
//  Copyright © 2018年 jiangdong. All rights reserved.
//

#import "LeftViewController.h"
#import "UIView+QDMailAdditions.h"
#import "UIViewController+ZTHSlide.h"

#define ZTH_Status_Bar_Height  [UIApplication sharedApplication].statusBarFrame.size.height


@interface LeftViewController ()

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.frame = CGRectMake(100, 200, 100, 100);
    [button addTarget:self action:@selector(buttonclick) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeInfoDark];
    button2.frame = CGRectMake(200, 200, 100, 100);
    [button2 addTarget:self action:@selector(closemmediately) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button2];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect rect = self.view.frame;
    //这里控制左视图页面大小
    rect.size.width = [UIScreen mainScreen].bounds.size.width - 80;
    self.view.frame = rect;
}

//显示时候状态栏隐藏,消失时候状态栏显示
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.2 animations:^{
        //私有api,特殊处理下,防止苹果扫描代码,statusBar直接hidden会导致首页导航控制器上移
        UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:[NSString stringWithFormat:@"%@%@", @"statu", @"sBar"]];
        statusBar.y = -ZTH_Status_Bar_Height;
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIView animateWithDuration:0.2 animations:^{
        UIView *statusBar = [[UIApplication sharedApplication] valueForKeyPath:[NSString stringWithFormat:@"%@%@", @"statu", @"sBar"]];
        statusBar.y = 0;
    }];
}

//关闭左边控制器
- (void)buttonclick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//立即关闭(无动画关闭),有时点击侧栏页,需要立即关闭侧栏,用首页控制器的导航栏打开一个新的控制器,不要用dismissViewControllerAnimated:NO
- (void)closemmediately {
    [self.presentingViewController closeLeftControllerNoAnimation];
}



@end
