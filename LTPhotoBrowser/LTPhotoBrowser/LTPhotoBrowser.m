//
//  LTPhotoBrowser.m
//  LTPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "LTPhotoBrowser.h"
#import "LTZoomingScrollView.h"
#import "LTPageControl.h"

@interface LTPhotoBrowser () <LTZoomingScrollViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIWindow *photoBrowserWindow;
/**
 *  存放所有图片的容器
 */
@property (nonatomic, strong) UIScrollView *scrollView;
/**
 *  保存图片时展示的加载菊花
 */
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
/**
 *  保存图片结果的UILabel
 */
@property (nonatomic, strong) UILabel *saveImageTipLabel;
/**
 *  正在使用的LTZoomingScrollView对象集
 */
@property (nonatomic, strong) NSMutableSet *visibleZoomingScrollViews;
/**
 *  循环利用池中的LTZoomingScrollView对象集,用于循环利用
 */
@property (nonatomic, strong) NSMutableSet *reusableZoomingScrollViews;
/**
 *  pageControl
 */
@property (nonatomic, strong) UIControl *pageControl;
/**
 *  索引UILabel
 */
@property (nonatomic, strong) UILabel *indexLabel;
/**
 *  保存按钮
 */
@property (nonatomic, strong) UIButton *saveButton;
/**
 *  图片集合
 */
@property (nonatomic, strong) NSArray *images;

@property (nonatomic, assign) CGSize pageControlDotSize;

@end

@implementation LTPhotoBrowser

#pragma mark    -   initial

- (void)awakeFromNib {
    [super awakeFromNib];
    [self didInitialize];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.backgroundColor = LTPhotoBrowserBackgroundColor;
    self.visibleZoomingScrollViews = [[NSMutableSet alloc] init];
    self.reusableZoomingScrollViews = [[NSMutableSet alloc] init];
    [self placeholderImage];
    
    _pageControlAliment = LTPhotoBrowserPageControlAlimentCenter;
    _pageControlStyle = LTPhotoBrowserPageControlStyleAnimated;
    _pageControlDotSize = CGSizeMake(10, 10);
    _hidesForSinglePage = YES;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _browserStyle = LTPhotoBrowserStylePageControl;
    
    self.currentIndex = 0;
    self.imageCount = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

- (void)setupUI {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];
    
    //如果刚进入的时候是0,不会调用scrollViewDidScroll:方法,不会展示第一张图片
    if (self.currentIndex == 0) {
        [self showPhotos];
    }
    
    [self setupPageControl];
    
    //index UILabel
    UILabel *indexLabel = [[UILabel alloc] init];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.font = [UIFont systemFontOfSize:18.0f];
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indexLabel.clipsToBounds = YES;
    self.indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
    //saveBtn
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setBackgroundColor:[UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.9f]];
    saveBtn.layer.cornerRadius = 5;
    saveBtn.clipsToBounds = YES;
    [saveBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton = saveBtn;
    [self addSubview:saveBtn];
    
    [self showFirstImage];
    [self updateIndexContent];
    [self updateIndexVisible];
    
}

- (void)dealloc
{
    [self.visibleZoomingScrollViews removeAllObjects];
    [self.reusableZoomingScrollViews removeAllObjects];
}

#pragma mark    -   layout

- (void)orientationDidChange {
    self.scrollView.delegate = nil;//旋转期间，禁止scrollView的代理事件
    LTZoomingScrollView *temp = [self zoomingScrollViewForIndex:self.currentIndex];
    [temp.scrollView setZoomScale:1.0 animated:YES];
    [self updateFrames];
    self.scrollView.delegate = self;
}

