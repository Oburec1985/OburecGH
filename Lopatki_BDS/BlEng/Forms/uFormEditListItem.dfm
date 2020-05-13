object FormEditListItem: TFormEditListItem
  Left = 173
  Top = 185
  Caption = 'FormEditListItem'
  ClientHeight = 114
  ClientWidth = 605
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  DesignSize = (
    605
    114)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 4
    Top = 24
    Width = 597
    Height = 47
    Anchors = [akLeft, akTop, akRight, akBottom]
  end
  object Label1: TLabel
    Left = 10
    Top = 28
    Width = 68
    Height = 13
    Caption = #1048#1084#1103' '#1076#1072#1090#1095#1080#1082#1072':'
  end
  object Label6: TLabel
    Left = 11
    Top = 7
    Width = 105
    Height = 13
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1072#1090#1095#1080#1082#1072':'
  end
  object Label2: TLabel
    Left = 111
    Top = 29
    Width = 76
    Height = 13
    Caption = #1053#1086#1084#1077#1088' '#1082#1072#1085#1072#1083#1072':'
  end
  object Label3: TLabel
    Left = 315
    Top = 29
    Width = 97
    Height = 13
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1076#1072#1090#1095#1080#1082#1072
  end
  object Label4: TLabel
    Left = 214
    Top = 29
    Width = 62
    Height = 13
    Caption = #1058#1080#1087' '#1076#1072#1090#1095#1080#1082#1072
  end
  object Label5: TLabel
    Left = 421
    Top = 28
    Width = 44
    Height = 13
    Caption = #1057#1090#1091#1087#1077#1085#1100':'
  end
  object NameEdit: TEdit
    Left = 10
    Top = 44
    Width = 84
    Height = 21
    TabOrder = 0
    Text = 'NameEdit'
    OnKeyDown = FormKeyDown
  end
  object CancelBtn: TButton
    Left = 10
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object ApplyBtn: TButton
    Left = 526
    Top = 79
    Width = 75
    Height = 27
    Anchors = [akLeft, akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 2
  end
  object DeleteBtn: TButton
    Left = 260
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1059#1076#1072#1083#1080#1090#1100
    ModalResult = 7
    TabOrder = 3
  end
  object ChanNumberIntEdit: TIntEdit
    Left = 112
    Top = 44
    Width = 84
    Height = 21
    ReadOnly = True
    TabOrder = 4
    Text = '000'
    OnKeyDown = FormKeyDown
  end
  object OffsetFloatEdit: TFloatEdit
    Left = 315
    Top = 48
    Width = 84
    Height = 21
    TabOrder = 5
    Text = '5.1'
    OnKeyDown = FormKeyDown
  end
  object SensorTypeComboBox: TComboBox
    Left = 215
    Top = 44
    Width = 84
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 6
    Text = #1050#1086#1088#1085#1077#1074#1086#1081
    OnKeyDown = FormKeyDown
    Items.Strings = (
      #1050#1086#1088#1085#1077#1074#1086#1081
      #1055#1077#1088#1080#1092#1077#1088#1080#1081#1085#1099#1081)
  end
  object StageComboBox: TComboBox
    Left = 420
    Top = 44
    Width = 93
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 7
    Text = #1050#1086#1088#1085#1077#1074#1086#1081
    OnKeyDown = FormKeyDown
    Items.Strings = (
      #1050#1086#1088#1085#1077#1074#1086#1081
      #1055#1077#1088#1080#1092#1077#1088#1080#1081#1085#1099#1081)
  end
end
