//
// Betwixt - Copyright 2012 Three Rings Design

#import "BTInput.h"
#import "BTMode.h"
#import "SPTouchProcessor.h"
#import "SPTouch_Internal.h"

@class BTReaction;

@interface BTInputRegistration ()
- (id)initWithInput:(BTInput*)input reaction:(BTReaction*)reaction;
@end

// Reaction
@interface BTReaction : NSObject 
- (id)initWithRegion:(BTInputRegion*)region listener:(id<BTTouchListener>)listener;
@property(nonatomic,readonly) BTInputRegion* region;
@property(nonatomic,readonly) id<BTTouchListener> listener;
@end

@implementation BTInput

- (id)initWithMode:(BTMode*)mode {
    if (!(self = [super init])) {
        return nil;
    }
    _touchProcessor = [[SPTouchProcessor alloc] initWithRoot:mode.sprite];
    _reactions = [NSMutableArray array];
    return self;
}

- (id<BTTouchListener>)hitTest:(SPPoint*)globalPt {
    // take a snapshot of the regions list to avoid concurrent modification if reactions
    // are added or removed during processing
    NSArray* snapshot = [NSArray arrayWithArray:_reactions];
    for (int ii = snapshot.count - 1; ii >= 0; ii--) {
        BTReaction* r = [snapshot objectAtIndex:ii];
        if (r.region.hasExpired) {
            [_reactions removeObject:r];
        } else if (r.region.canTrigger && [r.region hitTest:globalPt]) {
            return r.listener;
        }
    }
    return nil;
}

- (void)processTouches:(NSSet*)touches {
    // we currently only process one touch
    // process new touches
    SPTouch* currentTouch = nil;
    
    if (_lastTouch != nil) {
        for (SPTouch* touch in touches) {
            if ((_lastTouch.globalX == touch.previousGlobalX &&
                 _lastTouch.globalY == touch.previousGlobalY) ||
                (_lastTouch.globalX == touch.globalX &&
                 _lastTouch.globalY == touch.globalY)) {
             
                // existing touch; update values
                _lastTouch.timestamp = touch.timestamp;
                _lastTouch.previousGlobalX = touch.previousGlobalX;
                _lastTouch.previousGlobalY = touch.previousGlobalY;
                _lastTouch.globalX = touch.globalX;
                _lastTouch.globalY = touch.globalY;
                _lastTouch.phase = touch.phase;
                _lastTouch.tapCount = touch.tapCount;
                    
                currentTouch = _lastTouch;
                break;
            }  
        }
    }
    
    if (currentTouch == nil) {
        // find a new touch
        for (SPTouch* touch in touches) {
            if (touch.phase == SPTouchPhaseBegan) {
                // new touch!
                currentTouch = [SPTouch touch];
                currentTouch.timestamp = touch.timestamp;
                currentTouch.globalX = touch.globalX;
                currentTouch.globalY = touch.globalY;
                currentTouch.previousGlobalX = touch.previousGlobalX;
                currentTouch.previousGlobalY = touch.previousGlobalY;
                currentTouch.phase = touch.phase;
                currentTouch.tapCount = touch.tapCount;
                
                break;
            }
        }
    }
    
    // Send the touch to our reactors
    BOOL handled = NO;
    if (currentTouch != nil) {
        SPPoint* touchPt = [SPPoint pointWithX:currentTouch.globalX y:currentTouch.globalY];
        switch (currentTouch.phase) {
        case SPTouchPhaseBegan:
            _activeListener = [self hitTest:touchPt];
            if (_activeListener != nil) {
                [_activeListener onTouchStart:touchPt];
            }
            handled = YES;
            break;
            
        case SPTouchPhaseMoved:
            if (_activeListener != nil) {
                [_activeListener onTouchMove:touchPt];
                handled = YES;
            }
            break;
            
        case SPTouchPhaseStationary:
            handled = (_activeListener != nil);
            break;
            
        case SPTouchPhaseEnded:
        case SPTouchPhaseCancelled:
            if (_activeListener != nil) {
                [_activeListener onTouchEnd:touchPt];
                _activeListener = nil;
                handled = YES;
            }
            break;
        }
    }
    
    _lastTouch = currentTouch;
    
    // If it wasn't handled by any reactors, let the touch processor do its thing
    if (!handled) {
        [_touchProcessor processTouches:touches];
    }
}

- (BTInputRegistration*)registerListener:(id<BTTouchListener>)listener forRegion:(BTInputRegion*)region {
    BTReaction* reaction = [[BTReaction alloc] initWithRegion:region listener:listener];
    [_reactions addObject:reaction];
    return [[BTInputRegistration alloc] initWithInput:self reaction:reaction];
}

- (void)removeAllListeners {
    [_reactions removeAllObjects];
    _activeListener = nil;
}
    
- (void)removeReaction:(BTReaction*)reaction {
    [_reactions removeObject:reaction];
}

@end


/// Input regions
@interface BTBlockTouchListener : NSObject <BTTouchListener>
- (id)initWithOnTouchStart:(BTTouchBlock)onTouchStart 
               onTouchMove:(BTTouchBlock)onTouchMove 
                onTouchEnd:(BTTouchBlock)onTouchEnd;
@end

