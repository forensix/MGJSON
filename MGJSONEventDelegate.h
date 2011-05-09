// -----------------------------------------------------------------------------
//  MGJSONDelegate.h
//  MGJSON
//
//  MGAOP is available under *either* the terms of the modified BSD license
//  *or* the MIT License (2008). See http://opensource.org/licenses/alphabetical
//  for full text.
// 
//  Copyright (c) 2010-2011, Manuel Gebele. 
// -----------------------------------------------------------------------------

#import <UIKit/UIKit.h>

@class MGJSONParser, MGJSONParseError;

/*! ----------------------------------------------------------------------------
    @protocol
    @abstract   A protocol which defines callback methods to notify the client
                about any JSON related event.
    @discussion Such events could be the start or the end of a JSON document or
                a number value from a field, for example.
 
                To get a closer overview about the structure of a JSON document,
                take a look at http://www.json.org/
 
    @author     Manuel Gebele
 ---------------------------------------------------------------------------- */
@protocol MGJSONEventDelegate <NSObject>

@optional

// Indicates the beginning and ending of a JSON message.
- (void)parserDidStartMessage:(MGJSONParser *)parser;
- (void)parserDidEndMessage:(MGJSONParser *)parser;

// Indicates the beginning and ending of a JSON object.
- (void)parserDidStartObject:(MGJSONParser *)parser;
- (void)parserDidEndObject:(MGJSONParser *)parser;

// Indicates the beginning and ending of a JSON list (array).
- (void)parserDidStartList:(MGJSONParser *)parser;
- (void)parserDidEndList:(MGJSONParser *)parser;

// Indicates the beginning and ending of a JSON field.  This is the
// name entry in a name/value pair.
- (void)parser:(MGJSONParser *)parser didStartField:(NSString *)fieldName;
- (void)parserDidEndField:(MGJSONParser *)parser;

// Inidicates that a non complex JSON value was found by the parser.
- (void)parser:(MGJSONParser *)parser foundNumber:(NSString *)number;
- (void)parser:(MGJSONParser *)parser foundString:(NSString *)string;
- (void)parser:(MGJSONParser *)parser foundBoolean:(NSString *)boolean;
- (void)parserFoundNull:(MGJSONParser *)parser;

// Indicates that an error has occured during the parsing process.  Similar to
// NSXMLParser this will also stop the parsers parsing process.
- (void)parser:(MGJSONParser *)parser parseErrorOccurred:(MGJSONParseError *)parseError;

@end
