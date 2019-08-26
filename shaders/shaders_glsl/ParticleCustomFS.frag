#version 110

struct Globals
{
    mat4 ViewProjection;
    vec4 ViewRight;
    vec4 ViewUp;
    vec4 ViewDir;
    vec3 CameraPosition;
    vec3 AmbientColor;
    vec3 SkyAmbient;
    vec3 Lamp0Color;
    vec3 Lamp0Dir;
    vec3 Lamp1Color;
    vec4 FogParams;
    vec4 FogColor_GlobalForceFieldTime;
    vec4 Technology_Exposure;
    vec4 LightBorder;
    vec4 LightConfig0;
    vec4 LightConfig1;
    vec4 LightConfig2;
    vec4 LightConfig3;
    vec4 ShadowMatrix0;
    vec4 ShadowMatrix1;
    vec4 ShadowMatrix2;
    vec4 RefractionBias_FadeDistance_GlowFactor_SpecMul;
    vec4 OutlineBrightness_ShadowInfo;
    vec4 CascadeSphere0;
    vec4 CascadeSphere1;
    vec4 CascadeSphere2;
    vec4 CascadeSphere3;
    float hybridLerpDist;
    float hybridLerpSlope;
    float evsmPosExp;
    float evsmNegExp;
    float globalShadow;
    float shadowBias;
    float shadowAlphaRef;
    float debugFlagsShadows;
};

struct EmitterParams
{
    vec4 ModulateColor;
    vec4 Params;
    vec4 AtlasParams;
};

uniform vec4 CB0[32];
uniform vec4 CB1[3];
uniform sampler2D LightingAtlasTexture;
uniform sampler2D texTexture;

varying vec3 VARYING0;
varying vec4 VARYING1;
varying vec2 VARYING2;

void main()
{
    vec4 f0 = texture2D(texTexture, VARYING0.xy);
    vec3 f1 = (f0.xyz * VARYING1.xyz).xyz;
    vec3 f2 = vec3(CB0[15].x);
    vec4 f3 = texture2D(LightingAtlasTexture, VARYING2);
    vec3 f4 = mix(f1, f1 * f1, f2).xyz;
    vec3 f5 = mix(f4, (f3.xyz * (f3.w * 120.0)) * f4, vec3(CB1[2].w)).xyz;
    float f6 = (VARYING1.w * f0.w) * clamp(VARYING0.z, 0.0, 1.0);
    vec3 f7 = mix(f5, sqrt(clamp(f5 * CB0[15].z, vec3(0.0), vec3(1.0))), f2).xyz * f6;
    vec4 f8 = vec4(f7.x, f7.y, f7.z, vec4(0.0).w);
    f8.w = f6 * CB1[1].y;
    gl_FragData[0] = f8;
}

//$$LightingAtlasTexture=s2
//$$texTexture=s0