- (void)updateFrames {
    self.frame = [[UIScreen mainScreen] bounds];
    CGRect rect = self.bounds;
    rect.size.width += LTPhotoBrowserImageViewMargin;
    self.scrollView.frame = rect;
    self.scrollView.lt_x = 0;
    self.scrollView.contentSize = CGSizeMake((self.scrollView.lt_width * self.imageCount), 0);
    self.scrollView.contentOffset = CGPointMake(self.currentIndex * self.scrollView.lt_width, 0);
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag >= BaseTag) {
            obj.frame = CGRectMake(self.scrollView.lt_width * (obj.tag - BaseTag), 0, self.lt_width, self.lt_height);
        }
    }];
    
    self.saveButton.frame = CGRectMake(30, self.lt_height - 70, 50, 25);
    self.indexLabel.bounds = CGRectMake(0, 0, 80, 30);
    self.indexLabel.lt_centerX = self.lt_width * 0.5;
    self.indexLabel.lt_centerY = 35;
    self.indexLabel.layer.cornerRadius = self.indexLabel.lt_height * 0.5;
    
    self.saveImageTipLabel.layer.cornerRadius = 5;
    self.saveImageTipLabel.clipsToBounds = YES;
    [self.saveImageTipLabel sizeToFit];
    self.saveImageTipLabel.lt_height = 30;
    self.saveImageTipLabel.lt_width += 20;
    self.saveImageTipLabel.center = self.center;
    
    self.indicatorView.center = self.center;
    
    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[LTPageControl class]]) {
        LTPageControl *pageControl = (LTPageControl *)self.pageControl;
        size = [pageControl sizeForNumberOfPages:self.imageCount];
        BOOL hidden = pageControl.hidden;
        [pageControl sizeToFit];
        pageControl.hidden = hidden;
    } else {
        size = CGSizeMake(self.pageControlDotSize.width * self.imageCount * 1.2, self.pageControlDotSize.height);
    }
    CGFloat x;
    switch (self.pageControlAliment) {
        case LTPhotoBrowserPageControlAlimentLeft:
        {
            x = 20;
        }
            break;
        case LTPhotoBrowserPageControlAlimentCenter:
        {
            x = (self.lt_width - size.width) * 0.5;
        }
            break;
        case LTPhotoBrowserPageControlAlimentRight:
        {
            x = self.lt_width - size.width - 20;
        }
            break;
            
        default:
            break;
    }
    CGFloat y = self.lt_height - size.height - 10;
    self.pageControl.frame = CGRectMake(x, y, size.width, size.height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFrames];
}

#pragma mark    -   private loadimage

