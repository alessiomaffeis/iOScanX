//
//  iSXEvaluation.h
//  iOScanX
//
//  Created by Alessio Maffeis on 04/09/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iSXEvaluation : NSObject

@property (assign) NSUInteger ID;
@property (copy) NSString *name;
@property (copy) NSString *expression;

-(id)initWithName:(NSString*)name expression:(NSString*)expression ID:(NSUInteger)ID;

@end
