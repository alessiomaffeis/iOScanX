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
    NMSSHSession *_ssh, *_scp;
    NSTask *_relay;
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
}

- (void)loadApps {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *appsPath = [[fm applicationSupportDirectory] stringByAppendingPathComponent:@"Apps"];
    NSDirectoryEnumerator *de = [fm enumeratorAtPath:appsPath];
    NSString *appID;
    while (appID = [de nextObject]) {
        
        if(appID.length==36 && ![_appsViewController appExistsWithID:appID]) {
        
            iSXApp *app = [[iSXApp alloc] init];
            app.ID = appID;
            NSString *appFolder = [appsPath stringByAppendingPathComponent:appID];
            NSDirectoryEnumerator *ade = [fm enumeratorAtPath:appFolder];
            NSString *appFile;
            while (appFile = [ade nextObject]) {
                if ([[appFile pathExtension] isEqualToString:@"app"]) {
                    app.name = appFile;
                }
            }
            app.iconPath = [appFolder stringByAppendingPathComponent:@"iTunesArtwork"];
            [_appsViewController performSelectorOnMainThread:@selector(addApp:) withObject:app waitUntilDone: NO];
        }
    }
    
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
    [self performSelectorInBackground:@selector(loadApps) withObject:nil];
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
        if(_relay == nil)
        {
            host = @"127.0.0.1:2222";
            NSString *tcprelayPath = [[NSBundle mainBundle] pathForResource:@"tcprelay" ofType:@"py"];
            NSString *pythonPath = @"/usr/bin/python";
            NSArray *args = [NSArray arrayWithObjects:tcprelayPath, @"-t", @"22:2222", nil];
            _relay = [[NSTask alloc] init];
            [_relay setLaunchPath:pythonPath];
            [_relay setArguments:args];
            [_relay launch];
            [NSThread sleepForTimeInterval:2];
        }
    }
    else
    {
        host = [NSString stringWithFormat:@"%@:22", address];
    }
    
    _ssh = [NMSSHSession connectToHost:host withUsername:user];
    _scp = [NMSSHSession connectToHost:host withUsername:user];

    
    if (_ssh.isConnected && _scp.isConnected)
    {
        [_ssh authenticateByPassword:password];
        [_scp authenticateByPassword:password];
        
        if (_ssh.isAuthorized && _scp.isAuthorized )
        {
            [_progressSheetController updateMessage:@"Loading applications"];

            BOOL copiedDlyb = [_scp.channel uploadFile:[[NSBundle mainBundle] pathForResource:@"dumpdecrypted" ofType:@"dylib"] to:@"/var/local/"];
            
            if (copiedDlyb)
            {
                NSError *error = nil;
                NSString *response = [_ssh.channel execute:@"find /var/mobile/Applications/ $PWD -maxdepth 2 | grep .app$" error:&error];
                
                if (response != nil)
                {
                    NSArray *items = [response componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    
                    iSXSelectWindowController *selDialog = [[iSXSelectWindowController alloc]init];
                    
                    [selDialog addApps:items];
                    [selDialog show:[_mainView window]];
                    
                    if (selDialog.selectedApps && selDialog.selectedApps.count>0)
                    {
                        NSFileManager *fm = [NSFileManager defaultManager];
                        NSString *asPath = [fm applicationSupportDirectory];
                        
                        _progressSheetController.minValue = 0;
                        _progressSheetController.maxValue = selDialog.selectedApps.count*2;
                        _progressSheetController.value = 0;
                        [_progressSheetController updateIsIndeterminate:NO];
                        
                        int i = 1;
                        for (NSDictionary *app in selDialog.selectedApps)
                        {
                            NSString *appName = [app objectForKey:@"name"];
                            NSString *appPath = [app objectForKey:@"path"];
                            NSString *appID = [appPath lastPathComponent];
                            
                            if (appID.length==36)
                            {
                                [_progressSheetController updateMessage:[NSString stringWithFormat:@"Decrypting: %@", appName]];
                                
                                NSString *subPath = [NSString stringWithFormat:@"Apps/%@", appID];
                                NSString *dstPath = [asPath stringByAppendingPathComponent:subPath];
                                
                                [fm createDirectoryAtPath:dstPath withIntermediateDirectories:YES attributes:nil error:nil];
                                
                                NSString *binaryName = [appName stringByDeletingPathExtension];
                                NSString *escAppName = [appName stringByReplacingOccurrencesOfString:@" "
                                                                                withString:@"\\ "];
                                NSString *escBinName = [binaryName stringByReplacingOccurrencesOfString:@" "
                                                                                withString:@"\\ "];
                                
                                NSString *decrypted = [_ssh.channel execute:[NSString stringWithFormat:@"DYLD_INSERT_LIBRARIES=/var/local/dumpdecrypted.dylib /var/mobile/Applications/%@/%@/%@", appID, escAppName, escBinName] error:&error];
                                
                                if (decrypted != nil)
                                {
                                    [_progressSheetController incrementValue];
                                    [_progressSheetController updateMessage:[NSString stringWithFormat:@"Copying: %@", appName]];
                                    
                                    NSString *artwork = [NSString stringWithFormat:@"/var/mobile/Applications/%@/iTunesArtwork", appID];
                                    NSString *meta = [NSString stringWithFormat:@"/var/mobile/Applications/%@/iTunesMetadata.plist", appID];
                                    NSString *bundle = [NSString stringWithFormat:@"/var/mobile/Applications/%@/%@", appID, appName];
                                    
                                    BOOL ok = YES;
                                    ok &= [_scp.channel downloadFile:artwork to:[dstPath stringByAppendingPathComponent:@"iTunesArtWork" ]];
                                    ok &= [_scp.channel downloadFile:meta to:[dstPath stringByAppendingPathComponent:@"iTunesMetadata.plist"]];
                                    ok &= [self downloadFolder:bundle to:dstPath recursively:YES];
                                    
                                    if (!ok)
                                    {
                                        [fm removeItemAtPath:dstPath error:nil];
                                        [[NSAlert alertWithMessageText:@"Import error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"It was not possible to import the application from the device."] runModal];
                                    }
                                }
                                else
                                {
                                    [fm removeItemAtPath:dstPath error:nil];
                                    [[NSAlert alertWithError:error] runModal];
                                }
                            }
                            [_progressSheetController incrementValue];
                            i++;
                        }
                        
                        [selDialog release];
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
    
    [_scp disconnect];
    [_ssh disconnect];
    
    [_relay terminate];
    [_relay release];
    _relay = nil;
    [_progressSheetController closeSheet];
    
}

- (BOOL)downloadFolder:(NSString *)remotePath to:(NSString *)localPath recursively:(BOOL)recursively {
    
    if(!_scp.isAuthorized || !_ssh.isAuthorized)
        return NO;

    NSString *escRemotePath = [remotePath stringByReplacingOccurrencesOfString:@" "
                                                              withString:@"\\ "];

    NSString *folderName = [remotePath lastPathComponent];
    NSString *localFolder = [localPath stringByAppendingPathComponent:folderName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm createDirectoryAtPath:localFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSError *error = nil;
    NSString *folderContent = [_ssh.channel execute:[NSString stringWithFormat:@"ls -1 %@", escRemotePath] error:&error];
    NSString *subFolders = [_ssh.channel execute:[NSString stringWithFormat:@"ls -1 -d %@/*/", escRemotePath] error:&error];
    
    NSMutableArray *subFolderNames = nil;
    
    if (subFolders == nil)
        return NO;
    
    subFolderNames = [NSMutableArray arrayWithArray:[subFolders componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    
    
    int i=0;
    while (i<subFolderNames.count) {
        
        NSString *itemName = [[subFolderNames objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (itemName.length>0) {
            [subFolderNames replaceObjectAtIndex:i withObject:[itemName lastPathComponent]];
            i++;
        }
        else
        {
            [subFolderNames removeObjectAtIndex:i];
        }
    }
    
    if (folderContent == nil || subFolderNames == nil)
        return NO;
    
    NSArray *folderItems = [folderContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for(NSString *item in folderItems)
    {
        NSString *itemName = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (itemName.length>0 && ![subFolderNames containsObject:itemName])
        {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", remotePath, itemName];
            NSString *dstFilePath = [localFolder stringByAppendingPathComponent:itemName];
            BOOL res = [_scp.channel downloadFile:filePath to:dstFilePath];
            if (!res) {
                return NO;
            }
        }
    }
    
    if (recursively)
    {
        for(NSString *subName in subFolderNames)
        {
            [self downloadFolder:[remotePath stringByAppendingPathComponent:subName] to:localFolder  recursively:YES];
        }
    }

    
    return YES;
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
