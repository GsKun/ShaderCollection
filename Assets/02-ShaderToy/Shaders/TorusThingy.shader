// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ImageEffect/TorusThingy" { 
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

    #define I_MAX		400.
	#define E			0.00001
	#define FAR			50.
	#define PI			3.14

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

vec2	march(vec3 pos, vec3 dir);
vec3	camera(vec2 uv);
void	rotate(inout vec2 v, float angle);

float 	t;			// time
vec3	ret_col;	// torus color
vec3	h; 			// light amount

vec3 blackbody(float Temp)
{
	vec3 col = vec3(255., 255., 255.);
    col.x = 56100000. * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 35200000. * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
    if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

// -------------blackbody----------------- //


float scene(vec3 p)
{  
    float	var;
    float	mind = 1e5;
    p.z += 10.;
    
    rotate(p.xz, 1.57-.5*iTime );
    rotate(p.yz, 1.57-.5*iTime );
    var = atan(p.x,p.y);
    vec2 q = vec2( ( length(p.xy) )-6.,p.z);
    rotate(q, var*.25+iTime*2.*0.);
    vec2 oq = q ;
    q = abs(q)-2.5;
    if (oq.x < q.x && oq.y > q.y)
    	rotate(q, ( (var*1.)+iTime*0.)*3.14+iTime*0.);
    else
        rotate(q, ( .28-(var*1.)+iTime*0.)*3.14+iTime*0.);
    float	oldvar = var;
    ret_col = 1.-vec3(.350, .2, .3);
    mind = length(q)+.5+1.05*(length(fract(q*.5*(3.+3.*sin(oldvar*1. - iTime*2.)) )-.5)-1.215);
    h -= vec3(-3.20,.20,1.0)*vec3(1.,1.,1.)*.0025/(.051+(mind-sin(oldvar*1. - iTime*2. + 3.14)*.125 )*(mind-sin(oldvar*1. - iTime*2. + 3.14)*.125 ) );
    h -= vec3(1.20,-.50,-.50)*vec3(1.,1.,1.)*.025/(.501+(mind-sin(oldvar*1. - iTime*2.)*.5 )*(mind-sin(oldvar*1. - iTime*2.)*.5 ) );
    h += vec3(.25, .4, .5)*.0025/(.021+mind*mind);
    
    return (mind);
}

vec2 march(vec3 pos, vec3 dir)
{
    vec2	dist = vec2(0.0, 0.0);
    vec3	p = vec3(0.0, 0.0, 0.0);
    vec2	s = vec2(0.0, 0.0);

	    for (float i = -1.; i < I_MAX; ++i)
	    {
	    	p = pos + dir * dist.y;
	        dist.x = scene(p);
	        dist.y += dist.x*.2; // makes artefacts disappear
            // log trick by aiekick
	        if (log(dist.y*dist.y/dist.x/1e5) > .0 || dist.x < E || dist.y > FAR)
            {
                break;
            }
	        s.x++;
    }
    s.y = dist.y;
    return (s);
}

// Utilities

void rotate(inout vec2 v, float angle)
{
	v = vec2(cos(angle)*v.x+sin(angle)*v.y,-sin(angle)*v.x+cos(angle)*v.y);
}

vec3	camera(vec2 uv)
{
    float		fov = 1.;
	vec3		forw  = vec3(0.0, 0.0, -1.0);
	vec3    	right = vec3(1.0, 0.0, 0.0);
	vec3    	up    = vec3(0.0, 1.0, 0.0);

    return (normalize((uv.x) * right + (uv.y) * up + fov * forw));
}


//////////////////////////////////////////////

    vec4 main(vec2 fragCoord);

    fixed4 frag(v2f _iParam) : COLOR0 { 
        vec2 fragCoord = gl_FragCoord;
        return main(gl_FragCoord);
    }  

    vec4 main(vec2 f) 
    {

	    t  = iTime*.125;
	    vec3	col = vec3(0., 0., 0.);
		vec2 R = iResolution.xy,
      	uv  = vec2(f-R/2.) / R.y;
		vec3	dir = camera(uv);
	    vec3	pos = vec3(.0, .0, 0.0);

	    pos.z = 4.5+1.5*sin(t*10.);    
	    h*=0.;
	    vec2	inter = (march(pos, dir));
	    col.xyz = ret_col*(1.-inter.x*.0125);
	    col += h * .4;
	    return vec4(col,1.0);
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