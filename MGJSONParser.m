// -----------------------------------------------------------------------------
//  MGJSONParser.m
//  MGJSON
//
//  MGAOP is available under *either* the terms of the modified BSD license
//  *or* the MIT License (2008). See http://opensource.org/licenses/alphabetical
//  for full text.
// 
//  Copyright (c) 2010-2011, Manuel Gebele. 
// -----------------------------------------------------------------------------

#import "MGJSONParser.h"
#import "MGJSONEventAgent.h"

#pragma mark Internal-Usage-Only

@interface MGJSONParser ()
- (void)stickAndTriggerParseError:(MGJSONParserErrorCode)errorCode;
- (void)parseObject;
- (void)parseList;
- (void)parseValue;
- (void)parseString:(BOOL)triggerStringValue;
- (void)parseBoolean:(unichar)actChar;
- (void)parseNull;
- (void)parseNumber;
- (void)parseField;
- (void)parseEscapedChar:(unichar *)escapedChar fromIndex:(int *)index;
- (unichar)extractQuadHexValueFromIndex:(int *)index;
- (unichar) readFirstNonWhitespace;
@end

@implementation MGJSONParser

#pragma mark Finalization-And-Initialization

// -----------------------------------------------------------------------------
- (void)dealloc {
// -----------------------------------------------------------------------------

    [_eventAgent release]; _eventAgent = nil;
    [_parseError release]; _parseError = nil;
    
    [super dealloc];
}

// -----------------------------------------------------------------------------
- (id)initWithMessage:(NSString *)message delegate:(id)delegate {
// -----------------------------------------------------------------------------

    id retval;
    
    retval = [super init];
    if (!retval) {
        /*
         * NOTE:
         * This is the first internal error which could occurr.
         */
        NSLog(@"unable to allocate parser handle");
        return retval;
    }

    if (!message) {
        NSLog(@"cannot parse a <code>nil</code> message");
        return NO;
    }
    _message = [NSMutableString stringWithString:message];

    _eventAgent = [[MGJSONEventAgent alloc] initWithDelegate:delegate];
    if (!_eventAgent) {
        /*
         * NOTE:
         * This is the second internal error which could occurr.
         */
        NSLog(@"unable to allocate <code>_eventAgent</code> handle");
    } else {
        /* Set the global error code to success. */
        _errorCode = MGJSONParserSuccessErrorCode;
        _parseError = [[MGJSONParseError alloc] init];
        _abortParsing = NO;
    }
        
    return retval;
}

#define kObjectStartToken '{'
#define kObjectEndToken   '}'
#define kListStartToken   '['
#define kListEndToken     ']'
#define kEmptyToken       ' '
#define kTabulatorToken   '\t'
#define kNewlineToken     '\n'
#define kCarriageRetToken '\r'
#define kDoubleQuoteToken '"'
#define kListValueToken   ','
#define kBackslashToken   '\\'
#define kBackspaceToken   '\t'
#define kFormfeedToken    'f'
#define kSlashToken       '/'
#define kSeperatorToken   ':' // name : value

#pragma mark Programmers-Interface

// -----------------------------------------------------------------------------
+ (MGJSONParser *)parserWithMessage:(NSString *)message delegate:(id)delegate {
// -----------------------------------------------------------------------------
    
    return [[[MGJSONParser alloc] initWithMessage:message delegate:delegate]
            autorelease];
}

// -----------------------------------------------------------------------------
- (MGJSONParserErrorCode)parse {
// -----------------------------------------------------------------------------

    unichar intro;
    
    /*
     * A message related to JSON _must_ start with either a '{' character
     * (Object context) or with a '[' character (List context).
     */
    intro = [_message characterAtIndex:0];
    if (intro != kObjectStartToken && intro != kListStartToken) {
        [self stickAndTriggerParseError:MGJSONParserInvalidMessageErrorCode];
        return _errorCode;
    }
    [_eventAgent fireParserDidStartMessage:self];
    
    switch (intro) {
    case kObjectStartToken:
        [self parseObject];
        break;
    case kListStartToken:
        [self parseList];
        break;
    default:
        /* NEVER_REACHED */
        break;
    }
    
    // Clean document?
    unichar actChar = [self readFirstNonWhitespace];
    if (actChar != 65535 && actChar != ' ')
        [self stickAndTriggerParseError:MGJSONParserUncleanMessageErrorCode];
    [_eventAgent fireParserDidEndMessage:self];
    
    return _errorCode;
}

