//
// Betwixt - Copyright 2012 Three Rings Design

#import "BTMovieResourceKeyframe.h"
#import "GDataXMLNode+Extensions.h"
#import "SPMatrix+Extensions.h"

@implementation BTMovieResourceKeyframe
- (id)initWithIndex:(int)theIndex translationScale:(float)transScale xml:(GDataXMLElement*)frameEl {
    if (!(self = [super init])) return nil;
    
    index = theIndex;
    duration = [frameEl intAttribute:@"duration" defaultVal:1];
    label = [frameEl stringAttribute:@"label" defaultVal:nil];
    libraryItem = [frameEl stringAttribute:@"ref" defaultVal:nil];
    
    SPPoint* loc = [frameEl pointAttribute:@"loc" defaultVal:nil];
    if (loc != nil) {
        x = loc.x * transScale;
        y = loc.y * transScale;
    }
    
    SPPoint* scale = [frameEl pointAttribute:@"scale" defaultVal:nil];
    if (scale != nil) {
        scaleX = scale.x;
        scaleY = scale.y;
    } else {
        scaleX = 1;
        scaleY = 1;
    }
    
    SPPoint* pivot = [frameEl pointAttribute:@"pivot" defaultVal:nil];
    if (pivot != nil) {
        pivotX = pivot.x * transScale;
        pivotY = pivot.y * transScale;
    }
    
    rotation = [frameEl floatAttribute:@"rotation" defaultVal:0];
    alpha = [frameEl floatAttribute:@"alpha" defaultVal:1];
    visible = [frameEl boolAttribute:@"visible" defaultVal:YES];
    
    return self;
}


- (id)initFlipbookNamed:(NSString*)name withIndex:(int)theIndex xml:(GDataXMLElement*)frameEl {
    if (!(self = [super init])) return nil;
    index = theIndex;
    duration = [frameEl intAttribute:@"duration" defaultVal:1];
    label = [frameEl stringAttribute:@"label" defaultVal:nil];

    libraryItem = [NSString stringWithFormat:@"%@_flipbook_%d", name, index];

    scaleX = 1;
    scaleY = 1;
    return self;

}
@end
