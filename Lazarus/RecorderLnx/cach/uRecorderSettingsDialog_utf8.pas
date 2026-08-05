unit uRecorderSettingsDialog;

{
  РњРѕРґСѓР»СЊ uRecorderSettingsDialog

  РќР°Р·РЅР°С‡РµРЅРёРµ:
    Р”РёР°Р»РѕРі РЅР°СЃС‚СЂРѕР№РєРё РїР°СЂР°РјРµС‚СЂРѕРІ СЂРµРєРѕСЂРґРµСЂР° Рё РєРѕРЅС„РёРіСѓСЂР°С†РёРё Р°РїРїР°СЂР°С‚РЅС‹С… РєР°РЅР°Р»РѕРІ/СѓСЃС‚СЂРѕР№СЃС‚РІ.
    РџРѕР·РІРѕР»СЏРµС‚ Р·Р°РґР°РІР°С‚СЊ РїР°СЂР°РјРµС‚СЂС‹ РѕС‚РѕР±СЂР°Р¶РµРЅРёСЏ, Р±СѓС„РµСЂРёР·Р°С†РёРё, Р·Р°РїРёСЃРё, СѓСЃР»РѕРІРёСЏ
    СЃС‚Р°СЂС‚Р°/РѕСЃС‚Р°РЅРѕРІР° СЃР±РѕСЂР° РґР°РЅРЅС‹С…, Р° С‚Р°РєР¶Рµ РёРјРїРѕСЂС‚РёСЂРѕРІР°С‚СЊ СЃРёРіРЅР°Р»С‹ РёР· С„Р°Р№Р»РѕРІ С„РѕСЂРјР°С‚Р° Mera.

  Р‘РёР±Р»РёРѕС‚РµРєРё Рё Р·Р°РІРёСЃРёРјРѕСЃС‚Рё:
    - Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls: СЃС‚Р°РЅРґР°СЂС‚РЅС‹Рµ РјРѕРґСѓР»Рё LCL.
    - ComCtrls, ImgList, Grids, Buttons: РєРѕРјРїРѕРЅРµРЅС‚С‹ UI (РґРµСЂРµРІРѕ СѓСЃС‚СЂРѕР№СЃС‚РІ, СЃРїРёСЃРєРё РєР°РЅР°Р»РѕРІ).
    - uRecorderStateMachine, uRecorderRunControlSettings, uRecorderTags: Р±РёР·РЅРµСЃ-Р»РѕРіРёРєР° СЂРµРєРѕСЂРґРµСЂР°.
    - uMeraFile: РїР°СЂСЃРёРЅРі С„Р°Р№Р»РѕРІ РєРѕРЅС„РёРіСѓСЂР°С†РёРё СЃРёРіРЅР°Р»РѕРІ Mera.
    - uRecorderCommandImages: РєРѕРЅСЃС‚Р°РЅС‚С‹ РёРЅРґРµРєСЃРѕРІ РёРєРѕРЅРѕРє UI.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, ImgList, Grids, Buttons, Menus, LCLType,
  uRecorderStateMachine, uRecorderRunControlSettings, uRecorderTags, uMeraFile,
  uRecorderCommandImages, uTagSettingsDialog, uComponentServices,
  uRecorderSpectrumEngine, uRecorderFrequencyBands, uRecorderFrequencyBandsDialog;

type
  { TRecorderSettingsDialog }

  { РљР»Р°СЃСЃ РґРёР°Р»РѕРіРѕРІРѕРіРѕ РѕРєРЅР° РЅР°СЃС‚СЂРѕРµРє СЂРµРєРѕСЂРґРµСЂР° }
  TRecorderSettingsDialog = class(TForm)
  published
    fPageControl: TPageControl;                 // РљРѕРЅС‚РµР№РЅРµСЂ РІРєР»Р°РґРѕРє РЅР°СЃС‚СЂРѕРµРє
    fApplyButton: TButton;                     // РљРЅРѕРїРєР° "РџСЂРёРјРµРЅРёС‚СЊ"
    fHardwareTree: TTreeView;                   // Р”РµСЂРµРІРѕ Р°РїРїР°СЂР°С‚РЅРѕР№ РєРѕРЅС„РёРіСѓСЂР°С†РёРё/СѓСЃС‚СЂРѕР№СЃС‚РІ
    btnDeviceAdd: TBitBtn;                      // РљРЅРѕРїРєР° РґРѕР±Р°РІР»РµРЅРёСЏ СѓСЃС‚СЂРѕР№СЃС‚РІР° (Mera-С„Р°Р№Р»Р°)
    btnChannelAdd: TBitBtn;                     // РљРЅРѕРїРєР° РґРѕР±Р°РІР»РµРЅРёСЏ РІС‹Р±СЂР°РЅРЅРѕРіРѕ РєР°РЅР°Р»Р° РІ СЃРїРёСЃРѕРє Р°РєС‚РёРІРЅС‹С…
    btnChannelRemove: TBitBtn;                  // РљРЅРѕРїРєР° СѓРґР°Р»РµРЅРёСЏ РєР°РЅР°Р»Р° РёР· СЃРїРёСЃРєР° Р°РєС‚РёРІРЅС‹С…
    btnChannelEdit: TBitBtn;                    // РљРЅРѕРїРєР° РЅР°СЃС‚СЂРѕР№РєРё РІС‹Р±СЂР°РЅРЅРѕРіРѕ С‚РµРіР°
    pnChannelMoveButtons: TPanel;               // РџР°РЅРµР»СЊ РєРЅРѕРїРѕРє РїРµСЂРµРјРµС‰РµРЅРёСЏ РєР°РЅР°Р»РѕРІ
    spChannels: TSplitter;                      // Р Р°Р·РґРµР»РёС‚РµР»СЊ РјРµР¶РґСѓ СЃРµС‚РєР°РјРё РґРѕСЃС‚СѓРїРЅС‹С… Рё РІС‹Р±СЂР°РЅРЅС‹С… РєР°РЅР°Р»РѕРІ
    fAvailableChannelsGrid: TStringGrid;        // РўР°Р±Р»РёС†Р° РґРѕСЃС‚СѓРїРЅС‹С… РґР»СЏ РІС‹Р±РѕСЂР° РєР°РЅР°Р»РѕРІ
    fSelectedChannelsGrid: TStringGrid;         // РўР°Р±Р»РёС†Р° РІС‹Р±СЂР°РЅРЅС‹С… (Р°РєС‚РёРІРЅС‹С…) РєР°РЅР°Р»РѕРІ
    spChannelAlgorithms: TSplitter;             // Р Р°Р·РґРµР»РёС‚РµР»СЊ РјРµР¶РґСѓ РєР°РЅР°Р»Р°РјРё Рё Р°Р»РіРѕСЂРёС‚РјР°РјРё
    fAlgorithmsTree: TTreeView;                 // Р”РµСЂРµРІРѕ Р°Р»РіРѕСЂРёС‚РјРѕРІ РєР°РЅР°Р»РѕРІ
    fAlgorithmKindCombo: TComboBox;             // РўРёРї СЃРѕР·РґР°РІР°РµРјРѕРіРѕ Р°Р»РіРѕСЂРёС‚РјР°
    btnAlgorithmAdd: TBitBtn;                   // РЎРѕР·РґР°С‚СЊ Р°Р»РіРѕСЂРёС‚Рј РїРѕ РІС‹Р±СЂР°РЅРЅС‹Рј РєР°РЅР°Р»Р°Рј
    btnAlgorithmRemove: TBitBtn;                // РЈРґР°Р»РёС‚СЊ СѓР·РµР» Р°Р»РіРѕСЂРёС‚РјР°
    btnAlgorithmConfig: TBitBtn;                // РџСЂРёРјРµРЅРёС‚СЊ РїР°СЂР°РјРµС‚СЂС‹ FFT-СѓР·Р»Р°
    btnFrequencyBands: TBitBtn;                 // РќР°СЃС‚СЂРѕРёС‚СЊ С‡Р°СЃС‚РѕС‚РЅС‹Рµ РїРѕР»РѕСЃС‹
    fAlgorithmFftSizeEdit: TEdit;               // Р Р°Р·РјРµСЂ FFT
    fAlgorithmFftSizeUpDown: TUpDown;           // РЎС‚СЂРµР»РѕС‡РєРё РёР·РјРµРЅРµРЅРёСЏ СЂР°Р·РјРµСЂР° FFT
    fAlgorithmSampleRateEdit: TEdit;            // Р§Р°СЃС‚РѕС‚Р° РѕРїСЂРѕСЃР°
    fAlgorithmPortionLabel: TLabel;             // Р Р°Р·РјРµСЂ РїРѕСЂС†РёРё РІ СЃРµРєСѓРЅРґР°С…
    fAlgorithmAverageBlocksEdit: TEdit;         // РљРѕР»РёС‡РµСЃС‚РІРѕ Р±Р»РѕРєРѕРІ СѓСЃСЂРµРґРЅРµРЅРёСЏ
    fAlgorithmOverlapEdit: TEdit;               // РџРµСЂРµРєСЂС‹С‚РёРµ FFT
    fAlgorithmOverlapCombo: TComboBox;          // Р РµР¶РёРј РїРµСЂРµРєСЂС‹С‚РёСЏ FFT
    fAlgorithmWindowCombo: TComboBox;           // РћРєРѕРЅРЅР°СЏ С„СѓРЅРєС†РёСЏ
    fAlgorithmNormalizeCombo: TComboBox;        // РќРѕСЂРјРёСЂРѕРІРєР° СЃРїРµРєС‚СЂР°
    fAlgorithmZeroPadCheck: TCheckBox;          // Р”РѕРїРѕР»РЅСЏС‚СЊ РЅСѓР»СЏРјРё
    fAlgorithmAhCorrectionCheck: TCheckBox;     // РљРѕСЂСЂРµРєС†РёСЏ РђР§РҐ
    fAlgorithmIntegrationGroup: TRadioGroup;    // Р РµР¶РёРј РёРЅС‚РµРіСЂРёСЂРѕРІР°РЅРёСЏ
    Cfg: TEdit;

    // РџРѕР»СЏ РІРІРѕРґР° РѕР±С‰РёС… РЅР°СЃС‚СЂРѕРµРє
    fScreenUpdateEdit: TEdit;                   // РџРµСЂРёРѕРґ РѕР±РЅРѕРІР»РµРЅРёСЏ СЌРєСЂР°РЅР° (СЃРµРє)
    fBufferSecondsEdit: TEdit;                  // Р”Р»РёРЅР° РѕС‚РѕР±СЂР°Р¶Р°РµРјРѕРіРѕ Р±СѓС„РµСЂР° (СЃРµРє)
    fDataUpdateEdit: TEdit;                     // РџРµСЂРёРѕРґ РѕР±РЅРѕРІР»РµРЅРёСЏ РґР°РЅРЅС‹С… (СЃРµРє)
    fTestNameEdit: TEdit;                       // РРјСЏ С‚РµРєСѓС‰РµРіРѕ РёСЃРїС‹С‚Р°РЅРёСЏ
    fProductNameEdit: TEdit;                    // РРјСЏ РёСЃСЃР»РµРґСѓРµРјРѕРіРѕ РёР·РґРµР»РёСЏ
    fModifyNameCheck: TCheckBox;                // Р¤Р»Р°Рі Р°РІС‚РѕРјР°С‚РёС‡РµСЃРєРѕР№ РјРѕРґРёС„РёРєР°С†РёРё РёРјРµРЅРё РёСЃРїС‹С‚Р°РЅРёСЏ
    fPrehistoryCheck: TCheckBox;                // Р¤Р»Р°Рі Р·Р°РїРёСЃРё РїСЂРµРґС‹СЃС‚РѕСЂРёРё
    fPrehistoryEdit: TEdit;                     // Р”Р»РёРЅР° РїСЂРµРґС‹СЃС‚РѕСЂРёРё (СЃРµРє)
    fResetTimeCheck: TCheckBox;                 // Р¤Р»Р°Рі СЃР±СЂРѕСЃР° РІСЂРµРјРµРЅРё РїСЂРё СЃС‚Р°СЂС‚Рµ Р·Р°РїРёСЃРё
    fWriteWithPausesCheck: TCheckBox;           // Р¤Р»Р°Рі СЂР°Р·СЂРµС€РµРЅРёСЏ Р·Р°РїРёСЃРё СЃ РїР°СѓР·Р°РјРё
    fSaveConfigWithDataCheck: TCheckBox;        // Р¤Р»Р°Рі СЃРѕС…СЂР°РЅРµРЅРёСЏ С„Р°Р№Р»Р° РєРѕРЅС„РёРіСѓСЂР°С†РёРё РІРјРµСЃС‚Рµ СЃ РґР°РЅРЅС‹РјРё
    fWorkDirEdit: TEdit;                        // Р Р°Р±РѕС‡РёР№ РєР°С‚Р°Р»РѕРі СЃРѕС…СЂР°РЅРµРЅРёСЏ С„Р°Р№Р»РѕРІ
    fTemplateCheck: TCheckBox;                  // Р¤Р»Р°Рі РёСЃРїРѕР»СЊР·РѕРІР°РЅРёСЏ С€Р°Р±Р»РѕРЅР° РёРјРµРЅРё С„Р°Р№Р»Р°
    fTemplateButton: TButton;                   // РљРЅРѕРїРєР° РЅР°СЃС‚СЂРѕР№РєРё С€Р°Р±Р»РѕРЅР°
    fFrameDirEdit: TEdit;                       // РџСѓС‚СЊ Рє С‚РµРєСѓС‰РµРјСѓ РєР°РґСЂСѓ РґР°РЅРЅС‹С…

    // РЈСЃР»РѕРІРёСЏ СЃС‚Р°СЂС‚Р° Р·Р°РїРёСЃРё
    fStartManualRadio: TRadioButton;            // РЎС‚Р°СЂС‚ РІСЂСѓС‡РЅСѓСЋ (РїРѕ РєРЅРѕРїРєРµ)
    fStartLevelRadio: TRadioButton;             // РЎС‚Р°СЂС‚ РїРѕ РґРѕСЃС‚РёР¶РµРЅРёСЋ СѓСЂРѕРІРЅСЏ СЃРёРіРЅР°Р»Р°
    fStartTriggerRadio: TRadioButton;           // РЎС‚Р°СЂС‚ РїРѕ РІРЅРµС€РЅРµРјСѓ С‚СЂРёРіРіРµСЂСѓ
    fStartTriggerEdit: TEdit;                   // РќРѕРјРµСЂ С‚СЂРёРіРіРµСЂР° СЃС‚Р°СЂС‚Р°
    fStartChannelCombo: TComboBox;              // РљР°РЅР°Р»-РёСЃС‚РѕС‡РЅРёРє РґР»СЏ СѓСЃР»РѕРІРёСЏ СЃС‚Р°СЂС‚Р°
    fStartEdgeCombo: TComboBox;                 // РќР°РїСЂР°РІР»РµРЅРёРµ РїРµСЂРµС…РѕРґР° (Р±РѕР»СЊС€Рµ/РјРµРЅСЊС€Рµ)
    fStartLevelEdit: TEdit;                     // РџРѕСЂРѕРіРѕРІС‹Р№ СѓСЂРѕРІРµРЅСЊ РґР»СЏ СЃС‚Р°СЂС‚Р°

    // РЈСЃР»РѕРІРёСЏ РѕСЃС‚Р°РЅРѕРІР° Р·Р°РїРёСЃРё
    fStopManualRadio: TRadioButton;             // РћСЃС‚Р°РЅРѕРІС‹ РІСЂСѓС‡РЅСѓСЋ (РїРѕ РєРЅРѕРїРєРµ)
    fStopLevelRadio: TRadioButton;              // РћСЃС‚Р°РЅРѕРІ РїРѕ СѓСЂРѕРІРЅСЋ СЃРёРіРЅР°Р»Р°
    fStopDurationRadio: TRadioButton;           // РћСЃС‚Р°РЅРѕРІ РїРѕ РґР»РёС‚РµР»СЊРЅРѕСЃС‚Рё (С‚Р°Р№РјРµСЂСѓ)
    fStopDurationEdit: TEdit;                   // Р’СЂРµРјСЏ Р·Р°РїРёСЃРё РґРѕ РѕСЃС‚Р°РЅРѕРІР° (СЃРµРє)
    fStopChannelCombo: TComboBox;               // РљР°РЅР°Р»-РёСЃС‚РѕС‡РЅРёРє РґР»СЏ СѓСЃР»РѕРІРёСЏ РѕСЃС‚Р°РЅРѕРІР°
    fStopEdgeCombo: TComboBox;                  // РќР°РїСЂР°РІР»РµРЅРёРµ РїРµСЂРµС…РѕРґР° РґР»СЏ РѕСЃС‚Р°РЅРѕРІР°
    fStopLevelEdit: TEdit;                      // РџРѕСЂРѕРіРѕРІС‹Р№ СѓСЂРѕРІРµРЅСЊ РґР»СЏ РѕСЃС‚Р°РЅРѕРІР°
    fStopReturnToPreviewCheck: TCheckBox;       // Р¤Р»Р°Рі РІРѕР·РІСЂР°С‚Р° РІ СЂРµР¶РёРј РїСЂРѕСЃРјРѕС‚СЂР° РїРѕСЃР»Рµ РѕСЃС‚Р°РЅРѕРІР°

    // РћР±СЂР°Р±РѕС‚С‡РёРєРё СЃРѕР±С‹С‚РёР№ UI СЌР»РµРјРµРЅС‚РѕРІ РґРёР°Р»РѕРіР°
    procedure ApplyButtonClick(Sender: TObject);
    procedure OkButtonClick(Sender: TObject);
    procedure ConditionChanged(Sender: TObject);
    procedure btnDeviceAddClick(Sender: TObject);
    procedure btnChannelAddClick(Sender: TObject);
    procedure btnChannelRemoveClick(Sender: TObject);
    procedure btnChannelEditClick(Sender: TObject);
    procedure fAvailableChannelsGridDblClick(Sender: TObject);
    procedure fAvailableChannelsGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure fSelectedChannelsGridDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure fSelectedChannelsGridDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure fSelectedChannelsGridDblClick(Sender: TObject);
    procedure fSelectedChannelsGridMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure fAlgorithmsTreeChange(Sender: TObject; Node: TTreeNode);
    procedure fAlgorithmsTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure fAlgorithmsTreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure btnAlgorithmAddClick(Sender: TObject);
    procedure btnAlgorithmRemoveClick(Sender: TObject);
    procedure btnAlgorithmConfigClick(Sender: TObject);
    procedure btnFrequencyBandsClick(Sender: TObject);
    procedure fAlgorithmAhCorrectionCheckChange(Sender: TObject);
    procedure fAlgorithmFftParamChange(Sender: TObject);
    procedure fAlgorithmOverlapComboChange(Sender: TObject);
    procedure fHardwareTreeDblClick(Sender: TObject);
    procedure fHardwareTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fAlgorithmsTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fCfgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure fAlgorithmFftSizeUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure WorkDirBrowseClick(Sender: TObject);
  private
    fRunSettings: TRecorderRunControlSettings;   // РЎСЃС‹Р»РєР° РЅР° РѕР±СЉРµРєС‚ РЅР°СЃС‚СЂРѕРµРє Р·Р°РїСѓСЃРєР°/РѕСЃС‚Р°РЅРѕРІР°
    fTagRegistry: TRecorderTagRegistry;         // РЎСЃС‹Р»РєР° РЅР° СЂРµРµСЃС‚СЂ С‚РµРіРѕРІ РїСЂРёР»РѕР¶РµРЅРёСЏ
    fDeviceImageList: TCustomImageList;         // РЎРїРёСЃРѕРє РєР°СЂС‚РёРЅРѕРє РґР»СЏ РґРµСЂРµРІР° СѓСЃС‚СЂРѕР№СЃС‚РІ
    fTagDialogImageList: TCustomImageList;      // РЎРїРёСЃРѕРє РёРєРѕРЅРѕРє РґРёР°Р»РѕРіР° РЅР°СЃС‚СЂРѕР№РєРё С‚РµРіРѕРІ
    fMeraFolder: string;                        // РџСѓС‚СЊ Рє РїРѕСЃР»РµРґРЅРµР№ РїР°РїРєРµ РёРјРїРѕСЂС‚РёСЂРѕРІР°РЅРЅРѕРіРѕ Mera-С„Р°Р№Р»Р°
    fMeraFileName: string;                      // РРјСЏ РёРјРїРѕСЂС‚РёСЂРѕРІР°РЅРЅРѕРіРѕ Mera-С„Р°Р№Р»Р°
    fMeraSignals: TList;                        // РЎРїРёСЃРѕРє TMeraSignalInfo, Р·Р°РіСЂСѓР¶РµРЅРЅС‹С… РёР· С„Р°Р№Р»Р°
    fSelectedChannelTags: TList;                // Row-map РІС‹Р±СЂР°РЅРЅС‹С… РєР°РЅР°Р»РѕРІ РЅР° TRecorderTag
    fSelectedSortColumn: Integer;               // РљРѕР»РѕРЅРєР° С‚РµРєСѓС‰РµР№ СЃРѕСЂС‚РёСЂРѕРІРєРё РІС‹Р±СЂР°РЅРЅС‹С… РєР°РЅР°Р»РѕРІ
    fSelectedSortAscending: Boolean;            // РќР°РїСЂР°РІР»РµРЅРёРµ С‚РµРєСѓС‰РµР№ СЃРѕСЂС‚РёСЂРѕРІРєРё
    fSpectrumConfigTree: TRecorderSpectrumConfigTree; // Р§РµСЂРЅРѕРІР°СЏ РјРѕРґРµР»СЊ Р°Р»РіРѕСЂРёС‚РјРѕРІ РІРєР»Р°РґРєРё РєР°РЅР°Р»РѕРІ
    fFrequencyBands: TRecorderFrequencyBandList; // Р§РµСЂРЅРѕРІР°СЏ РјРѕРґРµР»СЊ С‡Р°СЃС‚РѕС‚РЅС‹С… РїРѕР»РѕСЃ
    fCanDrag: Boolean;
    fDragStartPt: TPoint;
    fDragSelectActive: Boolean;
    fDragSelectStart: TPoint;
    fDragSelectEnd: TPoint;
    fSelectingGrid: TStringGrid;
    fSavedSelection: TGridRect;
    procedure fSelectedChannelsGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure fSelectedChannelsGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridPaint(Sender: TObject);
    
    // Р’СЃРїРѕРјРѕРіР°С‚РµР»СЊРЅС‹Рµ РјРµС‚РѕРґС‹ СЂР°Р±РѕС‚С‹ СЃ Mera-СЃРёРіРЅР°Р»Р°РјРё
    procedure AddMeraSignal(ASignal: TMeraSignalInfo);
    function CloneMeraSignalForTag(ASignal: TMeraSignalInfo;
      const ATagName: string): TMeraSignalInfo;
    procedure ApplyMeraSignalToTag(ATag: TRecorderTag; ASignal: TMeraSignalInfo);
    function FindTagBySourceAddress(const ASourceId, AAddress: string): TRecorderTag;
    function SignalHasLinkedTag(ASignal: TMeraSignalInfo): Boolean;
    function SelectedTagByGridRow(ARow: Integer): TRecorderTag;
    function CompareTagsForSelectedGrid(ATagA, ATagB: TRecorderTag): Integer;
    procedure SortSelectedTags(ATags: TList);
    procedure SortSelectedChannelsByColumn(AColumn: Integer);
    procedure OpenSelectedChannelTagSettings;
    procedure AddSpectrumAlgorithmsFromSelectedChannels;
    procedure AddSpectrumAlgorithmForTag(ATag: TRecorderTag;
      ATargetNode: TRecorderSpectrumConfigNode);
    function CreateSpectrumConfigNode(ATag: TRecorderTag): TRecorderSpectrumConfigNode;
    function SelectedSpectrumConfigNode: TRecorderSpectrumConfigNode;
    procedure CreateSelectedMeraTags;
    procedure ClearMeraSignals;
    procedure RestoreMeraSignalsFromTags;
    function FindMeraSignalByTagName(const ATagName: string): TMeraSignalInfo;
    function AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    function SelectedSignalByGridRow(ARow: Integer): TMeraSignalInfo;
    procedure LoadMeraFile(const AFileName: string);
    procedure MarkSignalsFromRegistry;
    function MeraSourceId(const AFileName: string): string;
    procedure DeleteCurrentMeraSource;
    procedure ReloadCurrentMeraSource;
    procedure HardwareDeleteSourceClick(Sender: TObject);
    procedure HardwareReloadSourceClick(Sender: TObject);
    procedure HardwareEditSourceClick(Sender: TObject);
    
    // РњРµС‚РѕРґС‹ РёРЅРёС†РёР°Р»РёР·Р°С†РёРё Рё РѕР±РЅРѕРІР»РµРЅРёСЏ РёРЅС‚РµСЂС„РµР№СЃР°
    procedure PopulateChannelGrids;
    procedure PopulateHardwareTree;
    procedure PopulateAlgorithmsTree;
    procedure InitializeAlgorithmControls;
    procedure LoadSelectedAlgorithmSettings;
    procedure StoreSelectedAlgorithmSettings;
    procedure UpdateAlgorithmDerivedControls;
    procedure DeleteSelectedAlgorithms;
    function GetSettingsFromControls(const ACurrent: TRecorderSpectrumSettings): TRecorderSpectrumSettings;
    procedure UpdateConfigStr;
    procedure SetGridHeaders;
    procedure ToggleHardwareSignal(ANode: TTreeNode);
    procedure SetRunSettings(AValue: TRecorderRunControlSettings);
    procedure SetTagRegistry(AValue: TRecorderTagRegistry);
    procedure SetDeviceImageList(AValue: TCustomImageList);
    procedure SetDialogButtonImages;
    procedure InitializeHardwareTree;
    
    // Р”РёРЅР°РјРёС‡РµСЃРєРѕРµ РїРѕСЃС‚СЂРѕРµРЅРёРµ UI (РёСЃРїРѕР»СЊР·СѓРµС‚СЃСЏ РїСЂРё РѕС‚СЃСѓС‚СЃС‚РІРёРё lfm-С„Р°Р№Р»Р° С„РѕСЂРјС‹)
    procedure BuildUi;
    procedure BuildRecorderTab(ATab: TTabSheet);
    procedure BuildHardwareTab(ATab: TTabSheet);
    procedure BuildPlaceholderTab(const ACaption: string);
    
    // Р§С‚РµРЅРёРµ Рё СЃРѕС…СЂР°РЅРµРЅРёРµ РЅР°СЃС‚СЂРѕРµРє
    procedure LoadFromSettings;
    procedure StoreToSettings;
    procedure UpdateConditionControls;
    function ReadFloatEdit(AEdit: TEdit; ADefault: Double): Double;
    function ReadSecondsAsMs(AEdit: TEdit; ADefaultMs: Cardinal): Cardinal;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    // РЎРІРѕР№СЃС‚РІР° РґРѕСЃС‚СѓРїР° Рє Р·Р°РІРёСЃРёРјРѕСЃС‚СЏРј
    property DeviceImageList: TCustomImageList read fDeviceImageList write SetDeviceImageList;
    property TagDialogImageList: TCustomImageList read fTagDialogImageList write fTagDialogImageList;
    property RunSettings: TRecorderRunControlSettings read fRunSettings write SetRunSettings;
    property TagRegistry: TRecorderTagRegistry read fTagRegistry write SetTagRegistry;
  end;

{ РћС‚РѕР±СЂР°Р¶Р°РµС‚ РјРѕРґР°Р»СЊРЅС‹Р№ РґРёР°Р»РѕРі РЅР°СЃС‚СЂРѕРµРє }
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry = nil;
  ADeviceImageList: TCustomImageList = nil;
  ATagDialogImageList: TCustomImageList = nil): Boolean;

