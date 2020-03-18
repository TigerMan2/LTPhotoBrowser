//
//  TMZoomingScrollView.m
//  TMPhotoBrowser
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "TMZoomingScrollView.h"
#import "TMProgressView.h"
#import "TMPhotoBrowserDefine.h"
#import "SDImageCache.h"

@interface TMZoomingScrollView () <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
}

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) TMProgressView *progressView;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, assign) BOOL hasLoadedImage;
@property (nonatomic, strong) NSURL *imageURL;

@end

@implementation TMZoomingScrollView

#pragma mark - initial UI

- (void)awakeFromNib {
    [super awakeFromNib];
    [self didInitailize];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitailize];
    }
    return self;
}

- (void)didInitailize {
    [self addSubview:self.scrollView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:singleTap];
    [self addGestureRecognizer:doubleTap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.stateLabel.bounds = CGRectMake(0, 0, 160, 30);
    self.stateLabel.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    self.progressView.bounds = CGRectMake(0, 0, 40, 40);
    self.progressView.center = self.center;
    self.scrollView.frame = self.bounds;
    
    [self setMaxAndMinZoomScales];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.photoImageView.center = [self centerOfScrollViewContent:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollView.scrollEnabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    self.scrollView.userInteractionEnabled = YES;
}

#pragma mark - private func

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    CGFloat width = self.bounds.size.width / scale;
    CGFloat height = self.bounds.size.height / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

#pragma mark - UITapGestureRecognizer func

- (void)singleTap:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zoomingScrollView:singleTapDetected:)]) {
        [self.delegate zoomingScrollView:self singleTapDetected:gesture];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)gesture {
    if (!self.hasLoadedImage) return;
    
    self.scrollView.userInteractionEnabled = NO;
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint point = [gesture locationInView:gesture.view];
        CGFloat touchX = point.x;
        CGFloat touchY = point.y;
        touchX *= 1/self.scrollView.zoomScale;
        touchY *= 1/self.scrollView.zoomScale;
        touchX += self.scrollView.contentOffset.x;
        touchY += self.scrollView.contentOffset.y;
        CGRect rect = [self zoomRectForScale:self.scrollView.maximumZoomScale withCenter:CGPointMake(touchX, touchY)];
        [self.scrollView zoomToRect:rect animated:YES];
    }
}

#pragma mark - public func

- (void)showImage:(UIImage *)image {
    self.photoImageView.image = image;
    [self setMaxAndMinZoomScales];
    [self setNeedsLayout];
    self.progress = 1.0;
    self.hasLoadedImage = YES;
}

- (void)showHighQualityImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholderImage {
    if (!url) {[self showImage:placeholderImage]; return;}
    
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[url absoluteString]];
    if (cacheImage) {[self showImage:cacheImage]; return;}
    
    self.photoImageView.image = placeholderImage;
    [self setMaxAndMinZoomScales];
    
    __weak typeof(self) wSelf = self;
    [self addSubview:self.progressView];
    self.imageURL = url;
    
    //下载图片
    [self.photoImageView sd_setImageWithURL:url placeholderImage:placeholderImage options:SDWebImageLowPriority | SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wSelf) self = wSelf;
            if ([self.imageURL isEqual:targetURL] && expectedSize > 0) {
                self.progress = (CGFloat)receivedSize / expectedSize;
            }
        });
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        __strong typeof(wSelf) self = wSelf;
        [self.progressView removeFromSuperview];
        if (error) {
            [self setMaxAndMinZoomScales];
            [self addSubview:self.stateLabel];
            NSLog(@"加载图片失败，图片链接：%@  错误信息：%@",imageURL,error);
        } else {
            [self.stateLabel removeFromSuperview];
            [UIView animateWithDuration:0.25 animations:^{
                [self showImage:image];
                [self.photoImageView setNeedsDisplay];
                [self setMaxAndMinZoomScales];
            }];
        }
    }];
}

- (void)resetZoomScale {
    self.scrollView.maximumZoomScale = 1.0;
    self.scrollView.minimumZoomScale = 1.0;
}

/** 根据图片和屏幕比例关系,调整最大和最小伸缩比例 */
- (void)setMaxAndMinZoomScales {
    
    UIImage *image = self.photoImageView.image;
    if (!image || image.size.height == 0) return;
    
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    self.photoImageView.lt_width = self.lt_width;
    self.photoImageView.lt_height = self.lt_width / imageWidthHeightRatio;
    self.photoImageView.lt_x = 0;
    if (self.photoImageView.lt_height > kSCREEN_HEIGHT) {
        self.photoImageView.lt_y = 0;
        self.scrollView.scrollEnabled = YES;
    } else {
        self.photoImageView.lt_y = (kSCREEN_HEIGHT - self.photoImageView.lt_height) * 0.5;
        self.scrollView.scrollEnabled = NO;
    }
    self.scrollView.maximumZoomScale = MAX(kSCREEN_HEIGHT / self.photoImageView.lt_height, 3);
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = 1.0;
    self.scrollView.contentSize = CGSizeMake(self.photoImageView.lt_width, MAX(self.photoImageView.lt_height, kSCREEN_HEIGHT));
}

/** 重用，清理资源 */
- (void)prepareForReuse {
    [self setMaxAndMinZoomScales];
    self.progress = 0;
    self.photoImageView.image = nil;
    self.hasLoadedImage = NO;
    [self.stateLabel removeFromSuperview];
    [self.progressView removeFromSuperview];
}

#pragma mark - setter && getter

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressView.progress = progress;
    if ([self.delegate respondsToSelector:@selector(zoomingScrollView:imageLoadProgress:)]) {
        [self.delegate zoomingScrollView:self imageLoadProgress:progress];
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView addSubview:self.photoImageView];
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = YES;
    }
    return _scrollView;
}

- (TMProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[TMProgressView alloc] init];
        _progressView.progressType = TMProgressViewTypePie;
    }
    return _progressView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont systemFontOfSize:16];
        _stateLabel.textColor = [UIColor whiteColor];
        [_stateLabel setText:TMPhotoBrowserLoadNetworkImageFail];
        _stateLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        _stateLabel.layer.cornerRadius = 5;
        _stateLabel.clipsToBounds = YES;
        _stateLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _stateLabel;
}

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.backgroundColor = [UIColor clearColor];
    }
    return _photoImageView;
}

- (UIImage *)currentImage {
    return self.photoImageView.image;
}

- (UIImageView *)imageView {
    return self.photoImageView;
}

@end
