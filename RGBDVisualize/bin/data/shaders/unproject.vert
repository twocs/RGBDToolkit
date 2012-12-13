#version 110

uniform vec2 dim;
uniform vec2 shift;
uniform vec2 scale;

uniform sampler2DRect depthTex;
uniform vec2 principalPoint;
uniform vec2 fov;
uniform float farClip;
uniform float edgeClip;
uniform float xsimplify;
uniform float ysimplify;

uniform int useTexture;
varying float VZPositionValid0;
varying float intDistance;
void main(void)
{
    
    vec2 texCoordPixAligned = floor(gl_Vertex.xy) + vec2(.5,.5);
    
    float depth = texture2DRect(depthTex, texCoordPixAligned).r * 65535.;
    float right = texture2DRect(depthTex, texCoordPixAligned + vec2(xsimplify,0.0)).r * 65535.;
    float down  = texture2DRect(depthTex, texCoordPixAligned + vec2(0.0,ysimplify)).r * 65535.;
    
    VZPositionValid0 = (
                        abs(down - depth) < edgeClip &&
                        abs(right - depth) < edgeClip &&
                        depth < farClip &&
                        depth > 20. &&
                        right > 20. &&
                        down > 20.
                        ) ? 1.0 : 0.0;
    
	vec4 pos = vec4((gl_Vertex.x - principalPoint.x) * depth / fov.x,
                    (gl_Vertex.y - principalPoint.y) * depth / fov.y, depth, 1.0);
    
    intDistance = (texCoordPixAligned.y - floor(texCoordPixAligned.y))*100.0;
    //projective texture on the
    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * pos;
    gl_FrontColor = gl_Color;

    if(useTexture == 1){

        mat4 tTex = gl_TextureMatrix[0];
        vec4 texCd = tTex * pos;
        texCd.xyz /= texCd.w;
        
        texCd.y *= -1.;
        texCd.xy += 1.;
        texCd.xy /= 2.;
        
        texCd.xy *= scale;
        texCd.xy += shift;
        
        texCd.xy *= dim;
        gl_TexCoord[0] = texCd;
    }
}