@implementation BTInputRegion
- (id)initWithInput:(BTInput *)input {
    if (!(self = [super init])) {
        return nil;
    }
    _input = input;
    return self;
}
- (BOOL)canTrigger { return YES; }
- (BOOL)hasExpired { return NO; }
- (BOOL)hitTest:(SPPoint*)globalPt { return NO; }

- (BTInputRegistration*)registerListener:(id<BTTouchListener>)l {
    return [_input registerListener:l forRegion:self];
}

- (BTInputRegistration*)onTouchStart:(BTTouchBlock)onTouchStart 
                         onTouchMove:(BTTouchBlock)onTouchMove
                          onTouchEnd:(BTTouchBlock)onTouchEnd {
    return [self registerListener:[[BTBlockTouchListener alloc] initWithOnTouchStart:onTouchStart 
                                                                         onTouchMove:onTouchMove 
                                                                          onTouchEnd:onTouchEnd]];
    
}
- (BTInputRegistration*)onTouchStart:(BTTouchBlock)onTouchStart
                          onTouchEnd:(BTTouchBlock)onTouchEnd {
    return [self registerListener:[[BTBlockTouchListener alloc] initWithOnTouchStart:onTouchStart 
                                                                         onTouchMove:nil 
                                                                          onTouchEnd:onTouchEnd]];
    
}
- (BTInputRegistration*)onTouchStart:(BTTouchBlock)onTouchStart {
    return [self registerListener:[[BTBlockTouchListener alloc] initWithOnTouchStart:onTouchStart 
                                                                         onTouchMove:nil 
                                                                          onTouchEnd:nil]];
    
}
- (BTInputRegistration*)onTouchEnd:(BTTouchBlock)onTouchEnd {
    return [self registerListener:[[BTBlockTouchListener alloc] initWithOnTouchStart:nil 
                                                                         onTouchMove:nil 
                                                                          onTouchEnd:onTouchEnd]];
}
@end

@implementation BTScreenRegion
- (BOOL)hitTest:(SPPoint*)globalPt { return YES; }
+ (BTScreenRegion*)withInput:(BTInput *)input {
    return [[BTScreenRegion alloc] initWithInput:input];
}
@end


@implementation BTBoundsRegion {
@private
    SPRectangle* _bounds;
}
- (id)initWithInput:(BTInput*)input bounds:(SPRectangle*)bounds {
    if (!(self = [super initWithInput:input])) {
        return nil;
    }
    _bounds = bounds;
    return self;
}
- (BOOL)hitTest:(SPPoint*)globalPt { return [_bounds containsPoint:globalPt]; }
+ (BTBoundsRegion*)withInput:(BTInput *)input bounds:(SPRectangle *)bounds {
    return [[BTBoundsRegion alloc] initWithInput:input bounds:bounds];
}
@end


@implementation BTDisplayObjectRegion {
@private
    SPDisplayObject* _disp;
}
- (id)initWithInput:(BTInput*)input displayObject:(SPDisplayObject*)disp {
    if (!(self = [super initWithInput:input])) {
        return nil;
    }
    _disp = disp;
    return self;
}
- (BOOL)canTrigger { return _disp.visible; }
- (BOOL)hasExpired { return _disp.parent == nil; }
- (BOOL)hitTest:(SPPoint*)globalPt { 
    return ([_disp hitTestPoint:[_disp globalToLocal:globalPt] forTouch:NO] != nil);
}
+ (BTDisplayObjectRegion*)withInput:(BTInput *)input disp:(SPDisplayObject *)disp {
    return [[BTDisplayObjectRegion alloc] initWithInput:input displayObject:disp];
}
@end


@implementation BTReaction {
@protected
    BTInputRegion* _region;
    id<BTTouchListener>_listener;
}
- (id)initWithRegion:(BTInputRegion*)region listener:(id<BTTouchListener>)listener {
    if (!(self = [super init])) {
        return nil;
    }
    _region = region;
    _listener = listener;
    return self;
}
@synthesize region=_region, listener=_listener;
@end

@implementation BTInputRegistration {
@protected
    __weak BTInput* _input;
    __weak BTReaction* _reaction;
}
- (id)initWithInput:(BTInput*)input reaction:(BTReaction*)reaction {
    if (!(self = [super init])) {
        return nil;
    }
    _input = input;
    _reaction = reaction;
    return self;
}
- (void)cancel {
    [_input removeReaction:_reaction];
    _input = nil;
    _reaction = nil;
}
@end

@implementation BTBlockTouchListener {
    BTTouchBlock _onTouchStart;
    BTTouchBlock _onTouchMove;
    BTTouchBlock _onTouchEnd;
}

- (id)initWithOnTouchStart:(BTTouchBlock)onTouchStart onTouchMove:(BTTouchBlock)onTouchMove onTouchEnd:(BTTouchBlock)onTouchEnd {
    if (!(self = [super init])) {
        return nil;
    }
    _onTouchStart = onTouchStart;
    _onTouchMove = onTouchMove;
    _onTouchEnd = onTouchEnd;
    return self;
}

- (void)onTouchStart:(SPPoint *)globalPt {
    if (_onTouchStart != nil) {
        _onTouchStart(globalPt);
    }
}

- (void)onTouchMove:(SPPoint *)globalPt {
    if (_onTouchMove != nil) {
        _onTouchMove(globalPt);
    }
}

- (void)onTouchEnd:(SPPoint *)globalPt {
    if (_onTouchEnd != nil) {
        _onTouchEnd(globalPt);
    }
}

@end