
#import "PieceView.h"

@interface PieceView (Private)

- (void)draw:(NSImage *)theImage;

- (void)moveCluster:(NSEvent *)theEvent;
- (void)joinCluster:(NSEvent *)theEvent;

@end

@implementation PieceView

#define DIST ((CGFloat)2)
#define CLOSE(_v1, _v2) \
        ((_v1) > (_v2) ? \
        ((_v1) - (_v2) < DIST) : ((_v2) - (_v1) < DIST))


static id checkResult[2];

+ (id *)checkCluster:(BTree *)theCluster
		dimX:(NSInteger)dimx
		dimY:(NSInteger)dimy
{
    NSMutableArray *allLeaves = [theCluster leaves];
    PieceView *piece = nil, *refpiece = nil;
    BOOL fail;
    NSInteger curleaf, refx, refy;
    NSPoint reforigin, origin;

    refpiece = [allLeaves objectAtIndex:0];

    refx = [refpiece x];
    refy = [refpiece y];

    reforigin = [refpiece frame].origin;

    fail = NO;

    for(curleaf=1; curleaf<[allLeaves count]; curleaf++){
        piece  = (PieceView *)
            [allLeaves objectAtIndex:curleaf];
        origin = [piece frame].origin;

        if(!CLOSE(reforigin.x+([piece x]-refx)*dimx,
                  origin.x) ||
           !CLOSE(reforigin.y+([piece y]-refy)*dimy,
                  origin.y)){
            fail = YES;
            break;
        }
    }

    [allLeaves release];

    if(fail==YES){
        checkResult[0] = refpiece;
        checkResult[1] = piece;

        return checkResult;
    }

    return NULL;
}

+ (BTree *)doJoin:(BTree *)cl1 and:(BTree *)cl2
              all:(NSMutableArray *)allClusters
{
    BTree *newCluster;
    
    newCluster = 
        [[BTree alloc] 
            initWithPairFirst:cl1
            andSecond:cl2];
    [allClusters removeObject:cl1];
    [allClusters removeObject:cl2];
    [allClusters addObject:newCluster];

    // NSLog(@"clusters: %"PRIuPTR"\n", [allClusters count]);

    [newCluster
        inorderWithPointer:(void *)newCluster
        sel:@selector(setCluster:)];

    return newCluster;
}

static NSInteger count;