implementation

{$R *.lfm}

{ РўРѕС‡РєР° РІС…РѕРґР° РґР»СЏ Р·Р°РїСѓСЃРєР° РґРёР°Р»РѕРіР° РЅР°СЃС‚СЂРѕРµРє }
function ShowRecorderSettingsDialog(AOwner: TComponent;
  ARunSettings: TRecorderRunControlSettings;
  ATagRegistry: TRecorderTagRegistry;
  ADeviceImageList: TCustomImageList;
  ATagDialogImageList: TCustomImageList): Boolean;
var
  lDialog: TRecorderSettingsDialog;
begin
  lDialog := TRecorderSettingsDialog.Create(AOwner);
  try
    lDialog.DeviceImageList := ADeviceImageList;
    lDialog.TagDialogImageList := ATagDialogImageList;
    lDialog.TagRegistry := ATagRegistry;
    lDialog.RunSettings := ARunSettings;
    Result := lDialog.ShowModal = mrOk;
  finally
    lDialog.Free;
  end;
end;

{ Р’СЃРїРѕРјРѕРіР°С‚РµР»СЊРЅС‹Рµ С„СѓРЅРєС†РёРё РґРёРЅР°РјРёС‡РµСЃРєРѕРіРѕ СЃРѕР·РґР°РЅРёСЏ UI РєРѕРЅС‚СЂРѕР»РѕРІ }

function AddLabel(AOwner: TComponent; AParent: TWinControl; ALeft, ATop: Integer;
  const ACaption: string): TLabel;
begin
  Result := TLabel.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Caption := ACaption;
end;

function AddEdit(AOwner: TComponent; AParent: TWinControl; ALeft, ATop,
  AWidth: Integer; const AText: string): TEdit;
begin
  Result := TEdit.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Width := AWidth;
  Result.Text := AText;
end;

function AddGroup(AOwner: TComponent; AParent: TWinControl; ALeft, ATop,
  AWidth, AHeight: Integer; const ACaption: string): TGroupBox;
begin
  Result := TGroupBox.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
end;

function AddRadio(AOwner: TComponent; AParent: TWinControl; ALeft, ATop: Integer;
  const ACaption: string; AOnChange: TNotifyEvent): TRadioButton;
begin
  Result := TRadioButton.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Caption := ACaption;
  Result.OnChange := AOnChange;
end;

function AddCheck(AOwner: TComponent; AParent: TWinControl; ALeft, ATop: Integer;
  const ACaption: string): TCheckBox;
begin
  Result := TCheckBox.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Caption := ACaption;
end;

function AddCombo(AOwner: TComponent; AParent: TWinControl; ALeft, ATop,
  AWidth: Integer): TComboBox;
begin
  Result := TComboBox.Create(AOwner);
  Result.Parent := AParent;
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Width := AWidth;
  Result.Style := csDropDownList;
end;

