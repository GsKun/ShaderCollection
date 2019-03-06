// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ImageEffect/SunFlower" { 
    Properties{
        iMouse ("Mouse Pos", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100, 100, 0, 0)
    }

    CGINCLUDE    
    #include "UnityCG.cginc"   
    #pragma target 3.0      

    #define vec2 float2
    #define vec3 float3
    #define vec4 float4
    #define mat2 float2x2
    #define mat3 float3x3
    #define mat4 float4x4
    #define iGlobalTime _Time.y
    #define iTime _Time.y
    #define mod fmod
    #define mix lerp
    #define fract frac
    #define texture2D tex2D
    #define iResolution _ScreenParams
    #define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy)

    #define PI2 6.28318530718
    #define pi 3.14159265358979
    #define halfpi (pi * 0.5)
    #define oneoverpi (1.0 / pi)

    #define atan atan2

    #define N 10.

    fixed4 iMouse;
    sampler2D iChannel0;
    fixed4 iChannelResolution0;

    struct v2f {    
        float4 pos : SV_POSITION;    
        float4 scrPos : TEXCOORD0;   
    };              

    v2f vert(appdata_base v) {  
        v2f o;
        o.pos = UnityObjectToClipPos (v.vertex);
        o.scrPos = ComputeScreenPos(o.pos);
        return o;
    }  

/////////////////////////////////////////



//////////////////////////////////////////////

    vec4 main(vec2 fragCoord);

    fixed4 frag(v2f _iParam) : COLOR0 { 
        vec2 fragCoord = gl_FragCoord;
        return main(gl_FragCoord);
    }  

    vec4 main(vec2 u) 
    {
    	vec4 o = vec4(1,1,1,1);
	    u = (u+u-(o.xy=iResolution.xy))/o.y;
	    //u = 2.*(u / iResolution.y -vec2(.9,.5));
	    float t = iTime,
	  	r = length(u), a = atan(u.y,u.x),
	  	i = floor(r*N);
	    a *= floor(pow(128.,i/N)); 	 
	    a += 20.*sin(.5*t)+123.34*i-100.*r*cos(.5*t); // (r-0.*i/N)
	    r +=  (.5+.5*cos(a)) / N;    
	    r = floor(N*r)/N;
		o = (1.-r)*vec4(.5,1,1.5,1);
		return o;
    }

    ENDCG    

    SubShader {    
        Pass {    
            CGPROGRAM    

            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     

            ENDCG    
        }    
    }     
    FallBack Off    
}