- (id)initWithImage:(NSImage *)theImage
	       dimX:(NSInteger)dimx
	       dimY:(NSInteger)dimy
                loc:(NSPoint)theLoc
               posX:(NSInteger)posx outOf:(NSInteger)pxval
               posY:(NSInteger)posy outOf:(NSInteger)pyval
               left:(BTYPE)bleft
              right:(BTYPE)bright
              upper:(BTYPE)bupper
              lower:(BTYPE)blower
{
    NSSize size;
    NSRect iframe;
    NSInteger padding, shift;

    self = [super init];
    if (!self)
      return nil;

    piece_width = dimx;
    piece_height = dimy;
    size = [theImage size];

    tag = count++;

    done = NO;

    padding  = (((NSInteger)size.width))%PIECE_WIDTH;
    if(padding){
        padding = PIECE_WIDTH-padding;
    }
    padleft  = padding/2;
    padright = padding-padleft;

    padding  = (((NSInteger)size.height))%PIECE_HEIGHT;
    if(padding){
        padding = PIECE_HEIGHT-padding;
    }
    padlower = padding/2;
    padupper = padding-padlower;

    iframe.origin.x = theLoc.x; // -BOUNDARY;
    iframe.origin.y = theLoc.y; // -BOUNDARY;

    iframe.size.width  = PIECE_WIDTH +2*BOUNDARY;
    iframe.size.height = PIECE_HEIGHT+2*BOUNDARY;

    [super initWithFrame:iframe];

    image = [[NSImage alloc] initWithSize:iframe.size];
    complete = [[NSImage alloc] initWithSize:iframe.size];

    x = posx;
    y = posy;

    px = pxval;
    py = pyval;

    left  = bleft;
    right = bright;
    upper = bupper;
    lower = blower;

    clip = [NSBezierPath bezierPath];
    [clip moveToPoint:NSMakePoint(BOUNDARY, BOUNDARY)];

    if(left!=BORDER){
        [clip relativeLineToPoint:
                  NSMakePoint(0, PIECE_HEIGHT/2-OFFS)];

        shift = (left==INNER ? BOUNDARY : -BOUNDARY);
        [clip relativeCurveToPoint:
                  NSMakePoint(0, 2*OFFS)
              controlPoint1:NSMakePoint(shift, -OFFS)
              controlPoint2:NSMakePoint(shift, 3*OFFS)];
    }
    [clip lineToPoint:
              NSMakePoint(BOUNDARY, PIECE_HEIGHT+BOUNDARY)];

    if(upper!=BORDER){
        [clip relativeLineToPoint:
                  NSMakePoint(PIECE_WIDTH/2-OFFS, 0)];

        shift = (upper==INNER ? -BOUNDARY : BOUNDARY);
        [clip relativeCurveToPoint:
                  NSMakePoint(2*OFFS, 0)
              controlPoint1:NSMakePoint(-OFFS, shift)
              controlPoint2:NSMakePoint(3*OFFS, shift)];
    }
    [clip lineToPoint:
              NSMakePoint(PIECE_WIDTH+BOUNDARY, PIECE_HEIGHT+BOUNDARY)];
    
    if(right!=BORDER){
        [clip relativeLineToPoint:
                  NSMakePoint(0, -(PIECE_HEIGHT/2-OFFS))];

        shift = (right==INNER ? -BOUNDARY : BOUNDARY);
        [clip relativeCurveToPoint:
                  NSMakePoint(0, -2*OFFS)
              controlPoint1:NSMakePoint(shift, OFFS)
              controlPoint2:NSMakePoint(shift, -3*OFFS)];
    }
    [clip lineToPoint:
              NSMakePoint(BOUNDARY+PIECE_WIDTH, BOUNDARY)];

    if(lower!=BORDER){
        [clip relativeLineToPoint:
                  NSMakePoint(-(PIECE_WIDTH/2-OFFS), 0)];

        shift = (lower==INNER ? BOUNDARY : -BOUNDARY);
        [clip relativeCurveToPoint:
                  NSMakePoint(-2*OFFS, 0)
              controlPoint1:NSMakePoint(OFFS, shift)
              controlPoint2:NSMakePoint(-3*OFFS, shift)];
    }

    [clip closePath];
    [clip retain];

    boundary = [NSBezierPath bezierPath];
    [boundary moveToPoint:NSMakePoint(BOUNDARY, BOUNDARY)];

    if(left==BORDER){
	[boundary 
	    lineToPoint:
		NSMakePoint(BOUNDARY, PIECE_HEIGHT+BOUNDARY)];
    }
    else{
	[boundary 
	    moveToPoint:
		NSMakePoint(BOUNDARY, PIECE_HEIGHT+BOUNDARY)];
    }

    if(upper==BORDER){
	[boundary 
	    lineToPoint:
		NSMakePoint(PIECE_WIDTH+BOUNDARY, PIECE_HEIGHT+BOUNDARY)];
    }
    else{
	[boundary 
	    moveToPoint:
		NSMakePoint(PIECE_WIDTH+BOUNDARY, PIECE_HEIGHT+BOUNDARY)];
    }

    if(right==BORDER){
	[boundary 
	    lineToPoint:
		NSMakePoint(BOUNDARY+PIECE_WIDTH, BOUNDARY)];
    }
    else{
	[boundary 
	    moveToPoint:
		NSMakePoint(BOUNDARY+PIECE_WIDTH, BOUNDARY)];
    }

    if(lower==BORDER){
	[boundary 
	    lineToPoint:
		NSMakePoint(BOUNDARY, BOUNDARY)];
    }
    else{
	[boundary 
	    moveToPoint:
		NSMakePoint(BOUNDARY, BOUNDARY)];
    }

    // [boundary closePath];
    [boundary retain];

    [self draw:theImage];

    return self;
}

