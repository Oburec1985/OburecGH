unit uSyncScillogramEditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, Buttons, VirtualTrees, uVTServices, ExtCtrls,
  uControlEditFrame, uRecorderEvents, uControlObj,
  uComponentServises, upage,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService, uCommonTypes, uCommonMath,
  tags, recorder, uBaseObjService, uModesTabsForm, activex,
  DCL_MYOWN, uRcCtrls, uEventTypes, uSpin, Spin,
  uTagsListFrame, uaxis;

type
  TEditSyncOscFrm = class(TForm)
    TagsListFrame1: TTagsListFrame;
    BottomPanel: TPanel;
    TagsGB: TGroupBox;
    TagsTV: TVTree;
    MainPanel: TPanel;
    YAxisGB: TGroupBox;
    MinYLabel: TLabel;
    MaxYLabel: TLabel;
    AddAxisBtn: TSpeedButton;
    NameAxisLabel: TLabel;
    MinYfe: TFloatEdit;
    MaxYfe: TFloatEdit;
    LgYcb: TCheckBox;
    NameAxisEdit: TEdit;
    LengthLabel: TLabel;
    LengthFE: TFloatEdit;
    TrigRG: TRadioGroup;
    UpdateBtn: TSpeedButton;
    ChannelXCB: TRcComboBox;
    Label1: TLabel;
  private
    m_curObj:tobject;
  public
    procedure SetEditObj(p_osc:tobject);
  end;



var
  EditSyncOscFrm: TEditSyncOscFrm;

implementation
uses
  uSyncOscillogram;

{$R *.dfm}

{ TEditSyncOscFrm }

procedure TEditSyncOscFrm.SetEditObj(p_osc: tobject);
var
  osc:TSyncOscFrm;
  p:cpage;
  a:caxis;
begin
  m_curObj:=p_osc;
  osc:=TSyncOscFrm(m_curObj);
  // отображаемый интервал
  LengthFE.FloatNum:=osc.m_Length;
  TrigRG.ItemIndex:=TOscTypeToInt(osc.m_type);
  p:=cpage(osc.m_Chart.activePage);
  a:=p.activeAxis;
  MinYfe.FloatNum:=a.min.y;
  MaxYfe.FloatNum:=a.max.y;
  NameAxisEdit.text:=a.name;
end;



end.
