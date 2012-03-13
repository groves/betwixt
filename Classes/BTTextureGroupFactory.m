//
//  Betwixt - Copyright 2012 Three Rings Design

#import "BTTextureGroupFactory.h"
#import "BTMultiResourceFactory.h"
#import "BTTextureResource+Package.h"
#import "GDataXMLNode+Extensions.h"
#import "BTApp.h"
#import "BTResourceManager.h"
#import "BTDeviceType.h"


@implementation BTTextureGroupFactory {
    NSArray* _targetDevicePrefs;
}

+ (id<BTMultiResourceFactory>)sharedFactory {
    static BTTextureGroupFactory* instance = nil;
    @synchronized(self) {
        if (instance == nil) {
            instance = [[BTTextureGroupFactory alloc] init];
        }
    }
    return instance;
}

- (id)init {
    if (!(self = [super init])) {
        return nil;
    }
    
    // Build a list of device types, in the order that we prefer textures:
    // - textures for our device
    // - textures for lower-res devices
    // - textures for higher-res devices
    _targetDevicePrefs = [[BTDeviceType values] sortedArrayUsingComparator:^NSComparisonResult(BTDeviceType* a, BTDeviceType* b) {
        if (a == BTApp.app.deviceType) {
            return -1;
        } else if (b == BTApp.app.deviceType) {
            return 1;
        } else if (a.ordinal < b.ordinal) {
            return -1;
        } else if (a.ordinal > b.ordinal) {
            return 1;
        } else {
            return 0;
        }
    }];
    
    return self;
}

- (NSArray*)create:(GDataXMLElement*)xml {
    NSMutableArray* textures = [[NSMutableArray alloc] init];
    
    GDataXMLElement* theGroup = nil;
    for (BTDeviceType* type in _targetDevicePrefs) {
        for (GDataXMLElement* groupXml in [xml elementsForName:@"textureGroup"]) {
            BTDeviceType* targetType = [groupXml enumAttribute:@"target" type:[BTDeviceType class]];
            if (targetType == type) {
                theGroup = groupXml;
                break;
            }
        }
        
        if (theGroup != nil) {
            break;
        }
    }
    
    if (theGroup != nil) {
        for (GDataXMLElement* atlasXml in [theGroup elementsForName:@"atlas"]) {
            NSString* filename = [BTApp.app resourcePathFor:[atlasXml stringAttribute:@"file"]];
            SPTexture* atlas = [[SPTexture alloc] initWithContentsOfFile:filename];
            for (GDataXMLElement* child in [atlasXml elements]) {
                [textures addObject:[[BTTextureResource alloc] initFromAtlas:atlas withXml:child]];
            }
        }
    }
    
    return textures;
}
@end