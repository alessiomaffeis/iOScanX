//
//  iSXResult.m
//  iOScanX
//
//  Created by Alessio Maffeis on 01/10/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXResult.h"

@implementation iSXResult

-(id)init {
    
    self = [super init];
    if (self) {
        _name = @"";
    }
    return self;
}

-(void)dealloc {
    
    [_name release];
    [super dealloc];
}


@end
