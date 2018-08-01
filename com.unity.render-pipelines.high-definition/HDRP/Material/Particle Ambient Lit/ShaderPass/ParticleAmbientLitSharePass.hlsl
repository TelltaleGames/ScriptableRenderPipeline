#ifndef SHADERPASS
#error Undefine_SHADERPASS
#endif

#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_COLOR


#if defined(DEBUG_DISPLAY) || (SHADERPASS == SHADERPASS_LIGHT_TRANSPORT)
// For the meta pass with emissive we require UV1 and/or UV2
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#endif

// Needed for ambient lighting
//#if defined(_ENABLE_FOG_ON_TRANSPARENT) || (SHADERPASS == SHADERPASS_VELOCITY)
#define VARYINGS_NEED_POSITION_WS
//#endif

#define VARYINGS_NEED_TANGENT_TO_WORLD
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_TEXCOORD1
#define VARYINGS_NEED_TEXCOORD2

#define VARYINGS_NEED_COLOR


// This include will define the various Attributes/Varyings structure
#include "../../ShaderPass/VaryingMesh.hlsl"
