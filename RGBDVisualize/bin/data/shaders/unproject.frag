#version 110
#extension GL_ARB_texture_rectangle : enable

uniform sampler2DRect colorTex;
uniform sampler2DRect faceTex;
uniform sampler2DRect distortTex;

uniform float distortionSampleAmount;

uniform int useTexture;
varying float VZPositionValid0;
varying vec3 normal;
const float epsilon = 1e-6;

varying vec3 distortionColorSample;

uniform float scanlineDiscardThreshold;
varying float scanlineDiscard;

void main()
{
    if(VZPositionValid0 < epsilon || scanlineDiscard < (scanlineDiscardThreshold+epsilon)){
    	discard;
        return;
    }

    if(useTexture == 1){
        vec4 col = texture2DRect(colorTex, gl_TexCoord[0].st);
        vec4 distortionColor = texture2DRect(distortTex, distortionColorSample.xy);
        gl_FragData[0] = mix(col, distortionColor, distortionSampleAmount * (1.0 - ( pow(1.0 - distortionColorSample.z, 4.0) )) ) * gl_Color;
        //gl_FragData[0] = mix(col, distortionColor, 1.0 ) * gl_Color;
    }
    else{
        gl_FragData[0] = vec4(0);
    }    

    vec4 faceAttenuation = texture2DRect(faceTex, gl_TexCoord[0].st);
    //blue for face, red for eyes
    gl_FragData[1] = vec4( normal * (1.0 - faceAttenuation.b) , 1.0 ) ;
    //gl_FragData[1] = vec4( normal, 1.0 ) ;

    //gl_FragData[0] = vec4(1.0, 0.0, 0.0, 1.0);
    //gl_FragColor = vec4(VZPositionValid0);
    //gl_FragColor.z = 1.0;
}