//
//  DefineTypes.h
//  LUT-ObjC
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

#ifndef DefineTypes_h
#define DefineTypes_h

typedef struct {
    vector_float4 position; /*顶点坐标*/
    vector_float2 textureCoordinate; /*纹理坐标*/
} Vertex;

typedef enum FTI {
    FTINormal     = 0, /*预览纹理*/
    FTILut        = 1, /*LUT纹理*/
} FragmentTextureIndex;

#endif /* DefineTypes_h */