- setCluster:(BTree *)theCluster
{
    cluster = theCluster;
    return self;
}

- (BTree *)cluster
{
    return cluster;
}

- setDocument:(Document *)theDocument
{
    doc = theDocument;
    return self;
}

- (Document *)document
{
    return doc;
}

- (NSInteger)setDone:(NSInteger)dflag
{
    NSInteger prev = done;

    if(prev!=dflag){
	done = dflag;
    }

    return prev;
}


- (void)drawRect:(NSRect)aRect
{
    [clip addClip];
    [(done==YES ? complete : image) 
	compositeToPoint:aRect.origin
	fromRect:aRect
	operation:NSCompositeCopy];
}

- (void)draw:(NSImage *)theImage
{
    NSRect imageRect = {{ 0, 0 }, [theImage size] };
    NSRect pieceRect = 
    {{ -padleft+x*PIECE_WIDTH, -padlower+y*PIECE_HEIGHT },
     { PIECE_WIDTH, PIECE_HEIGHT}};
    NSPoint dest;

    NSImage *imgs[2] = { image, complete };
    NSInteger idx;

    for(idx=0; idx<2; idx++){
	NSBezierPath *lim;
	[imgs[idx] lockFocus];

	pieceRect.origin.x -= BOUNDARY;
	pieceRect.origin.y -= BOUNDARY;
	pieceRect.size.width  += 2*BOUNDARY;
	pieceRect.size.height += 2*BOUNDARY;

	pieceRect = NSIntersectionRect(imageRect, pieceRect);

	[clip addClip];

	dest.x =  padleft +BOUNDARY+pieceRect.origin.x-x*PIECE_WIDTH;
	dest.y =  padlower+BOUNDARY+pieceRect.origin.y-y*PIECE_HEIGHT;

	[theImage compositeToPoint:dest
		  fromRect:pieceRect
		  operation:NSCompositeCopy];

	if(!x && padleft){
	    [[NSColor blueColor] set];
	    PSrectfill(BOUNDARY, 0,
		       padleft, PIECE_BD_HEIGHT);
	}
	if(x==px-1 && padright){
	    [[NSColor blueColor] set];
	    PSrectfill(BOUNDARY+PIECE_WIDTH-padright, 0,
		       padright, PIECE_BD_HEIGHT);
	}
	if(!y && padlower){
	    [[NSColor blueColor] set];
	    PSrectfill(0, BOUNDARY,
		       PIECE_BD_WIDTH, padlower);
	}
	if(y==py-1 && padupper){
	    [[NSColor blueColor] set];
	    PSrectfill(0, BOUNDARY+PIECE_HEIGHT-padupper,
		       PIECE_BD_WIDTH, padupper);
	}

	lim = (idx==1 ? boundary : clip);

	[[NSColor redColor] set];
	[lim setLineWidth:4];
	[lim stroke];

	[[NSColor greenColor] set];
	[lim setLineWidth:2];
	[lim stroke];

	[imgs[idx] unlockFocus];
    }
}

- (void)outline:(CGFloat *)delta
{
    NSRect frame = [self frame];

    PSgsave();
    PStranslate(frame.origin.x+delta[0], 
                frame.origin.y+delta[1]);

    [[NSColor blackColor] set];
    [clip setLineWidth:4];
    [clip stroke];

    [[NSColor whiteColor] set];
    [clip setLineWidth:2];
    [clip stroke];

    PSgrestore();
}

