#ifndef GO_BOARD_H
#define GO_BOARD_H

#include <AppKit/AppKit.h>
#include "StoneUI.h"

@protocol BoardOwner
- (void) playerShouldPutStoneAtLocation:(GoLocation)location;
@end

@interface Board : NSView
{
	Go *_go;
	NSImage *_woodTile;

	StoneUI *_shadow_stone;
	GoLocation mouseLocation;

	id <BoardOwner> __owner;

	NSArray *_verticalMarks;
	NSArray *_horizontalMarks;
	GoLocation lastLocation;
	GoLocation lastLastLocation;
	float shalpha;
	float lialpha;
	NSTimer *liTimer;
	BOOL isEditable;
}

- (id) initWithGo:(Go *)go;
- (void) setGo:(Go *)go;
- (void) setTileImage:(NSImage *)image;
- (GoLocation) goLocationForPoint:(NSPoint)p;
- (NSPoint) pointForGoLocation:(GoLocation)loc;
- (Go *) go;
- (void) setOwner:(id <BoardOwner>)owner;
- (void) setEditable:(BOOL)editable;
@end
#endif
