
//
//  LTPhotoBrowserDefine.h
//  LTPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+LTExtension.h"
#import "UIView+LTExtension.h"
#import "SDImageCache.h"

#define LTPhotoBrowserBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]
#define BaseTag 100
// browser 图片间的margin
#define LTPhotoBrowserImageViewMargin 10
// browser中显示图片动画时长
#define LTPhotoBrowserShowImageAnimationDuration 0.4f
// browser中隐藏图片动画时长
#define LTPhotoBrowserHideImageAnimationDuration 0.4f
#define kSCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define kSCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

// 网络图片加载失败的提示文字
#define LTPhotoBrowserLoadNetworkImageFail @">_< 图片加载失败"
#define LTPhotoBrowserLoadingImageText @">_< 图片加载中,请稍后"

typedef NS_ENUM(NSUInteger, LTPhotoBrowserStyle) {
    /**
     *  长按弹出功能组件，底部一个pageControl
     */
    LTPhotoBrowserStylePageControl = 0,
    /**
     *  长按弹出功能组件，顶部一个索引UILabel
     */
    LTPhotoBrowserStyleIndexLabel,
    /**
     *  没有长按功能，顶部一个索引UILabel，底部一个保存图片按钮
     */
    LTPhotoBrowserStyleSimple
};

typedef NS_ENUM(NSUInteger, LTPhotoBrowserPageControlStyle) {
    /**
     * 系统自带经典样式
     */
    LTPhotoBrowserPageControlStyleClassic = 1,
    /**
     *  动画效果pagecontrol
     */
    LTPhotoBrowserPageControlStyleAnimated = 2,
    /**
     *  不显示pagecontrol
     */
    LTPhotoBrowserPageControlStyleNone = 3
};

typedef NS_ENUM(NSUInteger, LTPhotoBrowserPageControlAliment) {
    /**
     * 左边
     */
    LTPhotoBrowserPageControlAlimentLeft = 1,
    /**
     *  中间
     */
    LTPhotoBrowserPageControlAlimentCenter = 2,
    /**
     *  右边
     */
    LTPhotoBrowserPageControlAlimentRight = 3
};
