//
// Betwixt - Copyright 2012 Three Rings Design

#import "BTSignalTask.h"
#import "BTNode+Protected.h"

@implementation BTSignalTask {
    __weak RAReactor* _sig;
}

+ (BTSignalTask*)waitForSignal:(RAReactor*)signal {
    return [[BTSignalTask alloc] initWithSignal:signal];
}

- (id)initWithSignal:(RAReactor*)sig {
    if (!(self = [super init])) {
        return nil;
    }
    _sig = sig;
    return self;
}

- (void)attached {
    [super attached];
    if (_sig == nil) {
        NSLog(@"BTSignalTask: signal was destroyed. Task will never complete");
    } else {
        [self.conns onReactor:_sig connectUnit:^{
            [self detach];
        }];
    }
}

@end
