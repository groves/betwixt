//
// Betwixt - Copyright 2011 Three Rings Design

#import "BTNode.h"
#import "BTNode+Package.h"
#import "BTMode.h"

@implementation BTNode

-  (id)init {
    if (!(self = [super init])) return nil;
    _attached = [[RAUnitSignal alloc] init];
    _detached = [[RAUnitSignal alloc] init];
    return self;
}

- (void)detach {
    [_parent removeNode:self];
}

- (BTMode*) root {
    if ([_parent isKindOfClass:[BTMode class]]) return (BTMode*)_parent;
    return _parent.root;
}

- (RAConnectionGroup*)conns {
    if (_conns == nil) _conns = [[RAConnectionGroup alloc] init];
    return _conns;
}

@synthesize parent=_parent, attached=_attached, detached=_detached;
@end

@implementation BTNode (package)

- (void)removeInternal {
    _parent = nil;
    [self.detached emit];
    [_attached disconnectAll];
    [_detached disconnectAll];
    [_conns disconnectAll];
}

@end