object EditGraphForm: TEditGraphForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1080#1103
  ClientHeight = 271
  ClientWidth = 242
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 250
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    242
    271)
  PixelsPerInch = 96
  TextHeight = 13
  object NameLabel: TLabel
    Left = 8
    Top = 8
    Width = 19
    Height = 13
    Caption = #1048#1084#1103
  end
  object AutoScaleCB: TCheckBox
    Left = 8
    Top = 151
    Width = 121
    Height = 17
    Caption = #1040#1074#1090#1086#1084#1072#1089#1096#1090#1072#1073' '#1086#1089#1077#1081
    TabOrder = 0
  end
  object SelectSE: TSpinEdit
    Left = 8
    Top = 120
    Width = 218
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
  end
  object SelectTypeCB: TCheckBox
    Left = 8
    Top = 97
    Width = 217
    Height = 17
    Caption = #1054#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1072#1103' '#1087#1088#1080#1074#1103#1079#1082#1072'/ '#1072#1073#1089#1086#1083#1102#1090#1085#1072#1103
    TabOrder = 2
    OnClick = SelectTypeCBClick
  end
  object SelectCB: TComboBox
    Left = 8
    Top = 70
    Width = 220
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    Text = 'SelectCB'
  end
  object CancelBtn: TButton
    Left = 8
    Top = 238
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    ModalResult = 2
    TabOrder = 4
  end
  object OkBtn: TButton
    Left = 159
    Top = 238
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 5
  end
  object NameEdit: TEdit
    Left = 8
    Top = 27
    Width = 218
    Height = 21
    TabOrder = 6
  end
end
