object GenShockForm: TGenShockForm
  Left = 0
  Top = 0
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1091#1076#1072#1088#1072
  ClientHeight = 282
  ClientWidth = 537
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    537
    282)
  PixelsPerInch = 96
  TextHeight = 13
  object LengthLabel: TLabel
    Left = 8
    Top = 13
    Width = 119
    Height = 13
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100' '#1091#1076#1072#1088#1072', '#1089
  end
  object ALabel: TLabel
    Left = 8
    Top = 59
    Width = 90
    Height = 13
    Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1091#1076#1072#1088#1072
  end
  object FreqLabel: TLabel
    Left = 8
    Top = 111
    Width = 122
    Height = 13
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1076#1080#1089#1082#1088#1077#1090#1080#1079#1072#1094#1080#1080
  end
  object BeforeShockLabel: TLabel
    Left = 168
    Top = 13
    Width = 135
    Height = 13
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100' '#1076#1086' '#1091#1076#1072#1088#1072', '#1089
  end
  object AfterShockLabel: TLabel
    Left = 168
    Top = 61
    Width = 151
    Height = 13
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100' '#1087#1086#1089#1083#1077' '#1091#1076#1072#1088#1072', '#1089
  end
  object DscLabel: TLabel
    Left = 8
    Top = 175
    Width = 49
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077
  end
  object LengthFE: TFloatEdit
    Left = 8
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '0.005'
  end
  object AFE: TFloatEdit
    Left = 8
    Top = 80
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '10'
  end
  object FreqFE: TFloatEdit
    Left = 8
    Top = 132
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '2000'
  end
  object BeforeShockFE: TFloatEdit
    Left = 168
    Top = 32
    Width = 135
    Height = 21
    TabOrder = 3
    Text = '1'
  end
  object AfterShockFE: TFloatEdit
    Left = 168
    Top = 80
    Width = 135
    Height = 21
    TabOrder = 4
    Text = '2'
  end
  object DscEdit: TEdit
    Left = 8
    Top = 194
    Width = 521
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 5
    Text = 'DscEdit'
  end
end
