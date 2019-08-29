//
//  LTZoomingScrollView.h
//  LTPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LTZoomingScrollView;
@protocol LTZoomingScrollViewDelegate <NSObject>

/**
 单击图像时调用

 @param zoomingScrollView 图片缩放视图
 @param singleTap 单击手势
 */
- (void)zoomingScrollView:(LTZoomingScrollView *)zoomingScrollView singleTapDetected:(UITapGestureRecognizer *)singleTap;

/**
 图片加载进度

 @param zoomingScrollView 图片缩放视图
 @param progress 进度
 */
- (void)zoomingScrollView:(LTZoomingScrollView *)zoomingScrollView imageLoadProgress:(CGFloat)progress;

@end

@interface LTZoomingScrollView : UIView

/** delegate */
@property (nonatomic, weak) id <LTZoomingScrollViewDelegate> delegate;
/** 进度 */
@property (nonatomic, assign) CGFloat progress;
/** 当前展示图片 */
@property (nonatomic, strong, readonly) UIImage *currentImage;
/** 当前展示图片的imageView */
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

/**
 显示图片

 @param url 高清图片的URL
 @param placeholderImage 占位图
 */
- (void)showHighQualityImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;
/**
 显示图片

 @param image 图片
 */
- (void)showImage:(UIImage *)image;
/**
 调整尺寸
 */
- (void)setMaxAndMinZoomScales;
/**
 重用资源
 */
- (void)prepareForReuse;

@end

NS_ASSUME_NONNULL_END
