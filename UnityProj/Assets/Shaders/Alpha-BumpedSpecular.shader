Shader "Custom/Transparent/BumpedSpecular"
{
    Properties
    {
		_Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256)) = 20
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
				float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {                
                float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
                UNITY_FOG_COORDS(5)
            };

			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			half _Gloss;
			fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent.xyz) * v.tangent.w;
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(o);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 texCol = tex2D(_MainTex, i.uv.xy);

				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - dot(tangentNormal.xy, tangentNormal.xy));
				fixed3 worldNormal = normalize(float3(dot(i.TtoW0, tangentNormal), dot(i.TtoW1, tangentNormal), dot(i.TtoW2, tangentNormal)));

				fixed3 albedo = texCol.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

                fixed4 col = fixed4(ambient + (diffuse + specular) * atten, texCol.a * _AlphaScale);
                
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
				float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {                
                float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
                UNITY_FOG_COORDS(5)
            };

			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			half _Gloss;
			fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent.xyz) * v.tangent.w;
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(o);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 texCol = tex2D(_MainTex, i.uv.xy);

				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - dot(tangentNormal.xy, tangentNormal.xy));
				fixed3 worldNormal = normalize(float3(dot(i.TtoW0, tangentNormal), dot(i.TtoW1, tangentNormal), dot(i.TtoW2, tangentNormal)));

				fixed3 albedo = texCol.rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

                fixed4 col = fixed4((diffuse + specular) * atten, texCol.a * _AlphaScale);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
	FallBack "Specular"
}
