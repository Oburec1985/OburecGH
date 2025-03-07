object DensityForm: TDensityForm
  Left = 0
  Top = 0
  Caption = #1057#1090#1072#1090#1080#1089#1090#1080#1082#1072
  ClientHeight = 366
  ClientWidth = 275
  Color = clBtnFace
  TransparentColorValue = clMedGray
  Constraints.MaxHeight = 400
  Constraints.MinHeight = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object ApplyGB: TGroupBox
    Left = 0
    Top = 0
    Width = 275
    Height = 366
    Align = alClient
    Caption = #1042#1099#1073#1080#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    ExplicitWidth = 194
    ExplicitHeight = 225
    DesignSize = (
      275
      366)
    object OrderLabel: TLabel
      Left = 3
      Top = 67
      Width = 82
      Height = 13
      Caption = #1063#1072#1089#1090#1086#1089#1090#1100', '#1075#1088#1072#1076'.'
    end
    object SensorLabel: TLabel
      Left = 3
      Top = 21
      Width = 42
      Height = 13
      Caption = #1044#1072#1090#1095#1080#1082':'
    end
    object OkBtn: TButton
      Left = 197
      Top = 322
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 116
      ExplicitTop = 181
    end
    object CancelBtn: TButton
      Left = 3
      Top = 322
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 1
      ExplicitTop = 181
    end
    object OrderFE: TFloatSpinEdit
      Left = 3
      Top = 86
      Width = 266
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      Increment = 0.004999999888241291
      TabOrder = 2
      Value = 0.000500000023748726
      ExplicitWidth = 185
    end
    object SensorEdit: TEdit
      Left = 3
      Top = 40
      Width = 266
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      ExplicitWidth = 185
    end
    object TextCheckBox: TCheckBox
      Left = 3
      Top = 123
      Width = 185
      Height = 17
      Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1087#1086#1076#1087#1080#1089#1080' '#1082' '#1089#1090#1086#1083#1073#1094#1072#1084
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object NormaliseCheckBox: TCheckBox
      Left = 3
      Top = 146
      Width = 102
      Height = 17
      Caption = #1053#1086#1088#1084#1072#1083#1080#1079#1086#1074#1072#1090#1100
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object UseStageInfoCheckBox: TCheckBox
      Left = 3
      Top = 169
      Width = 198
      Height = 17
      Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1089#1090#1091#1087#1077#1085#1080
      Checked = True
      State = cbChecked
      TabOrder = 6
    end
  end
end
