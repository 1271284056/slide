//
//  ViewController.m
//  侧滑
//
//  Created by jiangdong on 2018/3/28.
//  Copyright © 2018年 jiangdong. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+ZTHSlide.h"
#import "LeftViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UIScrollView *contentScrollView;
//左侧控制器
@property (nonatomic, strong) LeftViewController *leftController;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.frame = CGRectMake(100, 60, 40, 40);
    [button addTarget:self action:@selector(buttonclick) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button];
    [self setupScrollView];
    
    //右滑滑出侧滑控制器
//    __weak typeof(self) weakSelf = self;
//    [self zth_setPanActionWithBlock:^(UIPanGestureRecognizer *gesture, CGFloat moveX, BOOL isCancleOrEnd) {
//        [weakSelf zth_showDragSlideController:weakSelf.leftController viewWidth:weakSelf.leftController.leftViewWidth gesture:gesture moveX:moveX isCancleOrEnd:isCancleOrEnd];
//    }];
}

//点击弹出控制器
- (void)buttonclick {
     LeftViewController *leftController = [[LeftViewController alloc] init];
    leftController.leftViewWidth = [UIScreen mainScreen].bounds.size.width - 80;
    [self zth_showSlideController:leftController viewWidth:leftController.leftViewWidth];
}

//如果页面有可以左右滑动的 scroolView,自己判断是否允许侧滑
- (BOOL)ZTHSliderPanEnabled:(UIGestureRecognizer *)gestureRecognizer {
    //触摸点
    CGPoint pointNow = [gestureRecognizer locationInView:self.view];
    if (pointNow.x > self.view.frame.size.width/2) {//可以设置允许的滑动范围
        return NO;
    }
    if (CGRectContainsPoint(_contentScrollView.frame, pointNow) ) {
        if (_contentScrollView.contentOffset.x <= 0) {
            return YES;
        }else{
            return NO;
        }
    }
    return YES;;
}

- (void)setupScrollView {
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
    contentScrollView.backgroundColor = [UIColor lightGrayColor];
    contentScrollView.frame = CGRectMake(0, 150, CGRectGetWidth(self.view.bounds), 300);
    contentScrollView.pagingEnabled = YES;
    contentScrollView.bounces = NO;
    contentScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds)*3 , 600);
    [self.view addSubview:contentScrollView];
    _contentScrollView = contentScrollView;
    _contentScrollView.showsHorizontalScrollIndicator = YES;
}

//左侧控制器
- (LeftViewController *)leftController {
    if (_leftController == nil) {
        _leftController = [[LeftViewController alloc] init];
        _leftController.leftViewWidth = [UIScreen mainScreen].bounds.size.width - 80;
    }
    return _leftController;
}

@end
