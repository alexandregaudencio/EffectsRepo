// =====================
// Toon Shading para Shader Graph (URP)
// =====================

// Inclui funções e structs essenciais do URP
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

void ToonShading_float(
    in float3 Normal, // Normal do fragmento (em espaço de mundo)
    in float ToonRampSmoothness, // Suavidade da transição da rampa toon
    in float3 ClipSpacePos, // Posição em clip space (para sombras em tela)
    in float3 WorldPos, // Posição em espaço de mundo
    in float4 ToonRampTinting, // Cor extra aplicada à rampa
    in float ToonRampOffset, // Offset da rampa toon
    out float3 ToonRampOutput, // Cor de saída
    out float3 Direction)               // Direção da luz principal (para rimlight)
{
#ifdef SHADERGRAPH_PREVIEW
        // No modo preview, evita cálculos complexos
        ToonRampOutput = float3(0.5, 0.5, 0.0);
        Direction = float3(0.5, 0.5, 0.0);
#else
        // =====================
        // Coordenadas de sombra
        // =====================
#if SHADOWS_SCREEN
            half4 shadowCoord = ComputeScreenPos(ClipSpacePos);
#else
    half4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
#endif

        // =====================
        // Luz principal
        // =====================
#if _MAIN_LIGHT_SHADOWS_CASCADE || _MAIN_LIGHT_SHADOWS
            Light mainLight = GetMainLight(shadowCoord);
#else
    Light mainLight = GetMainLight();
#endif

        // Cálculo toon para luz principal
    half d = dot(Normal, mainLight.direction) * 0.5h + 0.5h;
    half toonRamp = smoothstep(ToonRampOffset, ToonRampOffset + ToonRampSmoothness, d);
    toonRamp *= mainLight.shadowAttenuation;

        // Cor inicial com a luz principal
    half3 totalLight = mainLight.color * (toonRamp + ToonRampTinting.rgb);

        // =====================
        // Luzes adicionais (point, spot)
        // =====================
    int pixelLightCount = GetAdditionalLightsCount();

    for (int i = 0; i < pixelLightCount; i++)
    {
        Light aLight = GetAdditionalLight(i, WorldPos);

            // Atenuação da luz adicional
        half3 attenuatedLightColor = aLight.color * (aLight.distanceAttenuation * aLight.shadowAttenuation);

            // Cálculo toon para luz adicional
        half dExtra = dot(Normal, aLight.direction) * 0.5 + 0.5;
        half toonRampExtra = smoothstep(ToonRampOffset, ToonRampOffset + ToonRampSmoothness, dExtra);

        totalLight += attenuatedLightColor * (toonRampExtra + ToonRampTinting.rgb);
    }

        // Saídas finais
    ToonRampOutput = totalLight;
    Direction = mainLight.direction;
#endif
}
