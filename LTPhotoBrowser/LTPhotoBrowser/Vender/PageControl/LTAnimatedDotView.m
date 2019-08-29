//
//  LTAnimatedDotView.m
//  LTPageControl
//
//  Created by Luther on 2019/8/21.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "LTAnimatedDotView.h"

@implementation LTAnimatedDotView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _dotColor = [UIColor whiteColor];
    self.backgroundColor    = [UIColor clearColor];
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0;
    self.layer.borderColor  = [UIColor whiteColor].CGColor;
    self.layer.borderWidth  = 1;
}

- (void)changeActivityState:(BOOL)active {
    if (active) {
        [self animatedToActiveState];
    } else {
        [self animatedToDeactiveState];
    }
}

static CGFloat damping = 0.25;
static CGFloat const kAnimatedDuration = 1;

- (void)animatedToActiveState {
    [UIView animateWithDuration:kAnimatedDuration
                          delay:0
         usingSpringWithDamping:damping
          initialSpringVelocity:-20
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.backgroundColor = self->_dotColor;
                         self.transform = CGAffineTransformMakeScale(1.4, 1.4);
                     }
                     completion:nil];
}

- (void)animatedToDeactiveState {
    [UIView animateWithDuration:kAnimatedDuration
                          delay:0
         usingSpringWithDamping:damping
          initialSpringVelocity:-20
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.backgroundColor = [UIColor clearColor];
                         self.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

#pragma mark - getter & setter
- (void)setDotColor:(UIColor *)dotColor {
    _dotColor = dotColor;
    self.layer.borderColor = dotColor.CGColor;
}

@end
