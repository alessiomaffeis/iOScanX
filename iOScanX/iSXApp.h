//
//  iSXApp.h
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iSXApp : NSObject

@property (copy) NSString *name;
@property (copy) NSString *ID;
@property (copy) NSString *iconPath;
@property (copy) NSString *path;
@property (assign) BOOL selected;

@end
