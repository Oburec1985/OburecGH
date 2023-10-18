object SRSFrm: TSRSFrm
  Left = 0
  Top = 0
  Caption = 'SRSFrm'
  ClientHeight = 551
  ClientWidth = 941
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 17
  object SpmChart: cChart
    Left = 0
    Top = 0
    Width = 768
    Height = 551
    Align = alClient
    Caption = 'cChart1'
    TabOrder = 0
    allowEditPages = False
    showTV = False
    showLegend = False
    selectSize = 5
  end
  object RightGB: TGroupBox
    Left = 768
    Top = 0
    Width = 173
    Height = 551
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
    TabOrder = 1
    object ShockCountLabel: TLabel
      Left = 10
      Top = 27
      Width = 105
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1053#1072#1081#1076#1077#1085#1086' '#1091#1076#1072#1088#1086#1074
    end
    object ShockCountE: TEdit
      Left = 7
      Top = 52
      Width = 158
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 0
    end
    object EvalFRF: TButton
      Left = 7
      Top = 88
      Width = 98
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1056#1072#1089#1095#1077#1090
      TabOrder = 1
    end
  end
end
