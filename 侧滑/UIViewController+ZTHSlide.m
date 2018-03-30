//
//  UIViewController+ZTHSlide.m
//  侧滑
//
//  Created by jiangdong on 2018/3/28.
//  Copyright © 2018年 jiangdong. All rights reserved.
//

#import "UIViewController+ZTHSlide.h"
#import "ZTHSlideTransition.h"
#import <objc/runtime.h>
#import "UIView+QDMailAdditions.h"


//拖拽手势
static const char *ZTHSlidePanGestureKey = "ZTHSlidePanGestureKey";
//拖拽block
static const char *ZTHSlideActionBlockKey = "ZTHSlideActionBlockKey";

@implementation UIViewController (ZTHSlide)

//点击动画
- (void)zth_showSlideController:(UIViewController *)controller {
    //转场动画
    ZTHSlideTransition *slideTransition = objc_getAssociatedObject(self, ZTHSlideTransitionKey);
    if (!slideTransition) {
        slideTransition = [[ZTHSlideTransition alloc] init];
        objc_setAssociatedObject(self, ZTHSlideTransitionKey, slideTransition, OBJC_ASSOCIATION_RETAIN);
    }
    slideTransition.isDrag = NO;
    controller.transitioningDelegate = slideTransition;
    controller.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:controller animated:YES completion:nil];
}

//给首页加一个拖拽手势
- (void)zth_setPanActionWithBlock:(void (^)(UIPanGestureRecognizer *gesture ,CGFloat moveX,BOOL isCancleOrEnd))block
{
    UIPanGestureRecognizer *gesture = objc_getAssociatedObject(self, ZTHSlidePanGestureKey);
    if (!gesture) {
        gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(__handleActionForPanGesture:)];
        [self.view addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, ZTHSlidePanGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    gesture.delegate = (id<UIGestureRecognizerDelegate>)self;
    objc_setAssociatedObject(self, ZTHSlideActionBlockKey, block, OBJC_ASSOCIATION_COPY);
}

//拖拽手势事件
- (void)__handleActionForPanGesture:(UIPanGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView: [[UIApplication sharedApplication] keyWindow]];
    void(^action)(UIPanGestureRecognizer *gesture,CGFloat moveX,BOOL isCancleOrEnd) = objc_getAssociatedObject(self, ZTHSlideActionBlockKey);
    //拖拽起始x
    NSString *startX = objc_getAssociatedObject(self, ZTHSlideBegainX);
    if (gesture.state == UIGestureRecognizerStateBegan) {//移动开始
        startX = [NSString stringWithFormat:@"%f",touchPoint.x];
        objc_setAssociatedObject(self, ZTHSlideBegainX, startX, OBJC_ASSOCIATION_COPY);
        //x偏移量
        CGFloat x = [gesture translationInView:gesture.view].x;
        if (x < 0) {//只显示右滑
            return;
        }
        if (action) {
            action(gesture, 0, NO);
        }
        return;
    }else if (gesture.state == UIGestureRecognizerStateChanged ) {//移动
        if (action){
            action(nil, touchPoint.x - [startX intValue] ,NO);
        }
    }else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded) {
        //结束
        if (action){
            action(nil, 0 ,YES);
        }
    }
}

//首页拖拽出来的leftController
- (void)zth_showDragSlideController:(UIViewController *)controller gesture:(UIPanGestureRecognizer *)gesture moveX:(CGFloat)moveX isCancleOrEnd:(BOOL)isCancleOrEnd {
    //转场动画
    ZTHSlideTransition *slideTransition = objc_getAssociatedObject(self, ZTHSlideTransitionKey);
    if (!slideTransition) {
        slideTransition = [[ZTHSlideTransition alloc] init];
        objc_setAssociatedObject(self, ZTHSlideTransitionKey, slideTransition, OBJC_ASSOCIATION_RETAIN);
    }
    slideTransition.isDrag = YES;
    controller.transitioningDelegate = slideTransition;
    controller.modalPresentationStyle = UIModalPresentationCustom;
    if (gesture) {//刚开始滑动
        [self presentViewController:controller animated:YES completion:nil];
    }else{//拖拽或取消
        [slideTransition.maskView drag:moveX isCancleOrEnd:isCancleOrEnd gesture:gesture];
    }
}

#pragma mark UIGestureRecognizerDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
//是否允许侧滑手势开始
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UIPanGestureRecognizer *gesture = objc_getAssociatedObject(self, ZTHSlidePanGestureKey);
    BOOL isPanGesture = ([gesture isEqual:gestureRecognizer]);
    if (!isPanGesture) {//非self.pan 拖拽手势,不特殊处理
        return YES;
    }
    
    CGPoint point = [gesture velocityInView:self.view];
    // 如果是向左滑动，或者y轴的分量过大，那么不启用效果
    if ((point.x < 0 || fabs(point.y) > fabs(point.x) / 2)) {
        return NO;
    }
    //处理view上有左右滑动scrollView时特殊情况
    if ([self respondsToSelector:@selector(ZTHSliderPanEnabled:)]) {
        if ([self performSelector:@selector(ZTHSliderPanEnabled:) withObject:gestureRecognizer] == NO) {
            return NO;
        }
    }
    return YES;
}

#pragma clang diagnostic pop

//允许多个手势同时响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // 两个Pan手势不能同时触发
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    } else {
        return NO;
    }
}

//左视图关闭没有动画
- (void)closeLeftControllerNoAnimation {
    ZTHSlideTransition *slideTransition = objc_getAssociatedObject(self, ZTHSlideTransitionKey);
    if (slideTransition) {
        slideTransition.closeAnimaitonTime = 0.02;
        [slideTransition.containController dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
