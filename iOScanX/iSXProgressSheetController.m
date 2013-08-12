//
//  iSXProgressSheetController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 12/08/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXProgressSheetController.h"

@implementation iSXProgressSheetController {
    IBOutlet NSWindow *_sheet;
    IBOutlet NSProgressIndicator *_progressBar;
}

- (id)init {
    self = [super init];
    if (self) {
        _isIndeterminate = YES;
        _minValue = 0;
        _maxValue = 100;
        _value = 0;
        _message = @"Loading";
    }
    
    return self;
}

- (void) showSheet:(NSWindow*)window {
    
    if (_sheet == nil)
        [NSBundle loadNibNamed: @"iSXProgressSheet" owner: self];
    
    [NSApp beginSheet: _sheet
       modalForWindow: window
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [_progressBar startAnimation:self];
}

- (void) closeSheet {
    
    [NSApp endSheet: _sheet];
    [_sheet orderOut:self];
}


@end
