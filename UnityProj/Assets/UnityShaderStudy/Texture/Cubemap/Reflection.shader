Shader "Custom/Study/Texture/Cubemap/Reflection"
{
    Properties
    {
		_Color("Color Tint", Color) = (1,1,1,1)
        _ReflectionColor("Reflection Color", Color) = (1,1,1,1)
		_ReflectionAmount("Reflection Amount", Range(0,1)) = 1
		_Cubemap("Reflection Cubemap", Cube) = "_Skybox" {}
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
				float3 worldRefl : TEXCOORD2;
				SHADOW_COORDS(3)
            };

            fixed4 _Color;
			fixed4 _ReflectionColor;
			fixed _ReflectionAmount;
			samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldRefl = reflect(-UnityWorldSpaceViewDir(o.worldPos), o.worldNormal);
				TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldNormal, worldLightDir));

				fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb * _ReflectionColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				fixed4 col = fixed4(ambient + lerp(diffuse, reflection, _ReflectionAmount) * atten, 1.0);
                
                return col;
            }
            ENDCG
        }
    }
	FallBack "Reflective/VertexLit"
}
