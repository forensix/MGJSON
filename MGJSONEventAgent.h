// -----------------------------------------------------------------------------
//  MGJSONEventAgent.h
//  MGJSON
//
//  MGJSON is available under *either* the terms of the modified BSD license
//  *or* the MIT License (2008). See http://opensource.org/licenses/alphabetical
//  for full text.
// 
//  Copyright (c) 2010-2011, Manuel Gebele. 
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#pragma mark ForwardDeclarations

@class MGJSONParser, MGJSONParseError;
@protocol MGJSONEventDelegate;

/*! ----------------------------------------------------------------------------
    @class
    @abstract   Interface layer between the parser and the parsers delegate.
    @discussion I've implemented several paran01a checks, just in case!
 
    @author     Manuel Gebele
 ---------------------------------------------------------------------------- */
@interface MGJSONEventAgent : NSObject {

    id <MGJSONEventDelegate> _delegate;
    BOOL isInternalError; // Tells the parser if an internal error was happened.
                          // _not_ considered by the parser yet.
}
@property (readwrite) BOOL isInternalError;

// Init stuff ...
- (id)initWithDelegate:(id)delegate;

// Client notification ...
- (BOOL)fireParserDidStartMessage:(MGJSONParser *)parser;
- (BOOL)fireParserDidEndMessage:(MGJSONParser *)parser;
- (BOOL)fireParserDidStartObject:(MGJSONParser *)parser;
- (BOOL)fireParserDidEndObject:(MGJSONParser *)parser;
- (BOOL)fireParserDidStartList:(MGJSONParser *)parser;
- (BOOL)fireParserDidEndList:(MGJSONParser *)parser;
- (BOOL)fireParser:(MGJSONParser *)parser didStartField:(NSString *)fieldName;
- (BOOL)fireParserDidEndField:(MGJSONParser *)parser;
- (BOOL)fireParser:(MGJSONParser *)parser foundNumber:(NSString *)number;
- (BOOL)fireParser:(MGJSONParser *)parser foundString:(NSString *)string;
- (BOOL)fireParser:(MGJSONParser *)parser foundBoolean:(NSString *)boolean;
- (BOOL)fireParserFoundNull:(MGJSONParser *)parser;
// Error reporting ...
- (BOOL)fireParser:(MGJSONParser *)parser parseErrorOccurred:(MGJSONParseError *)parseError;

@end
