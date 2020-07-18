//
//  Texture.metal
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

#import "DefineTypes.h"

using namespace metal;

typedef struct {
    float4 clipSpacePosition [[position]]; /*position 的修饰符表示这个是顶点*/
    float2 textureCoordinate; /*纹理坐标，插值处理*/
} RasterizerData; /*光栅化数据*/

// 返回给片元着色器的数据;
// vertex_id 是顶点 shader 每次处理的 index，用于定位当前的顶点;
// buffer 表明是缓存数据，0 是索引;

// 顶点函数;
// vertex 函数修饰符表示顶点函数;
// RasterizerData 返回值类型;
// texture_vertex 函数名;
// vertex_id 顶点 id 修饰符，苹果内置不可变，[[vertex_id]];
// buffer 缓存数据修饰符，苹果内置不可变，0 是索引;
// [[buffer(0)]];
// constant 变量类型修饰符，表示存储在 device 区域;
vertex RasterizerData texture_vertex(uint vertexID [[ vertex_id ]], constant Vertex *vertexArray [[ buffer(0) ]]) {
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
// 可以加索引 [[ texture(0)]] 纹理 0， [[ texture(1)]] 纹理 1;
fragment float4 texture_fragment(RasterizerData input [[stage_in]], texture2d<half> colorTexture [[ texture(0) ]], sampler samplr [[sampler(0)]])  {
    half4 colorSample;
    
    if(false) { /*内部设置采样方式*/
        // constexpr 修饰符;
        // sampler 采样器;
        // textureSampler 采样器变量名;
        // mag_filter:: linear, min_filter:: linear 设置放大缩小过滤方式;
        constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);

        // 得到纹理对应位置的颜色;
        colorSample = colorTexture.sample(textureSampler, input.textureCoordinate);
    } else {
        colorSample = colorTexture.sample(samplr, input.textureCoordinate);
    }

    return float4(colorSample);
}
