Shader "Custom/Study/BasicLightingModel/LambertDiffusePixelLevel"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
			Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
            };

            fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				// 计算世界空间下的顶点法线
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 得到环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				// 计算漫反射颜色
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				fixed3 color = ambient + diffuse;

				return fixed4(color, 1.0);
            }
            ENDCG
        }
    }

	FallBack "Diffuse"
}