#pragma mark Proper-Parsing-Methods-And-Helpers

// -----------------------------------------------------------------------------
// Called to trim the global JSON message.  This method does nothing else as
// far as build a substring from the actually JSON message and assign this
// substring as new string to our message.
//
- (void)trimMessageFromIndex:(int)index {
// -----------------------------------------------------------------------------
    //_message = (NSMutableString *)[_message substringFromIndex:index];
    [_message deleteCharactersInRange:NSMakeRange(0, index)]; // Much faster ...
}

// -----------------------------------------------------------------------------
// Writes the last read char back to global JSON message.
//
- (void)writeLastCharBack:(unichar)lastChar {
// -----------------------------------------------------------------------------
    //_message = [NSMutableString stringWithFormat:@"%c%@", lastChar, _message];
    [_message insertString:[NSString stringWithCharacters:&lastChar length:1] atIndex:0]; // Much faster ...
}

// -----------------------------------------------------------------------------
// This method is just a helper to get the first non whitespace character from
// the global JSON message.
//
- (unichar) readFirstNonWhitespace {
// -----------------------------------------------------------------------------
    
    int actChar = 65535;
    BOOL isNonWhitespace = NO;
    
    int i;
    int len = [_message length];
    for (i = 0; i < len && !isNonWhitespace; i++) {
        actChar = [_message characterAtIndex:i];
        switch (actChar) {
        case kEmptyToken:
        case kTabulatorToken:
        case kNewlineToken:
        case kCarriageRetToken:
            break;
        default:
            // Ha, got it ...
            isNonWhitespace = YES;
        }
    }
    [self trimMessageFromIndex:i];
    
    return (unichar)actChar;
}

// -----------------------------------------------------------------------------
- (unichar)readNextChar {
// -----------------------------------------------------------------------------

    if ([_message length] < 1) {
        NSLog(@"JSON message has arrived its end");
        return 1;
    }
    
    unichar nextChar = [_message characterAtIndex:0];
    [self trimMessageFromIndex:1];
    
    return nextChar;
}

// Parse error report messages.
static const char *errorMsg[] = {
    /*  0 */ "_DUMMY_",
    /*  1 */ "internal error occured",
    /*  2 */ "invalid JSON message",
    /*  3 */ "invalid object start token",
    /*  4 */ "invalid object end token",
    /*  5 */ "invalid list start token",
    /*  6 */ "invalid list end token",
    /*  7 */ "invalid list",
    /*  8 */ "invalid string value",
    /*  9 */ "invalid escape character",
    /*  a */ "illegal hexadecimal number",
    /*  b */ "invalid boolean value",
    /*  c */ "invalid null value",
    /*  d */ "invalid digit value",
    /*  e */ "invalid character at start of value",
    /*  f */ "invalid name field, '\"' expected",
    /* 10 */ "invalid field seperator, ':' expected",
    /* 11 */ "unexpected trailing character",
};

// -----------------------------------------------------------------------------
- (void)stickAndTriggerParseError:(MGJSONParserErrorCode)errorCode {
// -----------------------------------------------------------------------------
    
    NSString *arg = nil;
    
    switch (errorCode) {
    case MGJSONParserInternalErrorCode:
    case MGJSONParserInvalidMessageErrorCode:
    case MGJSONParserObjectStartErrorCode:
    case MGJSONParserObjectEndErrorCode:
    case MGJSONParserListStartErrorCode:
    case MGJSONParserListEndErrorCode:
    case MGJSONParserInvalidListErrorCode:
    case MGJSONParserInvalidStringErrorCode:
    case MGJSONParserInvalidEscapeErrorCode:
    case MGJSONParserInvalidQuadHexErrorCode:
    case MGJSONParserInvalidBooleanErrorCode:
    case MGJSONParserInvalidNullErrorCode:
    case MGJSONParserInvalidDigitErrorCode:
    case MGJSONParserInvalidValueCharacterErrorCode:
    case MGJSONParserInvalidFieldNameErrorCode:
    case MGJSONParserInvalidFieldSeperatorErrorCode:
    case MGJSONParserUncleanMessageErrorCode:
        arg = [NSString stringWithUTF8String:errorMsg[errorCode]];
        _errorCode = errorCode;
        _parseError.error
        = [NSError errorWithDomain:@"MGJSON"
                              code:NSNotFound
                          userInfo:[NSDictionary dictionaryWithObject:(arg)
                            forKey:NSLocalizedDescriptionKey]];
        break;
    default:
        /* NEVER_REACHED */
        break;
    }
    
    // Finally inform the client/delegate that an error has happened.
    [_eventAgent fireParser:self parseErrorOccurred:_parseError];
}