- (void)showInvalid
{
    NSColor 
        *red   = [NSColor redColor],
        *green = [NSColor greenColor];

    [self lockFocus];

    [green set];
    PSsetlinewidth(6.0);
    PSmoveto(BOUNDARY, BOUNDARY);
    PSlineto(BOUNDARY+PIECE_WIDTH, BOUNDARY+PIECE_HEIGHT);
    PSmoveto(BOUNDARY, BOUNDARY+PIECE_HEIGHT);
    PSlineto(BOUNDARY+PIECE_WIDTH, BOUNDARY);
    PSstroke();

    [red set];
    PSsetlinewidth(4.0);
    PSmoveto(BOUNDARY, BOUNDARY);
    PSlineto(BOUNDARY+PIECE_WIDTH, BOUNDARY+PIECE_HEIGHT);
    PSmoveto(BOUNDARY, BOUNDARY+PIECE_HEIGHT);
    PSlineto(BOUNDARY+PIECE_WIDTH, BOUNDARY);
    PSstroke();

    [[self window] flushWindow];

    [self unlockFocus];
}


- (void)bbox:(NSRect *)bbox
{
    *bbox = NSUnionRect(*bbox, [self frame]);
}

- (BTYPE)left
{
    return left;
}

- (BTYPE)right
{
    return right;
}

- (BTYPE)upper
{
    return upper;
}

- (BTYPE)lower
{
    return lower;
}

- (NSInteger)tag
{
    return tag;
}



- (void)shiftView:(CGFloat *)delta
{
    NSRect cframe = [self frame];

    cframe.origin.x += delta[0];
    cframe.origin.y += delta[1];
    [self setFrame:cframe];

    [self setNeedsDisplay:YES];
}

- (NSInteger)x
{
    return x;
}

- (NSInteger)y
{
    return y;
}


- (PTYPE)classifyPoint:(NSPoint)pt
{
    NSPoint
        leftout, leftin,
        rightout, rightin,
        lowerout, lowerin,
        upperout, upperin;
    
    leftout.x = BOUNDARY/2;
    leftout.y = BOUNDARY+PIECE_HEIGHT/2;

    leftin.x = 3*BOUNDARY/2;
    leftin.y = BOUNDARY+PIECE_HEIGHT/2;

    rightout.x = BOUNDARY+PIECE_WIDTH+BOUNDARY/2;
    rightout.y = BOUNDARY+PIECE_HEIGHT/2;

    rightin.x = BOUNDARY+PIECE_WIDTH-BOUNDARY/2;
    rightin.y = BOUNDARY+PIECE_HEIGHT/2;

    lowerout.x = BOUNDARY+PIECE_WIDTH/2;
    lowerout.y = BOUNDARY/2;

    lowerin.x = BOUNDARY+PIECE_WIDTH/2;
    lowerin.y = 3*BOUNDARY/2;

    upperout.x = BOUNDARY+PIECE_WIDTH/2;
    upperout.y = BOUNDARY+PIECE_HEIGHT+BOUNDARY/2;

    upperin.x = BOUNDARY+PIECE_WIDTH/2;
    upperin.y = BOUNDARY+PIECE_HEIGHT-BOUNDARY/2;

    #define DELTA(p1, p2) ((p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y))

    if(DELTA(pt, leftout)<RADSQ){
        return LEFTOUT;
    }
    if(DELTA(pt, leftin)<RADSQ){
        return LEFTIN;
    }

    if(DELTA(pt, rightout)<RADSQ){
        return RIGHTOUT;
    }
    if(DELTA(pt, rightin)<RADSQ){
        return RIGHTIN;
    }

    if(DELTA(pt, lowerout)<RADSQ){
        return LOWEROUT;
    }
    if(DELTA(pt, lowerin)<RADSQ){
        return LOWERIN;
    }

    if(DELTA(pt, upperout)<RADSQ){
        return UPPEROUT;
    }
    if(DELTA(pt, upperin)<RADSQ){
        return UPPERIN;
    }

    #undef DELTA

    if(BOUNDARY<=pt.x && pt.x<=BOUNDARY+PIECE_WIDTH &&
       BOUNDARY<=pt.y && pt.y<=BOUNDARY+PIECE_HEIGHT){
        return CENTER;
    }

    return EXTERIOR;
}

