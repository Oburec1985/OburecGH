unit uEditProfileFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,uComponentServises,
  Dialogs, StdCtrls, Grids, uStringGridExt, ExtCtrls, uSpin, Buttons, uCommonTypes, inifiles,
  uCommonMath, math, utrend, ubasictrend;

type
  tunits = (tuPercent, tuLg10, tuLg20, tuAbs, tuVals);

  TProfileData = record
    p:double;
    hh:double;
    h:double;
    l:double;
    ll:double;
  end;

  TProfile = class
  private
    pars:tstringlist;
    fname:string;
  public
    m_Owner:tstringlist;
    x, HH, LL, H, L, P:array of double;
    m_data:array of TProfileData;
    units:tunits;
  protected
    procedure setname(s:string);
    procedure setsettings(s:string);
    function getsettings:string;
    Procedure SetCount(c:integer);
    function getCount:integer;
    function getValue(Ref:double;V:double):double;
  public
    procedure evalData;
    property count:integer read getcount write setcount;
    property name:string read fname write setname;
    property settings:string read getsettings write setsettings;
    constructor create;
    destructor destroy;
  end;

  TProfileList = class(tstringlist)
  protected
  public
    procedure cleardata;
    function getprof(s:string; var ind:integer):tprofile;overload;
    function getprof(ind:integer):tprofile;overload;
    constructor create;
    destructor destroy;
  end;

  TEditProfileFrm = class(TForm)
    ProfilePointsSG: TStringGridExt;
    Splitter1: TSplitter;
    Panel1: TPanel;
    ProfileNameLabel: TLabel;
    UnitsLabel: TLabel;
    LLLabel: TLabel;
    LLabel: TLabel;
    HHLabel: TLabel;
    HLabel: TLabel;
    ProfileNameEdit: TEdit;
    UnitsCB: TComboBox;
    EvalBtn: TButton;
    HiHiSE: TFloatSpinEdit;
    HiSE: TFloatSpinEdit;
    LoSE: TFloatSpinEdit;
    LoLoSE: TFloatSpinEdit;
    ApplySelectBtn: TButton;
    ApplyBtn: TSpeedButton;
    UpdateBtn: TSpeedButton;
    ProfileLB: TListBox;
    procedure ApplyBtnClick(Sender: TObject);
    procedure UpdateBtnClick(Sender: TObject);
    procedure ProfileLBMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ProfilePointsSGEndEdititng(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure ProfilePointsSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    m_prof:tprofile;
    plist:TProfileList;
  private
    procedure init;
    procedure pToSg(p:tprofile);
    procedure SgToP(p:tprofile);
    // удаляем профили которые отсутствую в списке
    procedure SyncProfileList(plist:TProfileList);
    procedure showprofilelist(plist:tstringlist);
  public
    function editProfile(p:TProfile; profilelist:tprofilelist):TProfile;
    procedure saveToIni(dir:string);
    procedure LoadIni(dir:string);
    constructor create(aowner:tcomponent);override;
  end;

function TUnitsToInt(u:tunits):integer;
function IntToUnits(i:integer):tunits;
procedure addPointsToProfile(x: array of double; data: array of TProfileData;
                             dataind: integer; tr: ctrend);

var
  EditProfileFrm: TEditProfileFrm;

const
  c_headerSize = 1;
  c_Col_N = 0;
  c_Col_X = 1;
  c_Col_P = 2;
  c_Col_HH = 3;
  c_Col_H = 4;
  c_Col_L = 5;
  c_Col_LL = 6;


implementation

{$R *.dfm}


function TUnitsToInt(u:tunits):integer;
begin
  case u of
    tuPercent: result:=0;
    tuLg10: result:=1;
    tuLg20: result:=2;
    tuAbs: result:=3;
    tuVals: result:=4;
  end;
end;

function IntToUnits(i:integer):tunits;
begin
  case i of
    0: result:=tuPercent;
    1: result:=tuLg10;
    2: result:=tuLg20;
    3: result:=tuAbs;
    4: result:=tuVals;
  end;
end;

{ TProfile }
procedure TProfile.SetCount(c: integer);
begin
  SetLength(x,c);
  SetLength(HH,c);
  SetLength(LL,c);
  SetLength(L,c);
  SetLength(H,c);
  SetLength(P,c);
  SetLength(m_data,c);
end;

function TProfile.getCount: integer;
begin
  result:=Length(x);
end;

constructor TProfile.create;
begin
  pars:=TStringList.Create;
end;

destructor TProfile.destroy;
begin
  delPars(pars);
  pars.Destroy;
end;

procedure TProfile.evalData;
var
  I, c: Integer;
begin
  c:=count;
  for I := 0 to c - 1 do
  begin
    m_data[i].p:=P[i];
    m_data[i].hh:=getValue(P[i], hh[i]);
    m_data[i].h:=getValue(P[i], h[i]);
    m_data[i].l:=getValue(P[i], l[i]);
    m_data[i].ll:=getValue(P[i], ll[i]);
  end;
end;

procedure TProfile.setname(s: string);
var
  p:tprofile;
  index:integer;
begin
  if s<>fname then
  begin
    if m_Owner<>nil then
    begin
      p:=TProfileList(m_Owner).getProf(s, index);
      while ((p<>self) and (p<>nil)) do
      begin
        s:=ModName(s, false);
        p:=TProfileList(m_Owner).getProf(s,index);
      end;

      if index<>-1 then
      begin
        m_Owner.Delete(index);
      end;
      m_Owner.AddObject(s, self);
    end;
    fname:=s;
  end;
end;

function TProfile.getValue(Ref, V: double): double;
begin
  case units of
    tuPercent:
    begin
      result:=ref*((100+v)/100);
    end;
    tuLg20: //20log
    begin
      result:=ref*(Power(10,v/20));
    end;
    tuLg10:  //10log
    begin
      result:=ref*(Power(10,v/10));
    end;
    tuAbs:  //10log
    begin
      result:=ref+v;
    end;
    tuVals:
    begin
      result:=v;
    end;
  end;
end;


procedure readArray(var a:array of double; count:integer; str:string);
var
  substr:string;
  i,ind:integer;
begin
  ind:=0;
  for I := 0 to count - 1 do
  begin
    substr:=GetSubString(str,';',ind+1,ind);
    a[i]:=strtoFloatExt(substr);
  end;
end;


procedure TProfile.setsettings(s: string);
var
  v:string;
  c:integer;
  u: Integer;
begin
  v:=GetParam(s,'Name');
  name:=v;
  c:=strtoint(getparam(s,'Count'));
  u:=strtoint(getparam(s,'Units'));
  units:=IntToUnits(u);
  count:=c;

  v:=getParam(s, 'X');
  readArray(x,c,v);
  v:=GetParam(s, 'P');
  readArray(p,c,v);
  v:=GetParam(s, 'HH');
  readArray(hh,c,v);
  v:=GetParam(s, 'H');
  readArray(h,c,v);
  v:=GetParam(s, 'L');
  readArray(l,c,v);
  v:=GetParam(s, 'LL');
  readArray(ll,c,v);
end;


function TProfile.getsettings: string;
var
  I,c: Integer;
  v:double;
  str, vstr:string;
begin
  c:=count;
  addParam(pars, 'Name', name);
  addParam(pars, 'Count', inttostr(c));
  addParam(pars, 'Units', inttostr(TUnitsToInt(units)));

  str:='';
  // X
  for I := 0 to c - 1 do
  begin
    v:=x[i];
    vstr:=floattostr(v);
    vstr:=replaceChar(vstr,',', '.');
    str:=str+vstr;
    if i<c-1 then
      str:=str+';';
  end;
  addParam(pars, 'X', str);
  // Profile
  str:='';
  for I := 0 to c - 1 do
  begin
    v:=p[i];
    vstr:=floattostr(v);
    vstr:=replaceChar(vstr,',', '.');
    str:=str+vstr;
    if i<c-1 then
      str:=str+';';
  end;
  addParam(pars, 'P', str);
  // HH
  str:='';
  for I := 0 to c - 1 do
  begin
    v:=HH[i];
    vstr:=floattostr(v);
    vstr:=replaceChar(vstr,',', '.');
    str:=str+vstr;
    if i<c-1 then
      str:=str+';';
  end;
  addParam(pars, 'HH', str);
  // H
  str:='';
  for I := 0 to c - 1 do
  begin
    v:=H[i];
    vstr:=floattostr(v);
    vstr:=replaceChar(vstr,',', '.');
    str:=str+vstr;
    if i<c-1 then
      str:=str+';';
  end;
  addParam(pars, 'H', str);
  // L
  str:='';
  for I := 0 to c - 1 do
  begin
    v:=l[i];
    vstr:=floattostr(v);
    vstr:=replaceChar(vstr,',', '.');
    str:=str+vstr;
    if i<c-1 then
      str:=str+';';
  end;
  addParam(pars, 'L', str);
  // LL
  str:='';
  for I := 0 to c - 1 do
  begin
    v:=LL[i];
    vstr:=floattostr(v);
    vstr:=replaceChar(vstr,',', '.');
    str:=str+vstr;
    if i<c-1 then
      str:=str+';';
  end;
  addParam(pars, 'LL', str);

  result:=ParsToStr(pars);
  delpars(pars);
end;


{ TEditProfileFrm }
procedure TEditProfileFrm.ApplyBtnClick(Sender: TObject);
var
  p:tprofile;
  I: Integer;
begin
  p:=TProfile.create;
  p.name:=ProfileNameEdit.text;
  p.units:=IntToUnits(UnitsCB.ItemIndex);
  p.m_Owner:=plist;
  plist.AddObject(p.name,p);
  showprofilelist(plist);
  for I := 0 to ProfileLB.Count - 1 do
  begin
    if profilelb.Items.Objects[i]=p then
    begin
      profilelb.Selected[i];
      break;
    end;
  end;
end;

procedure TEditProfileFrm.UpdateBtnClick(Sender: TObject);
var
  I: Integer;
  p:tprofile;
begin
  p:=nil;
  for I := 0 to profileLB.Count - 1 do
  begin
    if profilelb.Selected[i] then
    begin
      p:=tprofile(profilelb.items.Objects[i]);
      if ProfileNameEdit.text<>'' then
      begin
        p.name:=ProfileNameEdit.text;
        p.units:=IntToUnits(UnitsCB.ItemIndex);
      end;
      sgtop(p);
    end;
  end;
  if p=nil then
  begin
    if profileLB.Count>0 then
    begin
      p:=tprofile(profilelb.items.Objects[0]);
      sgtop(p);
    end;
  end;
end;

constructor TEditProfileFrm.create(aowner: tcomponent);
begin
  inherited;
  init;
end;

function TEditProfileFrm.editProfile(p: TProfile; profilelist:tprofilelist):TProfile;
var
  I: Integer;
begin
  plist:=profilelist;
  showprofilelist(profilelist);
  m_prof:=p;
  if p<>nil then
  begin
    ProfileNameEdit.Text:=m_prof.name;
    unitscb.ItemIndex:=tunitstoint(m_prof.units);
    ptosg(m_prof);
  end;
  if showmodal=mrok then
  begin
    result:=m_prof;
  end
  else
  begin

  end;
end;

procedure TEditProfileFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ModalResult:=mrok;
end;

procedure TEditProfileFrm.init;
begin
  ProfilePointsSG.RowCount:=2;
  ProfilePointsSG.ColCount:=7;
  ProfilePointsSG.Cells[c_Col_N, 0] :=  '№';
  ProfilePointsSG.Cells[c_Col_X, 0] :=  'X';
  ProfilePointsSG.Cells[c_Col_P, 0] :=  'Задание';
  ProfilePointsSG.Cells[c_Col_HH, 0] := 'HH';
  ProfilePointsSG.Cells[c_Col_H, 0] :=  'H';
  ProfilePointsSG.Cells[c_Col_L, 0] :=  'L';
  ProfilePointsSG.Cells[c_Col_LL, 0] := 'LL';
  SGChange(ProfilePointsSG);
end;




procedure TEditProfileFrm.ProfileLBMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  p:tprofile;
  first:boolean;
begin
  first:=false;
  m_prof:=nil;
  for I := 0 to Profilelb.Count - 1 do
  begin
    if profilelb.Selected[i] then
    begin
      p:=tprofile(profilelb.items.Objects[i]);
      SetMultiSelectComponentString(ProfileNameEdit, p.name);
      SetMultiSelectItemInd(ProfileNameEdit, TUnitsToInt(p.units));
      if not first then
      begin
        first:=true;
        pToSg(p);
        m_prof:=p;
      end;
    end;
    endMultiSelect(ProfileNameEdit);
    endMultiSelect(unitscb);
  end;
end;

procedure TEditProfileFrm.ProfilePointsSGEndEdititng(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
var
  sg: TStringGridExt;
  prop, val: string;
  I, ind: Integer;
begin
  sg := TStringGridExt(Sender);
  if (ARow = sg.rowcount - 1) then
  begin
    // добавить строку
    if not sg.rowempty(ARow) then
    begin
      sg.rowcount := sg.rowcount + 1;
      sg.eraseRow(sg.rowcount - 1);
    end;
    for I := c_Col_HH to c_Col_LL do
    begin
      if i<>acol then
      begin
        case i of
          c_Col_HH:sg.Cells[i,arow]:=floattostr(HiHiSE.Value);
          c_Col_H:sg.Cells[i,arow]:=floattostr(HiSE.Value);
          c_Col_l:sg.Cells[i,arow]:=floattostr(LoSE.Value);
          c_Col_LL:sg.Cells[i,arow]:=floattostr(LoLoSE.Value);
        end;
      end;
    end;
  end;
  if (ARow = sg.rowcount - 2) then
  begin
    // удалить строку
    if sg.rowempty(ARow) then
    begin
      if sg.rowempty(ARow + 1) then
      begin
        sg.rowcount := sg.rowcount - 1;
      end;
    end;
  end;
  SGChange(sg);
end;

procedure TEditProfileFrm.ProfilePointsSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  sg: TStringGridExt;
begin
  sg := TStringGridExt(Sender);
  if sg.row = 0 then
    exit;
  if Key = VK_DELETE then
  begin
    if sg.rowcount = 1 then
      sg.rowcount := 2;
  end;
end;

procedure TEditProfileFrm.showprofilelist(plist:tstringlist);
var
  I: Integer;
  p:TProfile;
begin
  profileLB.Clear;
  for I := 0 to plist.Count - 1 do
  begin
    p:=tprofile(plist.objects[i]);
    profileLB.AddItem(p.name,p);
  end;
end;


procedure TEditProfileFrm.SyncProfileList(plist: tprofilelist);
var
  I, j: Integer;
  p:TProfile;
  find:boolean;
begin
  i:=0;
  while i<plist.count do
  begin
    p:=plist.getprof(i);
    find:=false;
    for j := 0 to profilelb.Count - 1 do
    begin
      if p=profilelb.items.Objects[j] then
      begin
        find:=true;
        break;
      end;
    end;
    if find then
    begin
      p.Destroy;
      plist.Delete(i);
    end
    else
    begin
      inc(i);
    end;
  end;
end;

procedure TEditProfileFrm.pToSg(p: tprofile);
var
  i, row: integer;
begin
  ProfilePointsSG.RowCount := c_headerSize + length(p.HH)+1;
  for i := 0 to length(p.HH) - 1 do
  begin
    row := i + c_headerSize;
    ProfilePointsSG.Cells[c_Col_N, row] := inttostr(row);
    ProfilePointsSG.Cells[c_Col_X, row] := floattostr(p.x[i]);
    ProfilePointsSG.Cells[c_Col_P, row] := floattostr(p.P[i]);
    ProfilePointsSG.Cells[c_Col_HH,row] := floattostr(p.Hh[i]);
    ProfilePointsSG.Cells[c_Col_H, row] := floattostr(p.H[i]);
    ProfilePointsSG.Cells[c_Col_L, row] := floattostr(p.L[i]);
    ProfilePointsSG.Cells[c_Col_LL,row] := floattostr(p.LL[i]);
  end;
  SGChange(ProfilePointsSG);
end;

procedure TEditProfileFrm.saveToIni(dir: string);
var
  ifile:tinifile;
begin
  ifile:=tinifile.create(dir+'EditProfileFrm.ini');
  ifile.WriteInteger('Main','Units',unitscb.ItemIndex);
  ifile.WriteFloat('Main','HH',HiHiSE.Value);
  ifile.WriteFloat('Main','H', HiSE.Value);
  ifile.WriteFloat('Main','L', LoSE.Value);
  ifile.WriteFloat('Main','LL',LoLoSE.Value);
  ifile.destroy;
end;

procedure TEditProfileFrm.LoadIni(dir: string);
var
  ifile:tinifile;
begin
  ifile:=tinifile.create(dir+'EditProfileFrm.ini');
  unitscb.ItemIndex:=ifile.ReadInteger('Main','Units',0);
  HiHiSE.Value:=ifile.ReadFloat('Main','HH',20);
  HiSE.Value:=ifile.ReadFloat('Main','H', 10);
  LoSE.Value:=ifile.ReadFloat('Main','L', -10);
  LoLoSE.Value:=ifile.ReadFloat('Main','LL', -20);
  ifile.destroy;
end;

procedure TEditProfileFrm.SgToP(p: tprofile);
var
  i, row: integer;
begin
  p.SetCount(ProfilePointsSG.RowCount-c_headerSize-1);
  for i := 0 to length(p.HH) - 1 do
  begin
    row := i + c_headerSize;
    p.x[i]:=strtofloatext(ProfilePointsSG.Cells[c_Col_X, row]);
    p.P[i]:=strtofloatext(ProfilePointsSG.Cells[c_Col_P, row]);
    p.Hh[i]:=strtofloatext(ProfilePointsSG.Cells[c_Col_HH,row]);
    p.H[i]:=strtofloatext(ProfilePointsSG.Cells[c_Col_H, row]);
    p.L[i]:=strtofloatext(ProfilePointsSG.Cells[c_Col_L, row]);
    p.LL[i]:=strtofloatext(ProfilePointsSG.Cells[c_Col_LL,row]);
  end;
end;

{ TProfileList }
function TProfileList.getprof(s: string; var ind: integer): tprofile;
begin
  result:=nil;
  ind:=-1;
  if find(s, ind) then
  begin
    result:=getprof(ind);
  end;
end;

procedure TProfileList.cleardata;
var
  I: Integer;
  p:tprofile;
begin
  for I := 0 to Count - 1 do
  begin
    p:=getprof(i);
    p.Destroy;
  end;
  clear;
  inherited;
end;

constructor TProfileList.create;
begin
  inherited;
  sorted:=true;
end;

destructor TProfileList.destroy;
begin
  cleardata;
  inherited;
end;

function TProfileList.getprof(ind: integer): tprofile;
begin
  result:=TProfile(Objects[ind]);
end;

procedure addPointsToProfile(x: array of double; data: array of TProfileData;
  dataind: integer; tr: ctrend);
var
  i: integer;
  v: double;
begin
  tr.Clear;
  for i := 0 to length(x) - 1 do
  begin
    case dataind of
      0:
        v := data[i].p;
      1:
        v := data[i].hh;
      2:
        v := data[i].h;
      3:
        v := data[i].l;
      4:
        v := data[i].ll;
    end;
    tr.AddPoint(p2(x[i], v));
  end;
end;

end.
