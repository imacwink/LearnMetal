//
//  MetalContext.h
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

#import <Metal/Metal.h>
#import <AVFoundation/AVFoundation.h>

@protocol MTLDevice, MTLLibrary, MTLCommandQueue;

@interface MetalContext : NSObject

@property (strong) id<MTLDevice> device;
@property (strong) id<MTLLibrary> library;
@property (strong) id<MTLCommandQueue> commandQueue;

+ (instancetype)shareMetalContext;
+ (instancetype)newContext;

- (id<MTLTexture>) textureFromPixelBuffer:(CVPixelBufferRef)vpBuffer;

@end
