unit uAddRZDDatafrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, uBtnListView, Spin, uComponentServises,
  uCommonMath, Pathutils, uPathMng, uLogFile, inifiles,
  ShellAPI;

type
  rzdpars = record
    // 0  - заезд, 1 -vc; 2- h; 3 - hout; 4 - hin
    sType:integer;
    reg:integer;
    seg:integer;
  end;

  cRzdPars = class
  public
    pars:rzdpars;
  end;

  TAddRZDDataFrm = class(TForm)
    ApplyGB: TGroupBox;
    ApplyBtnMR: TButton;
    LV1: TBtnListView;
    Panel2: TPanel;
    SigNameLabel: TLabel;
    SigName: TEdit;
    Panel1: TPanel;
    CalibrRG: TRadioGroup;
    TypeRG: TRadioGroup;
    CalibrPanel: TPanel;
    Label1: TLabel;
    SegSE: TSpinEdit;
    Splitter2: TSplitter;
    BasePath: TEdit;
    Label2: TLabel;
    AplyBtn1: TButton;
    RegSE: TSpinEdit;
    RegionLabel: TLabel;
    procedure TypeRGClick(Sender: TObject);
    procedure LV1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ApplyBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ApplyBtnMRClick(Sender: TObject);
  private
    m_list:tstringlist;
    parslist:tlist;
    //log:clogfile;
  private
    function GenTypeStr(p:crzdpars):string;
    function StrToRzdPars(str:string):rzdpars;
    function GenTypeRec:rzdpars;
    procedure ShowSelectedProps;
    function getPath(fname:string;p:rzdpars):string;
    procedure CopyFiles;
    procedure cleardata;
  public
    procedure showsignals(list:tstringlist);
  end;

  function Pars(str:string):rzdpars;

var
  AddRZDDataFrm: TAddRZDDataFrm;
const
  c_vc=1;
  c_h=2;
  c_hout=3;
  c_hin=4;


implementation
uses
  uRzdFrm;
{$R *.dfm}

function Pars(str:string):rzdpars;
var
  i,p:integer;
  res:string;
begin
  i:=0;
  res:=GetSubString(str,';',i+1,i);
  if res='Test' then
  begin
    result.sType:=0;
    res:=GetSubString(str,';',i+1,i);
    p:=pos('=',res);
    res:=copy(res,p+1,length(res)-p);
    result.reg:=strtoint(res);
  end
  else
  begin
    res:=GetSubString(str,';',i+1,i);
    if res='VC' then result.sType:=1;
    if res='H' then result.sType:=2;
    if res='Hout' then result.sType:=3;
    if res='Hin' then result.sType:=4;
    res:=GetSubString(str,';',i+1,i);
    p:=pos('=',res);
    res:=copy(res,p+1,length(res)-p);
    result.reg:=strtoint(res);
    res:=GetSubString(str,';',i+1,i);
    p:=pos('=',res);
    res:=copy(res,p+1,length(res)-p);
    result.seg:=strtoint(res);
  end;
end;

