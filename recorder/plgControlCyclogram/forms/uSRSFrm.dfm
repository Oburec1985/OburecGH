object SRSFrm: TSRSFrm
  Left = 0
  Top = 0
  Caption = 'SRSFrm'
  ClientHeight = 421
  ClientWidth = 720
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SpmChart: cChart
    Left = 0
    Top = 0
    Width = 587
    Height = 421
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    Caption = 'cChart1'
    TabOrder = 0
    allowEditPages = False
    showTV = False
    showLegend = False
    selectSize = 5
  end
  object RightGB: TGroupBox
    Left = 587
    Top = 0
    Width = 133
    Height = 421
    Align = alRight
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    TabOrder = 1
    object ShockCountLabel: TLabel
      Left = 8
      Top = 21
      Width = 84
      Height = 13
      Caption = #1053#1072#1081#1076#1077#1085#1086' '#1091#1076#1072#1088#1086#1074
    end
    object ShockCountE: TEdit
      Left = 5
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 0
    end
    object EvalFRF: TButton
      Left = 5
      Top = 67
      Width = 75
      Height = 25
      Caption = #1056#1072#1089#1095#1077#1090
      TabOrder = 1
    end
    object SaveBtn: TButton
      Left = 5
      Top = 107
      Width = 75
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 2
      OnClick = SaveBtnClick
    end
  end
end
