//
// Betwixt - Copyright 2012 Three Rings Design

@class BTMode;
@protocol BTNodeContainer;

@interface BTNode : NSObject {
@package
    id<BTNodeContainer> _parent;
    RAUnitSignal* _detached;
    RAConnectionGroup* _conns;
    BOOL _isDetached;
}

/// Detaches the node from its mode. Once a node has been detached, it can't
/// be reattached or reused.
- (void)detach;

/// "Keyed" objects are uniquely identified in their containing BTMode
/// No two nodes can share the same key in a given mode.
/// You can retrieve a keyed node from its mode with [BTMode nodeForKey:]
/// You can use BT_STATIC_KEYS(@"foo", @"bar") for easy implementation.
/// Alternately, if your keys are defined dynamically, you can use BT_KEYS(...)
- (NSArray*)keys;

/// Multiple objects can belong to the same group.
/// You can retrieve all objects in a group with [BTMode nodesForGroup:]
/// You can use BT_STATIC_GROUPS(@"foo", @"bar") for easy implementation.
/// Alternately, if your groups are defined dynamically, you can use BT_GROUPS(...)
- (NSArray*)groups;

@property(nonatomic,readonly) RAUnitSignal* detached;
@property(nonatomic,readonly) BTMode* mode;
@property(nonatomic,readonly) RAConnectionGroup* conns;
@property(nonatomic,readonly) id<BTNodeContainer> parent;
@property(nonatomic,readonly) BOOL isAttached;
@property(nonatomic,readonly) BOOL isDetached;

@end

/// Helper macros for implementing the -keys and -groups methods

#define BT_GROUPS(...) \
    NSMutableArray* values = [NSMutableArray arrayWithObjects:__VA_ARGS__, nil]; \
    NSArray* parentGroups = super.groups; \
    if (parentGroups != nil) { [values addObjectsFromArray:parentGroups]; } \
    return values;

#define BT_KEYS(...) \
    NSMutableArray* values = [NSMutableArray arrayWithObjects:__VA_ARGS__, nil]; \
    NSArray* parentKeys = super.keys; \
    if (parentKeys != nil) { [values addObjectsFromArray:parentKeys]; } \
    return values;
    
#define BT_STATIC_GROUPS(...) \
    static NSMutableArray* gValues = nil;  \
    if (gValues == nil) { \
        gValues = [NSMutableArray arrayWithObjects:__VA_ARGS__, nil]; \
        NSArray* parentGroups = super.groups; \
        if (parentGroups != nil) { [gValues addObjectsFromArray:parentGroups]; } \
    } \
    return gValues;

#define BT_STATIC_KEYS(...) \
    static NSMutableArray* gValues = nil;  \
    if (gValues == nil) { \
        gValues = [NSMutableArray arrayWithObjects:__VA_ARGS__, nil]; \
        NSArray* parentKeys = super.keys; \
        if (parentKeys != nil) { [gValues addObjectsFromArray:parentKeys]; } \
    } \
    return gValues;
