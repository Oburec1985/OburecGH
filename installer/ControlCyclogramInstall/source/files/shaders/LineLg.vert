uniform vec4 a_minmax;
uniform ivec2 a_Lg;

//Log.b(X) = Log.a(X)/Log.a(b) 
float Log10(float x) {
	x = log2(x)/log2(10);
	return(x);
}

void main()
{
	float rate, y, lgMax, lgMin, lgRange, range, test;
	gl_Position	 = gl_Vertex;	
	gl_FrontColor = gl_Color;	
	if (a_Lg[0]==1) // если логарифм по Y включен
	{
		lgMax=log10(a_minmax[1]);
		test = lgMax;
		if (a_minmax[0]<=0){
		  lgMin=0.0000000001;
		}
		else{
		  lgMin=log10(a_minmax[0]);
		}
		lgRange=lgMax-lgMin;
		range=a_minmax[1]-a_minmax[0];
		lgRange=1/lgRange;
		
		if (gl_Position[0]==0) {
		  rate=0;
		  gl_Position[0]=-200;
		} else{
			rate=(log10(gl_Position[0])-lgMin)*lgRange; // перевод в относительные единицы от диапаона lg 0..1
			gl_Position[0]=range*rate+a_minmax[0];	
		}
	}

	if (a_Lg[1]==1) // если логарифм по Y включен
	{
		lgMax=log10(a_minmax[3]);
		test = lgMax;
		if (a_minmax[2]<=0){
		  lgMin=0.0000000001;
		}
		else{
		  lgMin=log10(a_minmax[2]);
		}
		lgRange=lgMax-lgMin;
		range=a_minmax[3]-a_minmax[2];
		lgRange=1/lgRange;
		
		if (gl_Position[1]==0) {
		  rate=0;
		  gl_Position[1]=-200;
		} else{
			rate=(log10(gl_Position[1])-lgMin)*lgRange; // перевод в относительные единицы от диапаона lg 0..1
			gl_Position[1]=range*rate+a_minmax[2];	
		}
	}
	// домножаем видовую матрицу
	gl_Position	 = gl_ModelViewProjectionMatrix*gl_Position;
	
	//int i=3;
	//if (gl_Position[1]>1) {
	//	gl_FrontColor = vec4(0.0,0.0,0.0,1.0);
	//}
} 