- (void)showPhotos {
    
    //只有一张图片
    if (self.imageCount == 1) {
        [self setupImageForZoomingScrollViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = self.scrollView.bounds;
    NSInteger firstIndex = floor(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex = floor((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    
    if (firstIndex >= self.imageCount) {
        firstIndex = self.imageCount - 1;
    }
    
    if (lastIndex < 0) {
        lastIndex = 0;
    }
    
    if (lastIndex >= self.imageCount) {
        lastIndex = self.imageCount - 1;
    }
    
    //回收不再显示的zoomingScrollView
    NSInteger zoomingScrollViewIndex = 0;
    for (LTZoomingScrollView *zoomingScrollView in self.visibleZoomingScrollViews) {
        zoomingScrollViewIndex = zoomingScrollView.tag - BaseTag;
        if (zoomingScrollViewIndex < firstIndex || zoomingScrollViewIndex > lastIndex) {
            [self.reusableZoomingScrollViews addObject:zoomingScrollView];
            [zoomingScrollView prepareForReuse];
            [zoomingScrollView removeFromSuperview];
        }
    }
    
    //_visibleZoomingScrollViews 减去 _reusableZoomingScrollViews中的元素
    [self.visibleZoomingScrollViews minusSet:self.reusableZoomingScrollViews];
    //循环利用池中保持两个可用的对象
    while (self.reusableZoomingScrollViews.count > 2) {
        [self.reusableZoomingScrollViews removeObject:[self.reusableZoomingScrollViews anyObject]];
    }
    
    //展示图片
    for (NSInteger index = firstIndex; index <= lastIndex; index ++) {
        if (![self isShowingZoomingScrollViewAtIndex:index]) {
            [self setupImageForZoomingScrollViewAtIndex:index];
        }
    }
    
}
/**
 *  判断指定位置的图片是否在显示
 */
- (BOOL)isShowingZoomingScrollViewAtIndex:(NSInteger)index {
    for (LTZoomingScrollView *zoomScrollView in self.visibleZoomingScrollViews) {
        if (zoomScrollView.tag - BaseTag == index) {
            return YES;
        }
    }
    return NO;
}
/**
 *  获取指定位置的LTZoomingScrollView对象，显示池，回收池，创建新对象
 */
- (LTZoomingScrollView *)zoomingScrollViewForIndex:(NSInteger)index {
    for (LTZoomingScrollView *zoomingScrollView in self.visibleZoomingScrollViews) {
        if (zoomingScrollView.tag - BaseTag == index) {
            return zoomingScrollView;
        }
    }
    LTZoomingScrollView *zoomingScrollView = [self dequeueReusableZoomingScrollView];
    [self setupImageForZoomingScrollViewAtIndex:index];
    return zoomingScrollView;
}
/**
 *  加载指定位置的图片
 */
- (void)setupImageForZoomingScrollViewAtIndex:(NSInteger)index {
    
    LTZoomingScrollView *zoomingScrollView = [self dequeueReusableZoomingScrollView];
    zoomingScrollView.delegate = self;
    [zoomingScrollView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    zoomingScrollView.tag = BaseTag + index;
    zoomingScrollView.frame = CGRectMake((self.scrollView.lt_width) * index, 0, self.lt_width, self.lt_height);
    self.currentIndex = index;
    if ([self highQualityImageURLForIndex:index]) { //加载高清图片
        [zoomingScrollView showHighQualityImageWithUrl:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else if ([self assetForIndex:index]) {
        ALAsset *asset = [self assetForIndex:index];
        CGImageRef imageRef = asset.defaultRepresentation.fullScreenImage;
        [zoomingScrollView showImage:[UIImage imageWithCGImage:imageRef]];
        CGImageRelease(imageRef);
    } else {
        [zoomingScrollView showImage:[self placeholderImageForIndex:index]];
    }
    [self.visibleZoomingScrollViews addObject:zoomingScrollView];
    [self.scrollView addSubview:zoomingScrollView];
}
/**
 *  从缓存池中获取一个LTZoomingScrollView对象
 */
- (LTZoomingScrollView *)dequeueReusableZoomingScrollView {
    LTZoomingScrollView *photoView = [self.reusableZoomingScrollViews anyObject];
    if (photoView) {
        [self.reusableZoomingScrollViews removeObject:photoView];
    } else {
        photoView = [[LTZoomingScrollView alloc] init];
    }
    return photoView;
}
/**
 *  获取指定位置高清大图的URL
 */
- (NSURL *)highQualityImageURLForIndex:(NSInteger)index {
    
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:highQualityImageForIndex:)]) {
        NSURL *url = [self.datasource photoBrowser:self highQualityImageForIndex:index];
        if (!url) {
            NSLog(@"高清大图URL为空, 请检查, 图片索引是: %zd",index);
            return nil;
        }
        if ([url isKindOfClass:[NSString class]]) {
            url = [NSURL URLWithString:(NSString *)url];
        }
        if (![url isKindOfClass:[NSURL class]]) {
            NSLog(@"高清大图的URL有问题, 问题数据为:%@, 图片索引为:%zd",url,index);
            return nil;
        }
        return url;
    } else if (self.images.count > index) {
        if ([self.images[index] isKindOfClass:[NSURL class]]) {
            return self.images[index];
        } else if ([self.images[index] isKindOfClass:[NSString class]]) {
            return [NSURL URLWithString:((NSString *)self.images[index])];
        }
        return nil;
    }
    return nil;
}
/**
 *  获取指定位置占位图
 */
- (UIImage *)placeholderImageForIndex:(NSInteger)index {
    
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.datasource photoBrowser:self placeholderImageForIndex:index];
    } else if (self.images.count > index) {
        if ([self.images[index] isKindOfClass:[UIImage class]]) {
            return self.images[index];
        } else {
            return self.placeholderImage;
        }
    }
    return self.placeholderImage;
}
/**
 *  获取指定位置的ALAsset对象
 */
- (ALAsset *)assetForIndex:(NSInteger)index {
    
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:assetForIndex:)]) {
        return [self.datasource photoBrowser:self assetForIndex:index];
    } else if (self.images.count > index) {
        if ([self.images[index] isKindOfClass:[ALAsset class]]) {
            return self.images[index];
        } else {
            return nil;
        }
    }
    return nil;
}
/**
 *  第一个展示的图片，点击图片，放大动画执行
 */
