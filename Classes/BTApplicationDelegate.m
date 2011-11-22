//
//  Betwixt - Copyright 2011 Three Rings Design

#import "BTApplicationDelegate.h" 

@implementation BTApplicationDelegate

@synthesize defaultStack=_defaultStack;

- (id)init {
    if (!(self = [super init])) return nil;
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _view = [[SPView alloc] initWithFrame:_window.bounds];
    // Set a dummy controller to make the runtime happy
    _window.rootViewController = [[UIViewController alloc] init];
    [_window addSubview:_view];
    return self;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SPStage setSupportHighResolutions:YES];
    // TODO - figure out why this is throwing an exception. Looks like an iOS 5 bug
    //[SPAudioEngine start];
    
    _view.stage = [[SPStage alloc] init];
    _view.multipleTouchEnabled = YES;
    
    [_window makeKeyAndVisible];
    [_view start];
    
    _defaultStack = [[BTModeStack alloc] init];
    [_view.stage addChild:_defaultStack->_sprite];
    [_view.stage addEventListener:@selector(advanceTime:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    return YES;
}

- (void)advanceTime:(SPEnterFrameEvent*)ev {
    [_defaultStack advanceTime:ev.passedTime];
}

- (void)applicationWillResignActive:(UIApplication*)application {    
    [_view stop];
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
	[_view start];
}

- (void)dealloc {
    //[SPAudioEngine stop];
}



@end