{ РќР°Р·РЅР°С‡РµРЅРёРµ РєР°СЂС‚РёРЅРєРё РєРЅРѕРїРєР°Рј СЃ РіР»РёС„РѕРј }
procedure AssignButtonImage(AButton: TBitBtn; AImages: TCustomImageList;
  AIndex: Integer);
var
  lBitmap: TBitmap;
  lNative: TBitmap;
  lW, lH: Integer;
begin
  if (AButton = nil) or (AImages = nil) or (AIndex < 0) or
    (AIndex >= AImages.Count) then
    Exit;

  lNative := TBitmap.Create;
  lBitmap := TBitmap.Create;
  try
    lNative.SetSize(AImages.Width, AImages.Height);
    AImages.GetBitmap(AIndex, lNative);
    
    lW := AButton.ClientWidth;
    if lW <= 0 then lW := AButton.Width;
    lH := AButton.ClientHeight;
    if lH <= 0 then lH := AButton.Height;
    
    // Add margin so it fits beautifully
    if lW > 6 then Dec(lW, 6);
    if lH > 6 then Dec(lH, 6);
    if lW <= 0 then lW := 16;
    if lH <= 0 then lH := 16;

    lBitmap.SetSize(lW, lH);
    lBitmap.Canvas.Brush.Color := clBtnFace;
    lBitmap.Canvas.FillRect(0, 0, lW, lH);
    lBitmap.Canvas.StretchDraw(Rect(0, 0, lW, lH), lNative);
    
    AButton.Caption := '';
    AButton.Glyph.Assign(lBitmap);
    AButton.Layout := blGlyphTop;
    AButton.Margin := 0;
  finally
    lNative.Free;
    lBitmap.Free;
  end;
end;

{ TRecorderSettingsDialog }

const
  CDeviceRootImageIndex = CIconDeviceRoot;
  CDeviceControllerImageIndex = CIconDeviceController;
  CDeviceModuleImageIndex = CIconDeviceModule;
  CMeraSampleFile = 'D:\works\mera\mera files signals\shocks\signal0005\signal0005.mera';

constructor TRecorderSettingsDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fMeraSignals := TList.Create;
  fSelectedChannelTags := TList.Create;
  fSpectrumConfigTree := TRecorderSpectrumConfigTree.Create;
  fFrequencyBands := TRecorderFrequencyBandList.Create;
  fSelectedSortColumn := 2;
  fSelectedSortAscending := True;

  if (btnChannelEdit = nil) and (pnChannelMoveButtons <> nil) then
  begin
    btnChannelEdit := TBitBtn.Create(Self);
    btnChannelEdit.Parent := pnChannelMoveButtons;
    btnChannelEdit.Left := 6;
    btnChannelEdit.Top := 276;
    btnChannelEdit.Width := 30;
    btnChannelEdit.Height := 30;
    btnChannelEdit.Caption := '...';
    btnChannelEdit.Hint := 'РќР°СЃС‚СЂРѕРёС‚СЊ РІС‹Р±СЂР°РЅРЅС‹Р№ РєР°РЅР°Р»';
    btnChannelEdit.ShowHint := True;
    btnChannelEdit.OnClick := @btnChannelEditClick;
  end;

  if FindComponent('btnWorkDirBrowse') is TButton then
    TButton(FindComponent('btnWorkDirBrowse')).OnClick := @WorkDirBrowseClick;

  if fSelectedChannelsGrid <> nil then
  begin
    fSelectedChannelsGrid.OnDblClick := @fSelectedChannelsGridDblClick;
    fSelectedChannelsGrid.OnMouseDown := @fSelectedChannelsGridMouseDown;
    fSelectedChannelsGrid.OnMouseMove := @fSelectedChannelsGridMouseMove;
    fSelectedChannelsGrid.OnMouseUp := @fSelectedChannelsGridMouseUp;
    fSelectedChannelsGrid.OnPaint := @GridPaint;
    fSelectedChannelsGrid.DragMode := dmManual;
  end;

  if fAvailableChannelsGrid <> nil then
  begin
    fAvailableChannelsGrid.OnMouseMove := @fSelectedChannelsGridMouseMove;
    fAvailableChannelsGrid.OnMouseUp := @fSelectedChannelsGridMouseUp;
    fAvailableChannelsGrid.OnPaint := @GridPaint;
    fAvailableChannelsGrid.DragMode := dmManual;
  end;
  if fAlgorithmsTree <> nil then
  begin
    fAlgorithmsTree.Images := fDeviceImageList;
    fAlgorithmsTree.ImagesWidth := 16;
  end;
  if fAlgorithmsTree <> nil then
  begin
    fAlgorithmsTree.Options := fAlgorithmsTree.Options + [tvoAllowMultiselect];
    fAlgorithmsTree.OnKeyDown := @fAlgorithmsTreeKeyDown;
  end;
  if fAlgorithmWindowCombo <> nil then
    fAlgorithmWindowCombo.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmZeroPadCheck <> nil then
    fAlgorithmZeroPadCheck.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmIntegrationGroup <> nil then
    fAlgorithmIntegrationGroup.OnClick := @fAlgorithmFftParamChange;
  if Cfg <> nil then
    Cfg.OnKeyDown := @fCfgKeyDown;
  if fAlgorithmFftSizeEdit <> nil then
    fAlgorithmFftSizeEdit.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmSampleRateEdit <> nil then
    fAlgorithmSampleRateEdit.OnChange := @fAlgorithmFftParamChange;
  if fAlgorithmOverlapCombo <> nil then
    fAlgorithmOverlapCombo.OnChange := @fAlgorithmOverlapComboChange;
  if fAlgorithmAhCorrectionCheck <> nil then
    fAlgorithmAhCorrectionCheck.OnChange := @fAlgorithmAhCorrectionCheckChange;

  SetGridHeaders;
  InitializeAlgorithmControls;
  InitializeHardwareTree;
  UpdateConditionControls;
end;

destructor TRecorderSettingsDialog.Destroy;
begin
  ClearMeraSignals;
  fFrequencyBands.Free;
  fSpectrumConfigTree.Free;
  fSelectedChannelTags.Free;
  fMeraSignals.Free;
  inherited Destroy;
end;

procedure TRecorderSettingsDialog.SetRunSettings(AValue: TRecorderRunControlSettings);
begin
  fRunSettings := AValue;
  LoadFromSettings;
end;

procedure TRecorderSettingsDialog.SetTagRegistry(AValue: TRecorderTagRegistry);
begin
  fTagRegistry := AValue;
  RestoreMeraSignalsFromTags;
end;

procedure TRecorderSettingsDialog.SetDeviceImageList(AValue: TCustomImageList);
begin
  fDeviceImageList := AValue;
  if fHardwareTree <> nil then
  begin
    fHardwareTree.Images := fDeviceImageList;
    fHardwareTree.ImagesWidth := 16;
  end;
  if fAlgorithmsTree <> nil then
  begin
    fAlgorithmsTree.Images := fDeviceImageList;
    fAlgorithmsTree.ImagesWidth := 16;
  end;
  SetDialogButtonImages;
end;

{ РќР°СЃС‚СЂРѕР№РєР° РёРєРѕРЅРѕРє РєРЅРѕРїРѕРє РЅР° РїР°РЅРµР»Рё РґРµСЂРµРІР° СѓСЃС‚СЂРѕР№СЃС‚РІ }
procedure TRecorderSettingsDialog.SetDialogButtonImages;
var
  lButton: TComponent;
begin
  AssignButtonImage(btnDeviceAdd, fDeviceImageList, CIconAdd);
  AssignButtonImage(btnChannelAdd, fDeviceImageList, CIconRight);
  AssignButtonImage(btnChannelRemove, fDeviceImageList, CIconLeft);
  AssignButtonImage(btnChannelEdit, fDeviceImageList, CIconProperty);

  lButton := FindComponent('btnDeviceDelete');
  if lButton is TBitBtn then
    AssignButtonImage(TBitBtn(lButton), fDeviceImageList, CIconRemove);

  lButton := FindComponent('btnDeviceSetup');
  if lButton is TBitBtn then
    AssignButtonImage(TBitBtn(lButton), fDeviceImageList, CIconProperty);

  lButton := FindComponent('btnDeviceSearch');
  if lButton is TBitBtn then
    AssignButtonImage(TBitBtn(lButton), fDeviceImageList, CIconSearch);
end;

procedure TRecorderSettingsDialog.AddMeraSignal(ASignal: TMeraSignalInfo);
begin
  if fMeraSignals = nil then
    fMeraSignals := TList.Create;
  fMeraSignals.Add(ASignal);
end;

function TRecorderSettingsDialog.CloneMeraSignalForTag(ASignal: TMeraSignalInfo;
  const ATagName: string): TMeraSignalInfo;
begin
  Result := TMeraSignalInfo.Create;
  Result.Name := ATagName;
  Result.Address := ASignal.Address;
  Result.ModuleName := ASignal.ModuleName;
  Result.DataTypeName := ASignal.DataTypeName;
  Result.DataType := ASignal.DataType;
  Result.FrequencyHz := ASignal.FrequencyHz;
  Result.StartSec := ASignal.StartSec;
  Result.UnitsName := ASignal.UnitsName;
  Result.Description := ASignal.Description;
  Result.FileName := ASignal.FileName;
  Result.XFileName := ASignal.XFileName;
  Result.HasXData := ASignal.HasXData;
  Result.Enabled := True;
  Result.Selected := True;
end;
function TRecorderSettingsDialog.MeraSourceId(const AFileName: string): string;
begin
  Result := 'Mera file: ' + AFileName;
end;

{ Copies MERA signal properties into a tag and binds it to the active source. }
procedure TRecorderSettingsDialog.ApplyMeraSignalToTag(ATag: TRecorderTag;
  ASignal: TMeraSignalInfo);
begin
  if (ATag = nil) or (ASignal = nil) then
    Exit;

  ATag.Address := ASignal.Address;
  ATag.UnitName := ASignal.UnitsName;
  ATag.SourceId := MeraSourceId(fMeraFileName);
  ATag.ModuleType := ASignal.ModuleName;
  ATag.PollFrequencyHz := ASignal.FrequencyHz;
  ATag.Description := Format('%s; type=%s; freq=%s; file=%s',
    [ASignal.Name, ASignal.DataTypeName, FormatFloat('0.######', ASignal.FrequencyHz),
    ExtractFileName(ASignal.FileName)]);