- (void)showFirstImage {
    
    //获取点击的UIImageView,进行坐标转换
    CGRect startRect;
    if (!self.sourceImageView) {
        if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:sourceImageViewForIndex:)]) {
            self.sourceImageView = [self.datasource photoBrowser:self sourceImageViewForIndex:self.currentIndex];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 1.0;
            }];
            NSLog(@"需要提供源视图才能做弹出/退出图片浏览器的缩放动画");
            return;
        }
    }
    
    startRect = [self.sourceImageView.superview convertRect:self.sourceImageView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentIndex];
    tempView.frame = startRect;
    [self addSubview:tempView];
    
    //目标frame
    CGRect targetRect;
    UIImage *image = self.sourceImageView.image;
    if (!image) {
        NSLog(@"需要提供源视图才能做弹出/退出图片浏览器的缩放动画");
        return;
    }
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    CGFloat width = kSCREEN_WIDTH;
    CGFloat height = width / imageWidthHeightRatio;
    CGFloat x = 0;
    CGFloat y;
    if (height > kSCREEN_HEIGHT) {
        y = 0;
    } else {
        y = (kSCREEN_HEIGHT - height) * 0.5;
    }
    targetRect = CGRectMake(x, y, width, height);
    self.scrollView.hidden = YES;
    self.alpha = 1.0;
    
    // 动画修改图片的frame，居中同时放大
    [UIView animateWithDuration:LTPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.frame = targetRect;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
}

/**
 *  获取多图浏览,指定位置图片的UIImageView视图,用于做弹出放大动画和回缩动画
 */
- (UIView *)sourceImageViewForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:sourceImageViewForIndex:)]) {
        return [self.datasource photoBrowser:self sourceImageViewForIndex:index];
    }
    return nil;
}

#pragma mark    -   长按图片

- (void)longPress:(UILongPressGestureRecognizer *)gesture {
    NSLog(@"长按图片操作...");
}

#pragma mark    -   UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
    NSInteger pageNum = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    self.currentIndex = pageNum == self.imageCount ? pageNum - 1 : pageNum;
    [self updateIndexContent];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger pageNum = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    self.currentIndex = pageNum == self.imageCount ? pageNum - 1 : pageNum;
    [self updateIndexContent];
}

#pragma mark    -   LTZoomingScrollViewDelegate

- (void)zoomingScrollView:(LTZoomingScrollView *)zoomingScrollView imageLoadProgress:(CGFloat)progress {
    
}

