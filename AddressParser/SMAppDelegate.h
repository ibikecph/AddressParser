//
//  SMAppDelegate.h
//  AddressParser
//
//  Created by Ivan Pavlovic on 13/11/2013.
//  Copyright (c) 2013 Spoiled Milk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SMAppDelegate : NSObject <NSApplicationDelegate> {
    
    __weak NSTextField *_testFile;
    __unsafe_unretained NSTextView *_testOutput;
    __weak NSTextField *_inputText;
    __weak NSTextField *_street;
    __weak NSTextField *_house;
    __weak NSTextField *_zip;
    __weak NSTextField *_city;
}

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *testFile;
@property (unsafe_unretained) IBOutlet NSTextView *testOutput;
@property (weak) IBOutlet NSTextField *inputText;
@property (weak) IBOutlet NSTextField *street;
@property (weak) IBOutlet NSTextField *house;
@property (weak) IBOutlet NSTextField *zip;
@property (weak) IBOutlet NSTextField *city;
@end
