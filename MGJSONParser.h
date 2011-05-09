// -----------------------------------------------------------------------------
//  MGJSONParser.h
//  MGJSON
//
//  MGAOP is available under *either* the terms of the modified BSD license
//  *or* the MIT License (2008). See http://opensource.org/licenses/alphabetical
//  for full text.
// 
//  Copyright (c) 2010-2011, Manuel Gebele. 
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "MGJSONParseError.h"

#pragma mark ForwardDeclarations

@class MGJSONEventAgent;

/*! ----------------------------------------------------------------------------
    @class
    @abstract   A JSON (JavaScript Object Notation) push parser.   
    @discussion This parser based on push parsing model (event-based), like
                NSXMLParser (SAX) for XML on OS X and iPhone.
 
                http://www.extreme.indiana.edu/xgws/papers/xml_push_pull/
 
                NOTE:
                This parser was designed and tested for iPhone/iPod touch _only_
 
    @author:    Manuel Gebele
 ---------------------------------------------------------------------------- */
@interface MGJSONParser : NSObject {
@private
    MGJSONEventAgent *_eventAgent; // Informs the client about parsing events.
    NSMutableString   *_message;    // Global JSON message.
    MGJSONParserErrorCode _errorCode; // Global error code.
    MGJSONParseError *_parseError; // Passed to the delegates parse error method.
    BOOL _abortParsing;             // Indicates if the parser should stop parsing.
}

// Returns a parser object.
+ (MGJSONParser *)parserWithMessage:(NSString *)message delegate:(id)delegate;

// Starts the parsing operation.
- (MGJSONParserErrorCode)parse;

@end
