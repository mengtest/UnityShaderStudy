Shader "Custom/Study/Transparent/BlendOp Darken"
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

        Pass
        {
			ZWrite Off
			// Photoshop 中混合模式：Darken。变暗
			BlendOp Min
			Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texCol = tex2D(_MainTex, i.uv);

				fixed3 albedo = texCol.rgb * _Color.rgb;

				fixed3 diffuse = albedo;

                fixed4 col = fixed4(diffuse, texCol.a * _AlphaScale);

                return col;
            }
            ENDCG
        }
    }
	FallBack "Transparent/VertexLit"
}
