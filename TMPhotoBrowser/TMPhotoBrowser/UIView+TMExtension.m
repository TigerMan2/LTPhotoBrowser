//
//  UIView+TMExtension.m
//  TMPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "UIView+TMExtension.h"
#import <objc/runtime.h>

@implementation UIView (TMExtension)

- (BOOL)lt_isShowingOnKeyWindow {
    
    // 主窗口
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.firstObject;
    
    // 以主窗口左上角为坐标原点，计算self的bounds
    CGRect newFrame = [keyWindow convertRect:self.bounds fromView:self.superview];
    CGRect winBounds = keyWindow.bounds;
    
    // 主窗口的bounds 和 self的bounds是否有重叠
    BOOL intersects = CGRectIntersectsRect(newFrame, winBounds);
    
    return !self.isHidden && self.alpha > 0.01 && self.window == keyWindow && intersects;
    
}

+ (instancetype)lt_viewFormXib {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].firstObject;
}

static char RedTipViewKey;
- (UILabel *)redTipView {
    return objc_getAssociatedObject(self, &RedTipViewKey);
}

- (void)setRedTipView:(UILabel *)redTipView {
    objc_setAssociatedObject(self, &RedTipViewKey, redTipView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)lt_showRedTipViewInRedX:(CGFloat)redX redY:(CGFloat)redY redTipViewWidth:(CGFloat)width {
    [self lt_showRedTipViewInRedX:redX redY:redY redTipViewWidth:width backgroundColor:[UIColor redColor]];
}

- (void)lt_showRedTipViewInRedX:(CGFloat)redX redY:(CGFloat)redY redTipViewWidth:(CGFloat)width backgroundColor:(UIColor *)backgroundColor {
    if (!self.redTipView) {
        self.redTipView = [[UILabel alloc] init];
        self.redTipView.backgroundColor = backgroundColor;
        self.redTipView.lt_width = width;
        self.redTipView.lt_height = width;
        self.redTipView.layer.cornerRadius = width * 0.5;
        self.redTipView.layer.masksToBounds = YES;
        [self insertSubview:self.redTipView atIndex:self.subviews.count];
    }
    [self bringSubviewToFront:self.redTipView];
    self.redTipView.lt_x = redX;
    self.redTipView.lt_y = redY;
    self.redTipView.hidden = NO;
}

- (void)lt_showRedTipViewWithNumberCountInRedX:(CGFloat)redX redY:(CGFloat)redY redTipViewWidth:(CGFloat)width numberCount:(NSInteger)numberCount {
    if (!self.redTipView) {
        self.redTipView = [[UILabel alloc] init];
        self.redTipView.backgroundColor = [UIColor redColor];
    }
    self.redTipView.lt_x = redX;
    self.redTipView.lt_y = redY;
    self.redTipView.text = [NSString stringWithFormat:@"%zd",numberCount];
    self.redTipView.textAlignment = NSTextAlignmentCenter;
    self.redTipView.textColor = [UIColor whiteColor];
    self.redTipView.font = [UIFont systemFontOfSize:13];
    [self.redTipView sizeToFit];
    self.redTipView.lt_width += 8.5;
    self.redTipView.layer.cornerRadius = self.redTipView.lt_width * 0.5;
    self.redTipView.layer.masksToBounds = YES;
    [self insertSubview:self.redTipView atIndex:self.subviews.count];
    self.redTipView.hidden = NO;
}

- (void)lt_hideRedTipView {
    self.redTipView.hidden = YES;
}

#pragma mark - 计算frame
- (CGFloat)lt_x {
    return self.frame.origin.x;
}

- (void)setLt_x:(CGFloat)lt_x {
    CGRect frame = self.frame;
    frame.origin.x = lt_x;
    self.frame = frame;
}

- (CGFloat)lt_y {
    return self.frame.origin.y;
}

- (void)setLt_y:(CGFloat)lt_y {
    CGRect frame = self.frame;
    frame.origin.y = lt_y;
    self.frame = frame;
}

- (CGFloat)lt_width {
    return self.frame.size.width;
}

- (void)setLt_width:(CGFloat)lt_width {
    CGRect frame = self.frame;
    frame.size.width = lt_width;
    self.frame = frame;
}

- (CGFloat)lt_height {
    return self.frame.size.height;
}

- (void)setLt_height:(CGFloat)lt_height {
    CGRect frame = self.frame;
    frame.size.height = lt_height;
    self.frame = frame;
}

- (CGSize)lt_size {
    return self.frame.size;
}

- (void)setLt_size:(CGSize)lt_size {
    CGRect frame = self.frame;
    frame.size = lt_size;
    self.frame = frame;
}

- (CGFloat)lt_centerX {
    return self.center.x;
}

- (void)setLt_centerX:(CGFloat)lt_centerX {
    CGPoint center = self.center;
    center.x = lt_centerX;
    self.center = center;
}

- (CGFloat)lt_centerY {
    return self.center.y;
}

- (void)setLt_centerY:(CGFloat)lt_centerY {
    CGPoint center = self.center;
    center.y = lt_centerY;
    self.center = center;
}

@end
