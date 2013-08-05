//
//  iSXApp.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXApp.h"

@implementation iSXApp

-(id)init {
    
    self = [super init];
    if (self) {
        _name = @"Test App";
        _iconPath =  @"test.jpg";
        _analyze = YES;
    }
    return self;
}

-(void)dealloc {
    
    [_name release];
    [_iconPath release];
    [super dealloc];
}

@end