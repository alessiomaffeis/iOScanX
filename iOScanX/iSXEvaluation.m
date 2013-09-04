//
//  iSXEvaluation.m
//  iOScanX
//
//  Created by Alessio Maffeis on 04/09/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXEvaluation.h"

@implementation iSXEvaluation

-(id)init {
    
    self = [super init];
    if (self) {
        _name = @"Name";
        _expression =  @"Expression";
    }
    return self;
}

-(void)dealloc {
    
    [_name release];
    [_expression release];
    [super dealloc];
}

@end
