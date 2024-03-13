attribute vec4 a_minmax;

//Log.b(X) = Log.a(X)/Log.a(b) 
float Log10(float x) {
	x = log2(x)/log2(10);
	return(x);
}

void main()
{
	float rate, y, lgMax, lgMin, lgRange, range;
    lgMax=log10(a_minmax[3]);
    if (a_minmax[2]<=0){
      lgMin=0.0000000001;
	}
    else{
      lgMin=log10(a_minmax[2]);
    }
    lgRange=lgMax-lgMin;
    range=a_minmax[3]-a_minmax[2];
	gl_Position	 = gl_Vertex;
	if (gl_Position[1]==0) {
      rate=0;
	  gl_Position[1]=-200;
	} else{
        rate=(log10(gl_Position[1])-lgMin)*lgRange; // перевод в относительные единицы от диапаона lg 0..1
        gl_Position[1]=range*rate+a_minmax[2];	
	}	
} 