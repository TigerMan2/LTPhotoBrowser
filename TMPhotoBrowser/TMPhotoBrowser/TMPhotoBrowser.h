//
//  TMPhotoBrowser.h
//  TMPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TMPhotoBrowserDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class TMPhotoBrowser;

@protocol TMPhotoBrowserDelegate <NSObject>

@optional
/**
 点击弹出的功能组件回调

 @param photoBrowser 图片浏览器
 @param actionSheetIndex 点击功能组件索引
 @param currentImageIndex 当前图片索引
 */
- (void)photoBrowser:(TMPhotoBrowser *)photoBrowser clickActionSheetIndex:(NSInteger)actionSheetIndex currentImageIndex:(NSInteger)currentImageIndex;

@end

@protocol TMPhotoBrowserDatasource <NSObject>

@optional

/**
 根据索引返回占位图 也可以是原图。(如果不实现该方法，则使用placeholderImage)

 @param photoBrowser 图片浏览器
 @param index 索引
 @return 占位图
 */
- (UIImage *)photoBrowser:(TMPhotoBrowser *)photoBrowser placeholderImageForIndex:(NSInteger)index;

/**
 根据索引返回高清原图的URL

 @param photoBrowser 图片浏览器
 @param index 索引
 @return 高清原图的URL
 */
- (NSURL *)photoBrowser:(TMPhotoBrowser *)photoBrowser highQualityImageForIndex:(NSInteger)index;

/**
 根据索引返回asset对象

 @param photoBrowser 图片浏览器
 @param index 索引
 @return asset对象
 */
- (ALAsset *)photoBrowser:(TMPhotoBrowser *)photoBrowser assetForIndex:(NSInteger)index;

/**
 根据索引返回图片的imageView，用于图片浏览器的弹入和弹出动画，
 如果没有实现该方法，则没有动画，如果传过来的view有问题，则也没有动画

 @param photoBrowser 图片浏览器
 @param index 索引
 @return 图片的imageView
 */
- (UIImageView *)photoBrowser:(TMPhotoBrowser *)photoBrowser sourceImageViewForIndex:(NSInteger)index;

@end

@interface TMPhotoBrowser : UIView

/**
 *  delegate
 */
@property (nonatomic, weak) id <TMPhotoBrowserDelegate> delegate;
/**
 *  datasource
 */
@property (nonatomic, weak) id <TMPhotoBrowserDatasource> datasource;
/**
 *  点击图片的imageView,没实现此属性，
 *  则会从photoBrowser:sourceImageViewForIndex:方法中获取，如果也获取不到，则图片浏览器的弹出弹入动画没有
 */
@property (nonatomic, strong) UIImageView *sourceImageView;
/**
 *  当前显示图片的索引，默认是0
 */
@property (nonatomic, assign) NSInteger currentIndex;
/**
 *  图片总数量，大于0
 */
@property (nonatomic, assign) NSInteger imageCount;
/**
 *  浏览器弹出的样式，默认是TMPhotoBrowserStylePageControl
 */
@property (nonatomic, assign) TMPhotoBrowserStyle browserStyle;
/**
 *  占位图片，(默认是一张100*100的灰色图像)
 *  没有实现photoBrowser:placeholderImageForIndex:这个方法是，默认会使用这个图片
 */
@property (nonatomic, strong) UIImage *placeholderImage;

#pragma mark - pageControl
/**
 *  只有一张图片时，是否隐藏pageControl，默认是YES
 */
@property (nonatomic, assign) BOOL hidesForSinglePage;
/**
 *  pageControl的样式
 */
@property (nonatomic, assign) TMPhotoBrowserPageControlStyle pageControlStyle;
/**
 *  pageControl的位置，默认TMPhotoBrowserPageControlAlimentCenter
 */
@property (nonatomic, assign) TMPhotoBrowserPageControlAliment pageControlAliment;
/**
 *  当前分页控件小圆标颜色
 */
@property (nonatomic, strong) UIColor *currentPageDotColor;
/**
 *  其他分页控件小圆标颜色
 */
@property (nonatomic, strong) UIColor *pageDotColor;
/**
 *  当前分页控件小圆标图片
 */
@property (nonatomic, strong) UIImage *currentPageDotImage;
/**
 *  其他分页控件小圆标图片
 */
@property (nonatomic, strong) UIImage *pageDotImage;

/**
 快速创建图片浏览器对象
 
 @param images 图片集合
 @param currentImageIndex 当前图片索引
 @return 图片浏览器对象
 */
+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images
                         currentImageIndex:(NSInteger)currentImageIndex;
/**
 快速创建图片浏览器对象
 
 @param currentImageIndex 当前图片索引
 @param imageCount 图片数量
 @param datasource 代理
 @return 图片浏览器对象
 */
+ (instancetype)showPhotoBrowserWithCurrentImageIndex:(NSInteger)currentImageIndex
                                           imageCount:(NSInteger)imageCount
                                           datasource:(id<TMPhotoBrowserDatasource>)datasource;

- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
