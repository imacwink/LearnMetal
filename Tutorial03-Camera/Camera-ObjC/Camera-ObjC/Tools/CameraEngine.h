//
//  CameraEngine.h
//  Camera-ObjC
//
//  Created by 王云刚 on 2020/7/18.
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
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraEngineDelegate <NSObject>

- (void)didOutputVideoBuffer: (CVPixelBufferRef) vpBuffer;

@end

@interface CameraEngine : NSObject

@property (nonatomic, assign) id<CameraEngineDelegate> delegate;

- (instancetype)initCE;
- (void)startCE;
- (void)stopCE;

@end

NS_ASSUME_NONNULL_END
