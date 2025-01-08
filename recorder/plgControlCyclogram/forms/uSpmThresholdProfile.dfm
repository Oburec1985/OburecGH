object SpmThresholdProfileFrm: TSpmThresholdProfileFrm
  Left = 0
  Top = 0
  Caption = #1055#1088#1086#1092#1080#1083#1100' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
  ClientHeight = 392
  ClientWidth = 643
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PanBottom: TPanel
    Left = 0
    Top = 344
    Width = 643
    Height = 48
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 347
    object UnitsLabel: TLabel
      Left = 201
      Top = 5
      Width = 45
      Height = 13
      Caption = #1045#1076#1080#1085#1080#1094#1099
    end
    object ProfileNameLabel: TLabel
      Left = 3
      Top = 5
      Width = 73
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
    end
    object UnitsCB: TComboBox
      Left = 201
      Top = 20
      Width = 94
      Height = 21
      TabOrder = 0
      Text = '%'
      Items.Strings = (
        '%'
        #1044#1073', SweepSinus 10Log(...)'
        #1044#1073', '#1064#1057#1042' 20Log(...)'
        #1040#1073#1089'. ('#1086#1090#1082#1083#1086#1085#1077#1085#1080#1077')'
        #1047#1085#1072#1095#1077#1085#1080#1077)
    end
    object ProfileNameEdit: TEdit
      Left = 3
      Top = 20
      Width = 193
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = 'ProfileNameEdit'
    end
  end
  object PanAlClient: TPanel
    Left = 0
    Top = 0
    Width = 643
    Height = 344
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 256
    ExplicitTop = 192
    ExplicitWidth = 185
    ExplicitHeight = 41
    object GBleft: TGroupBox
      Left = 1
      Top = 1
      Width = 208
      Height = 342
      Align = alLeft
      Caption = #1055#1088#1086#1092#1080#1083#1100
      TabOrder = 0
      ExplicitHeight = 349
      object ProfileSG: TStringGridExt
        Left = 2
        Top = 15
        Width = 204
        Height = 325
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 3
        ExplicitTop = 12
        ExplicitHeight = 332
      end
    end
  end
end
