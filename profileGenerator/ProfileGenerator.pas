unit ProfileGenerator;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uChart, DCL_MYOWN, Spin, uTrend, uBuffTrend1d, uPage, uAxis,
  uPoint, uCommonTypes, uCommonMath, math, MathFunction, ImgList, ComCtrls,
  uBtnListView, uSpin, uEditform, uFloatEdit, uLabel, uFloatLabel, uChartInputFrame,
  uPolarGraphPage, uBuffTrend2d,
  uGrid, uComponentServises, Menus, uEditTubeFrm, uMerafile, uSignalsUtils, uMeraSignal;

type
  TEditProfileForm = class(TForm)
    GroupBox1: TGroupBox;
    cChart1: cChart;
    GroupBox2: TGroupBox;
    ImportBtn: TButton;
    ExportBtn: TButton;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    YFE: TFloatEdit;
    XFE: TFloatEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    UnitsCB: TComboBox;
    Label7: TLabel;
    EvalBtn: TButton;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    HiHiSE: TFloatSpinEdit;
    HiSE: TFloatSpinEdit;
    LoSE: TFloatSpinEdit;
    LoLoSE: TFloatSpinEdit;
    MouseGB: TGroupBox;
    GroupBox4: TGroupBox;
    ToleranceLV: TBtnListView;
    GroupBox5: TGroupBox;
    DelPointBtn: TButton;
    Splitter1: TSplitter;
    AddPointBtn: TButton;
    Button1: TButton;
    MainMenu1: TMainMenu;
    FileMng: TMenuItem;
    ApplySelectBtn: TButton;
    procedure cChart1Init(Sender: TObject);
    procedure ImportBtnClick(Sender: TObject);
    procedure cChart1SelectPoint(Sender: TObject);
    procedure EvalBtnClick(Sender: TObject);
    procedure ExportBtnClick(Sender: TObject);
    procedure ToleranceLVDblClickProcess(item: TListItem; lv: TListView);
    procedure XFEKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cChart1AddPoint(data, subdata: TObject);
    procedure cChart1MovePoint(data, subdata: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure AddPointBtnClick(Sender: TObject);
    procedure DelPointBtnClick(Sender: TObject);
    procedure SaveCurrent(Sender: TObject);
    procedure FileMngClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplySelectBtnClick(Sender: TObject);
  private
    profile: ctrend;
    hihi,lolo,lo,hi:ctrend;
    userAddPoint:boolean;
    importFile:string;
  private
    procedure TestPolarGraph;
    procedure SaveMeraFile(f:string);
    procedure OpenParamStr;
  public
    procedure eval;
    // отобразить профиль в таблице
    procedure showProfile;
    function GetScale(point, percent:single; units:integer):single;
    procedure movePoint(x,y:single);
  end;

var
  EditProfileForm: TEditProfileForm;

implementation

{$R *.dfm}
procedure TEditProfileForm.DelPointBtnClick(Sender: TObject);
var
  li:tlistitem;
  I: Integer;
begin
  li:=ToleranceLV.Selected;
  if li=nil then exit;
  li.Destroy;
  for I := 0 to ToleranceLV.items.Count - 1 do
  begin
    li:=ToleranceLV.Items[i];
    ToleranceLV.SetSubItemByColumnName('№',inttostr(i),li);
  end;
  if ToleranceLV.Items.Count>1 then
    eval;
end;

procedure TEditProfileForm.AddPointBtnClick(Sender: TObject);
begin
  EditForm.initvals(LoLoSE.Value,LoSE.Value,hiSE.Value,hihiSE.Value);
  EditForm.NewItem(ToleranceLV);
  LVChange(ToleranceLV);
  eval;
end;

procedure TEditProfileForm.ApplySelectBtnClick(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
begin
  if ToleranceLV.Selected<>nil then
  begin
    li:=ToleranceLV.Selected;
    i:=li.Index;
    for I := i+1 to i+ToleranceLV.SelCount do
    begin
      ToleranceLV.SetSubItemByColumnName('LoLo',floattostr(lolose.Value),li);
      ToleranceLV.SetSubItemByColumnName('Lo',floattostr(lose.Value),li);
      ToleranceLV.SetSubItemByColumnName('Hi',floattostr(hise.Value),li);
      ToleranceLV.SetSubItemByColumnName('HiHi',floattostr(hihise.Value),li);
      li:=ToleranceLV.items[i];
    end;
  end;
end;

procedure TEditProfileForm.cChart1AddPoint(data, subdata: TObject);
begin
  if userAddPoint then
  // отобразить профиль в таблице
    showProfile;
end;

procedure TEditProfileForm.TestPolarGraph;
var
  polar:cPolarGraphPage;
  bound:trect;
  graph:cPolarGraph1d;
  I: Integer;
  x,y:array [0..999] of double;
begin

  polar:=cPolarGraphPage.create;
  cChart1.activeTab.AddChild(polar);
  bound:=cChart1.activepage.bound;
  bound.top:=bound.bottom;
  bound.bottom:=bound.top-80;
  cChart1.activepage.bound:=bound;
  polar.bound:=bound;
  cChart1.activeTab.Alignpages(2);
  graph:=cPolarGraph1d.create;
  graph.Count:=1000;
  for I := 0 to 999 do
  begin
    x[i]:=Sin(i*2*pi/1000);
    y[i]:=Cos(i*2*pi/1000);
  end;
  graph.addData(x,y,0);
  polar.AddChild(graph);
end;

procedure TEditProfileForm.cChart1Init(Sender: TObject);
var
  page:cpage;

  Grid:cGrid;

  col:ccolumn;
  raw:craw;

  ax:caxis;
  bound:trect;

  edit:cFloatEdit;
  lab:cLabel;

  frame:TChartInputFrame;
begin
  unitscb.ItemIndex:=0;

  page:=cpage(cchart1.activePage);
  //userAddPoint:=true;
  //page.caption:='Многострочный'+char(10)+'текст';
  //page.PageLabel.Transparent:=false;
  //page.PageLabel.flocked:=false;

  ax:=page.activeAxis;
  ax.Lg:=true;

  profile:=ctrend.create;
  profile.m_LineStripple:=true;
  profile.enabled:=true;
  profile.name:='Profile';
  profile.color:=p3(0,1,0);
  ax.AddChild(profile);

  LoLo:=ctrend.create;
  LoLo.selectable:=false;
  LoLo.name:='LoLo';
  LoLo.color:=p3(1,0,0);
  ax.AddChild(LoLo);

  Lo:=ctrend.create;
  Lo.selectable:=false;
  Lo.name:='Lo';
  Lo.color:=p3(1,1,0);
  ax.AddChild(Lo);

  Hi:=ctrend.create;
  Hi.selectable:=false;
  Hi.name:='Hi';
  Hi.color:=p3(1,1,0);
  ax.AddChild(Hi);

  HiHi:=ctrend.create;
  HiHi.selectable:=false;
  HiHi.name:='HiHi';
  HiHi.color:=p3(1,0,0);
  ax.AddChild(HiHi);

  // Создаем фрейм для отображения координат графика
  mousegb.Visible:=true;
  frame:=TChartInputFrame.create(self);
  frame.Visible:=true;
  frame.parent:=MouseGB;
  frame.lincchart(cChart1);

  //ax:=page.Newaxis;
  //ax.name:='Vax';
  //ax.m_YUnits:='V';
  //ax.minY:=0;
  //ax.maxY:=100;
  //page.addaxis(ax);


  page:=cpage(cchart1.activeTab.addPage(true));
  // отладка поларного графика
  //testPolarGraph;

  // блок отладки таблицы
  {bound:=cChart1.activepage.bound;
  bound.Bottom:=bound.Bottom+80;
  cChart1.activepage.bound:=bound;

  bound.top:=bound.bottom;
  bound.bottom:=bound.top-80;

  Grid:=cGrid.create;
  col:=grid.AddColumn('11112222');
  col:=grid.AddColumn('222');
  col.width:=80;
  col:=grid.AddColumn('333');
  raw:=grid.AddRaw;
  raw.SubItem[0]:='11111111';
  raw.SubItem[1]:='2222';
  raw.SubItem[2]:='3333';
  raw.colors[0]:=red;
  raw:=grid.AddRaw;
  raw.SubItem[0]:='1111';
  raw:=grid.AddRaw;
  raw.SubItem[0]:='1111';
  raw:=grid.AddRaw;
  raw.SubItem[0]:='1111';
  raw:=grid.AddRaw;
  raw.SubItem[0]:='1111';
  raw:=grid.AddRaw;
  raw.SubItem[0]:='1111';
  raw:=grid.AddRaw;

  cChart1.activeTab.AddChild(grid);
  grid.bound:=bound;}

  {
  edit:=cFloatEdit.create;
  edit.Value:=111111111111111111;
  cChart1.activeTab.AddChild(edit);
  edit.bound:=bound;

  lab:=cFloatlabel.create;
  ax.AddChild(lab);
  lab:=cFloatlabel.create;
  lab.Transparent:=true;
  lab.align:=c_right;
  page.AddChild(lab);
  }
  OpenParamStr;
  LVChange(ToleranceLV);
end;

procedure TEditProfileForm.cChart1MovePoint(data, subdata: TObject);
var
  index:integer;
  p1, p2:cbeziepoint;
begin
  ctrend(data).FindPoint(cbeziepoint(subdata).point.x,index);
  if index=0 then
  begin
    p1:=cbeziepoint(subdata);
    p2:=ctrend(data).getPoint(ctrend(data).count-1);
    p2.y:=p1.y;
  end;
  //              floattostr(cbeziepoint(subdata).point.x),li);
  //              floattostr(cbeziepoint(subdata).point.y),li);
end;

procedure TEditProfileForm.cChart1SelectPoint(Sender: TObject);
var
  p:cbeziepoint;
begin
  p:=cbeziepoint(sender);
  xfe.FloatNum:=p.point.x;
  yfe.FloatNum:=p.point.y;
end;

procedure TEditProfileForm.ImportBtnClick(Sender: TObject);
var
  strlist:tstringlist;
  str,sval:string;
  f1,f2 :single;
  I, ind, p: Integer;
begin
  if OpenDialog1.Execute then
  begin

    str:=lowercase(OpenDialog1.FileName);
    profile.Clear;
    strlist:=TStringList.Create;
    strlist.LoadFromFile(OpenDialog1.FileName);
    // последний открытый файл
    importfile:=OpenDialog1.FileName;

    if ExtractFileExt(str)='tuf' then
    begin
      str:=strlist.Strings[i];
      sval:=GetSubString(str,';',1,ind);
      // частота
      f1:=strtofloatext(sval);
      sval:=GetSubString(str,';',ind+1,ind);
      // уровень
      f2:=strtofloatext(sval);
      profile.AddPoint(p2(f1,f2));
    end
    else
    begin
      for I := 0 to strList.Count - 1 do
      begin
        str:=strlist.Strings[i];
        sval:=GetSubString(str,';',1,ind);
        f1:=strtofloatext(sval);
        sval:=GetSubString(str,';',ind+1,ind);
        f2:=strtofloatext(sval);
        profile.AddPoint(p2(f1,f2));
      end;
    end;
    cpage(cchart1.activePage).Normalise;
    cchart1.redraw;
  end;
  showProfile;
end;

procedure TEditProfileForm.movePoint(x,y:single);
var
  obj:tobject;
  tr:ctrend;
  p:point2;
  sp:selectpoint;
begin
  obj:=cChart1.selected;
  if obj is ctrend then
  begin
    tr:=ctrend(obj);
    sp:=tr.GetSelectPoint(0);
    if sp<>nil then
    begin
      p:=p2(x,y);
      if sp<>nil then
      begin
       tr.SetPoint(p,sp);
       cchart1.redraw;
      end;
    end;
  end;
end;

function Power(const Base, Exponent: Extended): Extended;
begin
  if Exponent = 0.0 then
    Result := 1.0 { n**0 = 1 }
  else if (Base = 0.0) and (Exponent > 0.0) then
    Result := 0.0 { 0**n = 0, n > 0 }
  else if (Frac(Exponent) = 0.0) and (Abs(Exponent) <= MaxInt) then
    Result := IntPower(Base, Integer(Trunc(Exponent)))
  else
    Result := Exp(Exponent * Ln(Base))
end;

function TEditProfileForm.GetScale(point, percent:single; units:integer):single;
var
  v:single;
begin
  case units of
    0:
    begin
      result:=point*((100+percent)/100);
    end;
    1: //20log
    //20lg(a/point)=percent;
    //lg(a/point):=percent/20;
    //a/point = (10^percent/20)
    //a=point*(10^percent/20)
    begin
      result:=point*(Power(10,percent/20));
    end;
    2:  //10log
    begin
      result:=point*(Power(10,percent/10));
    end;
  end;
end;


procedure TEditProfileForm.eval;
var
  I: Integer;
  k, val:single;
  p:point2;
  str:string;
  li:tlistitem;
begin
  userAddPoint:=false;
  profile.Clear;
  hihi.Clear;
  hi.Clear;
  lo.Clear;
  lolo.Clear;

  for I := 0 to ToleranceLV.items.count - 1 do
  begin
    li:=tolerancelv.items[i];

    tolerancelv.GetSubItemByColumnName('Частота',li, str);
    p.x:=strtofloatext(str);

    tolerancelv.GetSubItemByColumnName('Значение',li, str);
    p.y:=strtofloatext(str);
    profile.AddPoint(p);

    tolerancelv.GetSubItemByColumnName('HiHi',li, str);
    val:=strtofloat(str);
    hihi.AddPoint(p2(p.x,GetScale(p.y, val, UnitsCB.ItemIndex)));

    tolerancelv.GetSubItemByColumnName('Hi',li, str);
    val:=strtofloat(str);
    hi.AddPoint(p2(p.x,GetScale(p.y, val, UnitsCB.ItemIndex)));

    tolerancelv.GetSubItemByColumnName('Lo',li, str);
    val:=strtofloat(str)*(-1);
    lo.AddPoint(p2(p.x,GetScale(p.y, Val, UnitsCB.ItemIndex)));

    tolerancelv.GetSubItemByColumnName('LoLo',li, str);
    val:=strtofloat(str)*(-1);
    lolo.AddPoint(p2(p.x,GetScale(p.y, Val, UnitsCB.ItemIndex)));
  end;
  cchart1.redraw;
  userAddPoint:=true;
end;

procedure TEditProfileForm.EvalBtnClick(Sender: TObject);
begin
  eval;
end;

procedure TEditProfileForm.SaveCurrent(Sender: TObject);
var
  strlist:tstringlist;
  str, fname:string;
  p:point2;
  i,j:integer;
begin
  if (hihi.count<>profile.count) or
  (lolo.count<>profile.count) or
  (hi.count<>profile.count) or
  (lo.count<>profile.count) then
    exit;
  if profile.count=0 then
    exit;
  if importfile='' then
  begin
    savedialog1.Title:='Сохранение профиля';
    savedialog1.execute;
    importfile:=savedialog1.FileName;
    if extractfileext(importfile)='' then
      importfile:=importfile+'.csv';
  end;
  // сохраняем профиль
  strlist:=tstringlist.Create;
  for I := 0 to profile.count - 1 do
  begin
    p:=profile.getPoint(i).point;
    str:=floattostr(p.x)+';';
    str:=str+floattostr(p.y);
    for j := 1 to length(str) - 1 do
    begin
      if str[j]=',' then
      begin
        str[j]:='.';
      end;
    end;
    strlist.Add(str);
  end;
  strlist.SaveToFile(importfile);
  strlist.destroy;

  fname:=extractfilename(importfile);
  fname:=importfile+'_levels.csv';
  strlist:=tstringlist.Create;
  for I := 0 to profile.count - 1 do
  begin
    p:=profile.getPoint(i).point;
    str:=floattostr(p.x)+';';

    p:=lo.getPoint(i).point;
    str:=str+floattostr(p.y)+';';

    p:=hi.getPoint(i).point;
    str:=str+floattostr(p.y)+';';

    p:=lolo.getPoint(i).point;
    str:=str+floattostr(p.y)+';';

    p:=hihi.getPoint(i).point;
    str:=str+floattostr(p.y);
    for j := 1 to length(str) - 1 do
    begin
      if str[j]=',' then
      begin
        str[j]:='.';
      end;
    end;
    strlist.Add(str);
  end;
  strlist.SaveToFile(fname);
  strlist.destroy;
end;

procedure TEditProfileForm.SaveMeraFile(f:string);
var
  i:integer;
  name:string;
  merafile:cmerafile;
  s:csignal;
begin
  if lowercase(extractfileext(f))<>'.mera' then
    f:=f+'.mera';
  merafile:=cmerafile.create(f);
  merafile.add(CreateSignal(profile));
  merafile.add(CreateSignal(lolo));
  merafile.add(CreateSignal(lo));
  merafile.add(CreateSignal(hihi));
  merafile.add(CreateSignal(hi));

  name:=extractfilename(f);
  name:=TrimExt(name);

  for I := 0 to merafile.signals.Count - 1 do
  begin
    s:=merafile.GetSignal(i);
    s.name:=name+'_'+s.name;
  end;
  merafile.Save;
end;
procedure TEditProfileForm.ExportBtnClick(Sender: TObject);
var
  strlist:tstringlist;
  str:string;
  p:point2;
  i,j:integer;
begin
  if (hihi.count<>profile.count) or
  (lolo.count<>profile.count) or
  (hi.count<>profile.count) or
  (lo.count<>profile.count) then
    exit;
  if profile.count=0 then
    exit;
  savedialog1.Title:='Сохранение уставок';
  if savedialog1.execute then
  begin
    savedialog1.FileName:=lowercase(savedialog1.FileName);
    strlist:=tstringlist.Create;
    // 3 - mera файл
    if savedialog1.FilterIndex=3 then
    begin
      SaveMeraFile(savedialog1.FileName);
    end;
    // 1 - tuf файлы
    if savedialog1.FilterIndex=2 then
    begin
      if lowercase(extractfileext(savedialog1.FileName))<>'.tuf' then
        savedialog1.FileName:=savedialog1.FileName+'.tuf';
      strlist.Add(';Последовательность: freq, Level, Lo, Hi, LoLo, HiHi');
      for I := 0 to profile.count - 1 do
      begin
        //  freq, Level, Lo, Hi, LoLo, HiHi
        p:=profile.getPoint(i).point;
        str:=floattostr(p.x)+';'+floattostr(p.y)+';';
        str:=str+floattostr(lo.getPoint(i).point.y)+';'+floattostr(hi.getPoint(i).point.y)+';';
        str:=str+floattostr(lolo.getPoint(i).point.y)+';'+floattostr(hihi.getPoint(i).point.y)+';';
        // винпос не читает запятую, только точку
        for j := 1 to length(str) - 1 do
        begin
          if str[j]=',' then
          begin
            str[j]:='.';
          end;
        end;
        strlist.Add(str);
        strlist.SaveToFile(savedialog1.FileName);
      end;
      strlist.destroy;
    end;
    if savedialog1.filterindex=1 then
    begin
      if lowercase(extractfileext(savedialog1.FileName))<>'.csv' then
      begin
        savedialog1.FileName:=savedialog1.FileName+'.csv';
      end;
      for I := 0 to profile.count - 1 do
      begin
        p:=profile.getPoint(i).point;
        str:=floattostr(p.x)+';';

        p:=lo.getPoint(i).point;
        str:=str+floattostr(p.y)+';';

        p:=hi.getPoint(i).point;
        str:=str+floattostr(p.y)+';';

        p:=lolo.getPoint(i).point;
        str:=str+floattostr(p.y)+';';

        p:=hihi.getPoint(i).point;
        str:=str+floattostr(p.y);
        for j := 1 to length(str) - 1 do
        begin
          if str[j]=',' then
          begin
            str[j]:='.';
          end;
        end;
        strlist.Add(str);
      end;
      strlist.SaveToFile(savedialog1.FileName);
      strlist.destroy;
      savedialog1.Title:='Сохранение профиля';
      if savedialog1.execute then
      begin
        if lowercase(extractfileext(savedialog1.FileName))<>'.csv' then
        begin
          savedialog1.FileName:=savedialog1.FileName+'.csv';
        end;
        strlist:=tstringlist.Create;
        for I := 0 to profile.count - 1 do
        begin
          p:=profile.getPoint(i).point;
          str:=floattostr(p.x)+';';
          str:=str+floattostr(p.y);
          for j := 1 to length(str) - 1 do
          begin
            if str[j]=',' then
            begin
              str[j]:='.';
            end;
          end;
          strlist.Add(str);
        end;
      end;
      strlist.SaveToFile(savedialog1.FileName);
      strlist.destroy;
    end;
  end;
end;

procedure TEditProfileForm.FileMngClick(Sender: TObject);
begin
  EditTubeFrm.ShowModal
end;

procedure TEditProfileForm.FormShow(Sender: TObject);
begin
  WindowState:=wsMaximized;
  RequestAlign;
  cChart1Init(cChart1);
end;

procedure TEditProfileForm.showProfile;
var
  I: Integer;
  p:point2;
  li:tlistitem;
begin
  ToleranceLV.Clear;
  for I := 0 to profile.Count - 1 do
  begin
    p:=profile.getPoint(i).point;
    li:=ToleranceLV.Items.Add;
    ToleranceLV.SetSubItemByColumnName('№',inttostr(li.Index),li);
    ToleranceLV.SetSubItemByColumnName('Значение',floattostr(p.y),li);
    ToleranceLV.SetSubItemByColumnName('Частота',floattostr(p.x),li);
    ToleranceLV.SetSubItemByColumnName('LoLo',floattostr(lolose.Value),li);
    ToleranceLV.SetSubItemByColumnName('Lo',floattostr(lose.Value),li);
    ToleranceLV.SetSubItemByColumnName('Hi',floattostr(hise.Value),li);
    ToleranceLV.SetSubItemByColumnName('HiHi',floattostr(hihise.Value),li);
  end;
end;

procedure TEditProfileForm.Splitter1Moved(Sender: TObject);
begin
  LVChange(ToleranceLV);
end;



procedure TEditProfileForm.ToleranceLVDblClickProcess(item: TListItem;
  lv: TListView);
begin
  EditForm.EditItem(item,tbtnlistview(lv));
  eval;
end;

procedure TEditProfileForm.XFEKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=13 then
  begin
    movePoint(xfe.FloatNum, yfe.FloatNum);
  end;
end;

procedure TEditProfileForm.OpenParamStr;
var
  strlist:tstringlist;
  str,sval:string;
  f1,f2:single;
  I, ind, p: Integer;
begin
  if paramstr(1)='' then exit;
  if not FileExists(paramstr(1)) then exit;
  // последний открытый файл
  importfile:=paramstr(1);

  profile.Clear;
  strlist:=TStringList.Create;
  strlist.LoadFromFile(paramstr(1));
  for I := 0 to strList.Count - 1 do
  begin
    str:=strlist.Strings[i];
    sval:=GetSubString(str,';',1,ind);
    if decimalseparator<>'.' then
    begin
      p:=pos('.',sval);
      if p>0 then
      begin
        sval[p]:=decimalseparator;
      end
    end
    else
    begin
      p:=pos(',',sval);
      if p>0 then
      begin
        sval[p]:=decimalseparator;
      end
    end;
    f1:=strtofloat(sval);
    sval:=GetSubString(str,';',ind+1,ind);
    if decimalseparator<>'.' then
    begin
      p:=pos('.',sval);
      if p>0 then
      begin
        sval[p]:=decimalseparator;
      end
    end
    else
    begin
      p:=pos(',',sval);
      if p>0 then
      begin
        sval[p]:=decimalseparator;
      end
    end;
    f2:=strtofloat(sval);
    profile.AddPoint(p2(f1,f2));
  end;
  cpage(cchart1.activePage).Normalise;
  cchart1.redraw;
  showProfile;

  if paramstr(2)<>'' then
  begin
    lolose.Value:=strtoFloatExt(paramstr(2));
    lose.Value:=strtoFloatExt(paramstr(3));
    hise.Value:=strtoFloatExt(paramstr(4));
    hihise.Value:=strtoFloatExt(paramstr(5));
    unitscb.itemindex:=strtoint(paramstr(6));
    eval;
  end;
end;

end.