// -----------------------------------------------------------------------------
- (void)parseField {
// -----------------------------------------------------------------------------

    unichar actChar;
    
    actChar = [self readFirstNonWhitespace];
    [self writeLastCharBack:actChar];
    if (actChar != kDoubleQuoteToken) {
        [self stickAndTriggerParseError:MGJSONParserInvalidFieldNameErrorCode];
        _abortParsing = YES;
        return;
    }
    [self parseString:NO]; // This also triggers the startField callback!
    if (_abortParsing)
        return;
    
    actChar = [self readFirstNonWhitespace];
    if (actChar != kSeperatorToken) {
        [self stickAndTriggerParseError:MGJSONParserInvalidFieldSeperatorErrorCode];
        _abortParsing = YES;
        return;
    }
    [self parseValue];
    if (_abortParsing)
        return;
    [_eventAgent fireParserDidEndField:self];
}

// -----------------------------------------------------------------------------
- (void)parseObject {
// -----------------------------------------------------------------------------

    unichar intro, actChar;
    
    intro = [self readFirstNonWhitespace];
    if (intro != kObjectStartToken) {
        [self stickAndTriggerParseError:MGJSONParserObjectStartErrorCode];
        _abortParsing = YES;
        return;
    }
    [_eventAgent fireParserDidStartObject:self];
    
    actChar = [self readFirstNonWhitespace];
    [self writeLastCharBack:actChar];
    if (actChar != kObjectEndToken) {
        [self parseField];
        if (_abortParsing)
            return;
    }
    
    BOOL objectHasEnded = NO;
    while (!objectHasEnded) {
        actChar = [self readFirstNonWhitespace];
        if (actChar == kListValueToken) {
            [self parseField];
            if (_abortParsing)
                return;
            
            continue;
        }
        if (actChar == kObjectEndToken) {
            objectHasEnded = YES;
            
            continue;
        }
        
        // At this point we've detected an
        // invalid object.
        [self stickAndTriggerParseError:MGJSONParserObjectEndErrorCode];
        _abortParsing = YES;
        return;
    }
    [_eventAgent fireParserDidEndObject:self];
}

// -----------------------------------------------------------------------------
- (void)parseList {
// -----------------------------------------------------------------------------

    unichar intro, actChar;
    
    intro = [self readFirstNonWhitespace];
    if (intro != kListStartToken) {
        [self stickAndTriggerParseError:MGJSONParserListStartErrorCode];
        _abortParsing = YES;
        return;
    }
    [_eventAgent fireParserDidStartList:self];
    
    actChar = [self readFirstNonWhitespace];
    [self writeLastCharBack:actChar];
    if (actChar != kListEndToken) {
        [self parseValue];
        if (_abortParsing)
            return;
    }
    
    BOOL listHasEnded = NO;
    while (!listHasEnded) {
        actChar = [self readFirstNonWhitespace];
        if (actChar == kListValueToken) {
            [self parseValue];
            if (_abortParsing)
                return;
            
            continue;
        }
        if (actChar == kListEndToken) {
            listHasEnded = YES;
           
            continue;
        }
        
        // At this point we've detected an
        // invalid list.
        [self stickAndTriggerParseError:MGJSONParserInvalidListErrorCode];
        _abortParsing = YES;
        return;
    }
    [_eventAgent fireParserDidEndList:self];
}

