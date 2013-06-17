//
//  iSXApp.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXApp.h"

@implementation iSXApp

@synthesize name = _name;
@synthesize iconURL = _iconURL;
@synthesize toAnalize = _toAnalize;

-(id)init {
    self = [super init];
    if (self) {
        _name = @"App Name";
        _iconURL =  nil;
        _toAnalize = YES;
    }
    return self;
}

@end