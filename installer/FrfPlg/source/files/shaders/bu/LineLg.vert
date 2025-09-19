// minx, maxx, miny, maxy 
in vec4 a_minmax;
void main()
{
	lightDir = normalize(vec3(gl_LightSource[0].position));
	normal = gl_NormalMatrix * gl_Normal;
	// gl_Position - встроенная переменная вершинного шейдера
	// gl_Vertex текущая вершина в конвеере
	gl_Position = gl_Vertex;
} 