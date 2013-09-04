//
//  iSXModule.h
//  iOScanX
//
//  Created by Alessio Maffeis on 02/09/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iSXModule : NSObject

@property (copy) NSString *name;
@property (copy) NSString *prefix;
@property (copy) NSString *ID;
@property (copy) NSArray *metrics;
@property (copy) NSString *path;

@property (assign) BOOL selected;

@end
