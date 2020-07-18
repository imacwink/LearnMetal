//
//  Triangle.m
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

#import "Triangle.h"

typedef struct {
    vector_float4 position;
    vector_float4 color;
} Vertex;

@interface Triangle ()

@property (nonatomic, strong) CAMetalLayer *mtlLayer;
@property (nonatomic, strong) MetalContext *mtlContext;
@property (nonatomic, strong) id<MTLRenderPipelineState> mtlRenderPipelineState;
@property (nonatomic, strong) id<MTLBuffer> mtlVertexBuffer;

@end

@implementation Triangle

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
    _mtlLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void)initMetalPipeline {
    NSError *error = nil;
    id<MTLLibrary> library = _mtlContext.library;
    
    id<MTLFunction> triangleVertexFunc = [library newFunctionWithName:@"triangle_vertex"];
    id<MTLFunction> triangleFragmentFunc = [library newFunctionWithName:@"triangle_fragment"];
    
    MTLRenderPipelineDescriptor *trianglePipelineDes = [MTLRenderPipelineDescriptor new];
    trianglePipelineDes.colorAttachments[0].pixelFormat = _mtlLayer.pixelFormat;
    trianglePipelineDes.vertexFunction = triangleVertexFunc;
    trianglePipelineDes.fragmentFunction = triangleFragmentFunc;
    
    _mtlRenderPipelineState = [_mtlContext.device newRenderPipelineStateWithDescriptor:trianglePipelineDes error:&error];
    
    if (nil == _mtlRenderPipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
}

- (void)initDrawData {
    static const Vertex triangleVertices[] = {
        { .position = {  0.0,  0.5, 0.0, 1 }, .color = { 1, 0, 0, 1 } },
        { .position = {  0.5, -0.5, 0.0, 1 }, .color = { 0, 1, 0, 1 } },
        { .position = { -0.5, -0.5, 0.0, 1 }, .color = { 0, 0, 1, 1 } },
    };
    
    _mtlVertexBuffer = [_mtlContext.device newBufferWithBytes:triangleVertices
                                                       length:sizeof(triangleVertices)
                                                      options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)processDraw {
    id<CAMetalDrawable> drawable = [self.mtlLayer nextDrawable];
    id<MTLTexture> framebufferTexture = drawable.texture;
    if (drawable) {
        MTLRenderPassDescriptor *passDes = [MTLRenderPassDescriptor renderPassDescriptor];
        passDes.colorAttachments[0].texture = framebufferTexture;
        passDes.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0);  // 背景色;
        passDes.colorAttachments[0].storeAction = MTLStoreActionStore;
        passDes.colorAttachments[0].loadAction = MTLLoadActionClear;
        
        id<MTLCommandBuffer> cmdBuffer = [_mtlContext.commandQueue commandBuffer];
        cmdBuffer.label = @"TriangleCMD";
        
        id<MTLRenderCommandEncoder> cmdEncoder = [cmdBuffer renderCommandEncoderWithDescriptor:passDes];
        [cmdEncoder setRenderPipelineState:self.mtlRenderPipelineState];
        [cmdEncoder setVertexBuffer: _mtlVertexBuffer offset:0 atIndex:0];
        [cmdEncoder drawPrimitives: MTLPrimitiveTypeTriangle vertexStart: 0 vertexCount: 3];  // 绘制 3 个顶点;
        [cmdEncoder endEncoding];
        
        [cmdBuffer presentDrawable:drawable];
        [cmdBuffer commit];
    }
}

@end
