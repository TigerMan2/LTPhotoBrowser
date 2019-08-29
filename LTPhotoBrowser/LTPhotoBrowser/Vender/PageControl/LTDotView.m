//
//  LTDotView.m
//  LTPageControl
//
//  Created by Luther on 2019/8/21.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "LTDotView.h"

@implementation LTDotView

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
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)changeActivityState:(BOOL)active {
    if (active) {
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
