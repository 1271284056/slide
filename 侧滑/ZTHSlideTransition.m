//
//  ZTHSlideTransition.m
//  侧滑
//
//  Created by jiangdong on 2018/3/28.
//  Copyright © 2018年 jiangdong. All rights reserved.
//

#import "ZTHSlideTransition.h"
#import "UIView+QDMailAdditions.h"
#import <objc/runtime.h>
#import "UIViewController+ZTHSlide.h"

@interface ZTHSlideTransition () <UIViewControllerAnimatedTransitioning>

@end

@implementation ZTHSlideTransition

//UIViewControllerAnimatedTransitioning
//动画时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

//动画方式
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionType == ZTHSlideTransitionTypeBegain) {//开始
        [self presentAnimation:transitionContext];
    }else{
        [self dismissAnimation:transitionContext];
    }
}

//UIViewControllerTransitioningDelegate
//present开始调用
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.transitionType = ZTHSlideTransitionTypeBegain;
    return self;
}

//dissmiss调用
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.transitionType = ZTHSlideTransitionTypeEnd;
    return self;
}

//实现present动画逻辑代码
- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containView = transitionContext.containerView;
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    //leftVc = toController
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.fromController = fromController;
    toController.view.x = -[UIScreen mainScreen].bounds.size.width;
    self.containController = toController;
    //显示蒙版
    ZTHSlideMaskView *maskView = [ZTHSlideMaskView shareInstance];
    self.maskView = maskView;
    maskView.slideTransition = self;
    maskView.frame = fromController.view.bounds;
    maskView.containController = toController;
    [containView addSubview:maskView];
    [containView addSubview:toController.view];
    if (self.isDrag) {//首页拖拽开始
        maskView.alpha = 0.02;
        [UIView animateWithDuration:0.02 animations:^{

        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else{//点击开始
        [UIView animateWithDuration:0.25 animations:^{
            toController.view.x = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];

        }];
    }
}

//实现dismiss动画逻辑代码
- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containView = transitionContext.containerView;
    //leftController
    UIViewController *leftController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *leftView = leftController.view;
    [containView addSubview:leftView];

    [UIView animateWithDuration:0.25 animations:^{
        leftView.x = -leftView.width;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [self clearData];
    }];
}

//清空数据
- (void)clearData{
    [self.containController.view removeGestureRecognizer:self.maskView.leftViewPan];
    [ZTHSlideMaskView releaseInstance];
    self.containController = nil;
    objc_setAssociatedObject(self.fromController, ZTHSlideTransitionKey, nil, OBJC_ASSOCIATION_RETAIN);
}

- (void)dealloc {
//    NSLog(@"dismissAnimation dealloc");
}

@end


#pragma mark - ZTHSlideMaskView

@interface ZTHSlideMaskView ()<UIGestureRecognizerDelegate>

//起始触摸点
@property (nonatomic, assign) CGPoint startTouch;
//是否动画中
@property (nonatomic,assign) BOOL isMoving;


@end

@implementation ZTHSlideMaskView

//这样写手动销毁
static ZTHSlideMaskView *zth_mask_shareInstance = nil;
static dispatch_once_t zth_mask_onceToken;
+ (instancetype)shareInstance {
    dispatch_once(&zth_mask_onceToken, ^{
        zth_mask_shareInstance = [[ZTHSlideMaskView alloc] init];
    });
    return zth_mask_shareInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addObserver: self forKeyPath: @"containController.view.x" options: NSKeyValueObservingOptionNew context: nil];

        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.3;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        //蒙版上点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
        //蒙版上拖拽手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        pan.delegate = self;
        self.pan = pan;
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)setContainController:(UIViewController *)containController {
    _containController = containController;
    //给左视图view添加一个手势,拖拽左视图view也可以移动
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pan.delegate = self;
    self.leftViewPan = pan;
    [_containController.view addGestureRecognizer:pan];
}

