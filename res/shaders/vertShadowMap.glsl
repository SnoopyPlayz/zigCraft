#version 330

// Input vertex attributes
in uint vertexPosition;

// Input uniform values
uniform mat4 mvp;
uniform mat4 matModel;
uniform mat4 matNormal;

// Output vertex attributes (to fragment shader)
out vec3 fragPosition;
out vec2 fragTexCoord;
out vec4 fragColor;
out vec3 fragNormal;

// NOTE: Add here your custom variables

uint texPos;
vec3 UnpackInt(uint pos) {
	texPos = (pos >> 20) & uint(0xFF);
	uint x = (pos >> 12) & uint(0x3F);
	uint y = (pos >> 6) & uint(0x3F);
	uint z = pos & uint(0x3F);

	return vec3(float(x) - 0.5,float(y) - 0.5,float(z) - 0.5);
}

void main(){
	vec3 pos = UnpackInt(vertexPosition);
	// Send vertex attributes to fragment shader
	fragPosition = vec3(matModel*vec4(pos, 1.0));

	int row = int(texPos / 16.0); // row in texture atlas
	float blockTexSize = (1.0 / 16.0);
	fragTexCoord = vec2(float(texPos - uint(row * 17)) * blockTexSize, float(row) * blockTexSize);

	//fragNormal = normalize(vec3(matNormal*vec4(vertexNormal, 1.0)));

	// Calculate final vertex position
	gl_Position = mvp*vec4(pos, 1.0);
}
