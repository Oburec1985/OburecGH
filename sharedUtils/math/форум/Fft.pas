unit fft;
interface
uses Math, Ap, Sysutils;
 
procedure FastFourierTransform(var a : TReal1DArray;
     nn : Integer;
     InverseFFT : Boolean);
 
implementation
 
procedure FastFourierTransform(var a : TReal1DArray;
     nn : Integer;
     InverseFFT : Boolean);
var
    ii : Integer;
    jj : Integer;
    n : Integer;
    mmax : Integer;
    m : Integer;
    j : Integer;
    istep : Integer;
    i : Integer;
    isign : Integer;
    wtemp : Double;
    wr : Double;
    wpr : Double;
    wpi : Double;
    wi : Double;
    theta : Double;
    tempr : Double;
    tempi : Double;
begin
    if InverseFFT then
    begin
        isign := -1;
    end
    else
    begin
        isign := 1;
    end;
    n := 2*nn;
    j := 1;
    ii:=1;
    while ii<=nn do
    begin
        i := 2*ii-1;
        if j>i then
        begin
            tempr := a[j-1];
            tempi := a[j];
            a[j-1] := a[i-1];
            a[j] := a[i];
            a[i-1] := tempr;
            a[i] := tempi;
        end;
        m := n div 2;
        while (m>=2) and (j>m) do
        begin
            j := j-m;
            m := m div 2;
        end;
        j := j+m;
        Inc(ii);
    end;
    mmax := 2;
    while n>mmax do
    begin
        istep := 2*mmax;
        theta := 2*Pi/(isign*mmax);
        wpr := -2.0*sqr(sin(0.5*theta));
        wpi := sin(theta);
        wr := 1.0;
        wi := 0.0;
        ii:=1;
        while ii<=mmax div 2 do
        begin
            m := 2*ii-1;
            jj:=0;
            while jj<=(n-m) div istep do
            begin
                i := m+jj*istep;
                j := i+mmax;
                tempr := wr*a[j-1]-wi*a[j];
                tempi := wr*a[j]+wi*a[j-1];
                a[j-1] := a[i-1]-tempr;
                a[j] := a[i]-tempi;
                a[i-1] := a[i-1]+tempr;
                a[i] := a[i]+tempi;
                Inc(jj);
            end;
            wtemp := wr;
            wr := wr*wpr-wi*wpi+wr;
            wi := wi*wpr+wtemp*wpi+wi;
            Inc(ii);
        end;
        mmax := istep;
    end;
    if InverseFFT then
    begin
        I:=1;
        while I<=2*nn do
        begin
            a[I-1] := a[I-1]/nn;
            Inc(I);
        end;
    end;
end;
 
 
end.