//
//  TextureLoader.h
//  Texture-ObjC
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

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MTLDevice;

@interface TextureLoader : NSObject

+ (id<MTLTexture>)loadTexture:(id<MTLDevice>)device assertName:(NSString *)name;
+ (id<MTLTexture>)loadTexture:(id<MTLDevice>)device imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
