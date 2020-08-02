//
//  LutTexture.metal
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

#include <metal_stdlib>

#import "DefineTypes.h"

using namespace metal;

typedef struct {
    float4 clipSpacePosition [[position]]; /*position 的修饰符表示这个是顶点*/
    float2 textureCoordinate; /*纹理坐标，插值处理*/
} RasterizerData; /*光栅化数据*/

typedef struct {
    unsigned int maxColorValue;   /* Lut 每个分量的有多少种颜色最大取值 */
    unsigned int latticeCnt;      /* 每排格数 */
    unsigned int w;               /* Lut 宽 */
    unsigned int h;               /* Lut 高 */
} LutInfo;

/**
 Shader 有三个基本函数（概念理解）
 顶点函数（vertex）：对每个顶点进行处理，生成数据并输出到绘制管线
 像素函数（fragment）：对光栅化后的每个像素点进行处理，生成数据并输出到绘制管线
 通用计算函数（kernel）：是并行计算的函数，其返回值类型必须为 void
**/

// 顶点函数;
// vertex 函数修饰符表示顶点函数;
// RasterizerData 返回值类型;
// texture_vertex 函数名;
// vertex_id 顶点 id 修饰符，苹果内置不可变，[[vertex_id]];
// buffer 缓存数据修饰符，苹果内置不可变，0 是索引;
// [[buffer(0)]];
// constant 变量类型修饰符，表示存储在 device 区域;
vertex RasterizerData lut_texture_vertex(uint vertexID [[ vertex_id ]],
                                         constant Vertex *vertexArray [[ buffer(0) ]]) {
    RasterizerData out;
    out.clipSpacePosition = vertexArray[vertexID].position; /*源于CPU传递*/
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return out;
}

// 片元函数
// fragment 函数修饰符表示片元函数 float4 返回值类型->颜色RGBA texture_fragment 函数名;
// RasterizerData 参数类型 input 变量名;
// [[stage_in] stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）;
// texture2d 类型表示纹理 baseTexture 变量名;
// [[ texture(index)]] 纹理修饰符;
// 可以加索引 [[ texture(0)]] 纹理 0（预览纹理）， [[ texture(1)]] 纹理 1（Lut 纹理）;
fragment float4 lut_texture_fragment(RasterizerData input [[stage_in]],
                                     constant float &intensity [[buffer(2)]],
                                     constant LutInfo &lutInfo [[buffer(3)]],
                                     texture2d<float> normalTexture [[ texture(FTINormal) ]],
                                     texture2d<float> lutTexture [[ texture(FTILut) ]]) {
    
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear); // sampler 是采样器;
    float4 textureColor = normalTexture.sample(textureSampler, input.textureCoordinate); // 正常的纹理颜色;
    
    float blueColor = textureColor.b * 63.0; // 蓝色部分 [0, 63] 共 64 种;
    
    float2 quad1; // 第一个正方形的位置, 假如 blueColor = 22.5，则 y = 22 / 8 = 2，x = 22 - 8 * 2 = 6，即是第 2 行，第 6 个正方形；（因为 y 是纵坐标）;
    quad1.y = floor(floor(blueColor) * 0.125);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    
    float2 quad2; // 第二个正方形的位置，同上。注意 x、y 坐标的计算，还有这里用 int 值也可以，但是为了效率使用 float;
    quad2.y = floor(ceil(blueColor) * 0.125);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);
    
    float2 texPos1; // 计算颜色 (r, b, g) 在第一个正方形中对应位置;
    texPos1.x = ((quad1.x * 64) +  textureColor.r * 63 + 0.5) / 512.0;
    texPos1.y = ((quad1.y * 64) +  textureColor.g * 63 + 0.5) / 512.0;
    
    float2 texPos2; // 同上;
    texPos2.x = ((quad2.x * 64) +  textureColor.r * 63 + 0.5) / 512.0;
    texPos2.y = ((quad2.y * 64) +  textureColor.g * 63 + 0.5) / 512.0;
    
    float4 newColor1 = lutTexture.sample(textureSampler, texPos1); // 正方形 1 的颜色值;
    float4 newColor2 = lutTexture.sample(textureSampler, texPos2); // 正方形 2 的颜色值;
    
    float4 newColor = mix(newColor1, newColor2, fract(blueColor)); // 根据小数点的部分进行 mix;
    
    return float4(newColor.rgb, textureColor.w); // 不修改alpha值;
}
