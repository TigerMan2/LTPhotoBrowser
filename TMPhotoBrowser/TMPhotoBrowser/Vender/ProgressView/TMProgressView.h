//
//  TMProgressView.h
//  TMProgressView
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TMProgressViewType) {
    TMProgressViewTypePie = 0,      //圆饼
    TMProgressViewTypeLoop          //圆环
};

@interface TMProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) TMProgressViewType progressType;

@end

NS_ASSUME_NONNULL_END
