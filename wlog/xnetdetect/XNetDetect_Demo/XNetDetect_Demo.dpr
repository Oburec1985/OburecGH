program XNetDetect_Demo;

uses
  Forms,
  uXNetDetect_Demo in 'uXNetDetect_Demo.pas' {Form1},
  XuNetUtil in '..\..\..\sharedUtils\компоненты\dcl_dpk\x-net\XuNetUtil.pas',
  XNetDetect_v2 in '..\..\..\sharedUtils\компоненты\dcl_dpk\x-net\XNetDetect_v2.pas',
  XuConnCheckThread in '..\..\..\sharedUtils\компоненты\dcl_dpk\x-net\XuConnCheckThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
