Shader "Custom/Study/Misc/VPos"
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
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (float4 sp : VPOS/*WPOS*/) : SV_Target
            {
                // 用屏幕坐标除以屏幕分辨率 _ScreenParams.xy，得到视口空间中的坐标
                return fixed4(sp.xy/_ScreenParams.xy,0.0,1.0);
            }
            ENDCG
        }
    }
}
