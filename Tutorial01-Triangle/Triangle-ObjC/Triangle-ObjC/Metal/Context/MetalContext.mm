//
//  MetalContext.mm
//  Triangle-ObjC
//
//  Created by 王云刚 on 2020/7/16.
//
//
//
//                 .-~~~~~~~~~-._       _.-~~~~~~~~~-.
//             __.'              ~.   .~              `.__
//           .'//                  \./                  \\`.
//         .'//                     |                     \\`.
//       .'// .-~"""""""~~~~-._     |     _,-~~~~"""""""~-. \\`.
//     .'//.-"                 `-.  |  .-'                 "-.\\`.
//   .'//______.============-..   \ | /   ..-============.______\\`.
// .'______________________________\|/______________________________`.
//

#import "MetalContext.h"
#import <Metal/Metal.h>

@implementation MetalContext

static MetalContext *_instance;
+ (instancetype)shareMetalContext {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == _instance) {
            _instance = [[self alloc] initWithDevice:nil];
        }
    });
    return _instance;
}

+ (instancetype)newContext {
    return [[self alloc] initWithDevice:nil];
}

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    if ((self = [super init])) {
        _device = device ?: MTLCreateSystemDefaultDevice();
        _library = [_device newDefaultLibrary];
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}

@end
