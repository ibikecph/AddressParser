//
//  SMAppDelegate.m
//  AddressParser
//
//  Created by Ivan Pavlovic on 13/11/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import "SMAppDelegate.h"
#import "SMAddressParser.h"

@implementation SMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (IBAction)openProject:(id)sender {
    NSURL* url = nil;
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    // Multiple files not allowed
    [openDlg setAllowsMultipleSelection:NO];
    // Can't select a directory
    [openDlg setCanChooseDirectories:NO];
    // Display the dialog. If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton ) {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* urls = [openDlg URLs];
        
        // Loop through all the files and process them.
        for(int i = 0; i < [urls count]; i++ ) {
            url = [urls objectAtIndex:i];
            NSLog(@"Url: %@", url);
        }
    }
    
    if (url) {
        [_testFile setStringValue:[url path]];
        [_testOutput setString:@""];
    }
}

- (IBAction)doParse:(id)sender {
    if ([_testFile.stringValue isEqualToString:@""] == NO) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:_testFile.stringValue isDirectory:NO]) {
            [_testOutput setString:@""];
            NSString * content = [NSString stringWithContentsOfFile:_testFile.stringValue usedEncoding:nil error:NULL];
            for (NSString *line in [content componentsSeparatedByString:@"\n"]) {
                NSDictionary * d = [SMAddressParser parseAddress:line];
                [_testOutput insertText:[NSString stringWithFormat:@"Input: %@\nOutput:\n%@\n***************\n\n", line, d]];
            }
        }
    }
}


- (IBAction)doParseSingle:(id)sender {
    [_street setStringValue:@""];
    [_house setStringValue:@""];
    [_city setStringValue:@""];
    [_zip setStringValue:@""];
    if ([_inputText.stringValue isEqualToString:@""] == NO) {
        NSDictionary * d = [SMAddressParser parseAddress:_inputText.stringValue];
        if ([d objectForKey:@"street"]) {
            [_street setStringValue:[d objectForKey:@"street"]];
        }
        if ([d objectForKey:@"number"]) {
            [_house setStringValue:[d objectForKey:@"number"]];
        }
        if ([d objectForKey:@"zip"]) {
            [_zip setStringValue:[d objectForKey:@"zip"]];
        }
        if ([d objectForKey:@"city"]) {
            [_city setStringValue:[d objectForKey:@"city"]];
        }
        
    }
}

@end
