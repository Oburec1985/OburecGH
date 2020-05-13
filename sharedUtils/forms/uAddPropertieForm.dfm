object AddPropertieForm: TAddPropertieForm
  Left = 0
  Top = 0
  Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1074#1086#1081#1089#1090#1074#1086
  ClientHeight = 423
  ClientWidth = 210
  Color = clBtnFace
  Constraints.MinHeight = 452
  Constraints.MinWidth = 176
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    210
    423)
  PixelsPerInch = 96
  TextHeight = 13
  object TypeLabel: TLabel
    Left = 8
    Top = 157
    Width = 64
    Height = 13
    Caption = #1058#1080#1087' '#1086#1073#1098#1077#1082#1090#1072
  end
  object ValueLabel: TLabel
    Left = 8
    Top = 109
    Width = 48
    Height = 13
    Caption = #1047#1085#1072#1095#1077#1085#1080#1077
  end
  object DscLabel: TLabel
    Left = 8
    Top = 61
    Width = 49
    Height = 13
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077
  end
  object NameLabel: TLabel
    Left = 8
    Top = 13
    Width = 19
    Height = 13
    Caption = #1048#1084#1103
  end
  object TypeListBox: TListBox
    Left = 7
    Top = 176
    Width = 195
    Height = 203
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
  end
  object ValueEdit: TEdit
    Left = 8
    Top = 128
    Width = 194
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object CancelBtn: TButton
    Left = 8
    Top = 390
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'CancelBtn'
    ModalResult = 2
    TabOrder = 2
    ExplicitTop = 322
  end
  object OkBtn: TButton
    Left = 128
    Top = 390
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Button1'
    ModalResult = 1
    TabOrder = 3
    ExplicitLeft = 134
    ExplicitTop = 322
  end
  object DscEdit: TEdit
    Left = 8
    Top = 80
    Width = 194
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
  end
  object NameEdit: TEdit
    Left = 8
    Top = 32
    Width = 194
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
end
