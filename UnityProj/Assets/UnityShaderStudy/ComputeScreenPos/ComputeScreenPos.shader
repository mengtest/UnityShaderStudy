Shader "Custom/Study/Misc/ComputeScreenPos"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				// Step 1：把 ComputeScreenPos 的结果保存到  中
				o.scrPos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				// Step 2：用 scrPos.xy 除以 scrPos.w 得到视口空间（Viewport Space）中的坐标
                float2 wcoord = (i.scrPos.xy/i.scrPos.w);
                return fixed4(wcoord,0.0,1.0);
            }
            ENDCG
        }
    }
}
