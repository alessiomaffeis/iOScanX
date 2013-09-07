//
//  iSXEvaluationsViewController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXEvaluationsViewController.h"

@interface iSXEvaluationsViewController ()

@end

@implementation iSXEvaluationsViewController {
    
    NSUInteger _nextID;
    IBOutlet NSArrayController *_evaluationsArrayController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _nextID = 1;
    }
    
    return self;
}

- (void)controlTextDidEndEditing:(NSNotification *)obj {
    
    [self save];
}

- (void)addEvaluation:(iSXEvaluation *)evaluation {
    
    if (_nextID <= evaluation.ID)
        _nextID = evaluation.ID + 1;
    
    [_evaluationsArrayController addObject:evaluation];
}

- (IBAction)add:(id)sender {
    
    [_evaluationsArrayController addObject:[[[iSXEvaluation alloc] initWithName:@"Name" expression:@"Expression" ID:_nextID] autorelease]];
    _nextID++;
    [self save];
}

- (void)save {
    
    NSMutableArray *toSave = [NSMutableArray array];
    for (iSXEvaluation *evaluation in _evaluationsArrayController.arrangedObjects) {
        [toSave addObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithUnsignedLong:evaluation.ID], @"ID", evaluation.name, @"name", evaluation.expression, @"expression", nil]];
    }
    [_delegate saveEvaluations:toSave];
}

- (NSInteger)count {
    
    return [_evaluationsArrayController.arrangedObjects count];
}

- (NSArray*)evaluations {
    
    return [[_evaluationsArrayController.arrangedObjects copy] autorelease];
}

- (IBAction)delete:(id)sender {
    
    NSMutableArray *toDelete = [NSMutableArray array];
    for (iSXEvaluation *evaluation in _evaluationsArrayController.selectedObjects) {
        [toDelete addObject:evaluation];
    }
    [_evaluationsArrayController removeObjects:toDelete];
    [self save];
}

@end
