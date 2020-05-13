unit uLog3dFile;

interface
uses Windows,  SysUtils, Forms, Classes,Menus,shellapi, dialogs, mathfunction,
  uCommonTypes, u3dTypes;
type
  // ����� ��� ���������� ������� ������
  cLog3dFile = class
  private
    // ��� ����� �� �������� ����������� ������ �������� ������
    m_Filename:string;
  public
    // ������ ���� ������
    log:TStringList;
  public
    // �������� ��� ����� � ������ �����
    constructor Create(Filename:string);
    // �������� ��� ����� � ������ �����
    destructor Destroy;
    // �������� ������ � ���
    procedure addstring(str:string);
    // �������� ������� � ��� ��� ������ name. ������ � ������
    procedure addmatrixstr(name:string;m:matrixgl);
    // �������� ������� � ��� ��� ������ name. ������ ����������
    procedure addmatrix(name:string;m:matrixgl);
    // �������� ������
    procedure addp3(name:string;p3:point3);
    // �������� bound
    procedure addBound(name:string;bound:tbound);
    // �������� ������ ������
    procedure AddEmpty;
    // ��������� ���
    procedure Save;
  end;

implementation

constructor cLog3dFile.Create(Filename: string);
begin
  m_filename:=filename;
  log:=tstringlist.Create;
end;

Destructor cLog3dFile.destroy;
begin
  save;
  log.Destroy;
end;

procedure cLog3dFile.Save;
var f:file;
begin
  if not fileexists(m_filename) then
  begin
    assignfile(f,m_filename);
    ReWrite(f);
    closefile(f);
  end;
  log.SaveToFile(m_filename);
end;

procedure cLog3dFile.addstring(str:string);
begin
  log.Add(str);
end;

procedure cLog3dFile.addmatrixstr(name:string;m:matrixgl);
var str:string;
  I: Integer;
begin
  str:='matrix name: '+name+'  ';
  for I := 0 to 15 do
  begin
    str:=str+formatstr(m[i],3)+', ';
  end;
  addstring(str);
end;

procedure cLog3dFile.addmatrix(name:string;m:matrixgl);
begin

end;

procedure cLog3dFile.addp3(name:string;p3:point3);
var str:string;
begin
  str:=name+'  '+formatstr(p3.x,3)+', '+formatstr(p3.y,3)+', '+formatstr(p3.z,3);
  addstring(str);
end;

procedure cLog3dFile.addBound(name:string;bound:tbound);
var str:string;
begin
  str:=name+'  Lo: '+formatstr(bound.lo.x,3)+', '+formatstr(bound.lo.y,3)+', '+formatstr(bound.lo.z,3)
           +'  Hi: '+formatstr(bound.hi.x,3)+', '+formatstr(bound.hi.y,3)+', '+formatstr(bound.hi.z,3);
  addstring(str);
end;

procedure cLog3dFile.addEmpty;
var str:string;
begin
  str:='';
  addstring(str);
end;


end.
