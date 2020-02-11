Shader "Custom/Study/Texture/Cubemap/Refraction"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
		_RefractionColor("Refraction Color", Color) = (1,1,1,1)
		_RefractionAmount("Refraction Amount", Range(0,1)) = 1
		_RefractionRatio("Refraction Ratio", Range(0.1, 1)) = 0.5
		_Cubemap("Refraction Cubemap", Cube) = "_Skybox" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
			Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldRefr : TEXCOORD2;
				SHADOW_COORDS(3)
            };

			fixed4 _Color;
			fixed4 _RefractionColor;
			fixed _RefractionAmount;
			fixed _RefractionRatio;
			samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldRefr = refract(-normalize(UnityWorldSpaceViewDir(o.worldPos)), normalize(o.worldNormal), _RefractionRatio);
				TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

				fixed3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb * _RefractionColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				fixed4 col = fixed4(ambient + lerp(diffuse, refraction, _RefractionAmount) * atten, 1.0);

                return col;
            }
            ENDCG
        }
    }
	FallBack "Reflective/VertexLit"
}
