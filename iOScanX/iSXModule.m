//
//  iSXModule.m
//  iOScanX
//
//  Created by Alessio Maffeis on 02/09/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXModule.h"

@implementation iSXModule


-(id)init {
    
    self = [super init];
    if (self) {
        _name = @"";
        _prefix =  @"";
        _ID =  @"";
        _selected = YES;
    }
    return self;
}

-(void)dealloc {
    
    [_name release];
    [_prefix release];
    [_ID release];
    [super dealloc];
}


@end
