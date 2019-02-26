Shader "Custom/AverageBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Radius ("Radius", Range(0, 5)) = 1
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
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float _Radius;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				float2 uv1 = i.uv + _MainTex_TexelSize.x * float2(-1,1) * _Radius;
				float2 uv2 = i.uv + _MainTex_TexelSize.x * float2(1,1) * _Radius;
				float2 uv3 = i.uv + _MainTex_TexelSize.x * float2(1,-1) * _Radius;
				float2 uv4 = i.uv + _MainTex_TexelSize.x * float2(-1,-1) * _Radius;

				col += tex2D(_MainTex, uv1);
				col += tex2D(_MainTex, uv2);
				col += tex2D(_MainTex, uv3);
				col += tex2D(_MainTex, uv4);

				col *= 0.2;

				return col;
			}
			ENDCG
		}
	}
}
