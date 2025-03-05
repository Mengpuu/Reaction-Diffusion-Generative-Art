
#version 150

#define SAMPLER0 sampler2D // sampler2D, sampler3D, samplerCube
#define SAMPLER1 sampler2D // sampler2D, sampler3D, samplerCube
#define SAMPLER2 sampler2D // sampler2D, sampler3D, samplerCube
#define SAMPLER3 sampler2D // sampler2D, sampler3D, samplerCube

uniform SAMPLER0 iChannel0; // image/buffer/sound    Sampler for input textures 0
uniform SAMPLER1 iChannel1; // image/buffer/sound    Sampler for input textures 1
uniform SAMPLER2 iChannel2; // image/buffer/sound    Sampler for input textures 2
uniform SAMPLER3 iChannel3; // image/buffer/sound    Sampler for input textures 3

uniform vec3  iResolution;           // image/buffer          The viewport resolution (z is pixel aspect ratio, usually 1.0)
uniform float iTime;                 // image/sound/buffer    Current time in seconds
uniform float iTimeDelta;            // image/buffer          Time it takes to render a frame, in seconds
uniform int   iFrame;                // image/buffer          Current frame
uniform float iFrameRate;            // image/buffer          Number of frames rendered per second
uniform vec4  iMouse;                // image/buffer          xy = current pixel coords (if LMB is down). zw = click pixel
uniform vec4  iDate;                 // image/buffer/sound    Year, month, day, time in seconds in .xyzw
uniform float iSampleRate;           // image/buffer/sound    The sound sample rate (typically 44100)
uniform float iChannelTime[4];       // image/buffer          Time for channel (if video or sound), in seconds
uniform vec3  iChannelResolution[4]; // image/buffer/sound    Input texture resolution for each channel


// Buf A/B/C/D are duplicated to get higher speed without killing accuracy too much

const vec2 DiffusionRate = vec2(1.0, 0.5);
const float KillRate = 0.0590;
const float FeedRate = 0.0260;
const float Speed = 40.0;



vec2 computeLaplacian(vec2 uv, vec2 current)
{
    vec2 pixelSize = vec2(1.) / iResolution.xy;
    
    // with diagonals.
    return (texture(iChannel0, uv + vec2(pixelSize.x, 0.0)).xy +
            texture(iChannel0, uv - vec2(pixelSize.x, 0.0)).xy +
            texture(iChannel0, uv + vec2(0.0, pixelSize.y)).xy +
            texture(iChannel0, uv - vec2(0.0, pixelSize.y)).xy) * 0.2
            +
           (texture(iChannel0, uv + pixelSize).xy +
            texture(iChannel0, uv - pixelSize).xy +
            texture(iChannel0, uv + vec2(pixelSize.x, -pixelSize.y)).xy +
            texture(iChannel0, uv - vec2(pixelSize.x, -pixelSize.y)).xy) * 0.05
        -
            current;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord)
{
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 current = clamp(texture(iChannel0, uv).xy, vec2(0.), vec2(1.));


    // Compute diffusion.
    vec2 laplacian = computeLaplacian(uv, current);
    vec2 diffusion = DiffusionRate * laplacian;
        
    // Compute reaction.
    float u = current.x;
    float v = current.y;    
    float reactionU = - u * v * v + FeedRate * (1. - u);
    float reactionV = u * v * v - (FeedRate + KillRate) * v;

    

    // Apply using simple forward Euler.
    vec2 newValues = current + (diffusion + vec2(reactionU, reactionV)) * Speed * iTimeDelta;

    fragColor = vec4(newValues, 0.0, 1.0);
}