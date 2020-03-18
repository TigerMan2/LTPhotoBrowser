//
//  UIView+TMExtension.h
//  TMPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TMExtension)

@property (nonatomic, assign) CGFloat lt_x;
@property (nonatomic, assign) CGFloat lt_y;
@property (nonatomic, assign) CGFloat lt_height;
@property (nonatomic, assign) CGFloat lt_width;
@property (nonatomic, assign) CGSize lt_size;
@property (nonatomic, assign) CGFloat lt_centerX;
@property (nonatomic, assign) CGFloat lt_centerY;

/**
 *  判断一个控件是否显示在主窗口
 */
- (BOOL)lt_isShowingOnKeyWindow;

/**
 *  通过XIB加载view
 */
+ (instancetype)lt_viewFormXib;

/**
 在view上绘制一个指定width宽度的红色提醒圆点

 @param redX x坐标
 @param redY y坐标
 @param width 宽度
 */
- (void)lt_showRedTipViewInRedX:(CGFloat)redX
                           redY:(CGFloat)redY
                redTipViewWidth:(CGFloat)width;

/**
 在view上绘制一个指定width宽度和指定颜色的提醒圆点

 @param redX x坐标
 @param redY y坐标
 @param width 宽度
 @param backgroundColor 颜色
 */
- (void)lt_showRedTipViewInRedX:(CGFloat)redX
                           redY:(CGFloat)redY
                redTipViewWidth:(CGFloat)width
                backgroundColor:(UIColor *)backgroundColor;

/**
 在view上绘制一个带数字的圆点

 @param redX x坐标
 @param redY y坐标
 @param width 宽度
 @param numberCount 数值
 */
- (void)lt_showRedTipViewWithNumberCountInRedX:(CGFloat)redX
                                          redY:(CGFloat)redY
                               redTipViewWidth:(CGFloat)width
                                   numberCount:(NSInteger)numberCount;

/**
 隐藏红色圆点
 */
- (void)lt_hideRedTipView;

@end

NS_ASSUME_NONNULL_END
