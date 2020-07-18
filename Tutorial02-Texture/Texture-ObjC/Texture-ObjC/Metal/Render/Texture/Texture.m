//  Texture.m
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


#import "Texture.h"
#import "DefineTypes.h"

@interface Texture ()

@property (nonatomic, strong) CAMetalLayer *mtlLayer;
@property (nonatomic, strong) MetalContext *mtlContext;
@property (nonatomic, strong) id<MTLSamplerState> mtlSamplerState;
@property (nonatomic, strong) id<MTLRenderPipelineState> mtlRenderPipelineState;
@property (nonatomic, strong) id<MTLBuffer> mtlVertexBuffer;
@property (nonatomic, assign) NSUInteger vCnt;

@end

@implementation Texture

- (instancetype)initWithLayer:(CAMetalLayer *)layer context: (MetalContext *)context {
    if ((self = [super init])) {
        _mtlLayer = layer;
        _mtlContext = context;
        
        [self initMetalSetting];
        [self initMetalPipeline];
        [self initDrawData];
    }
    return self;
}

- (void)initMetalSetting {
    _mtlLayer.device = _mtlContext.device;
    _mtlLayer.pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
}

- (void)initMetalPipeline {
    NSError *error = nil;
    id<MTLLibrary> library = _mtlContext.library;
    
    id<MTLFunction> triangleVertexFunc = [library newFunctionWithName:@"texture_vertex"];
    id<MTLFunction> triangleFragmentFunc = [library newFunctionWithName:@"texture_fragment"];
    
    MTLRenderPipelineDescriptor *trianglePipelineDesc = [MTLRenderPipelineDescriptor new];
    trianglePipelineDesc.colorAttachments[0].pixelFormat = _mtlLayer.pixelFormat;
    trianglePipelineDesc.vertexFunction = triangleVertexFunc;
    trianglePipelineDesc.fragmentFunction = triangleFragmentFunc;
    
    // 创建图形渲染管道，耗性能操作不宜频繁调用;
    _mtlRenderPipelineState = [_mtlContext.device newRenderPipelineStateWithDescriptor:trianglePipelineDesc error:&error];
    
    if (nil == _mtlRenderPipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
}

- (void)initDrawData {
    static const Vertex textureVertices[] = { /*由于图片是正方形的，所以顶点坐标 Y 选取 0.5*/
        { .position = {  1.0, -0.5, 0.0, 1.0 }, .textureCoordinate = { 1.0, 1.0 } },
        { .position = { -1.0, -0.5, 0.0, 1.0 }, .textureCoordinate = { 0.0, 1.0 } },
        { .position = { -1.0,  0.5, 0.0, 1.0 }, .textureCoordinate = { 0.0, 0.0 } },
        
        { .position = {  1.0, -0.5, 0.0, 1.0 }, .textureCoordinate = { 1.0, 1.0 } },
        { .position = { -1.0,  0.5, 0.0, 1.0 }, .textureCoordinate = { 0.0, 0.0 } },
        { .position = {  1.0,  0.5, 0.0, 1.0 }, .textureCoordinate = { 1.0, 0.0 } },
    };
    
    _mtlVertexBuffer = [_mtlContext.device newBufferWithBytes:textureVertices
                                                       length:sizeof(textureVertices)
                                                      options:MTLResourceStorageModeShared/*MTLResourceOptionCPUCacheModeDefault*/]; // 顶点缓存;
    
    _vCnt = sizeof(textureVertices) / sizeof(Vertex); // 顶点个数;
    
    // 创建采样状态;
    MTLSamplerDescriptor *samplerDesc = [MTLSamplerDescriptor new];
    samplerDesc.sAddressMode = MTLSamplerAddressModeClampToEdge;
    samplerDesc.tAddressMode = MTLSamplerAddressModeClampToEdge;
    samplerDesc.minFilter = MTLSamplerMinMagFilterNearest;
    samplerDesc.magFilter = MTLSamplerMinMagFilterLinear;
    samplerDesc.mipFilter = MTLSamplerMipFilterLinear;
    _mtlSamplerState = [_mtlContext.device newSamplerStateWithDescriptor:samplerDesc];
}

- (void)processDraw:(id<MTLTexture>) inTexture {
    id<CAMetalDrawable> drawable = [self.mtlLayer nextDrawable];
    id<MTLTexture> framebufferTexture = drawable.texture;
    if (drawable) {
        id<MTLCommandBuffer> cmdBuffer = [_mtlContext.commandQueue commandBuffer];
        cmdBuffer.label = @"TextureCMD";
        
        MTLRenderPassDescriptor *passDesc = [MTLRenderPassDescriptor renderPassDescriptor];
        passDesc.colorAttachments[0].texture = framebufferTexture;
        passDesc.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0); // 背景色;
        passDesc.colorAttachments[0].storeAction = MTLStoreActionStore;
        passDesc.colorAttachments[0].loadAction = MTLLoadActionClear;
        
        id<MTLRenderCommandEncoder> cmdEncoder = [cmdBuffer renderCommandEncoderWithDescriptor:passDesc];
        [cmdEncoder setRenderPipelineState:self.mtlRenderPipelineState]; // 设置渲染管道，以保证顶点和片元两个 Shader 会被调用;
        [cmdEncoder setVertexBuffer:self.mtlVertexBuffer offset:0 atIndex:0]; // 设置顶点缓存;
        [cmdEncoder setFragmentTexture:inTexture atIndex:0]; // 设置纹理;
        [cmdEncoder setFragmentSamplerState:self.mtlSamplerState atIndex:0]; // 设置采样状态;
        [cmdEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:self.vCnt]; // 绘制;
        [cmdEncoder endEncoding];
        
        [cmdBuffer presentDrawable:drawable]; // 显示;
        [cmdBuffer commit];
    }
}

@end
