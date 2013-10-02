//
//  iSXResultsViewController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 20/06/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXResultsViewController.h"

@interface iSXResultsViewController ()

@end

@implementation iSXResultsViewController {
    
    IBOutlet NSArrayController *_resultsArrayController;
    NSUInteger _evalCount;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _results = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)awakeFromNib {
    
    [_resultsArrayController setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease]]];
}

- (void)addResult:(iSXResult *)result {
    
    [_resultsArrayController addObject:result];
    _evalCount = result.evaluations.count;
}

- (void)removeAllResults {
    
    NSRange range = NSMakeRange(0, [[_resultsArrayController arrangedObjects] count]);
    [_resultsArrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}

- (IBAction)export:(id)sender {
    
    [_delegate exportResults];
}

- (void)dealloc {
    
    [_results release];
    [super dealloc];
}

// NSTableView's delegate methods:

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    return 4 + _evalCount*14;
}

//

@end
