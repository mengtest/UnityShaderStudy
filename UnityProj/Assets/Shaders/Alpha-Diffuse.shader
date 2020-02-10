Shader "Custom/Transparent/Diffuse"
{
    Properties
    {
		_Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Main Tex", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 200

        Pass
        {
			Tags { "LightMode"="ForwardBase" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				SHADOW_COORDS(3)
                UNITY_FOG_COORDS(4)                
            };

			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				TRANSFER_SHADOW(o);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 texCol = tex2D(_MainTex, i.uv);
				
				fixed3 albedo = texCol.rgb * _Color.rgb;

				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed4 col = fixed4(ambient + diffuse * atten, texCol.a * _AlphaScale);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

		Pass
        {
			Tags { "LightMode"="ForwardAdd" }

			Blend SrcAlpha One
			ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdadd
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				SHADOW_COORDS(3)
                UNITY_FOG_COORDS(4)                
            };

			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				TRANSFER_SHADOW(o);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 texCol = tex2D(_MainTex, i.uv);
				
				fixed3 albedo = texCol.rgb * _Color.rgb;

				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed4 col = fixed4(diffuse * atten, texCol.a * _AlphaScale);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}
