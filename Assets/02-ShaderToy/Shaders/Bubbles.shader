Shader "Custom/ImageEffect/Bubbles"
{
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
				float4 position : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv = -1.0 + 2.0 * i.position.xy / _ScreenParams.xy;
				uv.x *=  _ScreenParams.x / _ScreenParams.y;

				// background	 
				fixed4 color = fixed4(0.8 + 0.2 * uv.y, 0.8 + 0.2 * uv.y, 0.8 + 0.2 * uv.y, 1);

			    // bubbles	
				for( int j=0; j < 40; j++ )
				{
			        // bubble seeds
					float pha =   	sin(float(j)*546.13+1.0) * 0.5 + 0.5;
					float siz = pow(sin(float(j)*651.74+5.0) * 0.5 + 0.5, 4.0);
					float pox =     sin(float(j)*321.55+4.1) * _ScreenParams.x / _ScreenParams.y;

			        // buble size, position and color
					float rad = 0.1 + 0.5 * siz;
					float2 pos = float2(pox, - 1.0 - rad + (2.0 + 2.0 * rad) * fmod(pha + 0.1 * _Time.y * (0.2+0.8 * siz), 1.0));
					float dis = length(uv - pos);
					float3 col = lerp(float3(0.94, 0.3, 0.0), float3(0.1, 0.4, 0.8), 0.5 + 0.5 * sin(float(j) * 1.2 + 1.9));

					// Add a black outline around each bubble
					//   col+= 8.0*smoothstep( rad*0.95, rad, dis );
					
			        // render
					float f = length(uv-pos) / rad;
					f = sqrt(clamp(1.0 - f * f, 0.0, 1.0));
					color.rgb -= col.zyx * (1.0 - smoothstep(rad * 0.95, rad, dis)) * f;
				}

				// vigneting	
				color *= sqrt(1.5 - 0.5 * length(uv));
				
				return color;
			}
			ENDCG
		}
	}
}
