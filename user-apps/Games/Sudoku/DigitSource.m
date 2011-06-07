/* 
   Project: Sudoku
   DigitSource.m

   Copyright (C) 2007-2011 The Free Software Foundation, Inc

   Author: Marko Riedel

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "DigitSource.h"

@implementation DigitSource : NSView

static NSImage *dragImages[10] = {
  nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil
};

- initAtPoint:(NSPoint)loc withDigit:(int)dval
{
  NSRect frame = {
    { loc.x, loc.y }, { DIGIT_FIELD_DIM, DIGIT_FIELD_DIM }
  };
  [super initWithFrame:frame];

  digit = dval;

  if(dragImages[0]==nil){
    [self makeDragImages];
  }

  return self;
}

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)flag
{
  return NSDragOperationCopy;
}

- makeDragImages
{
  int dg;

  for(dg=1; dg<=10; dg++){
    NSImage *img =
      [[NSImage alloc] 
	initWithSize:NSMakeSize(DIGIT_FIELD_DIM, DIGIT_FIELD_DIM)];
    RETAIN(img);

    [img lockFocus];

    NSBezierPath 
      *bnds = [NSBezierPath bezierPathWithRect:[self bounds]];

    [[NSColor whiteColor] set];
    [bnds fill];

    [[NSColor blackColor] set];
    [bnds setLineWidth:4.0];
    [bnds stroke];

    NSFont *font = [NSFont boldSystemFontOfSize:DIGIT_FONT_SIZE];
    NSDictionary *attrDict =
      [NSDictionary dictionaryWithObjectsAndKeys:
			font, NSFontAttributeName, 
		    [NSColor blueColor], NSForegroundColorAttributeName,
		    nil];
    [font set];
    
    char str[2] = { (dg==10 ? '.' : '0' + dg), 0 };
    
    NSString *strObj = [NSString stringWithCString:str];
    NSSize strSize = [strObj sizeWithAttributes:attrDict];	    
    
    NSPoint loc =
      NSMakePoint((DIGIT_FIELD_DIM-strSize.width)/2,
		  (DIGIT_FIELD_DIM-strSize.height)/2);
    [strObj drawAtPoint:loc withAttributes:attrDict];
    
    [img unlockFocus];

    dragImages[dg-1] = img;
  }

  return self;
}

- (void)drawRect:(NSRect)aRec
{
  [dragImages[digit-1] compositeToPoint:NSMakePoint(0, 0) 
	     operation:NSCompositeCopy];
}

- (void)mouseDown:(NSEvent *)theEvent
{
  if([theEvent type]==NSLeftMouseDown){
        NSPasteboard *pboard =
	  [NSPasteboard pasteboardWithName:NSDragPboard];

        [pboard declareTypes:
		  [NSArray arrayWithObjects:DIGIT_TYPE, nil]
                owner:self];
	[pboard setString:
		  [NSString stringWithFormat:@"%d", digit]
		forType:DIGIT_TYPE];


        [self dragImage:dragImages[digit-1]
              at:NSMakePoint(0, 0)
              offset:NSMakeSize(0, 0)
              event:theEvent
              pasteboard:pboard
              source:self
              slideBack:YES];
  }

  return;
}

@end