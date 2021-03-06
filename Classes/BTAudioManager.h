//
// Betwixt - Copyright 2012 Three Rings Design

@class BTAudioControls;
@class BTAudioChannel;
@class BTSoundResource;
@class BTSoundType;
@class BTAudioState;

@interface BTAudioManager : NSObject {
@protected
    BTAudioControls* _masterControls;
    BTAudioControls* _sfxControls;
    BTAudioControls* _musicControls;
    BTAudioState* _defaultState;
    NSMutableArray* _activeChannels;
}

@property (nonatomic,readonly) BTAudioControls* masterControls;
@property (nonatomic,readonly) BTAudioControls* sfxControls;
@property (nonatomic,readonly) BTAudioControls* musicControls;

- (BTAudioControls*)getControlsForSoundType:(BTSoundType*)type;

- (BTAudioChannel*)playSoundNamed:(NSString*)name;
- (BTAudioChannel*)playSoundNamed:(NSString*)name loop:(BOOL)loop;
- (BTAudioChannel*)playSoundNamed:(NSString*)name 
                   parentControls:(BTAudioControls*)parentControls 
                             loop:(BOOL)loop;
- (BTAudioChannel*)playSound:(BTSoundResource*)soundResource 
              parentControls:(BTAudioControls*)parentControls 
                        loop:(BOOL)loop;

- (void)stopAllSounds;
- (void)stop:(BTAudioChannel*)channel;
- (void)pause:(BTAudioChannel*)channel;
- (void)resume:(BTAudioChannel*)channel;

- (void)update:(float)dt;
- (void)shutdown;

@end