procedure TAddRZDDataFrm.ApplyBtnClick(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  str:string;
  p:cRzdPars;
  sp, itemsp:rzdpars;
begin
  if lv1.SelCount=0 then exit;

  sp:=GenTypeRec;
  for I := 0 to lv1.items.Count - 1 do
  begin
    if lv1.items[i].selected then
    begin
      lv1.GetSubItemByColumnName('Тип', lv1.items[i], str);
      itemsp:=Pars(str);
      if m_list.Objects[i]=nil then
      begin
        p:=cRzdPars.Create;
        if sp.sType<>-1 then
          p.pars.sType:=sp.sType
        else
          p.pars.stype:=itemsp.stype;
        if sp.reg<>-1 then
          p.pars.reg:=sp.reg;
        if sp.seg<>-1 then
          p.pars.seg:=sp.seg;
        m_list.Objects[i]:=p;
      end
      else
      begin
        p:=cRzdPars(m_list.Objects[i]);
        if sp.sType<>-1 then
          p.pars.sType:=sp.sType;
        if sp.reg<>-1 then
          p.pars.reg:=sp.reg;
        if sp.seg<>-1 then
          p.pars.seg:=sp.seg;
      end;
      str:=GenTypeStr(p);
      li:=lv1.Items[i];
      lv1.SetSubItemByColumnName('Тип',str, li);
    end;
  end;
end;

function TAddRZDDataFrm.StrToRzdPars(str:string):rzdpars;
begin
  result:=pars(str);
end;

function TAddRZDDataFrm.GenTypeStr(p:crzdpars):string;
var
  i:integer;
begin
  case p.pars.sType of
    0: // заезд
    begin
      Result:='Test'+';Reg='+inttostr(Regse.Value);
    end;
    else
    begin
      i:=p.pars.sType-1;
      Result:='Calibr';
      case i of
        0:Result:=Result+';VC';
        1:Result:=Result+';H';
        2:Result:=Result+';Hout';
        3:Result:=Result+';Hin';
      end;
      if Regse.text<>'' then
        Result:=Result+';Reg='+inttostr(Regse.Value)
      else
        Result:=Result+';Reg='+inttostr(p.pars.reg);
      if Segse.text<>'' then
        Result:=Result+';Seg='+inttostr(Segse.Value)
      else
        Result:=Result+';Seg='+inttostr(p.pars.seg);
    end;
  end;
end;

function TAddRZDDataFrm.GenTypeRec:rzdpars;
begin
  case typerg.ItemIndex of
    0:
    begin
      Result.sType:=0;
    end;
    1:
    begin
      Result.sType:=calibrRg.ItemIndex+1;
      if Result.sType=0 then
        Result.sType:=-1;
    end;
    else
    begin
      Result.sType:=-1;
    end;
  end;
  if Regse.Text='' then
    Result.reg:=-1
  else
    Result.reg:=Regse.Value;
  if Segse.Text='' then
    Result.seg:=-1
  else
    Result.seg:=Segse.Value;
end;

procedure TAddRZDDataFrm.showsignals(list:tstringlist);
var
  I: Integer;
  li:tlistitem;
  str
  //,dir
  :string;

  p:crzdpars;
  r:rzdpars;
begin
  if parslist=nil then
    parslist:=tlist.Create;
  m_list:=list;
  //if log=nil then
  //begin
  //  dir:='c:\Mera\';
  //  ForceDirectories(dir);
  //  log:= cLogFile.create(dir+'Log.txt',';');
  //end;

  lv1.clear;
  for I := 0 to List.Count - 1 do
  begin
    str:=list.strings[i];
    li:=lv1.items.Add;
    LV1.SetSubItemByColumnName('Файл',str,li);
    r.sType:=0;
    if CheckPosSubstr(RZDFrm.m_VCPref,str) then
    begin
      r.sType:=1;
    end;
    if CheckPosSubstr(RZDFrm.m_H_Pref,str) then
    begin
      r.sType:=2;
    end;
    if CheckPosSubstr(RZDFrm.m_Hin_Pref,str) then
    begin
      r.sType:=4;
    end;
    if CheckPosSubstr(RZDFrm.m_Hout_Pref,str) then
    begin
      r.sType:=3;
    end;
    r.reg:=0;
    r.seg:=0;
    p:=cRzdPars.Create;
    p.pars:=r;
    str:=GenTypeStr(p);
    m_list.Objects[i]:=p;
    LV1.SetSubItemByColumnName('Тип',str,li);
  end;
  LVChange(LV1);
  if showmodal=mrok then
  begin
    CopyFiles;
  end;
  cleardata;
end;

procedure TAddRZDDataFrm.TypeRGClick(Sender: TObject);
begin
  case typerg.ItemIndex of
    0:
    begin
      CalibrRG.Visible:=false;
      CalibrPanel.Visible:=false;
    end;
    1:
    begin
      CalibrRG.Visible:=true;
      CalibrPanel.Visible:=true;
    end;
  end;
end;

procedure TAddRZDDataFrm.LV1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  ShowSelectedProps;
end;

procedure TAddRZDDataFrm.ShowSelectedProps;
var
  I: Integer;
  li:tlistitem;
  capt,str:string;
  p:rzdpars;
  stype:integer;
  test:boolean;
begin
  for I := 0 to lv1.items.Count - 1 do
  begin
    li:=lv1.Items[i];
    if li.Selected then
    begin
      LV1.GetSubItemByColumnName('Файл', li, str);
      SetMultiSelectComponentString(signame,str);
      str:='';
      capt:=str;
      LV1.GetSubItemByColumnName('Тип', li, str);
      if str<>'' then
      begin
        p:=Pars(str);
        SetMultiSelectComponentString(regse,inttostr(p.reg));
        SetMultiSelectComponentString(Segse,inttostr(p.seg));
        test:=p.stype=0;
        if test then
          SetMultiSelectItemInd(TypeRG, 0)
        else
        begin
          SetMultiSelectItemInd(TypeRG, 1);
          SetMultiSelectItemInd(CalibrRG, p.sType-1);
        end;
      end
      else
      begin
        if CheckPosSubstr(RZDFrm.m_VCPref,capt) then
        begin
          TypeRG.ItemIndex:=1;

        end;
        if CheckPosSubstr(RZDFrm.m_H_Pref,capt) then
        begin
          TypeRG.ItemIndex:=1;
        end;
        if CheckPosSubstr(RZDFrm.m_Hin_Pref,capt) then
        begin
          TypeRG.ItemIndex:=1;
        end;
        if CheckPosSubstr(RZDFrm.m_Hin_Pref,capt) then
        begin
          TypeRG.ItemIndex:=1;
        end;
      end;
    end;
  end;
  endMultiSelect(TypeRG);
  endMultiSelect(CalibrRG);
  endMultiSelect(signame);
  endMultiSelect(regse);
  endMultiSelect(segse);
end;

procedure TAddRZDDataFrm.CopyFiles;
var
  I: Integer;
  str, str1, fname:string;
  p:cRzdPars;
  pars:rzdpars;
  ifile:tinifile;
  list:tstringlist;

  //fos: TSHFileOpStruct;
  //dir:string;
begin
  list:=TStringList.Create;
  for I := 0 to m_list.Count - 1 do
  begin
    p:=cRzdPars(m_list.Objects[i]);
    str:=m_list.Strings[i];
    if p=nil then
    begin
      pars.sType:=0;
    end
    else
      pars:=p.pars;
    fname:=FindFileExt('*.mera',str,1, list);
    str1:=getPath(str,pars);
    if fileexists(fname) then
    begin
      ifile:=TIniFile.Create(fname);
      ifile.WriteInteger('MERA','RZDRegion',pars.reg);
      ifile.Destroy;
    end;
    CopyDir(str, str1, 0);
  end;
  list.Destroy;
  lvchange(lv1);
end;

procedure TAddRZDDataFrm.FormShow(Sender: TObject);
begin
  LVChange(lv1);
end;

function TAddRZDDataFrm.getPath(fname:string;p:rzdpars):string;
var
  str, int1,int2, strname:string;
begin
  // заезд
  if p.sType=0 then
  begin
    if pos(fname, '_reg')>0 then
    begin
      str:=RZDFrm.GetTestsFolder+ExtractFileName(fname)
    end
    else
    begin
      if RegSE.Value<10 then
      begin
        str:=RZDFrm.GetTestsFolder+ExtractFileName(fname)+'_reg0'+inttostr(RegSE.Value);
      end;
      if RegSE.Value<10 then
      begin
        str:=RZDFrm.GetTestsFolder+ExtractFileName(fname)+'_reg'+inttostr(RegSE.Value);
      end;
    end;
  end
  else
  begin
    str:=RZDFrm.getcalibrfolder;
    int1:=inttostr(p.reg);
    if length(int1)=1 then
    begin
      int1:='_0'+int1
    end
    else
      int1:='_'+int1;
    int2:=inttostr(p.seg);
    if length(int2)=1 then
    begin
      int2:='_0'+int2
    end
    else
      int2:='_'+int2;
    str:=str+'\'+RZDFrm.m_regionPref+int1+'\'+RZDFrm.m_sectionPref+int2+'\';
    strname:=ExtractFileName(fname);
    case p.sType of
      1:
      begin
        if pos(RZDFrm.m_VCPref,strname)<1 then
          strname:=RZDFrm.m_VCPref+strname;
      end;
      2:
      begin
        if pos(RZDFrm.m_H_Pref,strname)<1 then
          strname:=RZDFrm.m_H_Pref+strname;
      end;
      3:
      begin
        if pos(RZDFrm.m_Hout_Pref,strname)<1 then
          strname:=RZDFrm.m_Hout_Pref+strname;
      end;
      4:
      begin
        if pos(RZDFrm.m_Hin_Pref,strname)<1 then
          strname:=RZDFrm.m_Hin_Pref+strname;
      end;
    end;
    str:=str+strname;
  end;
  result:=str;
end;

function findinlist(l:tlist; p:crzdpars):crzdpars;
var
  I: Integer;
  lp:crzdpars;
begin
  result:=nil;
  for I := 0 to l.Count - 1 do
  begin
    lp:=crzdpars(l.Items[i]);
    if lp.pars.sType=p.pars.sType then
    begin
      if lp.pars.reg=p.pars.reg then
      begin
        if lp.pars.seg=p.pars.seg then
        begin
          result:=lp;
          exit;
        end;
      end;
    end;
  end;
end;


procedure TAddRZDDataFrm.ApplyBtnMRClick(Sender: TObject);
var
  I: Integer;
  li:tlistitem;
  p, lp:cRzdPars;
  str:string;
  list:tlist;
begin
  if lv1.items.Count=0 then
  begin
    ModalResult:=mrok;
    exit;
  end;
  parslist.Clear;
  for I := 0 to lv1.items.Count - 1 do
  begin
    li:=lv1.items[i];
    str:=extractfilename(li.Caption);
    p:=cRzdPars(m_list.Objects[i]);
    if p=nil then
    begin
      showmessage('Не назначен регион/ сечение сигналу: '+str);
      exit;
    end;
    if (p.pars.reg=0) or (p.pars.seg=0) then
    begin
      if p.pars.sType<>0 then
      begin
        showmessage('Не назначен регион/ сечение сигналу: '+str);
        exit;
      end;
    end;
    case p.pars.sType of
      c_vc:
      begin
        lp:=findinlist(parslist,p);
        if lp<>nil then
        begin
          str:='Сеч.='+inttostr(p.pars.seg)+' Рег.='+inttostr(p.pars.reg)+' верт. центр.';
          showmessage('Нельзя назначить одному региону и сечению два замера одного типа '+str);
          exit;
        end;
        parslist.Add(p);
      end;
      c_h:
      begin
        lp:=findinlist(parslist,p);
        if lp<>nil then
        begin
          str:='Сеч.='+inttostr(p.pars.seg)+' Рег.='+inttostr(p.pars.reg)+' гориз.';
          showmessage('Нельзя назначить одному региону и сечению два замера одного типа '+str);
          exit;
        end;
        parslist.Add(p);
      end;
      c_hin:
      begin
        lp:=findinlist(parslist,p);
        if lp<>nil then
        begin
          str:='Сеч.='+inttostr(p.pars.seg)+' Рег.='+inttostr(p.pars.reg)+' смещ. внутрь';
          showmessage('Нельзя назначить одному региону и сечению два замера одного типа '+str);
          exit;
        end;
        parslist.Add(p);
      end;
      c_hout:
      begin
        lp:=findinlist(parslist,p);
        if lp<>nil then
        begin
          str:='Сеч.='+inttostr(p.pars.seg)+' Рег.='+inttostr(p.pars.reg)+' смещ. наружу';
          showmessage('Нельзя назначить одному региону и сечению два замера одного типа '+str);
          exit;
        end;
        parslist.Add(p);
      end;
    end;
  end;

  ModalResult:=mrok;
end;

procedure TAddRZDDataFrm.cleardata;
var
  I: Integer;
  o:cRzdPars;
begin
  for I := 0 to m_List.Count - 1 do
  begin
    o:=cRzdPars(m_list.Objects[i]);
    if o<>nil then
      o.Destroy;
  end;
  m_list.Clear;
end;

end.
