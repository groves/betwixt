//
// Betwixt - Copyright 2012 Three Rings Design

@class BTMode;
@protocol BTRegistration;

@protocol BTTouchListener
- (BOOL)onTouchStart:(SPTouch*)touch;
- (BOOL)onTouchMove:(SPTouch*)touch;
- (BOOL)onTouchEnd:(SPTouch*)touch;
@end

@interface BTInput : NSObject {
@protected
    SPDisplayObjectContainer* _root;
    NSMutableArray* _listeners;
    NSMutableSet *_currentTouches;
}

- (id)initWithRoot:(SPDisplayObjectContainer*)root;

- (void)processTouches:(NSSet*)touches;

- (id<BTRegistration>)registerListener:(id<BTTouchListener>)l;
- (void)removeAllListeners;

@end
