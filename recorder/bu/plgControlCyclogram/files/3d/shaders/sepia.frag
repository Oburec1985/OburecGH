void main(void)
{
	float gray = dot(gl_Color.rgb, vec3(0.3, 0.59, 0.11));
	// Копируем полутоновое значение в RgB компоненты
	gl_FragColor = vec4(gray * vec3(1.2, 1.0, 0.8), 1.0);
}