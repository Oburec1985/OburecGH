object TresHoldFrame: TTresHoldFrame
  Left = 0
  Top = 0
  ClientHeight = 301
  ClientWidth = 486
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  DesignSize = (
    486
    301)
  PixelsPerInch = 120
  TextHeight = 16
  object NameLabel: TLabel
    Left = 8
    Top = 2
    Width = 121
    Height = 16
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
  end
  object OptsLabel: TLabel
    Left = 8
    Top = 50
    Width = 61
    Height = 16
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  end
  object ChannelLabel: TLabel
    Left = 9
    Top = 234
    Width = 35
    Height = 16
    Caption = #1050#1072#1085#1072#1083
  end
  object OutLabel: TLabel
    Left = 169
    Top = 234
    Width = 36
    Height = 16
    Caption = #1042#1099#1093#1086#1076
  end
  object Label1: TLabel
    Left = 8
    Top = 102
    Width = 75
    Height = 16
    Caption = #1048#1089#1090#1086#1088#1080#1103', '#1089#1077#1082
  end
  object AlgNameEdit: TEdit
    Left = 9
    Top = 24
    Width = 463
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 0
  end
  object OptsEdit: TEdit
    Left = 9
    Top = 72
    Width = 463
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 1
  end
  object ChannelCB: TRcComboBox
    Left = 9
    Top = 256
    Width = 145
    Height = 24
    TabOrder = 2
  end
  object OutChannelName: TEdit
    Left = 160
    Top = 256
    Width = 312
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 3
  end
  object HistFe: TFloatEdit
    Left = 8
    Top = 128
    Width = 121
    Height = 24
    TabOrder = 4
    Text = '10'
  end
end
