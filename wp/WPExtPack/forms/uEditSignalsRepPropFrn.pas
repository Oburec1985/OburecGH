unit uEditSignalsRepPropFrn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, uWPProc, posbase, Winpos_ole_TLB,
  inifiles;

type
  TEditRepPropFrm = class(TForm)
    GroupBox1: TGroupBox;
    ChannelsList: TBtnListView;
    Panel1: TPanel;
    OnBtn: TButton;
    OffBtn: TButton;
    Label1: TLabel;
    PropEdit: TEdit;
    ApplyBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnBtnClick(Sender: TObject);
    procedure OffBtnClick(Sender: TObject);
  private
    m_namelist, m_Srclist:tstringlist;
    m_propName:string;
  public
    procedure ShowNameList;
    procedure AddSrcList(list:tstringlist; PropertieName:string);
    procedure UpdateSrcProperties;
  end;

var
  EditRepPropFrm: TEditRepPropFrm;

implementation

{$R *.dfm}

procedure TEditRepPropFrm.UpdateSrcProperties;
var
  I,j: Integer;
  src:csrc;
  s:iwpsignal;
  str:string;
  li:tlistitem;
  ifile:tinifile;
begin
  for I := 0 to ChannelsList.items.Count - 1 do
  begin
    li:=ChannelsList.items[i];
    ChannelsList.GetSubItemByColumnName('Имя',li,str);
    for j := 0 to m_srcList.Count - 1 do
    begin
      src:=csrc(m_srcList.Objects[j]);
      s:=src.GetSignal(str);
      if s<>nil then
      begin
        if ChannelsList.items[i].Checked then
          s.SetProperty(m_propName,'1')
        else
          s.SetProperty(m_propName,'0');
      end;
    end;
  end;
  for i := 0 to m_srcList.Count - 1 do
  begin
    src:=csrc(m_srcList.Objects[i]);
    ifile:=tinifile.Create(src.merafile.FileName);
    for j := 0 to ChannelsList.items.Count - 1 do
    begin
      li:=ChannelsList.items[j];
      ChannelsList.GetSubItemByColumnName('Имя',li,str);
      if li.Checked then
        ifile.WriteString(str,m_propName,'1')
      else
        ifile.WriteString(str,m_propName,'0');
    end;
    ifile.Destroy;
  end;
end;

procedure TEditRepPropFrm.AddSrcList(list:tstringlist; PropertieName:string);
var
  I, j, ind: Integer;
  src:csrc;
  s:cwpsignal;
  str:string;
begin
  m_Srclist:=list;
  m_namelist.Clear;
  m_propName:=PropertieName;
  for I := 0 to List.Count - 1 do
  begin
    src:=csrc(list.Objects[i]);
    for j := 0 to src.ChildCount - 1 do
    begin
      s:=src.getSignalObj(j);
      if not isHelpChannel(s) then
      begin
        str:=s.name;
        if not m_namelist.find(str,ind) then
        begin
          m_namelist.Add(str);
        end;
      end;
    end;
  end;
  PropEdit.Text:=PropertieName;
  ShowNameList;
end;

procedure TEditRepPropFrm.ShowNameList;
var
  I, j: Integer;
  str:string;
  li:tlistitem;
  src:csrc;
  s:iwpsignal;
begin
  if m_srclist.Count>0 then
  begin
    src:=csrc(m_srclist.Objects[0]);
    ChannelsList.Clear;
    for I := 0 to m_nameList.Count - 1 do
    begin
      str:=m_namelist.Strings[i];
      li:=ChannelsList.Items.Add;
      ChannelsList.SetSubItemByColumnName('№', inttostr(i), li);
      ChannelsList.SetSubItemByColumnName('Имя', str, li);
      s:=src.GetSignal(str);
      if s<>nil then
        li.Checked:=s.GetProperty(m_PropName)='1'
      else
      begin
        li.Checked:=false;
      end;
    end;
  end;
end;

procedure TEditRepPropFrm.FormCreate(Sender: TObject);
begin
  m_namelist:=TStringList.Create;
  m_namelist.Sorted:=true;
end;

procedure TEditRepPropFrm.FormDestroy(Sender: TObject);
begin
  m_namelist.Destroy;
  m_namelist:=nil;
end;

procedure TEditRepPropFrm.OffBtnClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := ChannelsList.Selected; //Получаю выбранный элемент
  while Item <> nil do
  begin
    item.Checked:=false;
    Item := ChannelsList.GetNextItem(Item, sdAll, [isSelected]);
  end;
end;

procedure TEditRepPropFrm.OnBtnClick(Sender: TObject);
var
  Item: TListItem;
begin
  Item := ChannelsList.Selected; //Получаю выбранный элемент
  while Item <> nil do
  begin
    item.Checked:=true;
    Item := ChannelsList.GetNextItem(Item, sdAll, [isSelected]);
  end;
end;

end.