// -----------------------------------------------------------------------------
- (void)parseBoolean:(unichar)actChar {
// -----------------------------------------------------------------------------

    NSRange range;
    
    if (actChar == 't' && [_message length] >= 4)
        range = NSMakeRange(0, 4);
    else if (actChar == 'f' && [_message length] >= 5)
        range = NSMakeRange(0, 5);
    else {
        [self stickAndTriggerParseError:MGJSONParserInvalidBooleanErrorCode];
        _abortParsing = YES;
        return;
    } 
    
    NSString *boolean = [_message substringWithRange:range];
    if ([boolean isEqual:@"true"] || [boolean isEqual:@"false"])
        [_eventAgent fireParser:self foundBoolean:boolean];
    else {
        [self stickAndTriggerParseError:MGJSONParserInvalidBooleanErrorCode];
        _abortParsing = YES;
    }
    [self trimMessageFromIndex:range.length];
}

// -----------------------------------------------------------------------------
- (void)parseNull {
// -----------------------------------------------------------------------------

    NSRange range = NSMakeRange(0, 4);
    
    if ([_message length] < 4) {
        [self stickAndTriggerParseError:MGJSONParserInvalidNullErrorCode];
        _abortParsing = YES;
        return;
    }
    
    NSString *null = [_message substringWithRange:range];
    if ([null isEqual:@"null"])
        [_eventAgent fireParserFoundNull:self];
    else {
        [self stickAndTriggerParseError:MGJSONParserInvalidNullErrorCode];
        _abortParsing = YES;
    }
    [self trimMessageFromIndex:range.length];
}

// -----------------------------------------------------------------------------
- (NSString *)digitToken {
// -----------------------------------------------------------------------------

    unichar actChar;
    NSString *retChar = nil;
    
    actChar = [self readNextChar];
    switch (actChar) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
        retChar = [NSString stringWithCharacters:&actChar length:1];
        break;
    default:
        [self stickAndTriggerParseError:MGJSONParserInvalidDigitErrorCode];
        _abortParsing = YES;
        break;
}
    
    return retChar;
}

// -----------------------------------------------------------------------------
- (NSString *)nonZeroDigitToken {
// -----------------------------------------------------------------------------
    
    unichar actChar;
    NSString *retChar = nil;
    
    actChar = [self readNextChar];
    switch (actChar) {
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
        retChar = [NSString stringWithCharacters:&actChar length:1];
        break;
    default:
        [self stickAndTriggerParseError:MGJSONParserInvalidDigitErrorCode];
        _abortParsing = YES;
        break;
    }
    
    return retChar;
}

// -----------------------------------------------------------------------------
- (NSString *)digitStringToken {
// -----------------------------------------------------------------------------

    NSMutableString *stringToken = [NSMutableString string];
    
    BOOL gotNonDigit = NO;
    while (!gotNonDigit) {
        unichar actChar = [self readNextChar];
        switch (actChar) {
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            [stringToken appendString:[NSString stringWithCharacters:&actChar length:1]];
            
            break;
        default:
            gotNonDigit = YES;
            [self writeLastCharBack:actChar];
                
            break;
        }
    }
    
    return stringToken;
}

// -----------------------------------------------------------------------------
- (NSString *)extractFractionalComponent {
// -----------------------------------------------------------------------------
    
    unichar actChar;
    NSMutableString *number = [NSMutableString string];

    actChar = [self readNextChar];
    if (actChar == '.') {
        [number appendString:@"."];
        NSString *digit = [self digitToken];
        /*
         * NOTE:
         * An error could be happened at this point.
         */
        if (_abortParsing)
            return nil;
        [number appendString:digit];
        [number appendString:[self digitStringToken]];
    } else
        [self writeLastCharBack:actChar];
    
    return number;
}

// -----------------------------------------------------------------------------
- (NSString *)possibleSign {
// -----------------------------------------------------------------------------

    unichar actChar;
    NSString *sign = nil;
    
    actChar = [self readNextChar];
    if (actChar == '-')
        sign = @"-";
    else if (actChar == 'E')
        sign = @"E";
    else
        [self writeLastCharBack:actChar];
    
    return sign;
}

