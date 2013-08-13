//
//  iSXAppController.m
//  iOScanX
//
//  Created by Alessio Maffeis on 28/05/13.
//  Copyright (c) 2013 Alessio Maffeis. All rights reserved.
//

#import "iSXAppController.h"
#import "NSFileManager+DirectoryLocations.h"

@implementation iSXAppController {
    
    IBOutlet NSToolbar *_toolbar;
    NSView *_currentView;
    iSXImportViewController *_importViewController;
    iSXAppsViewController *_appsViewController;
    iSXModulesViewController *_modulesViewController;
    iSXEvaluationsViewController *_evaluationsViewController;
    iSXResultsViewController *_resultsViewController;
    iSXProgressSheetController *_progressSheetController;
    NMSSHSession *_ssh;    
}

- (id) init {
    [super init];
    if (self) {
        _scanner = [[SXScanner alloc] init];
        _importViewController = [[iSXImportViewController alloc] initWithNibName:@"iSXImportViewController" bundle:nil];
        _importViewController.delegate = self;
        _appsViewController = [[iSXAppsViewController alloc] initWithNibName:@"iSXAppsViewController" bundle:nil];
        _modulesViewController = [[iSXModulesViewController alloc] initWithNibName:@"iSXModulesViewController" bundle:nil];
        _evaluationsViewController = [[iSXEvaluationsViewController alloc] initWithNibName:@"iSXEvaluationsViewController" bundle:nil];
        _resultsViewController = [[iSXResultsViewController alloc] initWithNibName:@"iSXResultsViewController" bundle:nil];
        _progressSheetController = [[iSXProgressSheetController alloc] init];
    }
    return self;
}

- (void)initialize {
    
    [_toolbar setSelectedItemIdentifier:@"ImportView"];
    [self.mainView addSubview:[_importViewController view]];
    _currentView = [_importViewController view];
    [[_importViewController view] setFrame:[self.mainView bounds]];
    //[self performSelectorInBackground:@selector(loadApps) withObject:nil];
}

- (void)loadApps {
    
   /* NSFileManager *fm = [NSFileManager defaultManager];
    NSString *srcPath = [fm iTunesMobileAppsDirectory];
    NSString *asPath = [fm applicationSupportDirectory];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:srcPath];
    NSString *ipa;
    int bufSize = 65536;
    while (ipa = [de nextObject]) {
        
            NSString *subPath = [NSString stringWithFormat:@"Apps/%@", de];
            NSString *dstPath = [asPath stringByAppendingPathComponent:subPath];
    
            iSXApp *app = [[iSXApp alloc] init];
            app.name = ipa;
            app.iconPath = [dstPath stringByAppendingPathComponent:@"iTunesArtwork"];
            [_appsViewController performSelectorOnMainThread:@selector(addApp:) withObject:app waitUntilDone: NO];
    }

    */
    
}

// UI related methods:

