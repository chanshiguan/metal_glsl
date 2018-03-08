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

//http://glslsandbox.com/e#42081.0より
float Hash( float2 p)
{
    float3 p2 = float3(p.xy,1.0);
    return fract(sin(dot(p2,float3(37.1,61.7, 12.4)))*3758.5453123);
}

float noise(float2 p)
{
    float2 i = floor(p);
    float2 f = fract(p);
    f *= f * (3.0-2.0*f);
    
    return mix(mix(Hash(i + float2(0.,0.)), Hash(i + float2(1.,0.)),f.x),
               mix(Hash(i + float2(0.,1.)), Hash(i + float2(1.,1.)),f.x),
               f.y);
}

float fbm(float2 p)
{
    float v = 0.0;
    v += noise(p*1.0)*.5;
    v -= noise(p*2.)*.25;
    v += noise(p*4.)*.125;
    return v * -1.25;
}

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
    //float2 uv = float2(u,v);
    
    float2 uv = ( pos.xy / resolution.xy ) * 2.0 - 1.0;
    uv.x *= resolution.x/resolution.y;
    uv.xy = uv.yx;
    float j = 2.5;
    float3 finalColor = float3( 0.0 );
    for( int i=2; i < 13; ++i )
    {
        float hh =  0.5 - float(i);
        
        float t = abs(1.0 / ((uv.x + fbm( uv + (time + 40.)/float(i)))*200.));
        finalColor +=  t * float3( sin(hh-j), fract(t/j), cos(j-t) );
        j = float(i)-hh;
    }
    
    return float4( sqrt(finalColor), 1.0 );
    
    
}




