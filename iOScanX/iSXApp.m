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
        _name = @"Undefined";
        _iconPath =  @"";
        _path =  @"";
        _ID =  @"";
        _selected = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    iSXApp *copy = [[iSXApp alloc] init];
    
    if (copy) {
        
        copy.name = _name;
        copy.iconPath = _iconPath;
        copy.path = _path;
        copy.ID = _ID;
    }
    
    return copy;
}

-(void)dealloc {
    
    [_name release];
    [_ID release];
    [_path release];
    [_iconPath release];
    [super dealloc];
}

@end