//
//  Shader.metal
//  metaltest2
//
//  Created by Wai on 2018/03/07.
//  Copyright © 2018年 momomoromo. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct ColorInOut
{
    float4 position [[ position ]];
    float2 texCoords;
};

vertex ColorInOut vertexShader(device float4 *positions [[ buffer(0) ]],
                               device float2 *texCoords [[ buffer(1) ]],
                               uint           vid       [[ vertex_id ]])
{
    ColorInOut out;
    out.position = positions[vid];
    out.texCoords = texCoords[vid];
    return out;
}

//http://glslsandbox.com/e#45710.0より
float2 tile(float2 _st, float _zoom){
    _st *= _zoom;
    return fract(_st);
}

float box(float2 _st, float2 border){
    float2 uv = step(border, _st);
    return uv.x*uv.y;
}


fragment float4 fragmentShader(ColorInOut      in[[ stage_in ]],
                               constant float  &time[[ buffer(0) ]],
                               constant float2 &resolution [[buffer(1)]])
{
    //texCoordsを読みこんで座標設定も可
    //pはgl_FragCoordに対応
    float2 p = in.position.xy;
    //rはresolutionに対応
    float2 r = resolution;
    float u = p.x / r.x;
    float v = 1 - p.y / r.y;
    v = v * r.y / r.x;
    p.y = v * r.x;
    //uvは縦横比を正方形に正規化した座標
    float2 uv = float2(u,v);
    
    float2 st = uv;
    
    float tileScaling = 16.;
    
    
    float tileCount = tileScaling * tileScaling;
    float tileId = 1. + floor(st.x * tileScaling) + tileScaling * floor(st.y * tileScaling);
    
    // Divide the space in 256
    st = tile(st, tileScaling);
    
    // Draw the tile
    float modifier = tileId / tileCount;
    float3 color = float3(
                          abs(cos(modifier * time)),
                          sin(modifier * time * .8),
                          fract(modifier * time * .5));
    float isActive = abs(sin(time * 1.3 * modifier)) * box(st, float2(0.05));
    
    return float4(float3(isActive * color),1.0);
    
}
