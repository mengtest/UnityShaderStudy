// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/Study/BasicLightingModel/LambertDiffuseVertexLevel"
{
    Properties
    {
		// 材质漫反射颜色和强度
        _Diffuse("Diffuse",Color) = (1.0,1.0,1.0,1.0)
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
				fixed3 color : COLOR;
            };

            fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

				// 计算环境光颜色
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				// 将顶点法线变换到世界空间
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				// 得到光源方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                
				// 在世界空间中计算漫反射光照
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				o.color = ambient + diffuse.rgb;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }

	FallBack "Diffuse"
}