- (IBAction)showImport:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_importViewController view]];
    _currentView = [_importViewController view];
    [[_importViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showApps:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_appsViewController view]];
    _currentView = [_appsViewController view];
    [[_appsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showModules:(id)sender {

    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_modulesViewController view]];
    _currentView = [_modulesViewController view];
    [[_modulesViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showEvaluations:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_evaluationsViewController view]];
    _currentView = [_evaluationsViewController view];
    [[_evaluationsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)showResults:(id)sender {
    
    [_currentView removeFromSuperviewWithoutNeedingDisplay];
    [self.mainView addSubview:[_resultsViewController view]];
    _currentView = [_resultsViewController view];
    [[_resultsViewController view] setFrame:[self.mainView bounds]];
}

- (IBAction)toggleStart:(id)sender {
    
    NSLog(@"%@",[[NSBundle mainBundle] pathForResource:@"dumpdecrypted" ofType:@"dylib"]);
}

// iSXImportViewController delegate's methods:

- (void)connectWithUsername:(NSString*)user andPassword:(NSString*)password toAddress:(NSString*)address {

    _progressSheetController.isIndeterminate = YES;
    _progressSheetController.message = @"Connecting to the device";
    [_progressSheetController showSheet:[_mainView window]];
    
     NSString *host;
    
    if (address == nil)
    {
        host = @"127.0.0.1:2222";
        // TODO: start the USB/SSH relay, yay!
    }
    else
    {
        host = [NSString stringWithFormat:@"%@:22", address];
    }
    
    _ssh = [NMSSHSession connectToHost:host withUsername:user];
    
    if (_ssh.isConnected)
    {
        [_ssh authenticateByPassword:password];
        
        if (_ssh.isAuthorized)
        {
            [_progressSheetController updateMessage:@"Loading applications"];

            BOOL copiedDlyb = [_ssh.channel uploadFile:[[NSBundle mainBundle] pathForResource:@"dumpdecrypted" ofType:@"dylib"] to:@"/var/local/"];
            
            if (copiedDlyb)
            {
                NSError *error = nil;
                NSString *response = [_ssh.channel execute:@"ls /var/mobile/Applications/" error:&error];
                
                if (response != nil)
                {
                    NSArray *items = [response componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSFileManager *fm = [NSFileManager defaultManager];
                    NSString *asPath = [fm applicationSupportDirectory];

                    
                    _progressSheetController.minValue = 1;
                    _progressSheetController.maxValue = items.count-1;
                    [_progressSheetController updateIsIndeterminate:NO];
                    
                    int i = 1;
                    for (NSString *app in items) {
                        if (app.length==36) {
                            [_progressSheetController updateValue:i];
                            
                            NSString *subPath = [NSString stringWithFormat:@"Apps/%@", app];
                            NSString *dstPath = [asPath stringByAppendingPathComponent:subPath];
                            
                            if (![fm fileExistsAtPath:dstPath]) {
                                
                                [fm createDirectoryAtPath:dstPath withIntermediateDirectories:YES attributes:nil error:nil];
                            
                                NSString *bundleName = [_ssh.channel execute:[NSString stringWithFormat:@"ls /var/mobile/Applications/%@ |grep .app$", app] error:&error];
                                if (bundleName != nil)
                                {
                                    bundleName = [bundleName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    NSString *binaryName = [bundleName stringByDeletingPathExtension];
                                    
                                    [_progressSheetController updateMessage:[NSString stringWithFormat:@"Decrypting: %@", bundleName]];
                                    
                                    NSString *decrypted = [_ssh.channel execute:[NSString stringWithFormat:@"DYLD_INSERT_LIBRARIES=/var/local/dumpdecrypted.dylib /var/mobile/Applications/%@/%@/%@", app, bundleName, binaryName] error:&error];
                                    if (decrypted != nil)
                                    {
                                        [_progressSheetController updateMessage:[NSString stringWithFormat:@"Copying: %@", bundleName]];
                                        
                                        NSString *artwork = [NSString stringWithFormat:@"/var/mobile/Applications/%@/iTunesArtwork", app];
                                        NSString *meta = [NSString stringWithFormat:@"/var/mobile/Applications/%@/iTunesMetadata.plist", app];
                                        
                                        NMSSHSession *scp = [NMSSHSession connectToHost:host withUsername:user];
                                        if (scp.isConnected) {
                                            [scp authenticateByPassword:password];
                                            
                                            if (scp.isAuthorized) {
                                                [scp.channel downloadFile:artwork to:[dstPath stringByAppendingPathComponent:@"iTunesArtWork" ]];
                                                [scp.channel downloadFile:meta to:[dstPath stringByAppendingPathComponent:@"iTunesMetadata.plist"]];
                                                [fm createDirectoryAtPath:[dstPath stringByAppendingPathComponent:bundleName] withIntermediateDirectories:YES attributes:nil error:nil];
                                                NSString *bundleContent = [_ssh.channel execute:[NSString stringWithFormat:@"ls /var/mobile/Applications/%@/%@", app, bundleName] error:&error];
                                                if (bundleContent != nil)
                                                {
                                                    NSArray *bundleItems = [bundleContent componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                                    for(NSString *file in bundleItems)
                                                    {
                                                        NSString *fileName = [file stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                                        if (fileName.length>0) {
                                                            NSString *filePath = [NSString stringWithFormat:@"/var/mobile/Applications/%@/%@/%@", app, bundleName, fileName];
                                                            NSString *dstFilePath = [NSString stringWithFormat:@"%@/%@/%@",dstPath,bundleName,fileName];
                                                            NSLog(@"Source: %@", filePath);
                                                            NSLog(@"Dest: %@", dstFilePath);
                                                            [scp.channel downloadFile:filePath to:dstFilePath];

                                                        }
                                                    }
                                                }

                                                [scp disconnect];
                                            }
                                            else
                                            {
                                                [[NSAlert alertWithMessageText:@"Connection closed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to import the applications from the device."] runModal];
                                            }
                                        }
                                        else
                                        {
                                            [[NSAlert alertWithMessageText:@"Connection closed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to import the applications from the device."] runModal];
                                        }
                                        
                                    }
                                    else
                                    {
                                        [[NSAlert alertWithError:error] runModal];
                                    }


                                }
                                else
                                {
                                    [[NSAlert alertWithError:error] runModal];
                                }
                            }
                        }
                        i++;
                    }
                    
                }
                else
                {
                    [[NSAlert alertWithError:error] runModal];
                }
                
               
            }
            else
            {
                [[NSAlert alertWithMessageText:@"Connection closed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to import the applications from the device."] runModal];
            }
            
        }
        else
        {
            [[NSAlert alertWithMessageText:@"Authentication failed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please check your SSH User and Password and try again."] runModal];
        }
    }
    else
    {
         [[NSAlert alertWithMessageText:@"Connection failed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to establish a connection with the device."] runModal];
    }
    
    [_ssh disconnect];
    [_progressSheetController closeSheet];
    
}

// NSToolbar delegate's methods:

- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;
{    
    return [NSArray arrayWithObjects:@"ImportView",
            @"AppsView",
            @"ModulesView",
            @"EvaluationsView",
            @"ResultsView", nil];
}

//

- (void) dealloc {
    
    [_progressSheetController release];
    [_importViewController release];
    [_appsViewController release];
    [_modulesViewController release];
    [_evaluationsViewController release];
    [_resultsViewController release];
    [_scanner release];
    [super dealloc];
}

@end
