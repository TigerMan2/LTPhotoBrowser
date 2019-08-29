//
//  LTPageControl.m
//  LTPageControl
//
//  Created by Luther on 2019/8/21.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "LTPageControl.h"
#import "LTDotView.h"
#import "LTAnimatedDotView.h"

@interface LTPageControl ()

@property (nonatomic, strong) NSMutableArray *dots;

@end

@implementation LTPageControl

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initValue];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initValue];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initValue];
    }
    return self;
}

- (void)initValue {
    self.dotViewClass = [LTAnimatedDotView class];
    self.spacingBetweenDot = 8;
    self.numberOfPages = 0;
    self.currentPage = 0;
    self.hidesForSinglePage = NO;
    self.shouldResizeFromCenter = YES;
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view != self) {
        NSInteger index = [self.dots indexOfObject:touch.view];
        if ([self.delegate respondsToSelector:@selector(pageControl:didSelectPageAtIndex:)]) {
            [self.delegate pageControl:self didSelectPageAtIndex:index];
        }
    }
}

#pragma mark - Layout
- (void)sizeToFit {
    [self updateFrame:YES];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
    return CGSizeMake((self.dotSize.width + self.spacingBetweenDot) * pageCount - self.spacingBetweenDot, self.dotSize.height);
}

- (void)resetDotViews {
    for (UIView *dotView in self.dots) {
        [dotView removeFromSuperview];
    }

    [self.dots removeAllObjects];
    [self updateDots];
}

- (void)updateDots {
    if (self.numberOfPages == 0) return;
    
    for (int i = 0; i < self.numberOfPages; i ++) {
        UIView *dot;
        if (i < self.dots.count) {
            dot = [self.dots objectAtIndex:i];
        } else {
            dot = [self generateDotView];
        }
        
        [self updateDotFrame:dot atIndex:i];
    }
    
    [self changeActivity:YES atIndex:self.currentPage];
    
    [self hideForSinglePage];
}

- (void)updateFrame:(BOOL)overrideExistingFrame {
    CGPoint center = self.center;
    CGSize requestSize = [self sizeForNumberOfPages:self.numberOfPages];
    
    if (overrideExistingFrame || ((CGRectGetWidth(self.frame) < requestSize.width || CGRectGetHeight(self.frame) < requestSize.height) && !overrideExistingFrame)) {
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), requestSize.width, requestSize.height);
        if (self.shouldResizeFromCenter) {
            self.center = center;
        }
    }
    
    [self resetDotViews];
}

- (void)updateDotFrame:(UIView *)dot atIndex:(NSInteger)index {
    CGFloat x = (self.dotSize.width + self.spacingBetweenDot) * index + ((CGRectGetWidth(self.frame) - [self sizeForNumberOfPages:self.numberOfPages].width) / 2);
    CGFloat y = (CGRectGetHeight(self.frame) - self.dotSize.height) / 2;
    dot.frame = CGRectMake(x, y, self.dotSize.width, self.dotSize.height);
}

- (void)hideForSinglePage {
    if (self.dots.count == 1 && self.hidesForSinglePage) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
}

#pragma mark - utils
- (UIView *)generateDotView {
    UIView *dotView;
    
    if (self.dotViewClass) {
        dotView = [[self.dotViewClass alloc] initWithFrame:CGRectMake(0, 0, self.dotSize.width, self.dotSize.height)];
        if ([dotView isKindOfClass:[LTAnimatedDotView class]] && self.dotColor) {
            ((LTAnimatedDotView *)dotView).dotColor = self.dotColor;
        }
    } else {
        dotView = [[UIImageView alloc] initWithImage:self.dotImage];
        dotView.frame = CGRectMake(0, 0, self.dotSize.width, self.dotSize.height);
    }
    
    if (dotView) {
        [self addSubview:dotView];
        [self.dots addObject:dotView];
    }
    
    dotView.userInteractionEnabled = YES;
    return dotView;
}

- (void)changeActivity:(BOOL)active atIndex:(NSInteger)index {
    if (self.dotViewClass) {
        LTBaseDotView *dotView = (LTBaseDotView *)[self.dots objectAtIndex:index];
        if ([dotView respondsToSelector:@selector(changeActivityState:)]) {
            [dotView changeActivityState:active];
        } else {
            NSLog(@"Custom view : %@ must implement an 'changeActivityState' method or you can subclass %@ to help you.", self.dotViewClass, [LTBaseDotView class]);
        }
    } else if (self.dotImage && self.currentDotImage) {
        UIImageView *dotView = (UIImageView *)[self.dots objectAtIndex:index];
        dotView.image = active ? self.currentDotImage : self.dotImage;
    }
}

#pragma mark - setter
- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self resetDotViews];
}

- (void)setSpacingBetweenDot:(CGFloat)spacingBetweenDot {
    _spacingBetweenDot = spacingBetweenDot;
    [self resetDotViews];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (self.numberOfPages == 0 || _currentPage == currentPage) {
        _currentPage = currentPage;
        return;
    }
    
    [self changeActivity:NO atIndex:_currentPage];
    _currentPage = currentPage;
    [self changeActivity:YES atIndex:_currentPage];
}

- (void)setDotImage:(UIImage *)dotImage {
    _dotImage = dotImage;
    [self resetDotViews];
    self.dotViewClass = nil;
}

- (void)setCurrentDotImage:(UIImage *)currentDotImage {
    _currentDotImage = currentDotImage;
    [self resetDotViews];
    self.dotViewClass = nil;
}

- (void)setDotViewClass:(Class)dotViewClass {
    _dotViewClass = dotViewClass;
    self.dotSize = CGSizeZero;
    [self resetDotViews];
}

#pragma mark - getter
- (NSMutableArray *)dots {
    if (!_dots) {
        _dots = [[NSMutableArray alloc] init];
    }
    return _dots;
}

- (CGSize)dotSize {
    if (self.dotImage && CGSizeEqualToSize(_dotSize, CGSizeZero)) {
        _dotSize = self.dotImage.size;
    } else if (self.dotViewClass && CGSizeEqualToSize(_dotSize, CGSizeZero)) {
        _dotSize = (CGSize){8,8};
    }
    return _dotSize;
}

@end
