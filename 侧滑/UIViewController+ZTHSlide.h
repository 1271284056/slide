//
//  UIViewController+ZTHSlide.h
//  侧滑
//
//  Created by jiangdong on 2018/3/28.
//  Copyright © 2018年 jiangdong. All rights reserved.
//
/*
 侧滑控件,功能点
 1 对原控制器零入侵,用法简单,支持点击出来和滑动出来.
 2 支持原控制器view上有左右滚动scrollView时,scrollView到最左边才能滑出侧滑页面.
 3 支持侧滑范围自定义,可以设置侧边缘所有情况下滑出.
 4 侧滑页面上也可以拖拽滑动销毁.
 */
#import <UIKit/UIKit.h>

//转场动画key
static const char *ZTHSlideTransitionKey = "ZTHSlideTransitionKey";
//开始x
static const char *ZTHSlideBegainX = "ZTHSlideBegainX";

@interface UIViewController (ZTHSlide)<UIGestureRecognizerDelegate>

//点击弹出左滑控制器
- (void)zth_showSlideController:(UIViewController *)controller;
//添加滑动手势
- (void)zth_setPanActionWithBlock:(void (^)(UIPanGestureRecognizer *gesture,CGFloat moveX,BOOL isCancleOrEnd))block;
//拖拽出来左控制器
- (void)zth_showDragSlideController:(UIViewController *)controller gesture:(UIPanGestureRecognizer *)gesture moveX:(CGFloat)moveX isCancleOrEnd:(BOOL)isCancleOrEnd;

@end