- (void)zoomingScrollView:(LTZoomingScrollView *)zoomingScrollView singleTapDetected:(UITapGestureRecognizer *)singleTap {
    
    [UIView animateWithDuration:0.15 animations:^{
        self.saveImageTipLabel.alpha = 0.0;
        self.indicatorView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.saveImageTipLabel removeFromSuperview];
        [self.indicatorView removeFromSuperview];
    }];
    
    NSInteger currentIndex = zoomingScrollView.tag - BaseTag;
    UIView *sourceView = [self sourceImageViewForIndex:currentIndex];
    if (sourceView == nil) {
        [self dismiss];
        return;
    }
    self.scrollView.hidden = YES;
    self.pageControl.hidden = YES;
    self.indexLabel.hidden = YES;
    self.saveButton.hidden = YES;
    
    CGRect targetTemp = [sourceView.superview convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = zoomingScrollView.currentImage;
    tempView.frame = CGRectMake( - zoomingScrollView.scrollView.contentOffset.x + zoomingScrollView.imageView.lt_x,  - zoomingScrollView.scrollView.contentOffset.y + zoomingScrollView.imageView.lt_y, zoomingScrollView.imageView.lt_width, zoomingScrollView.imageView.lt_height);
    [self addSubview:tempView];
    
    [UIView animateWithDuration:LTPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

#pragma mark    -   public func

/**
 快速创建图片浏览器对象

 @param currentImageIndex 当前图片索引
 @param imageCount 图片数量
 @param datasource 代理
 @return 图片浏览器对象
 */
+ (instancetype)showPhotoBrowserWithCurrentImageIndex:(NSInteger)currentImageIndex imageCount:(NSInteger)imageCount datasource:(id<LTPhotoBrowserDatasource>)datasource {
    LTPhotoBrowser *browser = [[LTPhotoBrowser alloc] init];
    browser.imageCount = imageCount;
    browser.currentIndex = currentImageIndex;
    browser.datasource = datasource;
    [browser show];
    return browser;
}

/**
 快速创建图片浏览器对象

 @param images 图片集合
 @param currentImageIndex 当前图片索引
 @return 图片浏览器对象
 */
+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex
{
    if (images.count <=0 || images ==nil) {
        NSLog(@"一行代码展示图片浏览的方法,传入的数据源为空,请检查传入数据源");
        return nil;
    }
    
    //检查数据源对象是否非法
    for (id image in images) {
        if (![image isKindOfClass:[UIImage class]] && ![image isKindOfClass:[NSString class]] && ![image isKindOfClass:[NSURL class]] && ![image isKindOfClass:[ALAsset class]]) {
            NSLog(@"识别到非法数据格式,请检查传入数据是否为 NSString/NSURL/ALAsset 中一种");
            return nil;
        }
    }
    
    LTPhotoBrowser *browser = [[LTPhotoBrowser alloc] init];
    browser.imageCount = images.count;
    browser.currentIndex = currentImageIndex;
    browser.images = images;
    [browser show];
    return browser;
}

- (void)show {
    
    if (self.imageCount <= 0) return;
    
    if (self.currentIndex >= self.imageCount) {
        self.currentIndex = self.imageCount - 1;
    }
    
    if (self.currentIndex < 0) {
        self.currentIndex = 0;
    }
    
    self.frame = self.photoBrowserWindow.bounds;
    self.alpha = 0.0;
    [self.photoBrowserWindow.rootViewController.view addSubview:self];
    [self.photoBrowserWindow makeKeyAndVisible];
    [self setupUI];
}

- (void)dismiss {
    [UIView animateWithDuration:LTPhotoBrowserHideImageAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.photoBrowserWindow = nil;
    }];
}

#pragma mark - getter && setter

- (UILabel *)saveImageTipLabel {
    if (!_saveImageTipLabel) {
        _saveImageTipLabel = [[UILabel alloc] init];
        _saveImageTipLabel.font = [UIFont systemFontOfSize:17];
        _saveImageTipLabel.textColor = [UIColor whiteColor];
        _saveImageTipLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.9f];
        _saveImageTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _saveImageTipLabel;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return _indicatorView;
}

- (UIImage *)placeholderImage {
    if (!_placeholderImage) {
        _placeholderImage = [UIImage lt_imageWithColor:[UIColor grayColor] size:CGSizeMake(100, 100)];
    }
    return _placeholderImage;
}

- (UIWindow *)photoBrowserWindow {
    if (!_photoBrowserWindow) {
        _photoBrowserWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _photoBrowserWindow.windowLevel = MAXFLOAT;
        UIViewController *tempVC = [[UIViewController alloc] init];
        tempVC.view.backgroundColor = LTPhotoBrowserBackgroundColor;
        
        _photoBrowserWindow.rootViewController = tempVC;
    }
    return _photoBrowserWindow;
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor {
    _currentPageDotColor = currentPageDotColor;
    if ([self.pageControl isKindOfClass:[LTPageControl class]]) {
        LTPageControl *pageControl = (LTPageControl *)self.pageControl;
        pageControl.dotColor = currentPageDotColor;
    } else {
        UIPageControl *pageControl = (UIPageControl *)self.pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
}

- (void)setPageDotColor:(UIColor *)pageDotColor {
    _pageDotColor = pageDotColor;
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)self.pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage {
    _currentPageDotImage = currentPageDotImage;
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentPageDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage {
    _pageDotImage = pageDotImage;
    [self setCustomPageControlDotImage:pageDotImage isCurrentPageDot:NO];
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentPageDot:(BOOL)isCurrentPageDot {
    if (!image || !self.pageControl) return;
    
    if ([self.pageControl isKindOfClass:[LTPageControl class]]) {
        LTPageControl *pageControl = (LTPageControl *)self.pageControl;
        if (isCurrentPageDot) {
            pageControl.currentDotImage = image;
        } else {
            pageControl.dotImage = image;
        }
    } else {
        UIPageControl *pageControl = (UIPageControl *)self.pageControl;
        if (isCurrentPageDot) {
            [pageControl setValue:image forKey:@"_currentPageImage"];
        } else {
            [pageControl setValue:image forKey:@"_pageImage"];
        }
    }
}

- (void)setPageControlStyle:(LTPhotoBrowserPageControlStyle)pageControlStyle {
    _pageControlStyle = pageControlStyle;
    [self setupPageControl];
    [self updateIndexVisible];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    _hidesForSinglePage = hidesForSinglePage;
    [self updateIndexVisible];
}

- (void)setBrowserStyle:(LTPhotoBrowserStyle)browserStyle {
    _browserStyle = browserStyle;
    [self updateIndexVisible];
}

- (void)setPageControlAliment:(LTPhotoBrowserPageControlAliment)pageControlAliment {
    _pageControlAliment = pageControlAliment;
    switch (pageControlAliment) {
        case LTPhotoBrowserPageControlAlimentLeft:
        {
            self.pageControl.lt_x = 20;
        }
            break;
        case LTPhotoBrowserPageControlAlimentCenter:
        {
            self.pageControl.lt_x = (self.lt_width - self.pageControl.lt_width) - 20;
        }
            break;
        case LTPhotoBrowserPageControlAlimentRight:
        {
            self.pageControl.lt_x = (self.lt_width - self.pageControl.lt_width) * 0.5;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark    -   UIPageControl

- (void)setupPageControl {
    
    if (_pageControl) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
    }
    
    switch (self.pageControlStyle) {
        case LTPhotoBrowserPageControlStyleClassic:
        {
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.currentPage = self.currentIndex;
            pageControl.numberOfPages = self.imageCount;
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            pageControl.userInteractionEnabled = NO;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        case LTPhotoBrowserPageControlStyleAnimated:
        {
            LTPageControl *pageControl = [[LTPageControl alloc] init];
            pageControl.currentPage = self.currentIndex;
            pageControl.numberOfPages = self.imageCount;
            pageControl.dotColor = self.currentPageDotColor;
            pageControl.userInteractionEnabled = NO;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        default:
            break;
    }
    
    //重设pageControl的图片
    self.currentPageDotImage = self.currentPageDotImage;
    self.pageDotImage = self.pageDotImage;
}

#pragma mark    -   图片索引的显示内容和显隐逻辑

/**
 *  更新索引指示控件的显隐
 */
- (void)updateIndexVisible {
    
    switch (self.browserStyle) {
        case LTPhotoBrowserStylePageControl:
        {
            self.pageControl.hidden = NO;
            self.indexLabel.hidden = YES;
            self.saveButton.hidden = YES;
        }
            break;
        case LTPhotoBrowserStyleIndexLabel:
        {
            self.indexLabel.hidden = NO;
            self.pageControl.hidden = YES;
            self.saveButton.hidden = YES;
        }
            break;
        case LTPhotoBrowserStyleSimple:
        {
            self.indexLabel.hidden = NO;
            self.saveButton.hidden = NO;
            self.pageControl.hidden = YES;
        }
            break;
            
        default:
            break;
    }
    
    if (self.images.count == 1 && self.hidesForSinglePage) {
        self.indexLabel.hidden = YES;
        self.pageControl.hidden = YES;
    }
}

/**
 *  更新索引UILabel的内容
 */
- (void)updateIndexContent {
    UIPageControl *pageControl = (UIPageControl *)self.pageControl;
    pageControl.currentPage = self.currentIndex;
    NSString *title = [NSString stringWithFormat:@"%zd / %zd",self.currentIndex + 1,self.imageCount];
    self.indexLabel.text = title;
}

@end
