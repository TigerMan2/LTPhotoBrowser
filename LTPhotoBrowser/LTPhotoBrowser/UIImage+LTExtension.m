//
//  UIImage+LTExtension.m
//  LTPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "UIImage+LTExtension.h"

@implementation UIImage (LTExtension)

+ (UIImage *)lt_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (size.width <= 0) {
        size = CGSizeMake(3, 3);
    }
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
