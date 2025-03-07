unit testkmeansunit;
interface
uses Math, Sysutils, Ap, blas, kmeans;

function TestKMeans(Silent : Boolean):Boolean;
function testkmeansunit_test_silent():Boolean;
function testkmeansunit_test():Boolean;

implementation

procedure SimpleTest1(NVars : AlglibInteger;
     NC : AlglibInteger;
     PassCount : AlglibInteger;
     var ConvErrors : Boolean;
     var OtherErrors : Boolean;
     var SimpleErrors : Boolean);forward;
procedure RestartsTest(var ConvErrors : Boolean;
     var RestartsErrors : Boolean);forward;
function RNormal():Double;forward;
function RSphere(var XY : TReal2DArray;
     N : AlglibInteger;
     I : AlglibInteger):Double;forward;


function TestKMeans(Silent : Boolean):Boolean;
var
    NF : AlglibInteger;
    MaxNF : AlglibInteger;
    NC : AlglibInteger;
    MaxNC : AlglibInteger;
    PassCount : AlglibInteger;
    Pass : AlglibInteger;
    WasErrors : Boolean;
    ConvErrors : Boolean;
    SimpleErrors : Boolean;
    ComplexErrors : Boolean;
    OtherErrors : Boolean;
    RestartsErrors : Boolean;
