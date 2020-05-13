object DoubleCursorForm: TDoubleCursorForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1076#1074#1086#1081#1085#1086#1075#1086' '#1082#1091#1088#1089#1086#1088#1072
  ClientHeight = 331
  ClientWidth = 305
  Color = clBtnFace
  Constraints.MinHeight = 365
  Constraints.MinWidth = 313
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inline DrawObjFrame1: TDrawObjFrame
    Left = 0
    Top = 0
    Width = 305
    Height = 120
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 305
    ExplicitHeight = 120
  end
  object DoubleCursorProperties: TGroupBox
    Left = 0
    Top = 120
    Width = 305
    Height = 144
    Align = alBottom
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1082#1091#1088#1089#1086#1088#1072
    TabOrder = 1
    object LineWidthLabel1: TLabel
      Left = 4
      Top = 20
      Width = 97
      Height = 13
      Caption = #1058#1086#1083#1097#1080#1085#1072' 1-'#1081' '#1083#1080#1085#1080#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LineWidthLabel2: TLabel
      Left = 4
      Top = 67
      Width = 97
      Height = 13
      Caption = #1058#1086#1083#1097#1080#1085#1072' 2-'#1081' '#1083#1080#1085#1080#1080
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LineWidth1: TFloatSpinEdit
      Left = 3
      Top = 40
      Width = 121
      Height = 22
      Increment = 0.100000001490116100
      TabOrder = 0
    end
    object LineWidth2: TFloatSpinEdit
      Left = 3
      Top = 87
      Width = 121
      Height = 22
      Increment = 0.100000001490116100
      TabOrder = 1
    end
    object DoubleCheckBox: TCheckBox
      Left = 130
      Top = 42
      Width = 70
      Height = 17
      Caption = #1044#1074#1086#1081#1085#1086#1081
      TabOrder = 2
    end
    object DrawYLineCheckBox: TCheckBox
      Left = 130
      Top = 90
      Width = 143
      Height = 17
      Caption = #1056#1080#1089#1086#1074#1072#1090#1100' '#1083#1080#1085#1080#1102' '#1076#1083#1103' y'
      TabOrder = 3
    end
  end
  object ActionGB: TGroupBox
    Left = 0
    Top = 264
    Width = 305
    Height = 67
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 2
    DesignSize = (
      305
      67)
    object CancelBtn: TButton
      Left = 9
      Top = 24
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 213
      Top = 24
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end
