
//
//  TMPhotoBrowserDefine.h
//  TMPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+TMExtension.h"
#import "UIView+TMExtension.h"
#import "SDImageCache.h"

#define TMPhotoBrowserBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]
#define BaseTag 100
// browser 图片间的margin
#define TMPhotoBrowserImageViewMargin 10
// browser中显示图片动画时长
#define TMPhotoBrowserShowImageAnimationDuration 0.4f
// browser中隐藏图片动画时长
#define TMPhotoBrowserHideImageAnimationDuration 0.4f
#define kSCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define kSCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

// 网络图片加载失败的提示文字
#define TMPhotoBrowserLoadNetworkImageFail @">_< 图片加载失败"
#define TMPhotoBrowserLoadingImageText @">_< 图片加载中,请稍后"

typedef NS_ENUM(NSUInteger, TMPhotoBrowserStyle) {
    /**
     *  长按弹出功能组件，底部一个pageControl
     */
    TMPhotoBrowserStylePageControl = 0,
    /**
     *  长按弹出功能组件，顶部一个索引UILabel
     */
    TMPhotoBrowserStyleIndexLabel,
    /**
     *  没有长按功能，顶部一个索引UILabel，底部一个保存图片按钮
     */
    TMPhotoBrowserStyleSimple
};

typedef NS_ENUM(NSUInteger, TMPhotoBrowserPageControlStyle) {
    /**
     * 系统自带经典样式
     */
    TMPhotoBrowserPageControlStyleClassic = 1,
    /**
     *  动画效果pagecontrol
     */
    TMPhotoBrowserPageControlStyleAnimated = 2,
    /**
     *  不显示pagecontrol
     */
    TMPhotoBrowserPageControlStyleNone = 3
};

typedef NS_ENUM(NSUInteger, TMPhotoBrowserPageControlAliment) {
    /**
     * 左边
     */
    TMPhotoBrowserPageControlAlimentLeft = 1,
    /**
     *  中间
     */
    TMPhotoBrowserPageControlAlimentCenter = 2,
    /**
     *  右边
     */
    TMPhotoBrowserPageControlAlimentRight = 3
};
