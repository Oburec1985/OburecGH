unit uIRDiagramEditFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uControlEditFrame, uModeFrame, uRecorderEvents, uControlObj,
  uComponentServises, upage,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService, uCommonTypes,uCommonMath,
  tags, recorder, uBaseObjService, uModesTabsForm, activex, uRTrig,
  DCL_MYOWN, uRcCtrls, uTrigsFrm, uEventTypes, uSpin, uControlWarnFrm, uEditProfileFrm, Spin,
  uTagsListFrame, uaxis, uIrDiagram;

type
  TIRDiagrEditFrm = class(TForm)
    BackGroundColorDialog: TColorDialog;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    Panel1: TPanel;
    UpdateBtn: TSpeedButton;
    PropPanel: TPanel;
    TagsListFrame1: TTagsListFrame;
    TagsGB: TGroupBox;
    TagsTV: TVTree;
    Draw_GB: TGroupBox;
    pCountLabel: TLabel;
    AddBtn: TSpeedButton;
    GroupBox5: TGroupBox;
    XChan_CB: TRcComboBox;
    PCountSE: TSpinEdit;
    GroupBox6: TGroupBox;
    YChan_CB: TRcComboBox;
    GraphNameEdit: TEdit;
    DrawPointsCB: TCheckBox;
    Panel2: TPanel;
    DrawLineCB: TCheckBox;
    AL_Panel: TPanel;
    X_GB: TGroupBox;
    MaxXLabel: TLabel;
    MinXLabel: TLabel;
    MaxXfe: TFloatEdit;
    MinXfe: TFloatEdit;
    Y_GB: TGroupBox;
    MinYLabel: TLabel;
    MaxYLabel: TLabel;
    MinYfe: TFloatEdit;
    MaxYfe: TFloatEdit;
    NameLabel: TLabel;
    PSizeEdit: TFloatEdit;
    PSizeLabel: TLabel;
    NameEdit: TEdit;
  private
    procedure setcurWp(w:TWrkPoint);
    function getcurWp:TWrkPoint;
    procedure updateopts;

    procedure showChartTags;
    procedure showWp;
    procedure createevents;
    procedure Destroyevents;
    // перенос настроенных графиков в чарт
    procedure SetWpToChart;
    procedure ShowSpmTags;
    procedure ShowAphTags;
    // ОТОБРАЗИТЬ СПИСОК ДОСТУПНЫХ ТЕГОВ
    procedure ShowProfiles;
    procedure ClearTempData;
    function selectAxis:cAxis;
    function getWpAxisNode(wp:TWrkPoint):pvirtualnode;
  public
    property curwp:TWrkPoint read getcurWp write setcurWp;
    procedure DoUpdateCfg(sender:tobject);
    procedure updateTagsList;
    procedure EditChart(chart:TCntrlWrnChart);
    destructor destroy;override;
    constructor create(aowner:tcomponent);override;
  end;

var
  IRDiagrEditFrm: TIRDiagrEditFrm;

implementation

{$R *.dfm}

end.
