//
//  iSXEvaluationsViewController.h
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iSXEvaluation.h"

@protocol iSXEvaluationsViewDelegate

- (void)saveEvaluations:(NSArray*)evaluations;

@end

@interface iSXEvaluationsViewController : NSViewController

@property (assign) id <iSXEvaluationsViewDelegate> delegate;

- (void)save;
- (NSInteger)count;
- (void)addEvaluation:(iSXEvaluation*)evaluation;
- (IBAction)add:(id)sender;
- (IBAction)delete:(id)sender;

@end
