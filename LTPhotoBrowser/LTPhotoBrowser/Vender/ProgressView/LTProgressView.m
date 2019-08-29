//
//  LTProgressView.m
//  LTProgressView
//
//  Created by Luther on 2019/8/26.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "LTProgressView.h"

#define LTProgressViewBackgroundColor   [UIColor clearColor]
#define LTProgressViewStoreColor        [UIColor whiteColor]
#define LTProgressViewItemMargin        10
#define LTProgressViewLoopLineWidth     8

@interface LTProgressView ()
@property (nonatomic, strong) CAShapeLayer *sectorLayer;
@property (nonatomic, strong) CAShapeLayer *loadingLayer;
@property (nonatomic, strong) CAShapeLayer *sharpLayer;
@end

@implementation LTProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = LTProgressViewBackgroundColor;
        self.progressType = LTProgressViewTypePie;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    if (self.progressType == LTProgressViewTypePie) {
        [self setupSectorLayer];
        [self setupLoadingLayer];
        [self setupSharpLayer:rect];
    } else {
        [self setupLoadingLayer];
    }
}

- (void)setupSectorLayer {
    self.sectorLayer = [CAShapeLayer layer];
    [self.sectorLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.sectorLayer setLineWidth:1.0f];
    [self.sectorLayer setHidden:YES];
    [self.sectorLayer setStrokeColor:[[UIColor groupTableViewBackgroundColor] CGColor]];
    [self.sectorLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:[self bounds]] CGPath]];
    [self.layer addSublayer:self.sectorLayer];
}

- (void)setupLoadingLayer {
    self.loadingLayer = [CAShapeLayer layer];
    self.loadingLayer.frame = [self bounds];
    [self.loadingLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [self.loadingLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.loadingLayer setLineWidth:1.0f];
    [self.loadingLayer setStrokeColor:[[UIColor groupTableViewBackgroundColor] CGColor]];
    
    CGPoint center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    CGFloat loadRadius = self.bounds.size.width * 0.5;
    CGFloat endAngle = (2 * (float)M_PI) - ((float)M_PI / 8);
    
    self.loadingLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:loadRadius startAngle:0 endAngle:endAngle clockwise:YES].CGPath;
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setToValue:[NSNumber numberWithFloat:M_PI * 2]];
    [rotationAnimation setDuration:1.0f];
    [rotationAnimation setCumulative:YES];
    [rotationAnimation setRepeatCount:HUGE_VALF];
    [self.loadingLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self.layer addSublayer:self.loadingLayer];
}

- (void)setupSharpLayer:(CGRect)rect {
    CGFloat minSize = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGFloat radius = minSize/2 - 3;
    
    self.sharpLayer = [CAShapeLayer layer];
    [self.sharpLayer setFrame:[self bounds]];
    [self.sharpLayer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    [self.sharpLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.sharpLayer setStrokeColor:[[UIColor groupTableViewBackgroundColor] CGColor]];
    [self.sharpLayer setLineWidth:radius];
    [self.sharpLayer setStrokeStart:0];
    [self.sharpLayer setStrokeEnd:0];
    
    CGRect pathRect = CGRectMake(CGRectGetWidth(self.bounds)/2 - radius/2, CGRectGetHeight(self.bounds)/2 - radius/2, radius, radius);
    [self.sharpLayer setPath:[[UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:radius] CGPath]];
    [self.layer addSublayer:self.sharpLayer];
}

- (void)setProgress:(CGFloat)progress {
    progress = MAX(0.0f, progress);
    progress = MIN(1.0f, progress);
    
    if (self.progressType == LTProgressViewTypeLoop) {
        if (progress != _progress) {
            _progress = progress;
        }
        
        if (progress >= 1) {
            [self.loadingLayer removeAllAnimations];
            [self.loadingLayer removeFromSuperlayer];
        }
    } else {
        
        if (progress > 0) {
            [self.sectorLayer setHidden:NO];
            [self.loadingLayer removeAllAnimations];
            [self.loadingLayer removeFromSuperlayer];
        }
        
        if (progress != _progress) {
            self.sharpLayer.strokeEnd = progress;
            _progress = progress;
        }
        
        if (progress >= 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setHidden:YES];
                [self removeFromSuperview];
            });
        }
    }
    
}


@end