// -----------------------------------------------------------------------------
- (NSString *)extractExponent {
// -----------------------------------------------------------------------------

    unichar actChar;
    NSMutableString *number = [NSMutableString string];
    
    actChar = [self readNextChar];
    if (actChar == '.' || actChar == 'E') {
        [number appendString:@"E"];
        NSString *sign = [self possibleSign];
        if (sign)
            [number appendString:sign];
        NSString *digit = [self digitToken];
        /*
         * NOTE:
         * An error could be happened at this point.
         */
        if (_abortParsing)
            return nil;
        [number appendString:digit];
        [number appendString:[self digitStringToken]];
    } else
        [self writeLastCharBack:actChar];
    
    return number;
}

// -----------------------------------------------------------------------------
- (NSString *)extractNumber {
// -----------------------------------------------------------------------------

    unichar actChar;
    NSMutableString *number = [NSMutableString string];
    
    NSString *fract = nil;
    NSString *expo = nil;
    
    actChar = [self readNextChar];
    if (actChar == '0') {
        [number appendString:@"0"];
        fract = [self extractFractionalComponent];
        /*
         * NOTE:
         * An error could be happened at this point.
         */
        if (_abortParsing)
            return nil;
        [number appendString:fract];
        
        expo = [self extractExponent];
        /*
         * NOTE:
         * An error could be happened at this point.
         */
        if (_abortParsing)
            return nil;
        [number appendString:expo];
        
    } else {
        [self writeLastCharBack:actChar];
        NSString *digit = [self nonZeroDigitToken];
        /*
         * NOTE:
         * An error could be happened at this point.
         */
        if (_abortParsing)
            return nil;
        [number appendString:digit];
        [number appendString:[self digitStringToken]];
        fract = [self extractFractionalComponent];
        /*
         * NOTE:
         * An error could be happened at this point.
         */
        if (_abortParsing)
            return nil;
        [number appendString:fract];
        
        expo = [self extractExponent];
        /*
         * NOTE:
         * An error could be happened at this point.
         */
        if (_abortParsing)
            return nil;
        [number appendString:expo];
    }
    return number;
}

// -----------------------------------------------------------------------------
- (void)parseNumber {
// -----------------------------------------------------------------------------

    unichar actChar;
    NSMutableString *number = [NSMutableString string];

    actChar = [self readNextChar];
    if (actChar == '-')
        [number appendString:@"-"];
    else
        [self writeLastCharBack:actChar];
    
    NSString *tmp = [self extractNumber];
    /*
     * NOTE:
     * An error could be happened at this point.
     */
    if (_abortParsing)
        return;
    [number appendString:tmp];
    
    // Inform delegate ...
    [_eventAgent fireParser:self foundNumber:number];
}

// -----------------------------------------------------------------------------
- (void)parseValue {
// -----------------------------------------------------------------------------

    unichar actChar;
    
    actChar = [self readFirstNonWhitespace];
    switch (actChar) {
    // string
    case kDoubleQuoteToken:
        [self writeLastCharBack:actChar];
            [self parseString:YES];
        
        break;
    // true false
    case 't':
    case 'f':
        [self writeLastCharBack:actChar];
        [self parseBoolean:actChar];
            
        break;
    // null
    case 'n':
        [self writeLastCharBack:actChar];
        [self parseNull];
            
        break;
    // digit
    case '-':
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
        [self writeLastCharBack:actChar];
        [self parseNumber];
            
        break;
    // object
    case kObjectStartToken:
        [self writeLastCharBack:actChar];
        [self parseObject];
        
        break;
    // list
    case kListStartToken:
        [self writeLastCharBack:actChar];
        [self parseList];
        
        break;
    // error
    default:
        [self stickAndTriggerParseError:MGJSONParserInvalidValueCharacterErrorCode];
        _abortParsing = YES;
        
        break;
    }
}

// -----------------------------------------------------------------------------
- (void)getRawString:(NSMutableString *)string forChar:(unichar)actChar {
// -----------------------------------------------------------------------------

    NSMutableString *tmp;
    
    tmp = [[NSMutableString alloc] init]; 
    [tmp appendString:[NSString stringWithCharacters:&actChar length:1]];
    
    BOOL canConvert = [tmp canBeConvertedToEncoding:NSASCIIStringEncoding];
    if (!canConvert)
        [string appendString:[NSString stringWithFormat:@"\\u%04x", actChar]];
    else
        [string appendString:tmp];

    [tmp release];
}

