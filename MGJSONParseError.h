// -----------------------------------------------------------------------------
//  MGJSONParseError.h
//  MGJSON
//
//  MGAOP is available under *either* the terms of the modified BSD license
//  *or* the MIT License (2008). See http://opensource.org/licenses/alphabetical
//  for full text.
// 
//  Copyright (c) 2010-2011, Manuel Gebele. 
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>

enum {
    MGJSONParserSuccessErrorCode,      // Indicates that the parsing operation
                                        // was successfully done.
    MGJSONParserInternalErrorCode,     // Indicates an internal error.
    MGJSONParserInvalidMessageErrorCode, // Invalid JSON message.
    MGJSONParserObjectStartErrorCode, // Invalid object start character.
    MGJSONParserObjectEndErrorCode,   // Invalid object end character.
    MGJSONParserListStartErrorCode,   // Invalid list start character.
    MGJSONParserListEndErrorCode,    // Invalid list start character.
    MGJSONParserInvalidListErrorCode,
    MGJSONParserInvalidStringErrorCode,
    MGJSONParserInvalidEscapeErrorCode,
    MGJSONParserInvalidQuadHexErrorCode,
    MGJSONParserInvalidBooleanErrorCode,
    MGJSONParserInvalidNullErrorCode,
    MGJSONParserInvalidDigitErrorCode,
    MGJSONParserInvalidValueCharacterErrorCode,
    MGJSONParserInvalidFieldNameErrorCode,
    MGJSONParserInvalidFieldSeperatorErrorCode,
    MGJSONParserUncleanMessageErrorCode,
};
typedef NSUInteger MGJSONParserErrorCode;

@interface MGJSONParseError : NSObject {
    NSError *error;
    MGJSONParserErrorCode errorCode;
}
@property (nonatomic, retain) NSError *error;
@property (readwrite) MGJSONParserErrorCode errorCode;

@end