end;
function TRecorderSettingsDialog.FindTagBySourceAddress(const ASourceId,
  AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  if fTagRegistry = nil then
    Exit;

  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if SameText(lTag.SourceId, ASourceId) and SameText(lTag.Address, AAddress) then
      Exit(lTag);
  end;
end;

function TRecorderSettingsDialog.SignalHasLinkedTag(
  ASignal: TMeraSignalInfo): Boolean;
begin
  Result := (ASignal <> nil) and
    (FindTagBySourceAddress(MeraSourceId(fMeraFileName), ASignal.Address) <> nil);
end;

function TRecorderSettingsDialog.SelectedTagByGridRow(
  ARow: Integer): TRecorderTag;
begin
  Result := nil;
  if (fSelectedChannelTags = nil) or (ARow < 1) or
    (ARow > fSelectedChannelTags.Count) then
    Exit;
  if TObject(fSelectedChannelTags[ARow - 1]) is TRecorderTag then
    Result := TRecorderTag(fSelectedChannelTags[ARow - 1]);
end;

function TRecorderSettingsDialog.CompareTagsForSelectedGrid(ATagA,
  ATagB: TRecorderTag): Integer;
begin
  Result := 0;
  if (ATagA = nil) or (ATagB = nil) then
    Exit;

  case fSelectedSortColumn of
    0:
      Result := CompareText(ATagA.Name, ATagB.Name);
    1:
      begin
        Result := CompareText(ATagA.Address, ATagB.Address);
        if Result = 0 then
          Result := CompareText(ATagA.Name, ATagB.Name);
      end;
    2:
      Result := CompareText(ATagA.ModuleType, ATagB.ModuleType);
    3:
      Result := CompareValue(ATagA.PollFrequencyHz, ATagB.PollFrequencyHz);
    4:
      Result := 0;
    5:
      Result := CompareText(ATagA.SourceId, ATagB.SourceId);
    6:
      Result := CompareText(ATagA.Description, ATagB.Description);
    7:
      Result := CompareValue(ATagA.Id, ATagB.Id);
  else
    Result := CompareText(ATagA.Name, ATagB.Name);
  end;

  if (Result = 0) and (fSelectedSortColumn <> 1) then
  begin
    Result := CompareText(ATagA.Address, ATagB.Address);
    if Result = 0 then
      Result := CompareText(ATagA.Name, ATagB.Name);
  end;

  if not fSelectedSortAscending then
    Result := -Result;
end;

procedure TRecorderSettingsDialog.SortSelectedTags(ATags: TList);
var
  I: Integer;
  J: Integer;
  lTemp: Pointer;
begin
  if ATags = nil then
    Exit;

  for I := 0 to ATags.Count - 2 do
    for J := I + 1 to ATags.Count - 1 do
      if CompareTagsForSelectedGrid(TRecorderTag(ATags[I]),
        TRecorderTag(ATags[J])) > 0 then
      begin
        lTemp := ATags[I];
        ATags[I] := ATags[J];
        ATags[J] := lTemp;
      end;
end;

procedure TRecorderSettingsDialog.SortSelectedChannelsByColumn(AColumn: Integer);
begin
  if AColumn < 0 then
    Exit;

  if fSelectedSortColumn = AColumn then
    fSelectedSortAscending := not fSelectedSortAscending
  else
  begin
    fSelectedSortColumn := AColumn;
    fSelectedSortAscending := True;
  end;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.OpenSelectedChannelTagSettings;
var
  lDialogOk: Boolean;
  lTag: TRecorderTag;
  lTags: TList;
begin
  lTag := SelectedTagByGridRow(fSelectedChannelsGrid.Row);
  if lTag = nil then
    Exit;

  lTags := TList.Create;
  try
    lTags.Add(lTag);
    if fTagDialogImageList <> nil then
      lDialogOk := ShowTagSettingsDialog(Self, fTagRegistry, lTags, fTagDialogImageList)
    else
      lDialogOk := ShowTagSettingsDialog(Self, fTagRegistry, lTags, fDeviceImageList);
    if lDialogOk then
    begin
      MarkSignalsFromRegistry;
      PopulateHardwareTree;
      PopulateChannelGrids;
    end;
  finally
    lTags.Free;
  end;
end;

function TRecorderSettingsDialog.SelectedSpectrumConfigNode: TRecorderSpectrumConfigNode;
var
  lNode: TTreeNode;
begin
  Result := nil;
  if fAlgorithmsTree = nil then
    Exit;
  lNode := fAlgorithmsTree.Selected;
  while lNode <> nil do
  begin
    if TObject(lNode.Data) is TRecorderSpectrumConfigNode then
      Exit(TRecorderSpectrumConfigNode(lNode.Data));
    lNode := lNode.Parent;
  end;
end;

function TRecorderSettingsDialog.CreateSpectrumConfigNode(
  ATag: TRecorderTag): TRecorderSpectrumConfigNode;
var
  lSettings: TRecorderSpectrumSettings;
begin
  Result := fSpectrumConfigTree.AddNode('spectrum.' +
    IntToStr(fSpectrumConfigTree.NodeCount + 1),
    'РЎРїРµРєС‚СЂ ' + IntToStr(fSpectrumConfigTree.NodeCount + 1));
  lSettings := Result.Settings;
  if (ATag <> nil) and (ATag.PollFrequencyHz > 0) then
    lSettings.SampleRateHz := ATag.PollFrequencyHz;
  Result.Settings := lSettings;
end;

procedure TRecorderSettingsDialog.AddSpectrumAlgorithmForTag(ATag: TRecorderTag;
  ATargetNode: TRecorderSpectrumConfigNode);
var
  I: Integer;
  lNode: TRecorderSpectrumConfigNode;
  lBinding: TRecorderSpectrumTagBinding;
begin
  if ATag = nil then
    Exit;

  lNode := ATargetNode;
  if lNode = nil then
    lNode := CreateSpectrumConfigNode(ATag);

  for I := 0 to lNode.BindingCount - 1 do
    if SameText(lNode.Bindings[I].SourceTagName, ATag.Name) then
      Exit;

  lBinding := lNode.AddBinding(ATag.Name);
  lBinding.OutputPrefix := ATag.Name + '_spm';
end;

procedure TRecorderSettingsDialog.AddSpectrumAlgorithmsFromSelectedChannels;
var
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
  lTag: TRecorderTag;
  lTargetNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
begin
  if (fSelectedChannelsGrid = nil) or (fAlgorithmKindCombo = nil) then
    Exit;
  if fAlgorithmKindCombo.ItemIndex < 0 then
    fAlgorithmKindCombo.ItemIndex := 0;
  if fAlgorithmKindCombo.Text <> 'РЎРїРµРєС‚СЂ' then
    Exit;

  lSelection := fSelectedChannelsGrid.Selection;
  lTop := lSelection.Top;
  lBottom := lSelection.Bottom;
  if lTop > lBottom then
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;

  lTargetNode := SelectedSpectrumConfigNode;
  if lTargetNode = nil then
    lTargetNode := CreateSpectrumConfigNode(nil);

  for lRow := lTop to lBottom do
  begin
    lTag := SelectedTagByGridRow(lRow);
    if lTag <> nil then
    begin
      if (lTargetNode.Settings.SampleRateHz <= 0) and (lTag.PollFrequencyHz > 0) then
      begin
        lSettings := lTargetNode.Settings;
        lSettings.SampleRateHz := lTag.PollFrequencyHz;
        lTargetNode.Settings := lSettings;
      end;
      AddSpectrumAlgorithmForTag(lTag, lTargetNode);
    end;
  end;
  PopulateAlgorithmsTree;
  LoadSelectedAlgorithmSettings;
end;

procedure TRecorderSettingsDialog.InitializeAlgorithmControls;
begin
  if fAlgorithmKindCombo <> nil then
  begin
    fAlgorithmKindCombo.Items.Clear;
    fAlgorithmKindCombo.Items.Add('РЎРїРµРєС‚СЂ');
    fAlgorithmKindCombo.ItemIndex := 0;
  end;
  if fAlgorithmWindowCombo <> nil then
  begin
    fAlgorithmWindowCombo.Items.Clear;
    fAlgorithmWindowCombo.Items.Add('Rect');
    fAlgorithmWindowCombo.Items.Add('Hann');
    fAlgorithmWindowCombo.Items.Add('Hamming');
    fAlgorithmWindowCombo.Items.Add('Blackman');
    fAlgorithmWindowCombo.Items.Add('FlatTop');
    fAlgorithmWindowCombo.ItemIndex := Ord(swkHann);
  end;
  if fAlgorithmOverlapCombo <> nil then
  begin
    fAlgorithmOverlapCombo.Items.Clear;
    fAlgorithmOverlapCombo.Items.Add(RecorderSpectrumOverlapName(somNone));
    fAlgorithmOverlapCombo.Items.Add(RecorderSpectrumOverlapName(somHalf));
    fAlgorithmOverlapCombo.Items.Add(RecorderSpectrumOverlapName(somQuarter));
    fAlgorithmOverlapCombo.ItemIndex := Ord(somNone);
  end;
  if fAlgorithmIntegrationGroup <> nil then
  begin
    fAlgorithmIntegrationGroup.Items.Clear;
    fAlgorithmIntegrationGroup.Items.Add(RecorderSpectrumIntegrationName(simNone));
    fAlgorithmIntegrationGroup.Items.Add(RecorderSpectrumIntegrationName(simSingle));
    fAlgorithmIntegrationGroup.Items.Add(RecorderSpectrumIntegrationName(simDouble));
    fAlgorithmIntegrationGroup.ItemIndex := Ord(simNone);
  end;
  if fAlgorithmNormalizeCombo <> nil then
  begin
    fAlgorithmNormalizeCombo.Visible := False;
    fAlgorithmNormalizeCombo.ItemIndex := Ord(snmNone);
  end;
  PopulateAlgorithmsTree;
end;

procedure TRecorderSettingsDialog.PopulateAlgorithmsTree;
var
  I: Integer;
  J: Integer;
  lRoot: TTreeNode;
  lNode: TRecorderSpectrumConfigNode;
  lConfigTreeNode: TTreeNode;
  lBinding: TRecorderSpectrumTagBinding;
begin
  if fAlgorithmsTree = nil then
    Exit;

  fAlgorithmsTree.Items.BeginUpdate;
  try
    fAlgorithmsTree.Items.Clear;
    lRoot := fAlgorithmsTree.Items.Add(nil, 'РђР»РіРѕСЂРёС‚РјС‹');
    lRoot.Data := nil;
    for I := 0 to fSpectrumConfigTree.NodeCount - 1 do
    begin
      lNode := fSpectrumConfigTree.Nodes[I];
      lConfigTreeNode := fAlgorithmsTree.Items.AddChild(lRoot,
        lNode.DisplayName);
      lConfigTreeNode.Data := lNode;
      lConfigTreeNode.ImageIndex := CIconSpectrum;
      lConfigTreeNode.SelectedIndex := CIconSpectrum;
      for J := 0 to lNode.BindingCount - 1 do
      begin
        lBinding := lNode.Bindings[J];
        with fAlgorithmsTree.Items.AddChild(lConfigTreeNode,
          lBinding.SourceTagName + ' -> ' + lBinding.OutputPrefix) do
          Data := lBinding;
      end;
      lConfigTreeNode.Expand(True);
    end;
    lRoot.Expand(True);
    if fAlgorithmsTree.Selected = nil then
      fAlgorithmsTree.Selected := lRoot;
  finally
    fAlgorithmsTree.Items.EndUpdate;
  end;
end;

procedure TRecorderSettingsDialog.LoadSelectedAlgorithmSettings;
var
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;
  lSettings := lNode.Settings;
  if fAlgorithmFftSizeEdit <> nil then
    fAlgorithmFftSizeEdit.Text := IntToStr(lSettings.FFTSize);
  if fAlgorithmSampleRateEdit <> nil then
    fAlgorithmSampleRateEdit.Text := FormatFloat('0.###', lSettings.SampleRateHz);
  if fAlgorithmAverageBlocksEdit <> nil then
    fAlgorithmAverageBlocksEdit.Text := IntToStr(lSettings.AverageBlockCount);
  if fAlgorithmOverlapEdit <> nil then
    fAlgorithmOverlapEdit.Text := IntToStr(lSettings.Overlap);
  if fAlgorithmOverlapCombo <> nil then
    fAlgorithmOverlapCombo.ItemIndex := Ord(lSettings.OverlapMode);
  if fAlgorithmWindowCombo <> nil then
    fAlgorithmWindowCombo.ItemIndex := Ord(lSettings.WindowKind);
  if fAlgorithmZeroPadCheck <> nil then
    fAlgorithmZeroPadCheck.Checked := lSettings.ZeroPad;
  if fAlgorithmAhCorrectionCheck <> nil then
    fAlgorithmAhCorrectionCheck.Checked := lSettings.AhCorrectionEnabled;
  if fAlgorithmIntegrationGroup <> nil then
    fAlgorithmIntegrationGroup.ItemIndex := Ord(lSettings.IntegrationMode);
  if Cfg <> nil then
    Cfg.Text := lSettings.AsString;
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.StoreSelectedAlgorithmSettings;
var
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;

  lSettings := lNode.Settings;
  if (Cfg <> nil) and (Cfg.Text <> '') then
  begin
    try
      lSettings.FromString(Cfg.Text);
      lSettings.Validate;
      lNode.Settings := lSettings;
      LoadSelectedAlgorithmSettings;
      Exit;
    except
      // Ignore parsing error and read from input controls
    end;
  end;

  lSettings := GetSettingsFromControls(lSettings);
  lSettings.Validate;
  lNode.Settings := lSettings;
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.UpdateAlgorithmDerivedControls;
var
  lFftSize: Integer;
  lSampleRate: Double;
  lPortionSec: Double;
begin
  if fAlgorithmPortionLabel = nil then
    Exit;
  lFftSize := 0;
  lSampleRate := 0.0;
  if fAlgorithmFftSizeEdit <> nil then
    TryStrToInt(Trim(fAlgorithmFftSizeEdit.Text), lFftSize);
  if fAlgorithmSampleRateEdit <> nil then
    lSampleRate := ReadFloatEdit(fAlgorithmSampleRateEdit, 0.0);

  if (lFftSize > 0) and (lSampleRate > 0.0) then
  begin
    lPortionSec := lFftSize / lSampleRate;
    fAlgorithmPortionLabel.Caption := 'РїРѕСЂС†РёСЏ: ' +
      FormatFloat('0.###', lPortionSec) + ' СЃ';
  end
  else
    fAlgorithmPortionLabel.Caption := 'РїРѕСЂС†РёСЏ: - СЃ';

  UpdateConfigStr;
end;

procedure TRecorderSettingsDialog.DeleteSelectedAlgorithms;
var
  lNodeList: TList;
  lSelectedNode: TTreeNode;
  lObj: TObject;
  lBinding: TRecorderSpectrumTagBinding;
  lParentNode: TRecorderSpectrumConfigNode;
  I, J: Integer;
begin
  if (fAlgorithmsTree = nil) or (fAlgorithmsTree.SelectionCount = 0) then
    Exit;

  lNodeList := TList.Create;
  try
    for I := 0 to fAlgorithmsTree.SelectionCount - 1 do
      lNodeList.Add(fAlgorithmsTree.Selections[I]);

    fAlgorithmsTree.Items.BeginUpdate;
    try
      // First delete channel bindings (TRecorderSpectrumTagBinding)
      for I := 0 to lNodeList.Count - 1 do
      begin
        lSelectedNode := TTreeNode(lNodeList[I]);
        if lSelectedNode.Data = nil then
          Continue;
        lObj := TObject(lSelectedNode.Data);
        if lObj is TRecorderSpectrumTagBinding then
        begin
          lBinding := TRecorderSpectrumTagBinding(lObj);
          lParentNode := nil;
          if (lSelectedNode.Parent <> nil) and (TObject(lSelectedNode.Parent.Data) is TRecorderSpectrumConfigNode) then
            lParentNode := TRecorderSpectrumConfigNode(lSelectedNode.Parent.Data);

          if lParentNode <> nil then
          begin
            for J := lParentNode.BindingCount - 1 downto 0 do
              if lParentNode.Bindings[J] = lBinding then
              begin
                lParentNode.DeleteBinding(J);
                Break;
              end;
          end;
        end;
      end;

      // Then delete algorithms themselves (TRecorderSpectrumConfigNode)
      for I := 0 to lNodeList.Count - 1 do
      begin
        lSelectedNode := TTreeNode(lNodeList[I]);
        if lSelectedNode.Data = nil then
          Continue;
        lObj := TObject(lSelectedNode.Data);
        if lObj is TRecorderSpectrumConfigNode then
        begin
          for J := fSpectrumConfigTree.NodeCount - 1 downto 0 do
            if fSpectrumConfigTree.Nodes[J] = lObj then
            begin
              fSpectrumConfigTree.DeleteNode(J);
              Break;
            end;
        end;
      end;
    finally
      fAlgorithmsTree.Items.EndUpdate;
    end;
  finally
    lNodeList.Free;
  end;

  PopulateAlgorithmsTree;
end;

function TRecorderSettingsDialog.GetSettingsFromControls(
  const ACurrent: TRecorderSpectrumSettings): TRecorderSpectrumSettings;
var
  lInt: Integer;
begin
  Result := ACurrent;
  if (fAlgorithmFftSizeEdit <> nil) and
    TryStrToInt(Trim(fAlgorithmFftSizeEdit.Text), lInt) then
    Result.FFTSize := lInt;
  if (fAlgorithmOverlapEdit <> nil) and
    TryStrToInt(Trim(fAlgorithmOverlapEdit.Text), lInt) then
    Result.Overlap := lInt;
  if fAlgorithmSampleRateEdit <> nil then
    Result.SampleRateHz := ReadFloatEdit(fAlgorithmSampleRateEdit, Result.SampleRateHz);
  if (fAlgorithmAverageBlocksEdit <> nil) and
    TryStrToInt(Trim(fAlgorithmAverageBlocksEdit.Text), lInt) then
    Result.AverageBlockCount := lInt;
  if (fAlgorithmOverlapCombo <> nil) and (fAlgorithmOverlapCombo.ItemIndex >= 0) then
    Result.OverlapMode := TRecorderSpectrumOverlapMode(fAlgorithmOverlapCombo.ItemIndex);
  if (fAlgorithmWindowCombo <> nil) and (fAlgorithmWindowCombo.ItemIndex >= 0) then
    Result.WindowKind := TRecorderSpectrumWindowKind(fAlgorithmWindowCombo.ItemIndex);
  if fAlgorithmZeroPadCheck <> nil then
    Result.ZeroPad := fAlgorithmZeroPadCheck.Checked;
  if fAlgorithmAhCorrectionCheck <> nil then
    Result.AhCorrectionEnabled := fAlgorithmAhCorrectionCheck.Checked;
  if (fAlgorithmIntegrationGroup <> nil) and
    (fAlgorithmIntegrationGroup.ItemIndex >= 0) then
    Result.IntegrationMode := TRecorderSpectrumIntegrationMode(fAlgorithmIntegrationGroup.ItemIndex);
  Result.NormalizeMode := snmNone;
end;

procedure TRecorderSettingsDialog.UpdateConfigStr;
var
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
begin
  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;
  lSettings := GetSettingsFromControls(lNode.Settings);
  if Cfg <> nil then
    Cfg.Text := lSettings.AsString;
end;

procedure TRecorderSettingsDialog.fAlgorithmsTreeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    DeleteSelectedAlgorithms;
    Key := 0;
  end;
end;

procedure TRecorderSettingsDialog.fCfgKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    btnAlgorithmConfigClick(Sender);
    Key := 0;
  end;
end;

procedure TRecorderSettingsDialog.fAlgorithmFftSizeUpDownClick(Sender: TObject; Button: TUDBtnType);
  function NextPowerOfTwo(AValue: Integer): Integer;
  begin
    Result := 1;
    while Result <= AValue do
      Result := Result * 2;
  end;
  function PreviousPowerOfTwo(AValue: Integer): Integer;
  begin
    if AValue <= 2 then
    begin
      Result := 2;
      Exit;
    end;
    Result := 1;
    while Result < AValue do
      Result := Result * 2;
    Result := Result div 2;
  end;
  function IsPowerOfTwoVal(AValue: Integer): Boolean;
  begin
    Result := (AValue > 0) and ((AValue and (AValue - 1)) = 0);
  end;
var
  lVal: Integer;
begin
  if fAlgorithmFftSizeEdit = nil then
    Exit;

  if not TryStrToInt(Trim(fAlgorithmFftSizeEdit.Text), lVal) then
    lVal := 8192;

  if lVal < 2 then
    lVal := 2;

  if Button = btNext then
  begin
    if lVal < 1048576 then
    begin
      if not IsPowerOfTwoVal(lVal) then
        lVal := NextPowerOfTwo(lVal)
      else
        lVal := lVal * 2;
    end;
  end
  else
  begin
    if lVal > 2 then
    begin
      if not IsPowerOfTwoVal(lVal) then
        lVal := PreviousPowerOfTwo(lVal)
      else
        lVal := lVal div 2;
    end;
  end;

  fAlgorithmFftSizeEdit.Text := IntToStr(lVal);
  fAlgorithmFftParamChange(fAlgorithmFftSizeEdit);
end;

{ Marks signals already represented in registry. Name matches relink existing tags
  to the freshly reloaded source without creating duplicates. }
procedure TRecorderSettingsDialog.MarkSignalsFromRegistry;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
  lSourceId: string;
begin
  if (fTagRegistry = nil) or (fMeraSignals = nil) then
    Exit;

  lSourceId := MeraSourceId(fMeraFileName);
  if fMeraFileName <> '' then
    fTagRegistry.RegisterActiveSource(lSourceId);

  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    lSignal.Enabled := FindTagBySourceAddress(lSourceId, lSignal.Address) <> nil;
    lSignal.Selected := lSignal.Enabled;
  end;
end;

{ РЎРѕР·РґР°РЅРёРµ РёР»Рё РѕР±РЅРѕРІР»РµРЅРёРµ РєР°РЅР°Р»РѕРІ/С‚РµРіРѕРІ РІ СЂРµРµСЃС‚СЂРµ РЅР° РѕСЃРЅРѕРІРµ РІС‹Р±СЂР°РЅРЅС‹С… СЃРёРіРЅР°Р»РѕРІ Mera-С„Р°Р№Р»Р° }
procedure TRecorderSettingsDialog.CreateSelectedMeraTags;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
  lSourceId: string;
  lTagName: string;
begin
  if (fTagRegistry = nil) or (fMeraSignals = nil) then
    Exit;

  lSourceId := MeraSourceId(fMeraFileName);
  if fMeraFileName <> '' then
    fTagRegistry.RegisterActiveSource(lSourceId);

  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    if not lSignal.Selected then
      Continue;

    lTag := FindTagBySourceAddress(lSourceId, lSignal.Address);
    if lTag = nil then
    begin
      lTagName := MeraSignalToRecorderTagName(lSignal);
      lTag := fTagRegistry.FindByName(lTagName);
      if lTag = nil then
        lTag := fTagRegistry.CreateTag(lTagName, 4096);
    end;

    ApplyMeraSignalToTag(lTag, lSignal);
  end;
end;

procedure TRecorderSettingsDialog.ClearMeraSignals;
begin
  uMeraFile.ClearMeraSignals(fMeraSignals);
end;
procedure TRecorderSettingsDialog.RestoreMeraSignalsFromTags;
const
  CMeraSourcePrefix = 'Mera file: ';
var
  I: Integer;
  lFileName: string;
  lSignal: TMeraSignalInfo;
  lTag: TRecorderTag;
begin
  if (fTagRegistry = nil) or (fMeraSignals = nil) then
    Exit;

  lFileName := '';
  for I := 0 to fTagRegistry.TagCount - 1 do
  begin
    lTag := fTagRegistry.Tags[I];
    if Pos(CMeraSourcePrefix, lTag.SourceId) = 1 then
    begin
      lFileName := Trim(Copy(lTag.SourceId, Length(CMeraSourcePrefix) + 1, MaxInt));
      Break;
    end;
  end;

  if lFileName = '' then
  begin
    PopulateHardwareTree;
    PopulateChannelGrids;
    Exit;
  end;

  fMeraFolder := ExtractFilePath(lFileName);
  fMeraFileName := lFileName;
  if FileExists(lFileName) then
  begin
    LoadMeraSignalsFromFile(lFileName, fMeraSignals);
    MarkSignalsFromRegistry;
  end
  else
    ClearMeraSignals;

  PopulateHardwareTree;
  PopulateChannelGrids;
end;

function TRecorderSettingsDialog.FindMeraSignalByTagName(
  const ATagName: string): TMeraSignalInfo;
var
  I: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if fMeraSignals = nil then
    Exit;

  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    if SameText(MeraSignalToRecorderTagName(lSignal), ATagName) then
      Exit(lSignal);
  end;
end;

{ Р’РѕР·РІСЂР°С‰Р°РµС‚ Mera-СЃРёРіРЅР°Р» РїРѕ СЃС‚СЂРѕРєРµ С‚Р°Р±Р»РёС†С‹ РґРѕСЃС‚СѓРїРЅС‹С… РєР°РЅР°Р»РѕРІ }
function TRecorderSettingsDialog.AvailableSignalByGridRow(ARow: Integer): TMeraSignalInfo;
var
  I: Integer;
  lRow: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if (fMeraSignals = nil) or (ARow < 1) then
    Exit;

  lRow := 0;
  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    if SignalHasLinkedTag(lSignal) then
      Continue;
    Inc(lRow);
    if lRow = ARow then
      Exit(lSignal);
  end;
end;

{ Р’РѕР·РІСЂР°С‰Р°РµС‚ Mera-СЃРёРіРЅР°Р» РїРѕ СЃС‚СЂРѕРєРµ С‚Р°Р±Р»РёС†С‹ РІС‹Р±СЂР°РЅРЅС‹С… РєР°РЅР°Р»РѕРІ }
function TRecorderSettingsDialog.SelectedSignalByGridRow(ARow: Integer): TMeraSignalInfo;
var
  I: Integer;
  lRow: Integer;
  lSignal: TMeraSignalInfo;
begin
  Result := nil;
  if (fMeraSignals = nil) or (ARow < 1) then
    Exit;

  lRow := 0;
  for I := 0 to fMeraSignals.Count - 1 do
  begin
    lSignal := TMeraSignalInfo(fMeraSignals[I]);
    if not SignalHasLinkedTag(lSignal) then
      Continue;
    Inc(lRow);
    if lRow = ARow then
      Exit(lSignal);
  end;
end;

{ Р—Р°РіСЂСѓР·РєР° РёРЅС„РѕСЂРјР°С†РёРё Рѕ СЃРёРіРЅР°Р»Р°С… РёР· РІС‹Р±СЂР°РЅРЅРѕРіРѕ С„Р°Р№Р»Р° Mera }
procedure TRecorderSettingsDialog.LoadMeraFile(const AFileName: string);
begin
  fMeraFolder := ExtractFilePath(AFileName);
  fMeraFileName := AFileName;
  LoadMeraSignalsFromFile(AFileName, fMeraSignals);
  if fTagRegistry <> nil then
    fTagRegistry.RegisterActiveSource(MeraSourceId(fMeraFileName));
  MarkSignalsFromRegistry;

  PopulateHardwareTree;
  PopulateChannelGrids;
end;

{ РћР±РЅРѕРІР»РµРЅРёРµ РґРµСЂРµРІР° Р°РїРїР°СЂР°С‚РЅРѕР№ С‡Р°СЃС‚Рё РїСЂРё Р·Р°РіСЂСѓР·РєРµ С„Р°Р№Р»РѕРІ Mera }
procedure TRecorderSettingsDialog.DeleteCurrentMeraSource;
var
  I: Integer;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  if fMeraFileName = '' then
    Exit;

  if MessageDlg('РЈРґР°Р»РµРЅРёРµ РёСЃС‚РѕС‡РЅРёРєР° РґР°РЅРЅС‹С…',
    'РЈРґР°Р»РёС‚СЊ РёСЃС‚РѕС‡РЅРёРє РґР°РЅРЅС‹С… "' + ExtractFileName(fMeraFileName) + '"?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  lSourceId := MeraSourceId(fMeraFileName);
  if fTagRegistry <> nil then
  begin
    fTagRegistry.UnregisterActiveSource(lSourceId);
    for I := 0 to fTagRegistry.TagCount - 1 do
    begin
      lTag := fTagRegistry.Tags[I];
      if SameText(lTag.SourceId, lSourceId) then
        lTag.SourceId := 'Detached: ' + lSourceId;
    end;
  end;

  fMeraFileName := '';
  fMeraFolder := '';
  ClearMeraSignals;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.ReloadCurrentMeraSource;
begin
  if fMeraFileName = '' then
    Exit;
  if not FileExists(fMeraFileName) then
  begin
    MessageDlg('РџРµСЂРµС‡РёС‚С‹РІР°РЅРёРµ РёСЃС‚РѕС‡РЅРёРєР°',
      'Р¤Р°Р№Р» РёСЃС‚РѕС‡РЅРёРєР° РґР°РЅРЅС‹С… РЅРµ РЅР°Р№РґРµРЅ: ' + fMeraFileName,
      mtWarning, [mbOK], 0);
    Exit;
  end;

  LoadMeraSignalsFromFile(fMeraFileName, fMeraSignals);
  MarkSignalsFromRegistry;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.HardwareDeleteSourceClick(Sender: TObject);
begin
  DeleteCurrentMeraSource;
end;

procedure TRecorderSettingsDialog.HardwareReloadSourceClick(Sender: TObject);
begin
  ReloadCurrentMeraSource;
end;

procedure TRecorderSettingsDialog.HardwareEditSourceClick(Sender: TObject);
var
  lDialog: TOpenDialog;
  lOldSourceId, lNewSourceId: string;
  I: Integer;
  lTag: TRecorderTag;
begin
  if fMeraFileName = '' then
    Exit;

  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Р’С‹Р±РµСЂРёС‚Рµ С„Р°Р№Р» Mera';
    lDialog.Filter := 'Mera file (*.mera)|*.mera|All files (*.*)|*.*';
    lDialog.InitialDir := ExtractFilePath(fMeraFileName);
    lDialog.FileName := ExtractFileName(fMeraFileName);
    if lDialog.Execute then
    begin
      lOldSourceId := MeraSourceId(fMeraFileName);
      fMeraFileName := lDialog.FileName;
      fMeraFolder := ExtractFilePath(lDialog.FileName);
      lNewSourceId := MeraSourceId(fMeraFileName);

      if fTagRegistry <> nil then
      begin
        fTagRegistry.RegisterActiveSource(lNewSourceId);
        for I := 0 to fTagRegistry.TagCount - 1 do
        begin
          lTag := fTagRegistry.Tags[I];
          if SameText(lTag.SourceId, lOldSourceId) then
            lTag.SourceId := lNewSourceId;
        end;
      end;

      if FileExists(fMeraFileName) then
      begin
        LoadMeraSignalsFromFile(fMeraFileName, fMeraSignals);
        MarkSignalsFromRegistry;
      end
      else
        ClearMeraSignals;

      PopulateHardwareTree;
      PopulateChannelGrids;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TRecorderSettingsDialog.PopulateHardwareTree;
var
  lRootNode: TTreeNode;
  lSourceNode: TTreeNode;
  I: Integer;
  lSignal: TMeraSignalInfo;
begin
  if fHardwareTree = nil then
    Exit;

  fHardwareTree.Items.BeginUpdate;
  try
    fHardwareTree.Items.Clear;
    lRootNode := fHardwareTree.Items.Add(nil, 'РЈСЃС‚СЂРѕР№СЃС‚РІР°');
    lRootNode.ImageIndex := CDeviceRootImageIndex;
    lRootNode.SelectedIndex := CDeviceRootImageIndex;

    if fMeraFileName <> '' then
    begin
      lSourceNode := fHardwareTree.Items.AddChild(lRootNode,
        'Mera File - ' + ExtractFileName(fMeraFileName));
      if FileExists(fMeraFileName) then
      begin
        lSourceNode.ImageIndex := CDeviceControllerImageIndex;
        lSourceNode.SelectedIndex := CDeviceControllerImageIndex;
      end
      else
      begin
        lSourceNode.ImageIndex := 31;
        lSourceNode.SelectedIndex := 31;
      end;

      for I := 0 to fMeraSignals.Count - 1 do
      begin
        lSignal := TMeraSignalInfo(fMeraSignals[I]);
        if lSignal.Enabled then
          with fHardwareTree.Items.AddChild(lSourceNode, '[x] ' + lSignal.Name) do
          begin
            ImageIndex := CDeviceModuleImageIndex;
            SelectedIndex := CDeviceModuleImageIndex;
            Data := lSignal;
          end
        else
          with fHardwareTree.Items.AddChild(lSourceNode, '[ ] ' + lSignal.Name) do
        begin
          ImageIndex := CDeviceModuleImageIndex;
          SelectedIndex := CDeviceModuleImageIndex;
          Data := lSignal;
        end;
      end;
      lSourceNode.Expand(True);
    end;

    lRootNode.Expand(True);
  finally
    fHardwareTree.Items.EndUpdate;
  end;
end;

{ РЈСЃС‚Р°РЅРѕРІРєР° Р·Р°РіРѕР»РѕРІРєРѕРІ СЃРµС‚РѕРє РєР°РЅР°Р»РѕРІ }
procedure TRecorderSettingsDialog.SetGridHeaders;
begin
  if fAvailableChannelsGrid <> nil then
  begin
    fAvailableChannelsGrid.ColCount := 3;
    fAvailableChannelsGrid.FixedRows := 1;
    fAvailableChannelsGrid.RowCount := 2;
    fAvailableChannelsGrid.Cells[0, 0] := 'РђРґСЂРµСЃ';
    fAvailableChannelsGrid.Cells[1, 0] := 'РўРёРї';
    fAvailableChannelsGrid.Cells[2, 0] := 'РРјСЏ';
    fAvailableChannelsGrid.Cells[0, 1] := '';
    fAvailableChannelsGrid.Cells[1, 1] := '';
    fAvailableChannelsGrid.Cells[2, 1] := '';
  end;

  if fSelectedChannelsGrid <> nil then
  begin
    fSelectedChannelsGrid.ColCount := 8;
    fSelectedChannelsGrid.FixedRows := 1;
    fSelectedChannelsGrid.RowCount := 2;
    fSelectedChannelsGrid.Cells[0, 0] := 'РРјСЏ';
    fSelectedChannelsGrid.Cells[1, 0] := 'РђРґСЂРµСЃ';
    fSelectedChannelsGrid.Cells[2, 0] := 'РўРёРї';
    fSelectedChannelsGrid.Cells[3, 0] := 'Р§Р°СЃС‚РѕС‚Р°';
    fSelectedChannelsGrid.Cells[4, 0] := 'Р“РҐ';
    fSelectedChannelsGrid.Cells[5, 0] := 'Р“СЂСѓРїРїР°';
    fSelectedChannelsGrid.Cells[6, 0] := 'РРЅС„РѕСЂРјР°С†РёСЏ';
    fSelectedChannelsGrid.Cells[7, 0] := 'ID';
    fSelectedChannelsGrid.Cells[0, 1] := '';
    fSelectedChannelsGrid.Cells[1, 1] := '';
    fSelectedChannelsGrid.Cells[2, 1] := '';
    fSelectedChannelsGrid.Cells[3, 1] := '';
    fSelectedChannelsGrid.Cells[4, 1] := '';
    fSelectedChannelsGrid.Cells[5, 1] := '';
    fSelectedChannelsGrid.Cells[6, 1] := '';
    fSelectedChannelsGrid.Cells[7, 1] := '';
  end;
end;

{ Р—Р°РїРѕР»РЅРµРЅРёРµ СЃРµС‚РѕРє РґРѕСЃС‚СѓРїРЅС‹С… Рё РІС‹Р±СЂР°РЅРЅС‹С… РєР°РЅР°Р»РѕРІ РЅР° РѕСЃРЅРѕРІРµ fMeraSignals }
procedure TRecorderSettingsDialog.PopulateChannelGrids;
var
  I: Integer;
  lRow: Integer;
  lEnabledCount: Integer;
  lSelectedTags: TList;
  lSignal: TMeraSignalInfo;
  lSourceId: string;
  lTag: TRecorderTag;
begin
  SetGridHeaders;
  lSourceId := MeraSourceId(fMeraFileName);

  if fAvailableChannelsGrid <> nil then
  begin
    lEnabledCount := 0;
    for I := 0 to fMeraSignals.Count - 1 do
      if not SignalHasLinkedTag(TMeraSignalInfo(fMeraSignals[I])) then
        Inc(lEnabledCount);

    if lEnabledCount = 0 then
      fAvailableChannelsGrid.RowCount := 2
    else
      fAvailableChannelsGrid.RowCount := lEnabledCount + 1;
    lRow := 1;
    for I := 0 to fMeraSignals.Count - 1 do
    begin
      lSignal := TMeraSignalInfo(fMeraSignals[I]);
      if SignalHasLinkedTag(lSignal) then
        Continue;
      fAvailableChannelsGrid.Cells[0, lRow] := lSignal.Address;
      fAvailableChannelsGrid.Cells[1, lRow] := lSignal.ModuleName;
      fAvailableChannelsGrid.Cells[2, lRow] := lSignal.Name;
      Inc(lRow);
    end;
  end;

  if fSelectedChannelsGrid <> nil then
  begin
    fSelectedChannelTags.Clear;
    lSelectedTags := TList.Create;
    try
      if fTagRegistry <> nil then
        for I := 0 to fTagRegistry.TagCount - 1 do
        begin
          lTag := fTagRegistry.Tags[I];
          lSelectedTags.Add(lTag);
        end;

      SortSelectedTags(lSelectedTags);

      if lSelectedTags.Count = 0 then
        fSelectedChannelsGrid.RowCount := 2
      else
        fSelectedChannelsGrid.RowCount := lSelectedTags.Count + 1;

      lRow := 1;
      for I := 0 to lSelectedTags.Count - 1 do
      begin
        lTag := TRecorderTag(lSelectedTags[I]);
        fSelectedChannelTags.Add(lTag);
        fSelectedChannelsGrid.Cells[0, lRow] := lTag.Name;
        fSelectedChannelsGrid.Cells[1, lRow] := lTag.Address;
        fSelectedChannelsGrid.Cells[2, lRow] := lTag.ModuleType;
        fSelectedChannelsGrid.Cells[3, lRow] := FormatFloat('0.######', lTag.PollFrequencyHz);
        fSelectedChannelsGrid.Cells[4, lRow] := '-';
        fSelectedChannelsGrid.Cells[5, lRow] := 'Mera File';
        fSelectedChannelsGrid.Cells[6, lRow] := lTag.Description;
        fSelectedChannelsGrid.Cells[7, lRow] := IntToStr(lTag.Id);
        Inc(lRow);
      end;
    finally
      lSelectedTags.Free;
    end;
  end;

  SGChange(fAvailableChannelsGrid);
  SGChange(fSelectedChannelsGrid);
end;

{ РџРµСЂРµРєР»СЋС‡РµРЅРёРµ Р°РєС‚РёРІРЅРѕСЃС‚Рё СЃРёРіРЅР°Р»Р° РїРѕ РґРІРѕР№РЅРѕРјСѓ РєР»РёРєСѓ РІ РґРµСЂРµРІРµ Р°РїРїР°СЂР°С‚РЅС‹С… РјРѕРґСѓР»РµР№ }
procedure TRecorderSettingsDialog.ToggleHardwareSignal(ANode: TTreeNode);
var
  lSignal: TMeraSignalInfo;
begin
  if (ANode = nil) or (ANode.Data = nil) then
    Exit;

  lSignal := TMeraSignalInfo(ANode.Data);
  lSignal.Enabled := not lSignal.Enabled;
  if not lSignal.Enabled then
    lSignal.Selected := False;

  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.InitializeHardwareTree;
var
  lPopup: TPopupMenu;
  lItem: TMenuItem;
begin
  if fHardwareTree = nil then
    Exit;

  fHardwareTree.OnKeyDown := @fHardwareTreeKeyDown;
  if fHardwareTree.PopupMenu = nil then
  begin
    lPopup := TPopupMenu.Create(Self);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'РџРµСЂРµС‡РёС‚Р°С‚СЊ С‚РµРіРё РёСЃС‚РѕС‡РЅРёРєР°';
    lItem.OnClick := @HardwareReloadSourceClick;
    lPopup.Items.Add(lItem);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'РќР°СЃС‚СЂРѕР№РєР° РёСЃС‚РѕС‡РЅРёРєР°...';
    lItem.OnClick := @HardwareEditSourceClick;
    lPopup.Items.Add(lItem);

    lItem := TMenuItem.Create(lPopup);
    lItem.Caption := 'РЈРґР°Р»РёС‚СЊ РёСЃС‚РѕС‡РЅРёРє РґР°РЅРЅС‹С…';
    lItem.OnClick := @HardwareDeleteSourceClick;
    lPopup.Items.Add(lItem);

    fHardwareTree.PopupMenu := lPopup;
  end;

  fHardwareTree.Items.BeginUpdate;
  try
    fHardwareTree.ReadOnly := True;
    fHardwareTree.Options := fHardwareTree.Options + [tvoShowButtons, tvoShowLines, tvoShowRoot];
    fHardwareTree.ImagesWidth := 16;
    PopulateHardwareTree;
  finally
    fHardwareTree.Items.EndUpdate;
  end;
end;

{ Р”РёРЅР°РјРёС‡РµСЃРєРѕРµ СЃРѕР·РґР°РЅРёРµ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊСЃРєРѕРіРѕ РёРЅС‚РµСЂС„РµР№СЃР° }
procedure TRecorderSettingsDialog.BuildUi;
var
  lButtonPanel: TPanel;
  lButton: TButton;
  lTab: TTabSheet;
begin
  Caption := 'РќР°СЃС‚СЂРѕР№РєР°';
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  Width := 890;
  Height := 660;
  Constraints.MinWidth := 760;
  Constraints.MinHeight := 520;

  fPageControl := TPageControl.Create(Self);
  fPageControl.Parent := Self;
  fPageControl.Align := alClient;

  lTab := TTabSheet.Create(Self);
  lTab.PageControl := fPageControl;
  lTab.Caption := 'Р РµРєРѕСЂРґРµСЂ';
  BuildRecorderTab(lTab);

  lTab := TTabSheet.Create(Self);
  lTab.PageControl := fPageControl;
  lTab.Caption := 'РђРїРїР°СЂР°С‚РЅС‹Рµ СЃРІРѕР№СЃС‚РІР°';
  BuildHardwareTab(lTab);

  BuildPlaceholderTab('РљР°РЅР°Р»С‹');
  BuildPlaceholderTab('РџР»Р°РіРёРЅС‹');

  lButtonPanel := TPanel.Create(Self);
  lButtonPanel.Parent := Self;
  lButtonPanel.Align := alBottom;
  lButtonPanel.Height := 42;
  lButtonPanel.BevelOuter := bvNone;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Width := 82;
  lButton.Height := 28;
  lButton.Left := Width - 270;
  lButton.Top := 7;
  lButton.AnchorSideRight.Control := lButtonPanel;
  lButton.AnchorSideRight.Side := asrRight;
  lButton.Anchors := [akTop, akRight];
  lButton.Caption := 'OK';
  lButton.Default := True;
  lButton.OnClick := @OkButtonClick;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Width := 82;
  lButton.Height := 28;
  lButton.Left := Width - 182;
  lButton.Top := 7;
  lButton.AnchorSideRight.Control := lButtonPanel;
  lButton.AnchorSideRight.Side := asrRight;
  lButton.Anchors := [akTop, akRight];
  lButton.Caption := 'Р—Р°РєСЂС‹С‚СЊ';
  lButton.Cancel := True;
  lButton.ModalResult := mrCancel;

  fApplyButton := TButton.Create(Self);
  fApplyButton.Parent := lButtonPanel;
  fApplyButton.Width := 82;
  fApplyButton.Height := 28;
  fApplyButton.Left := Width - 94;
  fApplyButton.Top := 7;
  fApplyButton.AnchorSideRight.Control := lButtonPanel;
  fApplyButton.AnchorSideRight.Side := asrRight;
  fApplyButton.Anchors := [akTop, akRight];
  fApplyButton.Caption := 'РџСЂРёРјРµРЅРёС‚СЊ';
  fApplyButton.OnClick := @ApplyButtonClick;
end;

{ РљРѕРЅСЃС‚СЂСѓРёСЂРѕРІР°РЅРёРµ РІРєР»Р°РґРєРё РѕР±С‰РёС… РЅР°СЃС‚СЂРѕРµРє }
procedure TRecorderSettingsDialog.BuildRecorderTab(ATab: TTabSheet);
var
  lLeftPanel: TPanel;
  lRightPanel: TPanel;
  lGroup: TGroupBox;
  lButton: TButton;
begin
  lLeftPanel := TPanel.Create(Self);
  lLeftPanel.Parent := ATab;
  lLeftPanel.Align := alClient;
  lLeftPanel.BevelOuter := bvNone;

  lRightPanel := TPanel.Create(Self);
  lRightPanel.Parent := ATab;
  lRightPanel.Align := alRight;
  lRightPanel.Width := 230;
  lRightPanel.BevelOuter := bvNone;

  lGroup := AddGroup(Self, lLeftPanel, 8, 8, 210, 82, 'РћС‚РѕР±СЂР°Р¶РµРЅРёРµ');
  AddLabel(Self, lGroup, 10, 22, 'РџРµСЂРёРѕРґ РѕР±РЅРѕРІР»РµРЅРёСЏ');
  fScreenUpdateEdit := AddEdit(Self, lGroup, 126, 18, 56, '0.5');
  AddLabel(Self, lGroup, 186, 22, 'СЃ');

  lGroup := AddGroup(Self, lLeftPanel, 238, 8, 390, 82, 'РЎРёРіРЅР°Р»С‹');
  AddLabel(Self, lGroup, 10, 18, 'Р”Р»РёРЅР° РѕС‚РѕР±СЂР°Р¶Р°РµРјС‹С… РґР°РЅРЅС‹С…');
  fBufferSecondsEdit := AddEdit(Self, lGroup, 190, 14, 64, '1');
  AddLabel(Self, lGroup, 260, 18, 'СЃ');
  AddLabel(Self, lGroup, 10, 40, 'РџРµСЂРёРѕРґ РѕР±РЅРѕРІР»РµРЅРёСЏ РґР°РЅРЅС‹С…');
  fDataUpdateEdit := AddEdit(Self, lGroup, 190, 36, 64, '0.3');
  AddLabel(Self, lGroup, 260, 40, 'СЃ');

  lGroup := AddGroup(Self, lLeftPanel, 8, 102, 620, 78, '');
  AddLabel(Self, lGroup, 10, 18, 'РСЃРїС‹С‚Р°РЅРёРµ');
  fTestNameEdit := AddEdit(Self, lGroup, 130, 14, 470, 'РСЃРїС‹С‚Р°РЅРёРµ');
  AddLabel(Self, lGroup, 10, 42, 'РР·РґРµР»РёРµ');
  fProductNameEdit := AddEdit(Self, lGroup, 130, 42, 470, 'РР·РґРµР»РёРµ');

  lGroup := AddGroup(Self, lLeftPanel, 8, 190, 620, 284, 'Р—Р°РїРёСЃСЊ');
  fModifyNameCheck := AddCheck(Self, lGroup, 12, 22,
    'РњРѕРґРёС„РёС†РёСЂРѕРІР°С‚СЊ РёРјСЏ РїРѕ РєР°Р¶РґРѕРјСѓ РёСЃРїС‹С‚Р°РЅРёСЋ');
  fModifyNameCheck.Enabled := False;
  fPrehistoryCheck := AddCheck(Self, lGroup, 12, 48, 'РџСЂРµРґС‹СЃС‚РѕСЂРёСЏ');
  fPrehistoryEdit := AddEdit(Self, lGroup, 130, 44, 68, '10');
  AddLabel(Self, lGroup, 206, 48, 'СЃРµРє');
  fResetTimeCheck := AddCheck(Self, lGroup, 12, 74,
    'РЎР±СЂРѕСЃ РІСЂРµРјРµРЅРё РїСЂРё РЅР°С‡Р°Р»Рµ Р·Р°РїРёСЃРё');
  fWriteWithPausesCheck := AddCheck(Self, lGroup, 12, 100, 'Р—Р°РїРёСЃСЊ СЃ РїР°СѓР·Р°РјРё');
  fSaveConfigWithDataCheck := AddCheck(Self, lGroup, 12, 126,
    'РЎРѕС…СЂР°РЅСЏС‚СЊ С„Р°Р№Р» РєРѕРЅС„РёРіСѓСЂР°С†РёРё РІРјРµСЃС‚Рµ СЃ Р·Р°РїРёСЃСЊСЋ РґР°РЅРЅС‹С…');
  AddLabel(Self, lGroup, 10, 154, 'Р Р°Р±РѕС‡РёР№ РєР°С‚Р°Р»РѕРі');
  fWorkDirEdit := AddEdit(Self, lGroup, 10, 172, 526, 'C:\USML\');
  lButton := TButton.Create(Self);
  lButton.Parent := lGroup;
  lButton.Left := 548;
  lButton.Top := 170;
  lButton.Width := 54;
  lButton.Height := 26;
  lButton.Caption := '...';
  lButton.OnClick := @WorkDirBrowseClick;
  fTemplateCheck := AddCheck(Self, lGroup, 12, 204, 'РЁР°Р±Р»РѕРЅ');
  fTemplateButton := TButton.Create(Self);
  fTemplateButton.Parent := lGroup;
  fTemplateButton.Left := 84;
  fTemplateButton.Top := 200;
  fTemplateButton.Width := 86;
  fTemplateButton.Height := 26;
  fTemplateButton.Caption := 'РќР°СЃС‚СЂРѕРёС‚СЊ';
  fTemplateButton.Enabled := False;
  fFrameDirEdit := AddEdit(Self, lGroup, 10, 232, 470, 'C:\USML\signal0000');

  lGroup := AddGroup(Self, lRightPanel, 8, 8, 210, 142, 'РЈСЃР»РѕРІРёСЏ СЃС‚Р°СЂС‚Р° Р·Р°РїРёСЃРё');
  fStartManualRadio := AddRadio(Self, lGroup, 10, 20, 'РџРѕ РєР»Р°РІРёС€Рµ', @ConditionChanged);
  fStartLevelRadio := AddRadio(Self, lGroup, 104, 20, 'РџРѕ СѓСЂРѕРІРЅСЋ', @ConditionChanged);
  fStartTriggerRadio := AddRadio(Self, lGroup, 10, 46, 'РўСЂРёРіРіРµСЂРЅС‹Р№ СЃС‚Р°СЂС‚', @ConditionChanged);
  fStartTriggerEdit := AddEdit(Self, lGroup, 140, 42, 48, '1');
  AddLabel(Self, lGroup, 10, 76, 'РљР°РЅР°Р»');
  fStartChannelCombo := AddCombo(Self, lGroup, 52, 72, 136);
  fStartEdgeCombo := AddCombo(Self, lGroup, 10, 100, 74);
  fStartEdgeCombo.Items.Add('РјРµРЅСЊС€Рµ');
  fStartEdgeCombo.Items.Add('Р±РѕР»СЊС€Рµ');
  fStartLevelEdit := AddEdit(Self, lGroup, 92, 100, 72, '0.0');

  lGroup := AddGroup(Self, lRightPanel, 8, 160, 210, 170, 'РЈСЃР»РѕРІРёСЏ РѕСЃС‚Р°РЅРѕРІР° Р·Р°РїРёСЃРё');
  fStopManualRadio := AddRadio(Self, lGroup, 10, 20, 'РџРѕ РєР»Р°РІРёС€Рµ', @ConditionChanged);
  fStopLevelRadio := AddRadio(Self, lGroup, 104, 20, 'РџРѕ СѓСЂРѕРІРЅСЋ', @ConditionChanged);
  fStopDurationRadio := AddRadio(Self, lGroup, 10, 46, 'Р§РµСЂРµР·', @ConditionChanged);
  fStopDurationEdit := AddEdit(Self, lGroup, 70, 42, 74, '1.000000');
  AddLabel(Self, lGroup, 152, 46, 'СЃРµРє');
  AddLabel(Self, lGroup, 10, 76, 'РљР°РЅР°Р»');
  fStopChannelCombo := AddCombo(Self, lGroup, 52, 72, 136);
  fStopEdgeCombo := AddCombo(Self, lGroup, 10, 100, 74);
  fStopEdgeCombo.Items.Add('РјРµРЅСЊС€Рµ');
  fStopEdgeCombo.Items.Add('Р±РѕР»СЊС€Рµ');
  fStopLevelEdit := AddEdit(Self, lGroup, 92, 100, 72, '0.0');
  fStopReturnToPreviewCheck := AddCheck(Self, lGroup, 10, 126, 'РџРµСЂРµС…РѕРґ РІ РїСЂРѕСЃРјРѕС‚СЂ');
  fStopReturnToPreviewCheck.Enabled := False;

  lButton := TButton.Create(Self);
  lButton.Parent := lRightPanel;
  lButton.Left := 8;
  lButton.Top := 342;
  lButton.Width := 122;
  lButton.Height := 28;
  lButton.Caption := 'РЎРёСЃС‚РµРјРЅРѕРµ РІСЂРµРјСЏ';

  fStartChannelCombo.Items.Add('MemTag');
  fStartChannelCombo.Items.Add('SineTag');
  fStopChannelCombo.Items.Add('MemTag');
  fStopChannelCombo.Items.Add('SineTag');
end;

{ РљРѕРЅСЃС‚СЂСѓРёСЂРѕРІР°РЅРёРµ РІРєР»Р°РґРєРё РґРµСЂРµРІР° РѕР±РѕСЂСѓРґРѕРІР°РЅРёСЏ Рё СѓСЃС‚СЂРѕР№СЃС‚РІ }
procedure TRecorderSettingsDialog.BuildHardwareTab(ATab: TTabSheet);
var
  lGroup: TGroupBox;
  lRootNode: TTreeNode;
  lControllerNode: TTreeNode;
  lButtonPanel: TPanel;
  lButton: TButton;
begin
  lGroup := AddGroup(Self, ATab, 8, 8, 858, 560, 'РЈСЃС‚СЂРѕР№СЃС‚РІР°');
  lGroup.AnchorSideRight.Control := ATab;
  lGroup.AnchorSideRight.Side := asrRight;
  lGroup.AnchorSideBottom.Control := ATab;
  lGroup.AnchorSideBottom.Side := asrBottom;
  lGroup.Anchors := [akLeft, akTop, akRight, akBottom];

  lButtonPanel := TPanel.Create(Self);
  lButtonPanel.Parent := lGroup;
  lButtonPanel.Align := alBottom;
  lButtonPanel.Height := 52;
  lButtonPanel.BevelOuter := bvNone;

  fHardwareTree := TTreeView.Create(Self);
  fHardwareTree.Parent := lGroup;
  fHardwareTree.Align := alClient;
  fHardwareTree.ReadOnly := True;
  fHardwareTree.Images := fDeviceImageList;
  fHardwareTree.OnKeyDown := @fHardwareTreeKeyDown;
  fHardwareTree.Options := fHardwareTree.Options + [tvoShowButtons, tvoShowLines, tvoShowRoot];

  lRootNode := fHardwareTree.Items.Add(nil, 'РЈСЃС‚СЂРѕР№СЃС‚РІР°');
  lRootNode.ImageIndex := CDeviceRootImageIndex;
  lRootNode.SelectedIndex := CDeviceRootImageIndex;
  lControllerNode := fHardwareTree.Items.AddChild(lRootNode,
    '[1] РњРЎ-РљСЂРµР№С‚ - ISA РљСЂРµР№С‚-РєРѕРЅС‚СЂРѕР»Р»РµСЂ s/n: 0000');
  lControllerNode.ImageIndex := CDeviceControllerImageIndex;
  lControllerNode.SelectedIndex := CDeviceControllerImageIndex;
  with fHardwareTree.Items.AddChild(lControllerNode,
    'РЎР»РѕС‚ 1 - MC-212 СЃ/РЅ:00000 - РўРµРЅР·РѕРјРѕРґСѓР»СЊ 4 РєР°РЅР°Р»Р° v4.0-v5.0') do
  begin
    ImageIndex := CDeviceModuleImageIndex;
    SelectedIndex := CDeviceModuleImageIndex;
  end;
  lRootNode.Expand(True);
  lControllerNode.Expand(True);

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Left := 8;
  lButton.Top := 8;
  lButton.Width := 42;
  lButton.Height := 36;
  lButton.Caption := '+';
  lButton.Hint := 'Р”РѕР±Р°РІРёС‚СЊ СѓСЃС‚СЂРѕР№СЃС‚РІРѕ РІСЂСѓС‡РЅСѓСЋ';
  lButton.ShowHint := True;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Left := 62;
  lButton.Top := 8;
  lButton.Width := 42;
  lButton.Height := 36;
  lButton.Caption := '-';
  lButton.Hint := 'РЈРґР°Р»РёС‚СЊ СѓСЃС‚СЂРѕР№СЃС‚РІРѕ РІСЂСѓС‡РЅСѓСЋ';
  lButton.ShowHint := True;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Left := 116;
  lButton.Top := 8;
  lButton.Width := 42;
  lButton.Height := 36;
  lButton.Caption := '...';
  lButton.Hint := 'РќР°СЃС‚СЂРѕРёС‚СЊ РІС‹Р±СЂР°РЅРЅРѕРµ СѓСЃС‚СЂРѕР№СЃС‚РІРѕ';
  lButton.ShowHint := True;

  lButton := TButton.Create(Self);
  lButton.Parent := lButtonPanel;
  lButton.Left := 170;
  lButton.Top := 8;
  lButton.Width := 42;
  lButton.Height := 36;
  lButton.Caption := '?';
  lButton.Hint := 'РђРІС‚РѕРїРѕРёСЃРє РїРѕРґРєР»СЋС‡РµРЅРЅС‹С… СѓСЃС‚СЂРѕР№СЃС‚РІ';
  lButton.ShowHint := True;
end;

{ Р’СЃРїРѕРјРѕРіР°С‚РµР»СЊРЅР°СЏ Р·Р°РіР»СѓС€РєР° РІРєР»Р°РґРєРё РґР»СЏ РµС‰С‘ РЅРµ СЂР°Р·СЂР°Р±РѕС‚Р°РЅРЅС‹С… РєРѕРјРїРѕРЅРµРЅС‚РѕРІ }
procedure TRecorderSettingsDialog.BuildPlaceholderTab(const ACaption: string);
var
  lTab: TTabSheet;
  lLabel: TLabel;
begin
  lTab := TTabSheet.Create(Self);
  lTab.PageControl := fPageControl;
  lTab.Caption := ACaption;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := lTab;
  lLabel.Left := 16;
  lLabel.Top := 16;
  lLabel.Caption := 'Р Р°Р·РґРµР» Р±СѓРґРµС‚ Р·Р°РїРѕР»РЅРµРЅ РїРѕСЃР»Рµ РїРѕСЏРІР»РµРЅРёСЏ СЃРѕРѕС‚РІРµС‚СЃС‚РІСѓСЋС‰РµР№ РјРѕРґРµР»Рё.';
end;

{ Р§С‚РµРЅРёРµ РєРѕРЅС„РёРіСѓСЂР°С†РёРё РёР· РѕР±СЉРµРєС‚Р° TRecorderRunControlSettings РІ UI СЌР»РµРјРµРЅС‚С‹ РґРёР°Р»РѕРіР° }
procedure TRecorderSettingsDialog.LoadFromSettings;
begin
  if fRunSettings = nil then
    Exit;

  fStartManualRadio.Checked := fRunSettings.StartCondition = rscManual;
  fStartLevelRadio.Checked := fRunSettings.StartCondition = rscSignalLevel;
  fStartTriggerRadio.Checked := fRunSettings.StartCondition = rscExternalTrigger;
  fStartChannelCombo.Text := fRunSettings.StartChannelName;
  fStartEdgeCombo.ItemIndex := Ord(fRunSettings.StartEdge);
  fStartLevelEdit.Text := FloatToStr(fRunSettings.StartLevel);

  fStopManualRadio.Checked := fRunSettings.StopCondition = rstopManual;
  fStopLevelRadio.Checked := fRunSettings.StopCondition = rstopSignalLevel;
  fStopDurationRadio.Checked := fRunSettings.StopCondition = rstopDuration;
  fStopDurationEdit.Text := FormatFloat('0.000000', fRunSettings.StopDelayMs / 1000);
  fStopChannelCombo.Text := fRunSettings.StopChannelName;
  fStopEdgeCombo.ItemIndex := Ord(fRunSettings.StopEdge);
  fStopLevelEdit.Text := FloatToStr(fRunSettings.StopLevel);

  if fStartChannelCombo.Text = '' then
    fStartChannelCombo.Text := 'MemTag';
  if fStopChannelCombo.Text = '' then
    fStopChannelCombo.Text := 'MemTag';

  fScreenUpdateEdit.Text := FormatFloat('0.###', fRunSettings.ScreenUpdateMs / 1000);
  fBufferSecondsEdit.Text := FormatFloat('0.###', fRunSettings.DisplayBufferMs / 1000);
  fDataUpdateEdit.Text := FormatFloat('0.###', fRunSettings.DataUpdateMs / 1000);
  fWorkDirEdit.Text := IncludeTrailingPathDelimiter(fRunSettings.RecordRootDir);
  fFrameDirEdit.Text := IncludeTrailingPathDelimiter(fRunSettings.RecordRootDir) + '0001';
  fResetTimeCheck.Checked := True;

  UpdateConditionControls;
end;

{ РџРµСЂРµРЅРѕСЃ РЅР°СЃС‚СЂРѕРµРє РёР· UI РІ РѕР±СЉРµРєС‚ fRunSettings }
procedure TRecorderSettingsDialog.StoreToSettings;
begin
  if fRunSettings = nil then
    Exit;

  if fStartLevelRadio.Checked then
    fRunSettings.StartCondition := rscSignalLevel
  else if fStartTriggerRadio.Checked then
    fRunSettings.StartCondition := rscExternalTrigger
  else
    fRunSettings.StartCondition := rscManual;

  fRunSettings.StartChannelName := fStartChannelCombo.Text;
  fRunSettings.StartEdge := TRecorderSignalEdge(fStartEdgeCombo.ItemIndex);
  fRunSettings.StartLevel := ReadFloatEdit(fStartLevelEdit, fRunSettings.StartLevel);

  if fStopLevelRadio.Checked then
    fRunSettings.StopCondition := rstopSignalLevel
  else if fStopDurationRadio.Checked then
    fRunSettings.StopCondition := rstopDuration
  else
    fRunSettings.StopCondition := rstopManual;

  fRunSettings.StopChannelName := fStopChannelCombo.Text;
  fRunSettings.StopEdge := TRecorderSignalEdge(fStopEdgeCombo.ItemIndex);
  fRunSettings.StopLevel := ReadFloatEdit(fStopLevelEdit, fRunSettings.StopLevel);
  fRunSettings.StopDelayMs := ReadSecondsAsMs(fStopDurationEdit, fRunSettings.StopDelayMs);
  fRunSettings.ScreenUpdateMs := ReadSecondsAsMs(fScreenUpdateEdit,
    fRunSettings.ScreenUpdateMs);
  fRunSettings.DisplayBufferMs := ReadSecondsAsMs(fBufferSecondsEdit,
    fRunSettings.DisplayBufferMs);
  fRunSettings.DataUpdateMs := ReadSecondsAsMs(fDataUpdateEdit,
    fRunSettings.DataUpdateMs);
  fRunSettings.RecordRootDir := IncludeTrailingPathDelimiter(Trim(fWorkDirEdit.Text));
  fRunSettings.RequireValid;
end;

{ Р’РєР»СЋС‡РµРЅРёРµ/РІС‹РєР»СЋС‡РµРЅРёРµ РєРѕРЅС‚СЂРѕР»Р»РµСЂРѕРІ РІ Р·Р°РІРёСЃРёРјРѕСЃС‚Рё РѕС‚ РІС‹Р±СЂР°РЅРЅС‹С… С‚СЂРёРіРіРµСЂРѕРІ СЃС‚Р°СЂС‚Р°/РѕСЃС‚Р°РЅРѕРІР° }
procedure TRecorderSettingsDialog.UpdateConditionControls;
var
  lStartLevel: Boolean;
  lStopLevel: Boolean;
  lStopDuration: Boolean;
begin
  lStartLevel := fStartLevelRadio.Checked;
  fStartChannelCombo.Enabled := lStartLevel;
  fStartEdgeCombo.Enabled := lStartLevel;
  fStartLevelEdit.Enabled := lStartLevel;
  fStartTriggerEdit.Enabled := fStartTriggerRadio.Checked;

  lStopLevel := fStopLevelRadio.Checked;
  lStopDuration := fStopDurationRadio.Checked;
  fStopChannelCombo.Enabled := lStopLevel;
  fStopEdgeCombo.Enabled := lStopLevel;
  fStopLevelEdit.Enabled := lStopLevel;
  fStopDurationEdit.Enabled := lStopDuration;
end;

{ Р‘РµР·РѕРїР°СЃРЅРѕРµ С‡С‚РµРЅРёРµ РІРµС‰РµСЃС‚РІРµРЅРЅРѕРіРѕ С‡РёСЃР»Р° РёР· TEdit СЃ СѓС‡С‘С‚РѕРј Р»РѕРєР°Р»Рё }
function TRecorderSettingsDialog.ReadFloatEdit(AEdit: TEdit; ADefault: Double): Double;
var
  lText: string;
begin
  lText := Trim(AEdit.Text);
  lText := StringReplace(lText, '.', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  lText := StringReplace(lText, ',', DefaultFormatSettings.DecimalSeparator,
    [rfReplaceAll]);
  if not TryStrToFloat(lText, Result) then
    Result := ADefault;
end;

{ Р§С‚РµРЅРёРµ СЃРµРєСѓРЅРґ РёР· UI Рё РїРµСЂРµРІРѕРґ РІ РјРёР»Р»РёСЃРµРєСѓРЅРґС‹ }
function TRecorderSettingsDialog.ReadSecondsAsMs(AEdit: TEdit;
  ADefaultMs: Cardinal): Cardinal;
var
  lSeconds: Double;
begin
  lSeconds := ReadFloatEdit(AEdit, ADefaultMs / 1000);
  if lSeconds < 0 then
    lSeconds := 0;
  Result := Round(lSeconds * 1000);
end;


procedure TRecorderSettingsDialog.WorkDirBrowseClick(Sender: TObject);
var
  lDir: string;
begin
  lDir := Trim(fWorkDirEdit.Text);
  if lDir = '' then
    lDir := 'C:\USML\';
  if not SelectDirectory('Р’С‹Р±РµСЂРёС‚Рµ СЂР°Р±РѕС‡РёР№ РєР°С‚Р°Р»РѕРі РґР»СЏ Р·Р°РїРёСЃРё MERA-С„Р°Р№Р»РѕРІ', '', lDir) then
    Exit;
  fWorkDirEdit.Text := IncludeTrailingPathDelimiter(lDir);
  fFrameDirEdit.Text := IncludeTrailingPathDelimiter(lDir) + '0001';
end;
procedure TRecorderSettingsDialog.ApplyButtonClick(Sender: TObject);
begin
  StoreToSettings;
end;



procedure TRecorderSettingsDialog.OkButtonClick(Sender: TObject);
begin
  StoreToSettings;
  CreateSelectedMeraTags;
  ModalResult := mrOk;
end;

procedure TRecorderSettingsDialog.ConditionChanged(Sender: TObject);
begin
  UpdateConditionControls;
end;

{ Р”РѕР±Р°РІР»РµРЅРёРµ РЅРѕРІРѕРіРѕ СѓСЃС‚СЂРѕР№СЃС‚РІР° РїСѓС‚С‘Рј РёРјРїРѕСЂС‚Р° СЃРёРіРЅР°Р»РѕРІ РёР· С„Р°Р№Р»Р° Mera }
procedure TRecorderSettingsDialog.btnDeviceAddClick(Sender: TObject);
var
  lDialog: TOpenDialog;
begin
  if MessageDlg('Р”РѕР±Р°РІР»РµРЅРёРµ СѓСЃС‚СЂРѕР№СЃС‚РІР°', 'Mera file', mtConfirmation,
    [mbOK, mbCancel], 0) <> mrOk then
    Exit;

  lDialog := TOpenDialog.Create(Self);
  try
    lDialog.Title := 'Mera file';
    lDialog.Filter := 'Mera file (*.mera)|*.mera|All files (*.*)|*.*';
    lDialog.InitialDir := ExtractFilePath(CMeraSampleFile);
    lDialog.FileName := ExtractFileName(CMeraSampleFile);
    if lDialog.Execute then
    begin
      LoadMeraFile(lDialog.FileName);
      if fPageControl <> nil then
        fPageControl.ActivePageIndex := 1;
    end;
  finally
    lDialog.Free;
  end;
end;

{ Р”РѕР±Р°РІР»РµРЅРёРµ РєР°РЅР°Р»РѕРІ РІ Р°РєС‚РёРІРЅС‹Р№ СЃРїРёСЃРѕРє }
procedure TRecorderSettingsDialog.btnChannelAddClick(Sender: TObject);
var
  lSignal: TMeraSignalInfo;
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
begin
  if fAvailableChannelsGrid = nil then
    Exit;

  lSelection := fAvailableChannelsGrid.Selection;
  lTop := lSelection.Top;
  lBottom := lSelection.Bottom;
  if lTop > lBottom then
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;

  for lRow := lBottom downto lTop do
  begin
    lSignal := AvailableSignalByGridRow(lRow);
    if lSignal <> nil then
      lSignal.Selected := True;
  end;
  CreateSelectedMeraTags;
  MarkSignalsFromRegistry;
  PopulateChannelGrids;
end;

{ РСЃРєР»СЋС‡РµРЅРёРµ РєР°РЅР°Р»РѕРІ РёР· Р°РєС‚РёРІРЅРѕРіРѕ СЃРїРёСЃРєР° }
procedure TRecorderSettingsDialog.btnChannelRemoveClick(Sender: TObject);
var
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
  lTag: TRecorderTag;
begin
  if fSelectedChannelsGrid = nil then
    Exit;

  lSelection := fSelectedChannelsGrid.Selection;
  lTop := lSelection.Top;
  lBottom := lSelection.Bottom;
  if lTop > lBottom then
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;

  for lRow := lBottom downto lTop do
  begin
    lTag := SelectedTagByGridRow(lRow);
    if (lTag <> nil) and (fTagRegistry <> nil) then
      fTagRegistry.RemoveTag(lTag);
  end;
  MarkSignalsFromRegistry;
  PopulateHardwareTree;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.fAvailableChannelsGridDblClick(Sender: TObject);
var
  lSignal: TMeraSignalInfo;
begin
  if (fAvailableChannelsGrid = nil) or (fMeraSignals = nil) then
    Exit;

  lSignal := AvailableSignalByGridRow(fAvailableChannelsGrid.Row);
  if lSignal = nil then
    Exit;

  lSignal.Selected := True;
  CreateSelectedMeraTags;
  MarkSignalsFromRegistry;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.btnChannelEditClick(Sender: TObject);
begin
  OpenSelectedChannelTagSettings;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridDblClick(Sender: TObject);
begin
  OpenSelectedChannelTagSettings;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lGrid: TStringGrid;
  lCol: LongInt;
  lRow: LongInt;
begin
  lGrid := TStringGrid(Sender);
  if (Button <> mbLeft) or (lGrid = nil) then
    Exit;

  lGrid.MouseToCell(X, Y, lCol, lRow);
  if lRow = 0 then
  begin
    if lGrid = fSelectedChannelsGrid then
      SortSelectedChannelsByColumn(lCol);
    Exit;
  end;

  if (lRow >= lGrid.Selection.Top) and (lRow <= lGrid.Selection.Bottom) then
  begin
    fCanDrag := True;
    fDragStartPt := Point(X, Y);
    fDragSelectActive := False;
    fSavedSelection := lGrid.Selection;
  end
  else
  begin
    fDragSelectActive := True;
    fDragSelectStart := Point(X, Y);
    fDragSelectEnd := Point(X, Y);
    fSelectingGrid := lGrid;
    fCanDrag := False;
    lGrid.Selection := TGridRect(Rect(0, lRow, lGrid.ColCount - 1, lRow));
  end;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  lGrid: TStringGrid;
  lColStart, lRowStart, lColEnd, lRowEnd: LongInt;
  lTemp: LongInt;
begin
  lGrid := TStringGrid(Sender);
  if fCanDrag and (ssLeft in Shift) then
  begin
    if (Abs(X - fDragStartPt.X) > 5) or (Abs(Y - fDragStartPt.Y) > 5) then
    begin
      fCanDrag := False;
      lGrid.Selection := fSavedSelection;
      lGrid.BeginDrag(False);
    end;
    Exit;
  end;

  if fDragSelectActive and (fSelectingGrid = lGrid) and (ssLeft in Shift) then
  begin
    fDragSelectEnd := Point(X, Y);
    lGrid.Invalidate;

    lGrid.MouseToCell(fDragSelectStart.X, fDragSelectStart.Y, lColStart, lRowStart);
    lGrid.MouseToCell(fDragSelectEnd.X, fDragSelectEnd.Y, lColEnd, lRowEnd);

    if (lRowStart > 0) and (lRowEnd > 0) then
    begin
      if lRowStart > lRowEnd then
      begin
        lTemp := lRowStart;
        lRowStart := lRowEnd;
        lRowEnd := lTemp;
      end;
      if lRowStart < 1 then
        lRowStart := 1;

      lGrid.Selection := TGridRect(Rect(0, lRowStart, lGrid.ColCount - 1, lRowEnd));
    end;
  end;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lGrid: TStringGrid;
begin
  lGrid := TStringGrid(Sender);
  fCanDrag := False;
  if fDragSelectActive and (fSelectingGrid = lGrid) then
  begin
    fDragSelectActive := False;
    lGrid.Invalidate;
  end;
end;

procedure TRecorderSettingsDialog.GridPaint(Sender: TObject);
var
  lGrid: TStringGrid;
  lRect: TRect;
begin
  lGrid := TStringGrid(Sender);
  if fDragSelectActive and (fSelectingGrid = lGrid) then
  begin
    lRect.Left := Min(fDragSelectStart.X, fDragSelectEnd.X);
    lRect.Top := Min(fDragSelectStart.Y, fDragSelectEnd.Y);
    lRect.Right := Max(fDragSelectStart.X, fDragSelectEnd.X);
    lRect.Bottom := Max(fDragSelectStart.Y, fDragSelectEnd.Y);

    lGrid.Canvas.Brush.Style := bsClear;
    lGrid.Canvas.Pen.Color := clHighlight;
    lGrid.Canvas.Pen.Style := psDash;
    lGrid.Canvas.Pen.Width := 1;
    lGrid.Canvas.Rectangle(lRect);
  end;
end;

procedure TRecorderSettingsDialog.fAlgorithmsTreeChange(Sender: TObject;
  Node: TTreeNode);
begin
  LoadSelectedAlgorithmSettings;
end;

procedure TRecorderSettingsDialog.fAlgorithmsTreeDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  lDropNode: TTreeNode;
begin
  if Source = fSelectedChannelsGrid then
  begin
    lDropNode := fAlgorithmsTree.GetNodeAt(X, Y);
    if lDropNode <> nil then
      fAlgorithmsTree.Selected := lDropNode;
    AddSpectrumAlgorithmsFromSelectedChannels;
  end;
end;

procedure TRecorderSettingsDialog.fAlgorithmsTreeDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source = fSelectedChannelsGrid;
end;

procedure TRecorderSettingsDialog.btnAlgorithmAddClick(Sender: TObject);
begin
  AddSpectrumAlgorithmsFromSelectedChannels;
end;

procedure TRecorderSettingsDialog.btnAlgorithmRemoveClick(Sender: TObject);
begin
  DeleteSelectedAlgorithms;
end;

procedure TRecorderSettingsDialog.btnAlgorithmConfigClick(Sender: TObject);
begin
  try
    StoreSelectedAlgorithmSettings;
  except
    on E: Exception do
      MessageDlg('РќР°СЃС‚СЂРѕР№РєР° СЃРїРµРєС‚СЂР°', E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TRecorderSettingsDialog.btnFrequencyBandsClick(Sender: TObject);
begin
  ShowRecorderFrequencyBandsDialog(Self, fFrequencyBands);
end;

procedure TRecorderSettingsDialog.fAlgorithmAhCorrectionCheckChange(
  Sender: TObject);
var
  lNode: TRecorderSpectrumConfigNode;
  lSettings: TRecorderSpectrumSettings;
  lProfile: string;
begin
  if (fAlgorithmAhCorrectionCheck = nil) or
    (not fAlgorithmAhCorrectionCheck.Checked) then
    Exit;

  lNode := SelectedSpectrumConfigNode;
  if lNode = nil then
    Exit;

  lSettings := lNode.Settings;
  lProfile := lSettings.AhCorrectionProfileName;
  if lProfile = '' then
    lProfile := 'default';
  if InputQuery('РљРѕСЂСЂРµРєС†РёСЏ РђР§РҐ', 'РџСЂРѕС„РёР»СЊ РєРѕСЌС„С„РёС†РёРµРЅС‚РѕРІ СЃРїРµРєС‚СЂР°', lProfile) then
  begin
    lSettings.AhCorrectionEnabled := True;
    lSettings.AhCorrectionProfileName := lProfile;
    lNode.Settings := lSettings;
  end
  else
    fAlgorithmAhCorrectionCheck.Checked := lSettings.AhCorrectionEnabled;
end;

procedure TRecorderSettingsDialog.fAlgorithmFftParamChange(Sender: TObject);
begin
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.fAlgorithmOverlapComboChange(Sender: TObject);
var
  lFftSize: Integer;
  lOverlap: Integer;
begin
  if (fAlgorithmOverlapCombo = nil) or (fAlgorithmFftSizeEdit = nil) or
    (fAlgorithmOverlapEdit = nil) then
    Exit;
  if fAlgorithmOverlapCombo.ItemIndex < 0 then
    Exit;
  if not TryStrToInt(Trim(fAlgorithmFftSizeEdit.Text), lFftSize) then
    Exit;

  case TRecorderSpectrumOverlapMode(fAlgorithmOverlapCombo.ItemIndex) of
    somHalf:
      lOverlap := lFftSize div 2;
    somQuarter:
      lOverlap := lFftSize div 4;
  else
    lOverlap := 0;
  end;
  fAlgorithmOverlapEdit.Text := IntToStr(lOverlap);
  UpdateAlgorithmDerivedControls;
end;

procedure TRecorderSettingsDialog.fAvailableChannelsGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fSelectedChannelsGridMouseDown(Sender, Button, Shift, X, Y);
end;

{ Drag and Drop РґРѕСЃС‚СѓРїРЅРѕРіРѕ РєР°РЅР°Р»Р° РІ Р°РєС‚РёРІРЅСѓСЋ СЃРµС‚РєСѓ }
procedure TRecorderSettingsDialog.fSelectedChannelsGridDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  lSignal: TMeraSignalInfo;
  lSelection: TGridRect;
  lRow: Integer;
  lTop: Integer;
  lBottom: Integer;
begin
  if Source <> fAvailableChannelsGrid then
    Exit;

  lSelection := fAvailableChannelsGrid.Selection;
  lTop := lSelection.Top;
  lBottom := lSelection.Bottom;
  if lTop > lBottom then
  begin
    lTop := lSelection.Bottom;
    lBottom := lSelection.Top;
  end;

  for lRow := lBottom downto lTop do
  begin
    lSignal := AvailableSignalByGridRow(lRow);
    if lSignal <> nil then
      lSignal.Selected := True;
  end;
  CreateSelectedMeraTags;
  MarkSignalsFromRegistry;
  PopulateChannelGrids;
end;

procedure TRecorderSettingsDialog.fSelectedChannelsGridDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source = fAvailableChannelsGrid;
end;

{ Р”РІРѕР№РЅРѕР№ РєР»РёРє РЅР° СѓСЃС‚СЂРѕР№СЃС‚РІРµ/РјРѕРґСѓР»Рµ РІ РґРµСЂРµРІРµ РґР»СЏ РёР·РјРµРЅРµРЅРёСЏ РµРіРѕ Р°РєС‚РёРІРЅРѕСЃС‚Рё }
procedure TRecorderSettingsDialog.fHardwareTreeDblClick(Sender: TObject);
begin
  if (fHardwareTree = nil) or (fHardwareTree.Selected = nil) then
    Exit;

  ToggleHardwareSignal(fHardwareTree.Selected);
  if fPageControl <> nil then
    fPageControl.ActivePageIndex := 2;
end;

procedure TRecorderSettingsDialog.fHardwareTreeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_DELETE then
    Exit;

  DeleteCurrentMeraSource;
  Key := 0;
end;

initialization
  RegisterClasses([
    TPageControl, TTabSheet, TPanel, TGroupBox, TLabel, TEdit, TCheckBox,
    TRadioButton, TRadioGroup, TComboBox, TButton, TTreeView, TStringGrid,
    TSplitter
  ]);

end.
