/*
   Project: OresmeKit

   Copyright (C) 2011 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2011-08-21 23:58:53 +0200 by multix

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import <Foundation/Foundation.h>
#import <AppKit/NSView.h>

typedef enum
  {
    OKQuadrantCentered = 0,
    OKQuadrantI = 1,
    OKQuadrantII = 2,
    OKQuadrantIII = 3,
    OKQuadrantIV = 4,
    OKQuadrantAuto = 5
  } OKQuadrantPositioning;

@interface OKCartesius : NSView
{
  OKQuadrantPositioning quadrantPositioning;
  NSMutableArray *arrayX;
  NSMutableArray *arrayY;
}

-(NSMutableArray *)arrayX;
-(NSMutableArray *)arrayY;

@end


