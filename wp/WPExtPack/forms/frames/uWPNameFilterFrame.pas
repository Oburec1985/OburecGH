unit uWPNameFilterFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, uWPProc,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, uBtnListView, inifiles, posbase, Winpos_ole_TLB,
  Buttons;

type
  TSignalArray = array of iwpsignal;

  TWPNameFltFrame = class(TFrame)
    NamesLB: TListBox;
    Panel1: TPanel;
    PropList: TBtnListView;
    Panel2: TPanel;
    NameFlt: TEdit;
    NameFltCB: TCheckBox;
    DscFltCB: TCheckBox;
    DscFlt: TEdit;
    PropFltCB: TCheckBox;
    DelBtn: TSpeedButton;
    AddBtn: TSpeedButton;
    procedure NameFltChange(Sender: TObject);
    procedure DscFltChange(Sender: TObject);
    procedure NameFltCBClick(Sender: TObject);
    procedure DscFltCBClick(Sender: TObject);
  private
    siglist, selected:TSignalArray;
    section:string;
  protected
    procedure clearSList;
    procedure Updateselected;
    procedure ShowSlist(l:TSignalArray);
  public
    procedure SaveCfg(section,cfgpath:string);
    procedure ReadCfg(section,cfgpath:string);
    // ��������� �� ���� Tstringlist ���������� ������ �� ������ iwpsignals
    procedure setNames(l:TSignalArray);
    function getNames:TSignalArray;
    constructor create(AOwner: TComponent);override;
    destructor destroy;override;
  end;

  const
    c_NameFltOn ='UseNameFlt';
    c_NameFlt ='UseNameFlt';
    c_DscFltOn ='UseDscFlt';
    c_DscFlt ='UseDscFlt';
    c_PropFltOn ='UsePropFlt';
    c_PropFlt ='UsePropFlt';
    c_Props ='��������';
    c_Values ='��������';

implementation

{$R *.dfm}
constructor TWPNameFltFrame.create(AOwner: TComponent);
begin
  inherited;
end;

destructor TWPNameFltFrame.destroy;
begin
  inherited;
end;

procedure TWPNameFltFrame.DscFltCBClick(Sender: TObject);
begin
  Updateselected;
end;

procedure TWPNameFltFrame.DscFltChange(Sender: TObject);
begin
  Updateselected;
end;

procedure TWPNameFltFrame.SaveCfg(section,cfgpath:string);
var
  ifile:tinifile;
  I: Integer;
  s, v:string;
  li:tlistitem;
begin
  ifile:=tinifile.create(cfgpath);
  ifile.WriteBool(section, c_NameFltOn, NameFltCB.checked);
  ifile.WriteString(section, c_NameFlt, NameFlt.text);
  ifile.WriteBool(section, c_dscFltOn, DscFltCB.checked);
  ifile.WriteString(section, c_DscFlt, DscFlt.text);
  ifile.WriteBool(section, c_PropFltOn, PropFltCB.checked);
  for I := 0 to PropList.items.Count - 1 do
  begin
    PropList.GetSubItemByColumnName(c_Props,li,s);
    PropList.GetSubItemByColumnName(c_Props,li,v);
    ifile.WriteString(section, '.'+s, v);
  end;
end;

procedure TWPNameFltFrame.ReadCfg(section,cfgpath:string);
var
  ifile:tinifile;
  I: Integer;
  s, v:string;
  li:tlistitem;
  slist:tstringlist;
begin
  ifile:=tinifile.create(cfgpath);
  NameFltCB.checked:=ifile.ReadBool(section, c_NameFltOn, false);
  NameFlt.text:=ifile.ReadString(section, c_NameFlt, '');
  DscFltCB.checked:=ifile.ReadBool(section, c_dscFltOn, false);
  DscFlt.text:=ifile.ReadString(section, c_DscFlt,'');
  PropFltCB.checked:=ifile.ReadBool(section, c_PropFltOn, false);
  slist:=TStringList.Create;
  ifile.ReadSections(slist);
  for I := 0 to sList.Count - 1 do
  begin
    s:=slist.Strings[i];
    if s[1]='.' then
    begin
      s:=Copy(s,2,length(s));
      li:=PropList.items.add;
      v:=ifile.ReadString(section, s, '');
      PropList.SetSubItemByColumnName(c_Props, s, li);
      PropList.SetSubItemByColumnName(c_Values, v, li);
    end;
  end;
end;

procedure TWPNameFltFrame.ShowSlist(l:TSignalArray);
var
  i: Integer;
  sig:iwpsignal;
begin
  clearSList;
  for i := 0 to length(l) - 1 do
  begin
    sig:=l[i];
    namesLB.AddItem(sig.sname,nil);
  end;
end;

procedure TWPNameFltFrame.setNames(l:TSignalArray);
begin
  siglist:=l;
  ShowSlist(l);
end;

function TWPNameFltFrame.getNames:TSignalArray;
var
  I: Integer;
begin
  setlength(siglist, length(selected));
  for I := 0 to length(selected) - 1 do
  begin
    siglist[i]:=selected[i];
  end;
  result:=siglist;
end;

procedure TWPNameFltFrame.NameFltCBClick(Sender: TObject);
begin
  Updateselected;
end;

procedure TWPNameFltFrame.NameFltChange(Sender: TObject);
begin
  Updateselected;
end;

procedure TWPNameFltFrame.clearSList;
begin
  NamesLB.Clear;
end;

procedure TWPNameFltFrame.Updateselected;
var
  I, j: Integer;
  li:tlistitem;
  s, prop, propval, propval1:string;
  sig:iwpsignal;
  b, propCheck:boolean;
  count:integer;
begin
  count:=length(siglist);
  setlength(selected, count);
  // ���-�� ��������� ������ ��������
  count:=0;
  for I := 0 to length(siglist) - 1 do
  begin
    propcheck:=true;
    sig:=iwpsignal(siglist[i]);
    s:=sig.sname;
    b:=true;
    // ���� �� ����� ���������
    if NameFltCB.Checked then
    begin
      if NameFlt.text<>'' then
      begin
        if pos(NameFlt.text,s)<1 then
          continue;
      end;
    end;
    if DscFltCB.Checked then
    begin
      if DscFlt.text<>'' then
      begin
        if pos(DscFlt.text,sig.comment)<1 then
          continue;
      end;
    end;
    if PropFltCB.Checked then
    begin
      propCheck:=true;
      for j:= 0 to PropList.Items.Count - 1 do
      begin
        li:=PropList.Items[i];
        PropList.GetSubItemByColumnName(c_Props, li, prop);
        PropList.GetSubItemByColumnName(c_Values, li,propval);
        propval1:=sig.GetProperty(prop);
        if pos(propval, propval1)<1 then
        begin
          propcheck:=false;
          break;
        end;
      end;
    end;
    if not propcheck then
      Continue;
    selected[count]:=sig;
    inc(count);
  end;
  setlength(selected, count);
  ShowSlist(selected);
end;

end.
