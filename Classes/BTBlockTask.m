//
// Betwixt - Copyright 2011 Three Rings Design

#import "BTBlockTask.h"
#import "BTMode.h"

@implementation BTBlockTask

+ (BTBlockTask*)onAttach:(BTTaskBlock)block {
    BTBlockTask* task = [[BTBlockTask alloc] init];
    [task.attached connectUnit:^{
        block(task);
        [task detach];
    }];
    return task;
}

+ (BTBlockTask*)onEnterFrame:(BTTaskBlock)block {
    BTBlockTask* task = [[BTBlockTask alloc] init];
    [task.attached connectUnit:^{
        [task.conns addConnection:[task.root.enterFrame connectUnit:^{ block(task); }]];
    }];
    return task;
}
@end