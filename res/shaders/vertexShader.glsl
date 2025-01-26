#version 330
//vertex pos
in vec3 vertexPosition;
in vec2 vertexTexCoord;

// texture
out vec2 fragTexCoord;

// vertex color
in vec4 vertexColor;
out vec4 fragColor;

// camera projection
uniform mat4 mvp;

// texture reapeat tiling
uniform vec2 tiling = vec2(1.0, 1.0);

void main() {
	if(vertexColor.a < 0.1)
		discard;

    fragTexCoord = vertexTexCoord * tiling;
    fragColor = vertexColor;       
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
