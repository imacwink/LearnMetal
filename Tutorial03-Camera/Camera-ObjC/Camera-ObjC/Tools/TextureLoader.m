//
//  TextureLoader.m
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

#import "TextureLoader.h"

@implementation TextureLoader

+ (id<MTLTexture>)loadTexture:(id<MTLDevice>)device imageNamed:(NSString *)name {
    id<MTLTexture> mtlTexture;
    UIImage *image = [UIImage imageNamed:name];
    MTLTextureDescriptor *textureDesc = [[MTLTextureDescriptor alloc] init];
    textureDesc.pixelFormat = MTLPixelFormatRGBA8Unorm_sRGB;
    textureDesc.width = image.size.width;
    textureDesc.height = image.size.height;
    mtlTexture = [device newTextureWithDescriptor:textureDesc];

    // 纹理上传的范围;
    MTLRegion region = {{ 0, 0, 0 }, {image.size.width, image.size.height, 1}};

    // UIImage 的数据需要转成二进制才能上传，且不用jpg、png 的 NSData;
    Byte *imageBytes = [self loadImage:image];
    if (imageBytes) {
        [mtlTexture replaceRegion:region mipmapLevel:0 withBytes:imageBytes bytesPerRow:4 * image.size.width];
        free(imageBytes); // 需要释放资源;
        imageBytes = NULL;
    }

    return mtlTexture;
}

+ (Byte *)loadImage:(UIImage *)image {
    // 1.获取图片的CGImageRef;
    CGImageRef spriteImage = image.CGImage;

    // 2.读取图片的大小;
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);

    Byte * spriteData = (Byte *) calloc(width * height * 4, sizeof(Byte)); // rgba 共 4 个 byte;
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);

    // 3.在CGContextRef上绘图;
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);

    return spriteData;
}

+ (id<MTLTexture>)loadTexture:(id<MTLDevice>)device assertName:(NSString *)name {
    id<MTLTexture> retTexture;
    NSError *error;
    MTKTextureLoader* textureLoader = [[MTKTextureLoader alloc] initWithDevice:device];
    NSDictionary *textureLoaderOptions =
    @{
      MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead), // 表示我们这张贴图是只读的，不可写入;
      MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate) // 表示我们张贴图只有 GPU 可以访问，CPU 不可访问，这种模式下 Metal 可以进一步做一些优化，提高性能;
      };
    retTexture = [textureLoader newTextureWithName:name
                                      scaleFactor:1.0
                                           bundle:nil
                                          options:textureLoaderOptions
                                            error:&error];
    retTexture.label = @"retTexture";
    if(!retTexture || error) {
        NSLog(@"Error creating texture %@", error.localizedDescription);
    }
    return retTexture;
}

@end
