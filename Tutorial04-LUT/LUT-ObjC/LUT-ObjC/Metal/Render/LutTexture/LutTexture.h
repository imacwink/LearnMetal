//
//  LutTexture.h
//  LUT-ObjC
//
//  Created by 王云刚 on 2020/8/1.
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

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>
#import <simd/simd.h>
#import "MetalContext.h"

@interface LutTexture : NSObject

- (instancetype)initWithLayer:(CAMetalLayer *)layer context: (MetalContext *)context;
- (void)processDraw:(id<MTLTexture>) inTexture lut:(id<MTLTexture>)lutTexture;

@end
