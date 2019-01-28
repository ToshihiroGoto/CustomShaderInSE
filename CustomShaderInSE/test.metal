//
//  Shaders.metal
//  TestShader
//
//  Created by Toshihiro Goto on 2016/12/22.
//  Copyright © 2016年 Toshihiro Goto. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

enum {
SCNVertexSemanticPosition,
SCNVertexSemanticNormal,
SCNVertexSemanticTangent,
SCNVertexSemanticColor,
SCNVertexSemanticBoneIndices,
SCNVertexSemanticBoneWeights,
SCNVertexSemanticTexcoord0,
SCNVertexSemanticTexcoord1,
SCNVertexSemanticTexcoord2,
SCNVertexSemanticTexcoord3,
SCNVertexSemanticTexcoord4,
SCNVertexSemanticTexcoord5,
SCNVertexSemanticTexcoord6,
SCNVertexSemanticTexcoord7
};

struct SCNSceneBuffer {
    float4x4    viewTransform;
    float4x4    inverseViewTransform; // transform from view space to world space
    float4x4    projectionTransform;
    float4x4    viewProjectionTransform;
    float4x4    viewToCubeTransform; // transform from view space to cube texture space (canonical Y Up space)
    float4x4    lastFrameViewProjectionTransform;
    float4      ambientLightingColor;
    float4        fogColor;
    float3        fogParameters; // x:-1/(end-start) y:1-start*x z:exp
    float2      inverseResolution;
    float       time;
    float       sinTime;
    float       cosTime;
    float       random01;
    float       motionBlurIntensity;
    // new in macOS 10.12 and iOS 10
    float       environmentIntensity;
    float4x4    inverseProjectionTransform;
    float4x4    inverseViewProjectionTransform;
    // new in macOS 10.13 and iOS 11
    float2      nearFar; // x: near, y: far
    float4      viewportSize; // xy:size, zw:origin
    // new in macOS 10.14 and iOS 12
    float4x4    inverseTransposeViewTransform;
    
    // internal, DO NOT USE
    float4      clusterScale; // w contains z bias
};

// 頂点
struct VertexInput {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texcoord [[ attribute(SCNVertexSemanticTexcoord0) ]];
};

// モデル
struct NodeBuffer {
    float4x4 modelViewProjectionTransform;
};

// 変数
struct CustomBuffer {
    float4 color;
};

struct VertexOut {
    float4 position [[ position ]];
    float2 texcoord;
    float4 color;
    float random01;
};

vertex VertexOut textureVertex(VertexInput in [[ stage_in ]],
                               constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                               constant NodeBuffer& scn_node [[ buffer(1) ]],
                               constant CustomBuffer& custom [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.texcoord = in.texcoord;
    out.color = custom.color;
    out.random01 = scn_frame.random01;
    return out;
}

fragment float4 textureFragment(VertexOut in [[ stage_in ]],
                               texture2d<float> texture [[ texture(0) ]]) {
//    constexpr sampler defaultSampler;
//    float4 color;
//    color = texture.sample(defaultSampler, in.texcoord) + in.color;
    
    VertexOut out = in;
    float random = out.random01;
    
    return float4(random, 0.0, 0.0, 1.0);
}
