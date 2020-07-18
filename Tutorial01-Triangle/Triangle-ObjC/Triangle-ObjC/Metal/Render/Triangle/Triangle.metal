//
//  Triangle.metal
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

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4 clipSpacePosition [[position]];
    float4 pixelColor;
} RasterizerData;

// NOTICE::Writable resources in non-void vertex function;
// 错误提示是需要确保着色器只能从这些缓冲区中读取，因此需要将声明更改为 const device;
vertex RasterizerData triangle_vertex(const device RasterizerData *vertices [[buffer(0)]], uint vid [[vertex_id]]) {
    RasterizerData out;
    out.clipSpacePosition = vertices[vid].clipSpacePosition;
    out.pixelColor = vertices[vid].pixelColor;
    return out;
}

fragment float4 triangle_fragment(RasterizerData inVertex [[stage_in]]) {
    return inVertex.pixelColor;
}


