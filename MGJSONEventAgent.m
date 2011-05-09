// -----------------------------------------------------------------------------
//  MGJSONEventAgent.m
//  MGJSON
//
//  MGJSON is available under *either* the terms of the modified BSD license
//  *or* the MIT License (2008). See http://opensource.org/licenses/alphabetical
//  for full text.
// 
//  Copyright (c) 2010-2011, Manuel Gebele. 
// -----------------------------------------------------------------------------

#import "MGJSONEventAgent.h"
#import "MGJSONEventDelegate.h"
#import "MGJSONParseError.h"

@implementation MGJSONEventAgent

@synthesize isInternalError;

// -----------------------------------------------------------------------------
- (id)initWithDelegate:(id)delegate {
// -----------------------------------------------------------------------------

    id retval;
    
    retval = [super init];
    if (!retval)
        return retval;
    _delegate = delegate;
    isInternalError = NO;
    
    return retval;
}

// -----------------------------------------------------------------------------
- (BOOL)isDelegateValid {
// -----------------------------------------------------------------------------
    
    /*
     * If the delegate is <code>nil</code>, this usually means
     * that the client won't be notified about parsing events.  Note that
     * this isn't an error!
     */
    return (_delegate) ? YES : NO;
}

// -----------------------------------------------------------------------------
- (BOOL)isParserValid:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------
    
    return (parser) ? YES : NO;
}


// -----------------------------------------------------------------------------
- (BOOL)isStringValid:(NSString *)string {
// -----------------------------------------------------------------------------
    
    return (string) ? YES : NO;
}


// -----------------------------------------------------------------------------
- (BOOL)isErrorValid:(MGJSONParseError *)error {
// -----------------------------------------------------------------------------
    
    return (error) ? YES : NO;
}

// -----------------------------------------------------------------------------
- (BOOL)fireParserDidStartMessage:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parserDidStartMessage:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parserDidStartMessage:parser];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;
}

// -----------------------------------------------------------------------------
- (BOOL)fireParserDidEndMessage:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parserDidEndMessage:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parserDidEndMessage:parser];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;
}

// -----------------------------------------------------------------------------
- (BOOL)fireParserDidStartObject:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parserDidStartObject:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parserDidStartObject:parser];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;
}

// -----------------------------------------------------------------------------
- (BOOL)fireParserDidEndObject:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parserDidEndObject:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parserDidEndObject:parser];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;
}

// -----------------------------------------------------------------------------
- (BOOL)fireParserDidStartList:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------

    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parserDidStartList:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parserDidStartList:parser];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;    
}

// -----------------------------------------------------------------------------
- (BOOL)fireParserDidEndList:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parserDidEndList:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parserDidEndList:parser];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;    
}

// -----------------------------------------------------------------------------
- (BOOL)fireParser:(MGJSONParser *)parser didStartField:(NSString *)fieldName {
// -----------------------------------------------------------------------------

    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    if (![self isStringValid:fieldName]) {
        NSLog(@"<code>fieldName</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parser:didStartField:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parser:parser didStartField:fieldName];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;        
}

// -----------------------------------------------------------------------------
- (BOOL)fireParserDidEndField:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parserDidEndField:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parserDidEndField:parser];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;            
}

// -----------------------------------------------------------------------------
- (BOOL)fireParser:(MGJSONParser *)parser foundNumber:(NSString *)number {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    if (![self isStringValid:number]) {
        NSLog(@"<code>number</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parser:foundNumber:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parser:parser foundNumber:number];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;        
}

// -----------------------------------------------------------------------------
- (BOOL)fireParser:(MGJSONParser *)parser foundString:(NSString *)string {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    if (![self isStringValid:string]) {
        NSLog(@"<code>string</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parser:foundString:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parser:parser foundString:string];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;        
}

// -----------------------------------------------------------------------------
- (BOOL)fireParser:(MGJSONParser *)parser foundBoolean:(NSString *)boolean {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    if (![self isStringValid:boolean]) {
        NSLog(@"<code>boolean</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parser:foundBoolean:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parser:parser foundBoolean:boolean];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;        
}

// -----------------------------------------------------------------------------
- (BOOL)fireParserFoundNull:(MGJSONParser *)parser {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parserFoundNull:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parserFoundNull:parser];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }
    
    return YES;            
}

// -----------------------------------------------------------------------------
- (BOOL)    fireParser:(MGJSONParser *)parser
    parseErrorOccurred:(MGJSONParseError *)parseError {
// -----------------------------------------------------------------------------
    
    if (![self isDelegateValid])
        return YES;
    if (![self isParserValid:parser]) {
        NSLog(@"<code>parser</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    if (![self isErrorValid:parseError]) {
        NSLog(@"<code>parseError</code> is nil");
        self.isInternalError = YES;
        return NO;
    }
    
    SEL sel = @selector(parser:parseErrorOccurred:);
    if ([_delegate respondsToSelector:sel])
        [_delegate parser:parser parseErrorOccurred:parseError];
    else {
#ifdef VERBOSE_MODE
        NSLog(@"delegate not conform to selector");
#endif
    }

    return YES;
}

@end
