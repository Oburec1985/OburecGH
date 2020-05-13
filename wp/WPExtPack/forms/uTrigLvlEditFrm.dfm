object TrigLvlFrm: TTrigLvlFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1091#1088#1086#1074#1085#1077#1081
  ClientHeight = 130
  ClientWidth = 276
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    276
    130)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 24
    Width = 49
    Height = 13
    Caption = #1058#1088#1080#1075#1075#1077#1088' 1'
  end
  object Label2: TLabel
    Left = 152
    Top = 24
    Width = 49
    Height = 13
    Caption = #1058#1088#1080#1075#1075#1077#1088' 2'
  end
  object Trig1FE: TFloatEdit
    Left = 8
    Top = 43
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '0.0'
  end
  object Trig2FE: TFloatEdit
    Left = 152
    Top = 43
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '0.0'
  end
  object OkBtn: TButton
    Left = 193
    Top = 97
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1044#1072#1083#1077#1077
    ModalResult = 1
    TabOrder = 2
    ExplicitLeft = 349
  end
  object CancelBtn: TButton
    Left = 8
    Top = 97
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 3
  end
end
