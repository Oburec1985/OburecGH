program LuaTest;

uses
  Forms,
  Unit11 in 'Unit11.pas' {Form11},
  LuaBind.CustomType.DataSet in '..\..\LuaBind.CustomType.DataSet.pas',
  LuaBind.CustomType.PODO in '..\..\LuaBind.CustomType.PODO.pas',
  LuaBind.CustomType.UserType in '..\..\LuaBind.CustomType.UserType.pas',
  LuaBind.DelphiObjects in '..\..\LuaBind.DelphiObjects.pas',
  LuaBind.Filters.Text in '..\..\LuaBind.Filters.Text.pas',
  LuaBind.Intf in '..\..\LuaBind.Intf.pas',
  LuaBind in '..\..\LuaBind.pas',
  TestLuaEmbeddedTextFilter in '..\..\unittests\TestLuaEmbeddedTextFilter.pas',
  TestLuaWrapper in '..\..\unittests\TestLuaWrapper.pas',
  TestObjects in '..\..\unittests\TestObjects.pas';

{$R *.res}


begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  AApplication.CreateForm(TForm11, Form11);
  pplication.Run;

end.
