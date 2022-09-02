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
    procedure FilterEditChange(Sender: TObject);
  private
  public
    procedure ShowChannels;
  end;

implementation

{$R *.dfm}

procedure TTagsListFrame.FilterEditChange(Sender: TObject);
begin
  ShowChannels;
end;

procedure TTagsListFrame.ShowChannels;
var
  I, ind, tCount: Integer;
  ir: IRecorder;
  t: iTag;
  tname: string;
  li: TListItem;
begin
  ir := getIR;
  // обновляем список каналов
  tCount := ir.GetTagsCount;
  TagsLV.Clear;
  for I := 0 to tCount - 1 do
  begin
    t := GetTagByIndex(I);
    tname := t.GetName;
    if ((pos(lowercase(FilterEdit.text), lowercase(tname)) > 0) or
        (FilterEdit.text = '')) then
    begin
      li := TagsLV.Items.Add;
      li.Data := pointer(t);
      TagsLV.SetSubItemByColumnName('Имя', tname, li);
      TagsLV.SetSubItemByColumnName('Fs', formatstrNoE(t.GetFreq,3), li);
    end;
  end;
  LVChange(TagsLV);
end;


end.
