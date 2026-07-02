object ChartCfgForm: TChartCfgForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1075#1088#1072#1092#1080#1082#1072
  ClientHeight = 161
  ClientWidth = 273
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object MainGB: TGroupBox
    Left = 0
    Top = 0
    Width = 273
    Height = 94
    Align = alClient
    Caption = #1054#1090#1086#1073#1088#1072#1078#1077#1085#1080#1077' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1091#1087#1088#1072#1074#1083#1077#1085#1080#1103
    TabOrder = 0
    object ShowTVCheckBox: TCheckBox
      Left = 9
      Top = 24
      Width = 176
      Height = 17
      Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' '#1076#1077#1088#1077#1074#1086' '#1086#1073#1098#1077#1082#1090#1086#1074
      TabOrder = 0
    end
    object ShowLegendCB: TCheckBox
      Left = 9
      Top = 47
      Width = 128
      Height = 17
      Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' '#1083#1077#1075#1077#1085#1076#1091
      TabOrder = 1
    end
  end
  object ActionGB: TGroupBox
    Left = 0
    Top = 94
    Width = 273
    Height = 67
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    DesignSize = (
      273
      67)
    object CancelBtn: TButton
      Left = 9
      Top = 24
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 181
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end
