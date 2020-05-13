object StageReConfigForm: TStageReConfigForm
  Left = 0
  Top = 0
  Caption = #1055#1088#1077#1082#1086#1085#1092#1080#1075#1091#1088#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1090#1091#1087#1077#1085#1080
  ClientHeight = 334
  ClientWidth = 314
  Color = clBtnFace
  Constraints.MinHeight = 303
  Constraints.MinWidth = 322
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  DesignSize = (
    314
    334)
  PixelsPerInch = 96
  TextHeight = 13
  object BladeCountLabel: TLabel
    Left = 8
    Top = 118
    Width = 75
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082
  end
  object NameLabel: TLabel
    Left = 8
    Top = 69
    Width = 63
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1048#1084#1103' '#1089#1090#1091#1087#1077#1085#1080
  end
  object BladeCountIE: TIntEdit
    Left = 8
    Top = 141
    Width = 121
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 0
    Text = '000'
  end
  object NameEdit: TEdit
    Left = 8
    Top = 90
    Width = 121
    Height = 21
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    Text = 'NameEdit'
  end
  object FirstBladeOffsetGB: TGroupBox
    Left = 136
    Top = 69
    Width = 170
    Height = 193
    Anchors = [akLeft, akRight, akBottom]
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1076#1086' '#1087#1077#1088#1074#1086#1081' '#1083#1086#1087#1072#1090#1082#1080
    Constraints.MinHeight = 193
    TabOrder = 2
    DesignSize = (
      170
      193)
    object TahoLabel: TLabel
      Left = 16
      Top = 49
      Width = 64
      Height = 13
      Caption = #1058#1072#1093#1086' '#1076#1072#1090#1095#1080#1082
    end
    object SensorLabel: TLabel
      Left = 16
      Top = 105
      Width = 38
      Height = 13
      Caption = #1044#1072#1090#1095#1080#1082
    end
    object FirstBladeOffsetSE: TFloatSpinEdit
      Left = 16
      Top = 21
      Width = 121
      Height = 22
      Increment = 0.100000001490116100
      TabOrder = 0
    end
    object TahoCB: TComboBox
      Left = 16
      Top = 72
      Width = 121
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
    object SensorCB: TComboBox
      Left = 16
      Top = 128
      Width = 121
      Height = 21
      ItemHeight = 13
      TabOrder = 2
    end
    object EvalFirstBladeOffsetBtn: TButton
      Left = 16
      Top = 160
      Width = 121
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1056#1072#1089#1089#1095#1080#1090#1072#1090#1100
      TabOrder = 3
    end
  end
  object ApplyGB: TGroupBox
    Left = 0
    Top = 268
    Width = 314
    Height = 66
    Align = alBottom
    Caption = #1042#1099#1073#1080#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 3
    DesignSize = (
      314
      66)
    object OkBtn: TButton
      Left = 236
      Top = 30
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
    object CancelBtn: TButton
      Left = 3
      Top = 30
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 1
    end
  end
  object DscMemo: TMemo
    Left = 8
    Top = 8
    Width = 298
    Height = 55
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      #1040#1083#1075#1086#1088#1080#1090#1084' '#1088#1072#1089#1089#1095#1080#1090#1099#1074#1072#1077#1090' '#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1083#1086#1087#1072#1090#1086#1082' '#1085#1072' '#1089#1090#1091#1087#1077#1085#1080' '
      #1087#1086' '#1089#1084#1077#1097#1077#1085#1080#1103#1084' '#1084#1077#1078#1076#1091' '#1083#1086#1087#1072#1090#1082#1072#1084#1080' '#1080' '#1088#1072#1089#1089#1090#1086#1103#1085#1080#1102' '#1076#1086' '
      #1087#1077#1088#1074#1086#1081' '#1083#1086#1087#1072#1090#1082#1080)
    TabOrder = 4
  end
end
