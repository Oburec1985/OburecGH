void main(void)
{
	float gray = dot(gl_Color.rgb, vec3(0.3, 0.59, 0.11));
	// �������� ����������� �������� � RgB ����������
	gl_FragColor = vec4(gray, gray, gray, 1.0);
}