//
//  UIImage+TMExtension.h
//  TMPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TMExtension)

/**
 根据size绘制一个纯色的图片

 @param color 颜色
 @param size 大小
 @return 绘制的图片
 */
+ (UIImage *)lt_imageWithColor:(UIColor *)color size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
