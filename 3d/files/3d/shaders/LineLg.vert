// minx, maxx, miny, maxy 
in vec4 minmax;


void main()
{
	lightDir = normalize(vec3(gl_LightSource[0].position));
	normal = gl_NormalMatrix * gl_Normal;
	gl_Position = ftransform();
} 