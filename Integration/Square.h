//
//  Betwixt - Copyright 2011 Three Rings Design

#import <Foundation/Foundation.h>
#import "BTObject.h"

int SQUARES_ADDED;

int SQUARES_REMOVED;

@interface Square : BTObject {
@private
    SPQuad *_quad;
    NSString *_name;
    int _color;
}

- (id)initWithColor:(int)color andName:(NSString*)name;

@end
