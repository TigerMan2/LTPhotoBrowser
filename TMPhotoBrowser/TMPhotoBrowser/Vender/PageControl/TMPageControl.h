//
//  TMPageControl.h
//  TMPageControl
//
//  Created by Luther on 2019/8/21.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TMPageControl;

@protocol TMPageControlDelegate <NSObject>

@optional
- (void)pageControl:(TMPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index;

@end

@interface TMPageControl : UIControl

/** The class of Your custom UIView, make sure to respect the TMBaseDotView class. */
@property (nonatomic, assign, nullable) Class dotViewClass;

/** The image of dot view. */
@property (nonatomic, strong) UIImage *dotImage;

/** The image of current dot view. */
@property (nonatomic, strong) UIImage *currentDotImage;

/** Dot size of dot views, Default is {8,8}. */
@property (nonatomic, assign) CGSize dotSize;

/** The color of dot view. */
@property (nonatomic, strong) UIColor *dotColor;

/** The space between tow dot view, Default is 8. */
@property (nonatomic, assign) CGFloat spacingBetweenDot;

/** Numbers of page for pageControl, Default is 0. */
@property (nonatomic, assign) NSInteger numberOfPages;

/** Current page on pageControl is active, Default is 0. */
@property (nonatomic, assign) NSInteger currentPage;

/** Hide the pageControl if there is only one dot, Default is NO. */
@property (nonatomic, assign) BOOL hidesForSinglePage;

/** Let the control know if should grow bigger by keeping center, or just get longer (right side expanding). By default YES */
@property (nonatomic, assign) BOOL shouldResizeFromCenter;

/** Delegate of pageControl */
@property (nonatomic, weak) id <TMPageControlDelegate> delegate;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;


@end

NS_ASSUME_NONNULL_END
