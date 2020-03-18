//
//  TMBaseDotView.m
//  TMPageControl
//
//  Created by Luther on 2019/8/21.
//  Copyright © 2019 mrstock. All rights reserved.
//

#import "TMBaseDotView.h"

@implementation TMBaseDotView

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in %@",NSStringFromSelector(_cmd),self.class]
                                 userInfo:nil];
}

- (void)changeActivityState:(BOOL)active {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in %@",NSStringFromSelector(_cmd),self.class]
                                 userInfo:nil];
}

@end
