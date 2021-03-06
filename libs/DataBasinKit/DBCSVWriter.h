/* -*- mode: objc -*-
   Project: DataBasin

   Copyright (C) 2009-2014 Free Software Foundation

   Author: Riccardo Mottola

   Created: 2009-01-13 00:36:45 +0100 by multix

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

enum DBCSVLineBreakHandling
{
  DBCSVLineBreakNoChange = 0,
  DBCSVLineBreakDelete,
  DBCSVLineBreakReplaceWithSpace
};
typedef enum DBCSVLineBreakHandling DBCSVLineBreakHandling;

@protocol DBLoggerProtocol;

@interface DBCSVWriter : NSObject
{
  id<DBLoggerProtocol> logger;
  NSArray      *fieldNames;
  NSArray      *fieldTypes;
  NSFileHandle *file;
  NSString     *separator;
  BOOL         isQualified;
  NSString     *qualifier;
  NSString     *newLine;
  NSStringEncoding encoding;
  unsigned     bomLength;
  BOOL writeOrdered;
  DBCSVLineBreakHandling lineBreakHandling;
}

- (void)setQualifier: (NSString *)q;
- (void)setSeparator: (NSString *)sep;
- (void)setLineBreakHandling: (DBCSVLineBreakHandling)handling;
- (BOOL)writeFieldsOrdered;
- (void)setWriteFieldsOrdered:(BOOL)flag;
- (id)initWithHandle:(NSFileHandle *)fileHandle;
- (void)setLogger:(id<DBLoggerProtocol>)l;
- (void)setFieldNames: (id)obj andWriteThem: (BOOL)flag;
- (void)writeStart;
- (void)writeEnd;
- (void)writeDataSet:(NSArray *)array;
- (NSString *)formatOneLine:(id)data forHeader:(BOOL) headerFlag;
- (void)setStringEncoding: (NSStringEncoding) enc;

@end


