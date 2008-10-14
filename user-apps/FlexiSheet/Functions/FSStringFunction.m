//  $Id: FSStringFunction.m,v 1.1 2008/10/14 15:04:29 hns Exp $
//
//  FSStringFunction.m
//  FlexiSheet
//
//  Created by Stefan Leuker on 08-OCT-2001.
//
//  Copyright (c) 2001-2004, Stefan Leuker.        All rights reserved.
//  
//  Redistribution and use in source and binary forms,  with or without
//  modification,  are permitted provided that the following conditions
//  are met:
//  
//  *  Redistributions of source code must retain the above copyright
//     notice,  this list of conditions and the following disclaimer.
//  
//  *  Redistributions  in  binary  form  must  reproduce  the  above
//     copyright notice,  this  list of conditions  and the following
//     disclaimer  in  the  documentation  and / or  other  materials
//     provided with the distribution.
//  
//  *  Neither the name  "FlexiSheet"  nor the names of its copyright
//     holders  or  contributors  may  be used  to endorse or promote
//     products  derived  from  this software  without specific prior
//     written permission.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT
//  LIMITED TO,  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND  FITNESS
//  FOR  A PARTICULAR PURPOSE  ARE  DISCLAIMED.  IN NO EVENT  SHALL THE
//  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO,  PROCUREMENT  OF  SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN
//  ANY WAY  OUT  OF  THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//  

#import "FSStringFunction.h"
#include <math.h>

@implementation FSStringFunction

+ (void)initialize
{
    [FSFunction registerFunction:self];
}

+ (NSString*)functionName
{
    return @"string";
}

+ (NSString*)functionGroup
{
    return @"String";
}

+ (int)numberOfOperands
{
    return 2;
}

- (id)initWithArguments:(NSArray*)args
{
    self = [super init];
    if (self) {
        _expression = [[args objectAtIndex:0] retain];
        _digits = [[args objectAtIndex:1] retain];
    }
    return self;
}

- (void)dealloc
{
    [_expression release];
    [_digits release];
    [super dealloc];
}

+ (FSFunction*)functionWithArguments:(NSArray*)arguments
{
    return [[[self alloc] initWithArguments:arguments] autorelease];
}

- (id)formulaValueForKeySet:(FSKeySet*)fs
/*" Returns a random value. "*/
{
    int       digits = [[_digits formulaValueForKeySet:fs] intValue];
    double    value =  [[_expression formulaValueForKeySet:fs] doubleValue];
    NSString *format = [NSString stringWithFormat:@"%%1.%if", digits];
    return [NSString stringWithFormat:format, value];
}

- (NSString*)creatorString
{
    return [NSString stringWithFormat:@"%@(%@, %@)", 
        [[self class] functionName],
        [_expression creatorString],
        [_digits creatorString]];
}

@end
