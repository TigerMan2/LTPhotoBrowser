//
//  LTProgressView.h
//  LTProgressView
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LTProgressViewType) {
    LTProgressViewTypePie = 0,      //圆饼
    LTProgressViewTypeLoop          //圆环
};

@interface LTProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) LTProgressViewType progressType;

@end

NS_ASSUME_NONNULL_END