begin
    
    //
    // Primary settings
    //
    MaxNF := 5;
    MaxNC := 5;
    PassCount := 10;
    WasErrors := False;
    ConvErrors := False;
    OtherErrors := False;
    SimpleErrors := False;
    ComplexErrors := False;
    RestartsErrors := False;
    
    //
    //
    //
    NF:=1;
    while NF<=MaxNF do
    begin
        NC:=1;
        while NC<=MaxNC do
        begin
            SimpleTest1(NF, NC, PassCount, ConvErrors, OtherErrors, SimpleErrors);
            Inc(NC);
        end;
        Inc(NF);
    end;
    RestartsTest(ConvErrors, RestartsErrors);
    
    //
    // Final report
    //
    WasErrors := ConvErrors or OtherErrors or SimpleErrors or ComplexErrors or RestartsErrors;
    if  not Silent then
    begin
        Write(Format('K-MEANS TEST'#13#10'',[]));
        Write(Format('TOTAL RESULTS:                           ',[]));
        if  not WasErrors then
        begin
            Write(Format('OK'#13#10'',[]));
        end
        else
        begin
            Write(Format('FAILED'#13#10'',[]));
        end;
        Write(Format('* CONVERGENCE:                           ',[]));
        if  not ConvErrors then
        begin
            Write(Format('OK'#13#10'',[]));
        end
        else
        begin
            Write(Format('FAILED'#13#10'',[]));
        end;
        Write(Format('* SIMPLE TASKS:                          ',[]));
        if  not SimpleErrors then
        begin
            Write(Format('OK'#13#10'',[]));
        end
        else
        begin
            Write(Format('FAILED'#13#10'',[]));
        end;
        Write(Format('* COMPLEX TASKS:                         ',[]));
        if  not ComplexErrors then
        begin
            Write(Format('OK'#13#10'',[]));
        end
        else
        begin
            Write(Format('FAILED'#13#10'',[]));
        end;
        Write(Format('* OTHER PROPERTIES:                      ',[]));
        if  not OtherErrors then
        begin
            Write(Format('OK'#13#10'',[]));
        end
        else
        begin
            Write(Format('FAILED'#13#10'',[]));
        end;
        Write(Format('* RESTARTS PROPERTIES:                   ',[]));
        if  not RestartsErrors then
        begin
            Write(Format('OK'#13#10'',[]));
        end
        else
        begin
            Write(Format('FAILED'#13#10'',[]));
        end;
        if WasErrors then
        begin
            Write(Format('TEST SUMMARY: FAILED'#13#10'',[]));
        end
        else
        begin
            Write(Format('TEST SUMMARY: PASSED'#13#10'',[]));
        end;
        Write(Format(''#13#10''#13#10'',[]));
    end;
    Result :=  not WasErrors;
end;


(*************************************************************************
Simple test 1: ellipsoid in NF-dimensional space.
compare k-means centers with random centers
*************************************************************************)
procedure SimpleTest1(NVars : AlglibInteger;
     NC : AlglibInteger;
     PassCount : AlglibInteger;
     var ConvErrors : Boolean;
     var OtherErrors : Boolean;
     var SimpleErrors : Boolean);
var
    NPoints : AlglibInteger;
    MajorAxis : AlglibInteger;
    XY : TReal2DArray;
    Tmp : TReal1DArray;
    V : Double;
    I : AlglibInteger;
    J : AlglibInteger;
    Info : AlglibInteger;
    C : TReal2DArray;
    XYC : TInteger1DArray;
    Pass : AlglibInteger;
    Restarts : AlglibInteger;
    EKMeans : Double;
    ERandom : Double;
    DClosest : Double;
    CClosest : AlglibInteger;
    i_ : AlglibInteger;
begin
    NPoints := NC*100;
    Restarts := 5;
    PassCount := 10;
    SetLength(Tmp, NVars-1+1);
    Pass:=1;
    while Pass<=PassCount do
    begin
        
        //
        // Fill
        //
        SetLength(XY, NPoints-1+1, NVars-1+1);
        MajorAxis := RandomInteger(NVars);
        I:=0;
        while I<=NPoints-1 do
        begin
            RSphere(XY, NVars, I);
            XY[I,MajorAxis] := NC*XY[I,MajorAxis];
            Inc(I);
        end;
        
        //
        // Test
        //
        KMeansGenerate(XY, NPoints, NVars, NC, Restarts, Info, C, XYC);
        if Info<0 then
        begin
            ConvErrors := True;
            Exit;
        end;
        
        //
        // Test that XYC is correct mapping to cluster centers
        //
        I:=0;
        while I<=NPoints-1 do
        begin
            CClosest := -1;
            DClosest := MaxRealNumber;
            J:=0;
            while J<=NC-1 do
            begin
                APVMove(@Tmp[0], 0, NVars-1, @XY[I][0], 0, NVars-1);
                for i_ := 0 to NVars-1 do
                begin
                    Tmp[i_] := Tmp[i_] - C[i_,J];
                end;
                V := APVDotProduct(@Tmp[0], 0, NVars-1, @Tmp[0], 0, NVars-1);
                if AP_FP_Less(V,DClosest) then
                begin
                    CClosest := J;
                    DClosest := V;
                end;
                Inc(J);
            end;
            if CClosest<>XYC[I] then
            begin
                OtherErrors := True;
                Exit;
            end;
            Inc(I);
        end;
        
        //
        // Use first NC rows of XY as random centers
        // (XY is totally random, so it is as good as any other choice).
        //
        // Compare potential functions.
        //
        EKMeans := 0;
        I:=0;
        while I<=NPoints-1 do
        begin
            APVMove(@Tmp[0], 0, NVars-1, @XY[I][0], 0, NVars-1);
            for i_ := 0 to NVars-1 do
            begin
                Tmp[i_] := Tmp[i_] - C[i_,XYC[I]];
            end;
            V := APVDotProduct(@Tmp[0], 0, NVars-1, @Tmp[0], 0, NVars-1);
            EKMeans := EKMeans+V;
            Inc(I);
        end;
        ERandom := 0;
        I:=0;
        while I<=NPoints-1 do
        begin
            DClosest := MaxRealNumber;
            J:=0;
            while J<=NC-1 do
            begin
                APVMove(@Tmp[0], 0, NVars-1, @XY[I][0], 0, NVars-1);
                APVSub(@Tmp[0], 0, NVars-1, @XY[J][0], 0, NVars-1);
                V := APVDotProduct(@Tmp[0], 0, NVars-1, @Tmp[0], 0, NVars-1);
                if AP_FP_Less(V,DClosest) then
                begin
                    DClosest := V;
                end;
                Inc(J);
            end;
            ERandom := ERandom+V;
            Inc(I);
        end;
        if AP_FP_Less(ERandom,EKMeans) then
        begin
            SimpleErrors := True;
            Exit;
        end;
        Inc(Pass);
    end;
end;


(*************************************************************************
This non-deterministic test checks that Restarts>1 significantly  improves
quality of results.

Subroutine generates random task 3 unit balls in 2D, each with 20  points,
separated by 5 units wide gaps, and solves it  with  Restarts=1  and  with
Restarts=5. Potential functions are compared,  outcome  of  the  trial  is
either 0 or 1 (depending on what is better).

Sequence of 1000 such tasks is  solved.  If  Restarts>1  actually  improve
quality of solution, sum of outcome will be non-binomial.  If  it  doesn't
matter, it will be binomially distributed.

P.S. This test was added after report from Gianluca  Borello  who  noticed
error in the handling of multiple restarts.
*************************************************************************)
procedure RestartsTest(var ConvErrors : Boolean; var RestartsErrors : Boolean);
var
    NPoints : AlglibInteger;
    NVars : AlglibInteger;
    NClusters : AlglibInteger;
    ClusterSize : AlglibInteger;
    Restarts : AlglibInteger;
    PassCount : AlglibInteger;
    SigmaThreshold : Double;
    P : Double;
    S : Double;
    XY : TReal2DArray;
    CA : TReal2DArray;
    CB : TReal2DArray;
    XYCA : TInteger1DArray;
    XYCB : TInteger1DArray;
    Tmp : TReal1DArray;
    I : AlglibInteger;
    J : AlglibInteger;
    Info : AlglibInteger;
    Pass : AlglibInteger;
    EA : Double;
    EB : Double;
    V : Double;
    i_ : AlglibInteger;
begin
    Restarts := 5;
    PassCount := 1000;
    ClusterSize := 20;
    NClusters := 3;
    NVars := 2;
    NPoints := NClusters*ClusterSize;
    SigmaThreshold := 5;
    SetLength(XY, NPoints, NVars);
    SetLength(Tmp, NVars);
    P := 0;
    Pass:=1;
    while Pass<=PassCount do
    begin
        
        //
        // Fill
        //
        I:=0;
        while I<=NPoints-1 do
        begin
            RSphere(XY, NVars, I);
            J:=0;
            while J<=NVars-1 do
            begin
                XY[I,J] := XY[I,J]+AP_Double(I)/ClusterSize*5;
                Inc(J);
            end;
            Inc(I);
        end;
        
        //
        // Test: Restarts=1
        //
        KMeansGenerate(XY, NPoints, NVars, NClusters, 1, Info, CA, XYCA);
        if Info<0 then
        begin
            ConvErrors := True;
            Exit;
        end;
        EA := 0;
        I:=0;
        while I<=NPoints-1 do
        begin
            APVMove(@Tmp[0], 0, NVars-1, @XY[I][0], 0, NVars-1);
            for i_ := 0 to NVars-1 do
            begin
                Tmp[i_] := Tmp[i_] - CA[i_,XYCA[I]];
            end;
            V := APVDotProduct(@Tmp[0], 0, NVars-1, @Tmp[0], 0, NVars-1);
            EA := EA+V;
            Inc(I);
        end;
        
        //
        // Test: Restarts>1
        //
        KMeansGenerate(XY, NPoints, NVars, NClusters, Restarts, Info, CB, XYCB);
        if Info<0 then
        begin
            ConvErrors := True;
            Exit;
        end;
        EB := 0;
        I:=0;
        while I<=NPoints-1 do
        begin
            APVMove(@Tmp[0], 0, NVars-1, @XY[I][0], 0, NVars-1);
            for i_ := 0 to NVars-1 do
            begin
                Tmp[i_] := Tmp[i_] - CB[i_,XYCB[I]];
            end;
            V := APVDotProduct(@Tmp[0], 0, NVars-1, @Tmp[0], 0, NVars-1);
            EB := EB+V;
            Inc(I);
        end;
        
        //
        // Calculate statistic.
        //
        if AP_FP_Less(EA,EB) then
        begin
            P := P+1;
        end;
        if AP_FP_Eq(EA,EB) then
        begin
            P := P+0.5;
        end;
        Inc(Pass);
    end;
    
    //
    // If Restarts doesn't influence quality of centers found, P must be
    // binomially distributed random value with mean 0.5*PassCount and
    // standard deviation Sqrt(PassCount/4).
    //
    // If Restarts do influence quality of solution, P must be significantly
    // lower than 0.5*PassCount.
    //
    S := (P-0.5*PassCount)/Sqrt(AP_Double(PassCount)/4);
    RestartsErrors := RestartsErrors or AP_FP_Greater(S,-SigmaThreshold);
end;


(*************************************************************************
Random normal number
*************************************************************************)
function RNormal():Double;
var
    U : Double;
    V : Double;
    S : Double;
    X1 : Double;
    X2 : Double;
begin
    while True do
    begin
        U := 2*RandomReal-1;
        V := 2*RandomReal-1;
        S := AP_Sqr(u)+AP_Sqr(v);
        if AP_FP_Greater(S,0) and AP_FP_Less(S,1) then
        begin
            S := Sqrt(-2*Ln(S)/S);
            X1 := U*S;
            X2 := V*S;
            Break;
        end;
    end;
    Result := X1;
end;


(*************************************************************************
Random point from sphere
*************************************************************************)
function RSphere(var XY : TReal2DArray;
     N : AlglibInteger;
     I : AlglibInteger):Double;
var
    J : AlglibInteger;
    V : Double;
begin
    J:=0;
    while J<=N-1 do
    begin
        XY[I,J] := RNormal;
        Inc(J);
    end;
    V := APVDotProduct(@XY[I][0], 0, N-1, @XY[I][0], 0, N-1);
    V := RandomReal/Sqrt(V);
    APVMul(@XY[I][0], 0, N-1, V);
end;


(*************************************************************************
Silent unit test
*************************************************************************)
function testkmeansunit_test_silent():Boolean;
begin
    Result := TestKMeans(True);
end;


(*************************************************************************
Unit test
*************************************************************************)
function testkmeansunit_test():Boolean;
begin
    Result := TestKMeans(False);
end;


end.