Shader "Custom/Study/Transparent/Alpha Blend Both Side (Error)"
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

		Cull Off // 若直接关闭剔除功能来实现双面渲染，无法保证同一个物体的正面和背面图元的渲染顺序，
			     // 就会得到错误的半透明效果

        Pass
        {
			Tags { "LightMode"="ForwardBase" }

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
                UNITY_TRANSFER_FOG(o,o.pos);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 texCol = tex2D(_MainTex, i.uv);
                
				fixed3 albedo = texCol.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                fixed4 col = fixed4(ambient + diffuse, texCol.a * _AlphaScale);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
	FallBack "Transparent/VertexLit"
}
