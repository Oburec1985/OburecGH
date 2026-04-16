object EditSelsinFrm: TEditSelsinFrm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1077#1083#1100#1089#1080#1085#1072
  ClientHeight = 433
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    394
    433)
  PixelsPerInch = 96
  TextHeight = 13
  object Label6: TLabel
    Left = 8
    Top = 100
    Width = 15
    Height = 13
    Caption = 'L1:'
  end
  object Label7: TLabel
    Left = 159
    Top = 100
    Width = 15
    Height = 13
    Caption = 'L2:'
  end
  object Label1: TLabel
    Left = 297
    Top = 100
    Width = 15
    Height = 13
    Caption = 'L3:'
  end
  object Label12: TLabel
    Left = 7
    Top = 249
    Width = 87
    Height = 13
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1087#1080#1090#1072#1085#1080#1103
    Visible = False
  end
  object Label2: TLabel
    Left = 9
    Top = 167
    Width = 47
    Height = 13
    Caption = #1055#1080#1090#1072#1085#1080#1077':'
  end
  object Label4: TLabel
    Left = 8
    Top = 29
    Width = 65
    Height = 13
    Caption = #1048#1084#1103' '#1076#1072#1090#1095#1080#1082#1072
  end
  object Label5: TLabel
    Left = 158
    Top = 167
    Width = 106
    Height = 13
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1089#1077#1082#1090#1086#1088#1086#1074':'
  end
  object L1CB: TComboBox
    Left = 8
    Top = 119
    Width = 125
    Height = 21
    TabOrder = 0
    Text = 'L1CB'
    OnChange = L1CBEnter
  end
  object L2CB: TComboBox
    Left = 159
    Top = 119
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'X1CB'
    OnChange = L1CBEnter
  end
  object L3CB: TComboBox
    Left = 297
    Top = 119
    Width = 91
    Height = 21
    TabOrder = 2
    Text = 'X1CB'
    OnChange = L1CBEnter
  end
  object ExcFreqEdit: TFloatEdit
    Left = 7
    Top = 268
    Width = 125
    Height = 21
    ReadOnly = True
    TabOrder = 3
    Text = '402'
    Visible = False
  end
  object ExcCB: TComboBox
    Left = 8
    Top = 190
    Width = 125
    Height = 21
    TabOrder = 4
    Text = 'X1CB'
    OnChange = L1CBEnter
  end
  object NameEdit: TEdit
    Left = 8
    Top = 48
    Width = 380
    Height = 21
    TabOrder = 5
    Text = 'NameEdit'
  end
  object ShiftSectr: TSpinEdit
    Left = 159
    Top = 190
    Width = 121
    Height = 22
    MaxValue = 5
    MinValue = 0
    TabOrder = 6
    Value = 0
  end
  object OkBtn: TButton
    Left = 299
    Top = 383
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 7
  end
  object CancelBtn: TButton
    Left = 8
    Top = 383
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 8
    ExplicitTop = 403
  end
  object CreateAllCB: TCheckBox
    Left = 299
    Top = 268
    Width = 91
    Height = 17
    Caption = #1057#1086#1079#1076#1072#1090#1100' 6'
    TabOrder = 9
  end
  object CommonPntCB: TCheckBox
    Left = 158
    Top = 268
    Width = 120
    Height = 17
    Caption = #1041#1077#1079' '#1086#1073#1097'. '#1090#1095#1082'.'
    TabOrder = 10
  end
  object STypeCB: TCheckBox
    Left = 8
    Top = 316
    Width = 120
    Height = 17
    Caption = #1057#1077#1083#1100#1089#1080#1085
    TabOrder = 11
    OnClick = STypeCBClick
  end
end
