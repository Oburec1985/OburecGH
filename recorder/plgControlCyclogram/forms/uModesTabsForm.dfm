object ModesTabForm: TModesTabForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1088#1077#1078#1080#1084#1086#1074
  ClientHeight = 905
  ClientWidth = 983
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object Splitter1: TSplitter
    Left = 0
    Top = 628
    Width = 983
    Height = 2
    Cursor = crVSplit
    Align = alBottom
    Color = clBackground
    ParentColor = False
  end
  object ActionPanel: TPanel
    Left = 0
    Top = 630
    Width = 983
    Height = 275
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    TabOrder = 0
    inline ModesStepFrame1: TModesStepFrame
      Left = 1
      Top = 1
      Width = 981
      Height = 273
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 981
      ExplicitHeight = 273
      inherited ModesSG: TStringGrid
        Width = 981
        Height = 273
        ExplicitWidth = 981
        ExplicitHeight = 273
      end
    end
  end
  inline ModesTabFrame1: TModesTabFrame
    Left = 0
    Top = 0
    Width = 983
    Height = 628
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 983
    ExplicitHeight = 628
    inherited Splitter1: TSplitter
      Top = 301
      Width = 983
      Height = 2
      ExplicitLeft = 0
      ExplicitTop = 301
      ExplicitWidth = 983
      ExplicitHeight = 2
    end
    inherited ModesSG: TStringGrid
      Top = 303
      Width = 983
      Height = 278
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      ExplicitTop = 303
      ExplicitWidth = 983
      ExplicitHeight = 278
    end
    inherited Panel1: TPanel
      Width = 983
      Height = 301
      ExplicitWidth = 983
      ExplicitHeight = 301
    end
    inherited Panel2: TPanel
      Top = 581
      Width = 983
      ExplicitTop = 581
      ExplicitWidth = 983
      inherited Label3: TLabel
        Top = 10
        Width = 29
        Height = 17
        ExplicitTop = 10
        ExplicitWidth = 29
        ExplicitHeight = 17
      end
      inherited Label1: TLabel
        Top = 10
        Width = 13
        Height = 17
        ExplicitTop = 10
        ExplicitWidth = 13
        ExplicitHeight = 17
      end
      inherited Label2: TLabel
        Top = 10
        Height = 17
        ExplicitTop = 10
        ExplicitHeight = 17
      end
      inherited CursorPosY: TFloatSpinEdit
        Left = 449
        Width = 77
        Height = 27
        ExplicitLeft = 449
        ExplicitWidth = 77
        ExplicitHeight = 27
      end
      inherited XFE: TFloatSpinEdit
        Height = 27
        ExplicitHeight = 27
      end
      inherited YFE: TFloatSpinEdit
        Height = 27
        ExplicitHeight = 27
      end
      inherited PointTypeCB: TComboBox
        Left = 258
        Width = 143
        Height = 25
        ExplicitLeft = 258
        ExplicitWidth = 143
        ExplicitHeight = 25
      end
      inherited TaskParamsEdit: TEdit
        Height = 25
        ExplicitHeight = 25
      end
    end
    inherited ImageList_16: TImageList
      Top = 96
    end
  end
end
