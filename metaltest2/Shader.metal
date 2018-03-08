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

//http://glslsandbox.com/e#42184.6より
fragment float4 fragmentShader(ColorInOut      in[[ stage_in ]],
                               constant float  &time[[ buffer(0) ]],
                               constant float2 &resolution [[buffer(1)]])
{
    //texCoordsを読みこんで座標設定も可
    //pはgl_FragCoordに対応
    float2 pos = in.position.xy;
    //rはresolutionに対応
    float2 re = resolution;
    float u = pos.x / re.x;
    float v = 1 - pos.y / re.y;
    v = v * re.y / re.x;
    pos.y = v * re.x;
    //uvは縦横比を正方形に正規化した座標
    float2 uv = float2(u,v);
    
    float2 st = uv;
    
    float2 p = st * 15.;
    p = fmod(p, 2.);
    
    p.x += .1 * sin(2.5 * st.x + 4.*time);
    p.y += .2 * cos(2.5 * st.y + 5.*time);
    
    float r = .5;
    float l = length(p - float2(1.));
    float d = abs(l - r);
    
    float fr = 50. + 40. * sin(3.14*time + st.x);
    float fg = 50. + 40. * sin(5.27*time + st.y);
    float fb = 50. + 40. * sin(7.35*time);
    
    float3 color = float3(1. / (fr * d), 1. / (fg * d), 1. / (fb * d));
    color = color*smoothstep(.4, .5, color);
    
    return float4(color, 1.0);
    
    
}
