unit uTagsListFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, forms,
  ComCtrls, uBtnListView, StdCtrls, ExtCtrls,
  uRecorderEvents,
  uComponentServises,
  ImgList,
  uRCFunc, uRvclService,
  MathFunction,
  tags, recorder, uBaseObjService,
  DCL_MYOWN, uRcCtrls, Controls;

type
  TTagsListFrame = class(TFrame)
    FormChannelsGB: TGroupBox;
    ChanNamesPanel: TPanel;
    FrmTagPropLabel: TLabel;
    FrmTagPropValue: TLabel;
    FilterEdit: TEdit;
    FrmTagPropValueEdit: TEdit;
    FrmTagPropNameCB: TComboBox;
    TagsLV: TBtnListView;
    ShowScalarCB: TCheckBox;
    procedure FilterEditChange(Sender: TObject);
    procedure ShowScalarCBClick(Sender: TObject);
  public
    // отображать только вектора
    ShowVectortags:boolean;
  private
    function FltFunc(t:itag):boolean;
  public
    function gettag:itag;overload;
    function gettag(i:integer):itag;overload;
    procedure ShowChannels;
  end;

implementation

{$R *.dfm}

procedure TTagsListFrame.FilterEditChange(Sender: TObject);
begin
  ShowChannels;
end;

function TTagsListFrame.FltFunc(t:itag): boolean;
var
  tname: string;
begin
  tname := t.GetName;
  result:=((pos(lowercase(FilterEdit.text), lowercase(tname)) > 0) or (FilterEdit.text = ''));
  if result then
  begin
    if isScalar(t) then
    begin
      if ShowVectortags then
        result:=false;
    end;
  end;
end;

function TTagsListFrame.gettag: itag;
begin

end;

function TTagsListFrame.gettag(i: integer): itag;
var
  li:tlistitem;
begin
  li:=TagsLV.Selected;
  result:=itag(li.data);
end;

procedure TTagsListFrame.ShowChannels;
var
  I, ind, tCount: Integer;
  ir: IRecorder;
  t: iTag;
  li: TListItem;
begin
  ir := getIR;
  if ir=nil then exit;
  // обновляем список каналов
  tCount := ir.GetTagsCount;
  TagsLV.Clear;
  for I := 0 to tCount - 1 do
  begin
    t := GetTagByIndex(I);
    if FltFunc(t) then
    begin
      li := TagsLV.Items.Add;
      li.Data := pointer(t);
      li.Caption:=t.GetName;
      if li.SubItems.Count>1 then
        li.SubItems[1]:=formatstrNoE(t.GetFreq,3)
      else
      begin
        if (isScalar(t)) then
        begin
          li.SubItems.Add('S.');
        end
        else
        begin
          li.SubItems.Add('V.');
        end;
        li.SubItems.Add(formatstrNoE(t.GetFreq,3));
      end;
      //TagsLV.SetSubItemByColumnName('Имя', t.GetName, li);
      TagsLV.SetSubItemByColumnName('Fs', formatstrNoE(t.GetFreq,3), li);
    end;
  end;
  LVChange(TagsLV);
end;


procedure TTagsListFrame.ShowScalarCBClick(Sender: TObject);
begin
  ShowVectortags:=not ShowScalarCB.Checked;
  ShowChannels;
end;

end.
