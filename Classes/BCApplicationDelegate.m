#import "BCApplicationDelegate.h" 

@implementation BCApplicationDelegate

@synthesize defaultStack=_defaultStack;

- (id)init {
    if ((self = [super init]))
    {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _view = [[SPView alloc] initWithFrame:_window.bounds]; 
        [_window addSubview:_view];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    [SPStage setSupportHighResolutions:YES];
    [SPAudioEngine start];
    
    _view.stage = [[SPStage alloc] init];
    _view.multipleTouchEnabled = YES;
    
    [_window makeKeyAndVisible];
    [_view start];
    
    _defaultStack = [[BCModeStack alloc] init];
    [_view.stage addChild:_defaultStack->_sprite];
    [_view.stage addEventListener:@selector(advanceTime:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
}

-(void)advanceTime:(SPEnterFrameEvent *)ev {
    [_defaultStack advanceTime:ev.passedTime];
}

- (void)applicationWillResignActive:(UIApplication *)application {    
    [_view stop];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[_view start];
}

- (void)dealloc 
{
    [SPAudioEngine stop];
}

@end