/** * 监听属性值发生改变时回调 改变蒙版透明度*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSNumber *new = change[NSKeyValueChangeNewKey];
//    NSLog(@"new--> %f",[new floatValue]);
    CGFloat maskAlpha = ([new floatValue] + self.containController.view.width) / self.containController.view.width;
    if (maskAlpha < 0.02) {
        maskAlpha = 0.02;
    }
    if (maskAlpha > 0.3) {
        maskAlpha = 0.3;
    }
    self.alpha = maskAlpha;
}



//蒙版点击手势
- (void)singleTap {
    [self.containController dismissViewControllerAnimated:YES completion:nil];
}

//首页拖拽手势
- (void)drag:(CGFloat)moveX isCancleOrEnd:(BOOL)isCancleOrEnd {
    if (moveX - self.containController.view.width > 0) {
        return;
    }
    if (isCancleOrEnd) {//结束 清空开始x
        objc_setAssociatedObject(self.containController, ZTHSlideBegainX, nil, OBJC_ASSOCIATION_COPY);
        if (self.containController.view.x > -self.containController.view.width/2) {
            [UIView animateWithDuration:0.1 animations:^{
                self.containController.view.x = 0;
            } completion:^(BOOL finished) {//显示完成
            }];
        }else{
            [UIView animateWithDuration:0.1 animations:^{//消失完成
                self.containController.view.x = -self.containController.view.width;
            } completion:^(BOOL finished) {
                [self.containController dismissViewControllerAnimated:NO completion:nil] ;
                [self.slideTransition clearData];
            }];
        }
        return;
    }else{//拖拽
        self.containController.view.x = moveX - self.containController.view.width;
    }
}

//挡板拖拽手势
- (void)handleGesture:(UIPanGestureRecognizer *)pan {
    CGPoint touchPoint = [pan locationInView: [[UIApplication sharedApplication] keyWindow]];
    if (pan.state == UIGestureRecognizerStateBegan) {//开始
        _isMoving = YES;
        _startTouch = touchPoint;
    }else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled){
        if (self.containController.view.x > -self.containController.view.width/2) {//显示完成
            [UIView animateWithDuration:0.1 animations:^{
                self.containController.view.x = 0;
            } completion:^(BOOL finished) {
                _isMoving = NO;
            }];
        }else{
            [UIView animateWithDuration:0.1 animations:^{//消失完成
                self.containController.view.x = -self.containController.view.width;
            } completion:^(BOOL finished) {
                _isMoving = NO;
                [self.containController dismissViewControllerAnimated:NO completion:nil] ;
                [self.slideTransition clearData];
            }];
        }
        return;
    }
     if ( _isMoving ){//拖拽
        [self moveViewWithX:touchPoint.x - _startTouch.x];
    }
}

//开始移动
- (void)moveViewWithX:(float)x {
    //view已经移动到了最右边或最左边不需要执行任何操作了
    if (x > 0 || x < - [UIScreen mainScreen].bounds.size.width) {
        return;
    }
    self.containController.view.x = x;
}

+ (void)releaseInstance{
    [zth_mask_shareInstance removeFromSuperview];
    zth_mask_onceToken = 0;
    zth_mask_shareInstance = nil;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"containController.view.x"];
//    NSLog(@"mask dealloc");
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 两个Pan手势不能同时触发
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    } else {
        return NO;
    }
}

//是否允许侧滑手势开始,左视图上拖拽也可以滑动
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    BOOL isPanGesture = [self.pan isEqual:gestureRecognizer] || [self.leftViewPan isEqual:gestureRecognizer];
    if (!isPanGesture) {//非self.pan 拖拽手势,不特殊处理
        return YES;
    }
    if ([self.pan isEqual:gestureRecognizer]) {//蒙版上的手势
        CGPoint point = [gestureRecognizer velocityInView:self];
        // 如果y轴的分量过大，那么不启用效果
        if ((fabs(point.y) > fabs(point.x) / 2)) {
            return NO;
        }
    }else if ([self.leftViewPan isEqual:gestureRecognizer]) {//左视图手势
        CGPoint point = [gestureRecognizer velocityInView:self.containController.view];
        // y轴的分量过大，那么不启用效果
        if ((fabs(point.y) > fabs(point.x) / 2)) {
            return NO;
        }
        //触摸点
        CGPoint pointNow = [gestureRecognizer locationInView:[UIApplication sharedApplication].keyWindow];
        if (pointNow.x < [UIScreen mainScreen].bounds.size.width/2) {//可以设置允许的滑动范围,左半边不可以
            return NO;
        }
    }
    return YES;
}

@end


