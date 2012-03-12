//
// Betwixt - Copyright 2012 Three Rings Design

#import <Foundation/Foundation.h>

@class GDataXMLElement;

@interface BTMovieResourceKeyframe : NSObject {
@public
    int index, duration;
    float x, y, rotation, scaleX, scaleY;
    float pivotX, pivotY;
    float alpha;
    BOOL visible;
    NSString* libraryItem;
    NSString* label;
}

- (id)initWithIndex:(int)index translationScale:(float)transScale xml:(GDataXMLElement*)frameEl;
- (id)initFlipbookNamed:(NSString*)name withIndex:(int)index xml:(GDataXMLElement*)frameEl;

@end
