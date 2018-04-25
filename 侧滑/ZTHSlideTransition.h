//
//  ZTHSlideTransition.h
//  侧滑
//
//  Created by jiangdong on 2018/3/28.
//  Copyright © 2018年 jiangdong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZTHSlideMaskView;

typedef NS_ENUM(NSInteger, ZTHSlideTransitionType) {
    ZTHSlideTransitionTypeBegain, //开始
    ZTHSlideTransitionTypeEnd, //结束
};

@interface ZTHSlideTransition : NSObject <UIViewControllerTransitioningDelegate>

//转场动画类型
@property (nonatomic, assign) ZTHSlideTransitionType transitionType;
//起始控制器
@property (nonatomic, weak) UIViewController *fromController;
//leftviewController
@property (nonatomic, strong) UIViewController *containController;
//左视图出来后面的蒙版
@property (nonatomic, strong) ZTHSlideMaskView *maskView;
//是否滑动滑出侧滑控制器
@property (nonatomic, assign) BOOL isDrag;
//蒙层view宽度
@property (nonatomic, assign) CGFloat leftViewWidth;

//开始结束动画世界
@property (nonatomic, assign) CGFloat begainAnimaitonTime;
@property (nonatomic, assign) CGFloat closeAnimaitonTime;


//清除数据
- (void)clearData;

@end


#pragma mark - ZTHSlideMaskView

@interface ZTHSlideMaskView : UIView
//对应的动画
@property (nonatomic, weak) ZTHSlideTransition *slideTransition;
//蒙版上的拖拽手势
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
//leftvc
@property (nonatomic, strong) UIViewController *containController;

//创建,这样写为了不让它自动释放,手动销毁
+ (instancetype)shareInstance;
//销毁
+ (void)releaseInstance;

//拖拽手势
- (void)handleGesture:(UIPanGestureRecognizer *)pan;
//左视图上拖拽手势
@property (nonatomic, strong) UIPanGestureRecognizer *leftViewPan;
//拖拽移动view
- (void)drag:(CGFloat)moveX isCancleOrEnd:(BOOL)isCancleOrEnd gesture:(UIPanGestureRecognizer *)gesture;


@end


