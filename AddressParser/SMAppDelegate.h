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
}

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *testFile;
@property (unsafe_unretained) IBOutlet NSTextView *testOutput;
@end