#define PAD 7

- (void)joinCluster:(NSEvent *)theEvent
{
    NSPoint startp, curp, posp, cposp;
    NSEvent *curEvent = theEvent;
    NSRect bbox, wbbox;
    BOOL first = YES;
    NSWindow *win = [self window];
    NSView *sv = [self superview];
    PTYPE pos, cpos;
    PieceView *clicked;
    
    startp = [curEvent locationInWindow];
    posp   = [self convertPoint:startp fromView: nil];
    startp = [sv convertPoint:startp fromView: nil];

    pos = [self classifyPoint:posp];
    if(!((pos==LEFTOUT && left==OUTER) ||
         (pos==RIGHTOUT && right==OUTER) ||
         (pos==LOWEROUT && lower==OUTER) ||
         (pos==UPPEROUT && upper==OUTER) ||
         (pos==LEFTIN && left==INNER) ||
         (pos==RIGHTIN && right==INNER) ||
         (pos==LOWERIN && lower==INNER) ||
         (pos==UPPERIN && upper==INNER))){
	NSBeep();
        return;
    }

    do {
        if(first==NO){
            // [sv displayRect:bbox];
            [win restoreCachedImage];
        }
        first = NO;

        curp = [curEvent locationInWindow];
        curp = [sv convertPoint:curp fromView: nil];
        
        if(startp.x<curp.x){
            bbox.origin.x = startp.x;
            bbox.size.width = curp.x-startp.x;
        }
        else{
            bbox.origin.x = curp.x;
            bbox.size.width = startp.x-curp.x;
        }
        if(startp.y<curp.y){
            bbox.origin.y = startp.y;
            bbox.size.height = curp.y-startp.y;
        }
        else{
            bbox.origin.y = curp.y;
            bbox.size.height = startp.y-curp.y;
        }

        bbox.origin.x -= PAD;
        bbox.origin.y -= PAD;
        bbox.size.width  += 2*PAD;
        bbox.size.height += 2*PAD;

        wbbox = [sv convertRect:bbox toView:nil];

        [win cacheImageInRect:wbbox];
        [sv lockFocus];

        PSsetgray(0.0);
        PSsetlinewidth(3);
        PSarc(startp.x, startp.y, 3, 0, 360);
        PSarc(curp.x, curp.y, 3, 0, 360);
        PSmoveto(startp.x, startp.y);
        PSlineto(curp.x, curp.y);
        PSstroke();

        PSsetgray(1.0);
        PSsetlinewidth(1);
        PSarc(startp.x, startp.y, 1, 0, 360);
        PSarc(curp.x, curp.y, 1, 0, 360);
        PSmoveto(startp.x, startp.y);
        PSlineto(curp.x, curp.y);
        PSstroke();

        [sv unlockFocus];
        [win flushWindow];


        curEvent = 
            [[self window] 
                nextEventMatchingMask: 
                    NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    } while([curEvent type] != NSLeftMouseUp);

    // [sv displayRect:bbox];
    [win restoreCachedImage];
    [win flushWindow];

    curp  = [curEvent locationInWindow];
    cposp = [[sv superview] convertPoint:curp fromView: nil];
        
    if((clicked  = (PieceView *)[sv hitTest:cposp])!=nil &&
        ((NSView *)clicked) != sv){
        BOOL fail = NO;
        NSMutableArray *leaves, *cleaves, *allClusters;
        NSInteger curleaf, curcleaf;
        CGFloat delta[2];
        NSPoint origin;
        NSRect lframe = [self frame], cframe = [clicked frame];

        BTree *newCluster;
        BTree *ccluster = [clicked cluster];
        if(ccluster==cluster){
            NSBeep();
            return;
        }

        cposp = [clicked convertPoint:curp fromView: nil];
        cpos  = [clicked classifyPoint:cposp];

        if(!((pos==LEFTOUT  &&
              cpos==RIGHTIN && [clicked right]==INNER) ||
             (pos==RIGHTOUT &&
              cpos==LEFTIN  && [clicked left]==INNER) ||
             (pos==LOWEROUT &&
              cpos==UPPERIN && [clicked upper]==INNER) ||
             (pos==UPPEROUT &&
              cpos==LOWERIN && [clicked lower]==INNER) ||
	     (pos==LEFTIN  &&
              cpos==RIGHTOUT && [clicked right]==OUTER) ||
             (pos==RIGHTIN &&
              cpos==LEFTOUT  && [clicked left]==OUTER) ||
             (pos==LOWERIN &&
              cpos==UPPEROUT && [clicked upper]==OUTER) ||
             (pos==UPPERIN &&
              cpos==LOWEROUT && [clicked lower]==OUTER))){
            NSBeep();
            return;
        }

        switch(pos){
            case LEFTOUT: case LEFTIN:
                origin.x = lframe.origin.x-PIECE_WIDTH;
                origin.y = lframe.origin.y;
                break;
            case RIGHTOUT: case RIGHTIN:
                origin.x = lframe.origin.x+PIECE_WIDTH;
                origin.y = lframe.origin.y;
                break;
            case LOWEROUT: case LOWERIN:
                origin.x = lframe.origin.x;
                origin.y = lframe.origin.y-PIECE_HEIGHT;
                break;
            case UPPEROUT: case UPPERIN:
                origin.x = lframe.origin.x;
                origin.y = lframe.origin.y+PIECE_HEIGHT;
                break;
        }

        delta[0] = origin.x - cframe.origin.x;
        delta[1] = origin.y - cframe.origin.y;

        leaves = [cluster leaves]; cleaves = [ccluster leaves];

        for(curleaf=0; curleaf<[leaves count]; curleaf++){
            PieceView *piece1 = 
                (PieceView *)[leaves objectAtIndex:curleaf];
            NSPoint loc1 = [piece1 frame].origin;
            for(curcleaf=0; curcleaf<[cleaves count]; curcleaf++){
                PieceView *piece2 = 
                    (PieceView *)[cleaves objectAtIndex:curcleaf];
                NSPoint loc2 = [piece2 frame].origin;
                NSPoint shifted = { 
                    loc2.x+delta[0],
                    loc2.y+delta[1]
                };

                if((CLOSE(loc1.x, shifted.x-PIECE_WIDTH) &&
                    CLOSE(loc1.y, shifted.y)) &&
                   ([piece1 right]==BORDER ||
                    [piece2 left]==BORDER ||
                    [piece1 right]!=-[piece2 left])){
                    fail = YES;
                    break;
                }

                if((CLOSE(loc1.x, shifted.x+PIECE_WIDTH) &&
                    CLOSE(loc1.y, shifted.y)) &&
                   ([piece1 left]==BORDER ||
                    [piece2 right]==BORDER ||
                    [piece1 left]!=-[piece2 right])){
                    fail = YES;
                    break;
                }

                if((CLOSE(loc1.x, shifted.x) &&
                    CLOSE(loc1.y, shifted.y-PIECE_HEIGHT)) &&
                   ([piece1 upper]==BORDER ||
                    [piece2 lower]==BORDER ||
                    [piece1 upper]!=-[piece2 lower])){
                    fail = YES;
                    break;
                }

                if((CLOSE(loc1.x, shifted.x) &&
                    CLOSE(loc1.y, shifted.y+PIECE_HEIGHT)) &&
                   ([piece1 lower]==BORDER ||
                    [piece2 upper]==BORDER ||
                    [piece1 lower]!=-[piece2 upper])){
                    fail = YES;
                    break;
                }
            }
            if(fail==YES){
                break;
            }
        }

        if(fail==YES){
            NSBeep();
        }
        else{
            allClusters = [doc clusters];
            newCluster = 
                [PieceView doJoin:cluster and:ccluster 
                           all:allClusters];

            [ccluster inorderWithPointer:delta
                      sel:@selector(shiftView:)];
            [sv setNeedsDisplay:YES];

            [[self window] setDocumentEdited:YES];

            if([allClusters count]==1 &&
               [PieceView checkCluster:newCluster
			  dimX:piece_width
			  dimY:piece_height]==NULL){
		[doc setDone:YES];
                NSRunAlertPanel(_(@"Congratulations!"),
                                _(@"Puzzle solved."),
                                _(@"Ok"), nil, nil);
            }
        }

        [leaves release];
        [cleaves release];
    }
}


- (void)moveCluster:(NSEvent *)theEvent
{
    NSPoint startp, curp;
    NSEvent *curEvent = theEvent;
    CGFloat delta[2];
    NSRect bbox = {{0, 0}, {0, 0}}, wbbox;
    NSPoint orig;
    BOOL first = YES;
    NSWindow *win = [self window];
    NSView *sv = [self superview];
    
    startp = [curEvent locationInWindow];
    startp = [self convertPoint:startp fromView: nil];

    [cluster inorderWithPointer:&bbox
             sel:@selector(bbox:)];
    orig = bbox.origin;

    do {
        if(first==NO){
            // [sv displayRect:bbox];
            [win restoreCachedImage];
        }
        first = NO;

        curp = [curEvent locationInWindow];
        curp = [self convertPoint:curp fromView: nil];

        delta[0] = curp.x - startp.x;
        delta[1] = curp.y - startp.y;

        bbox.origin.x = orig.x + delta[0];
        bbox.origin.y = orig.y + delta[1];

        wbbox = [sv convertRect:bbox toView:nil];

        [win cacheImageInRect:wbbox];
        [sv lockFocus];
 
        if(delta[0]!=(CGFloat)0 || delta[1]!=(CGFloat)0){
           [cluster inorderWithPointer:delta 
                     sel:@selector(outline:)];
        }

        [sv unlockFocus];
        [win flushWindow];

        curEvent = 
            [win 
                nextEventMatchingMask: 
                    NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    } while([curEvent type] != NSLeftMouseUp);

    // [sv displayRect:bbox];
    [win restoreCachedImage];
    [win flushWindow];

    [cluster inorderWithPointer:delta
             sel:@selector(shiftView:)];
    [sv setNeedsDisplay:YES];

    [[self window] setDocumentEdited:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSArray *all = [[self superview] subviews];
    NSMutableArray *pieces = [NSMutableArray array];
    NSEnumerator *pieceEnum;
    PieceView *piece;
    NSInteger isJoin;
    [pieces addObjectsFromArray:all];

    // the clicked view is first
    [pieces removeObject:self];
    [pieces insertObject:self atIndex:0];

    pieceEnum = [pieces objectEnumerator];
    isJoin = [theEvent modifierFlags] & NSControlKeyMask;

    while((piece = [pieceEnum nextObject])!=nil){
	NSPoint startp = [theEvent locationInWindow];
	PTYPE pos;
	startp = [piece convertPoint:startp fromView: nil];

        pos = [piece classifyPoint:startp];
            
	if(!(pos==EXTERIOR ||
	     (pos==LEFTOUT && left!=OUTER) ||
	     (pos==RIGHTOUT && right!=OUTER) ||
	     (pos==LOWEROUT && lower!=OUTER) ||
	     (pos==UPPEROUT && upper!=OUTER) ||
	     (!isJoin && pos==LEFTIN && left==INNER) ||
	     (!isJoin && pos==RIGHTIN && right==INNER) ||
	     (!isJoin && pos==LOWERIN && lower==INNER) ||
	     (!isJoin && pos==UPPERIN && upper==INNER))){
	    break;
	}
    }

    if(piece==nil){
	return;
    }

    if(isJoin){
        [piece joinCluster:theEvent];
    }
    else{
        [piece moveCluster:theEvent];
    }

    [doc updateChangeCount:NSChangeDone];
    // [[self window] setDocumentEdited:YES];
}

#define SEP 7

- (void)extractFromCluster
{
    NSMutableArray *allClusters = [doc clusters];
    BTree *item, *other, *first, *second,
        *parent, *pparent;
    CGFloat delta[2];
    NSRect bbox = {{0, 0}, {0, 0}};

    item = [cluster findLeaf:self];
        
    parent = [item parent];
    if(parent==nil){
        NSBeep();
        return;
    }


    pparent = [parent parent];
    if(pparent==nil){
        [parent
            inorderWithPointer:&bbox
            sel:@selector(bbox:)];

        first = [parent first];
        second = [parent second];

        [allClusters removeObject:parent];
        [allClusters addObject:first];
        [allClusters addObject:second];

        [first
            inorderWithPointer:(void *)first
            sel:@selector(setCluster:)];
        [second
            inorderWithPointer:(void *)second
            sel:@selector(setCluster:)];

        [first setParent:nil];
        [second setParent:nil];
    }
    else{
        [pparent
            inorderWithPointer:&bbox
            sel:@selector(bbox:)];

        other = ([parent first]==item ? 
                 [parent second] : [parent first]);
        if([pparent first]==parent){
            [pparent setFirst:other];
        }
        else{
            [pparent setSecond:other];
        }

        [allClusters addObject:item];
        [item setParent:nil];
        [self setCluster:item];
    }

    delta[0] = SEP; delta[1] = SEP;
    [self shiftView:delta];

    bbox.size.width += SEP; bbox.size.height += SEP;
    [[self superview] setNeedsDisplayInRect:bbox];
}

- (void)splitCluster
{
    NSMutableArray *allClusters = [doc clusters];
    BTree *leftcl, *rightcl;
    CGFloat delta[2];
    NSRect bbox = {{0, 0}, {0, 0}};

    leftcl = [cluster first];
    rightcl = [cluster second];

    if(leftcl==nil && rightcl==nil){
        NSBeep();
        return;
    }

    [cluster
        inorderWithPointer:&bbox
        sel:@selector(bbox:)];

    [allClusters removeObject:cluster];

    delta[0] = SEP; delta[1] = SEP;
    [allClusters addObject:leftcl];
    [leftcl
        inorderWithPointer:(void *)leftcl
        sel:@selector(setCluster:)];
    [leftcl inorderWithPointer:delta
            sel:@selector(shiftView:)];

    delta[0] = -SEP; delta[1] = -SEP;
    [allClusters addObject:rightcl];
    [rightcl
        inorderWithPointer:(void *)rightcl
        sel:@selector(setCluster:)];
    [rightcl inorderWithPointer:delta
             sel:@selector(shiftView:)];

    bbox.origin.x -= SEP; bbox.origin.y -= SEP;
    bbox.size.width += 2*SEP; bbox.size.height += 2*SEP;
    [[self superview] setNeedsDisplayInRect:bbox];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    if([theEvent modifierFlags] & NSControlKeyMask){
        [self extractFromCluster];
    }
    else{
        [self splitCluster];
    }

    // [self setNeedsDisplay:YES];

    [doc updateChangeCount:NSChangeDone];
    [doc setDone:NO];

    // [[self window] setDocumentEdited:YES];
}

- (NSString *)toString
{
    NSPoint pos = [self frame].origin;

    return 
        [NSString stringWithFormat:@"%"PRIiPTR" %"PRIiPTR" %"PRIiPTR" %"PRIiPTR" %"PRIiPTR" %"PRIiPTR" %"PRIiPTR" %"PRIiPTR" %"PRIiPTR"\n",
                  tag, x, y, left, right, upper, lower,
                  (pos.x), (pos.y)];
}

@end