// -----------------------------------------------------------------------------
// Inspired by TouchJSON.
//
- (void)getSerializedString:(NSMutableString *)string {
// -----------------------------------------------------------------------------

    NSRange range = NSMakeRange(0, [string length]);
    
    //[string replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:range];
    [string replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:range];
    [string replaceOccurrencesOfString:@"/" withString:@"\\/" options:0 range:range];
    [string replaceOccurrencesOfString:@"\b" withString:@"\\b" options:0 range:range];
    [string replaceOccurrencesOfString:@"\f" withString:@"\\f" options:0 range:range];
    [string replaceOccurrencesOfString:@"\n" withString:@"\\n" options:0 range:range];
    [string replaceOccurrencesOfString:@"\r" withString:@"\\r" options:0 range:range];
    [string replaceOccurrencesOfString:@"\t" withString:@"\\t" options:0 range:range];
}
    
// -----------------------------------------------------------------------------
- (void)parseString:(BOOL)triggerStringValue {
// -----------------------------------------------------------------------------

    NSMutableString *string = [NSMutableString string]; // Our parsed string.
    unichar intro, escapedChar;

    intro = [_message characterAtIndex:0];
    if (intro != kDoubleQuoteToken) {
        [self stickAndTriggerParseError:MGJSONParserInvalidStringErrorCode];
        _abortParsing = YES;
        return;
    }
    
    /*
     * Here we build the string which the client
     * gets back in the foundString callback.
     */
    int index = 1;
    BOOL stringHasEnded = NO;
    while (!stringHasEnded) {
        unichar actChar = [_message characterAtIndex:index];
        if (actChar == kBackslashToken) {
            [self parseEscapedChar:&escapedChar fromIndex:&index];
            if (_abortParsing)
                return;
            [self getRawString:string forChar:escapedChar];
            
        } else if (actChar == kDoubleQuoteToken)
            stringHasEnded = YES;
        else 
            [self getRawString:string forChar:actChar];
        
        index++;
    }
    [self getSerializedString:string];
    [self trimMessageFromIndex:index];
    
    if (triggerStringValue)
        [_eventAgent fireParser:self foundString:string];
    else // Field start
        [_eventAgent fireParser:self didStartField:string];
}

// -----------------------------------------------------------------------------
- (void)parseEscapedChar:(unichar *)escapedChar fromIndex:(int *)index {
// -----------------------------------------------------------------------------

    unichar introChar;
    
    *index = *index + 1; // Go to backslash + 1
    introChar = [_message characterAtIndex:*index];
    switch (introChar) {
    case kDoubleQuoteToken:
        *escapedChar = kDoubleQuoteToken;
        break;
    case kBackslashToken:
        *escapedChar = kBackslashToken;
        break;
    case kSlashToken:
        *escapedChar = kSlashToken;
        break;
    case 'b':
        *escapedChar = kBackspaceToken;
        break;
    case 'f':
        *escapedChar = kFormfeedToken;
        break;
    case 'n':
        *escapedChar = kNewlineToken;
        break;
    case 'r':
        *escapedChar = kCarriageRetToken;
        break;
    case 't':
        *escapedChar = kTabulatorToken;
        break;
    case 'u':
        *escapedChar = [self extractQuadHexValueFromIndex:index];
        break;
    default:
        [self stickAndTriggerParseError:MGJSONParserInvalidEscapeErrorCode];
        _abortParsing = YES;
        break;
    } 
}

// -----------------------------------------------------------------------------
- (unichar)extractQuadHexValueFromIndex:(int *)index {
// -----------------------------------------------------------------------------
    
    unsigned hexVal = 0;
    int offset = 4; // A 4-digit hex value.
    
    // Go to first hex digit
    *index = *index + 1;
    
    NSRange range = NSMakeRange(*index, offset);
    NSString *hexString = [_message substringWithRange:range];
    
    BOOL isValidHex;
    
    isValidHex = [[NSScanner scannerWithString:hexString] scanHexInt:&hexVal];
    if (!isValidHex) {
        [self stickAndTriggerParseError:MGJSONParserInvalidQuadHexErrorCode];
        _abortParsing = YES;
    }
    
    *index = *index + 3;
    
    return (unichar)hexVal;
}

@end
