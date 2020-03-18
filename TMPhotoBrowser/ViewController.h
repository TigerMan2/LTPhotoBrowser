//
//  ViewController.h
//  TMPhotoBrowser
//
//  Created by Luther on 2019/8/25.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
/**
 * scrollView
 */
@property (nonatomic , strong) UIScrollView  *scrollView;
/**
 * 图片数组
 */
@property (nonatomic , strong) NSMutableArray  *images;
/**
 *  url strings
 */
@property (nonatomic , strong) NSArray  *urlStrings;

/**
 *  浏览图片
 */
- (void)clickImage:(UITapGestureRecognizer *)tap;
- (void)resetScrollView;

@end

