
program _test;
uses Sysutils, testevdunit;

var
    MySeed: Cardinal;
begin
    if StrToIntDef(ParamStr(1),0)=0 then
    begin
        Randomize();
        MySeed:=RandSeed;
    end
    else
        MySeed:=StrToIntDef(ParamStr(1),0);
    RandSeed:=MySeed;
    try 
        if not testevdunit_test_silent() then
            raise Exception.Create('');
    except on E: Exception do 
        begin
            WriteLn('SEED ', MySeed:9, '    UNIT ', 'evd');
            Halt(1);
        end;
    end;
    Halt(0);
end.
