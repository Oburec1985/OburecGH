object SensorRepForm: TSensorRepForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1086#1090#1095#1077#1090#1072
  ClientHeight = 537
  ClientWidth = 451
  Color = clBtnFace
  Constraints.MinHeight = 562
  Constraints.MinWidth = 430
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  inline BaseAlgOptsFrame1: TBaseAlgOptsFrame
    Left = 0
    Top = 0
    Width = 451
    Height = 416
    Align = alTop
    Constraints.MinHeight = 348
    Constraints.MinWidth = 451
    TabOrder = 0
    ExplicitHeight = 416
    inherited StageGB: TGroupBox
      Top = 159
      Height = 257
      ExplicitTop = 159
      ExplicitHeight = 257
      inherited UseBladesPos: TRadioGroup
        Top = 191
        ExplicitTop = 191
      end
      inherited ValidBladeGB: TGroupBox
        Top = 56
        Height = 135
        ExplicitTop = 56
        ExplicitHeight = 135
      end
    end
  end
  object SensorRepOptsGB: TGroupBox
    Left = 0
    Top = 416
    Width = 451
    Height = 121
    Align = alClient
    Caption = #1054#1087#1094#1080#1080' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
    TabOrder = 1
    ExplicitTop = 420
    DesignSize = (
      451
      121)
    object RepNameLabel: TLabel
      Left = 3
      Top = 21
      Width = 58
      Height = 13
      Caption = #1048#1084#1103' '#1086#1090#1095#1077#1090#1072
    end
    object PrecLabel: TLabel
      Left = 3
      Top = 48
      Width = 131
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = #1063#1080#1089#1083#1086' '#1079#1085#1072#1082#1086#1074' '#1076#1083#1103' '#1092#1083#1086#1090#1086#1074
      ExplicitTop = 65
    end
    object SelectNameBtn: TButton
      Left = 423
      Top = 40
      Width = 25
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 0
    end
    object CancelBtn: TButton
      Left = 3
      Top = 95
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 1
    end
    object OkBtn: TButton
      Left = 373
      Top = 95
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 2
    end
    object PrecSE: TSpinEdit
      Left = 3
      Top = 67
      Width = 121
      Height = 22
      Anchors = [akLeft, akBottom]
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 5
    end
    object RepNameCB: TComboBox
      Left = 3
      Top = 40
      Width = 297
      Height = 21
      ItemHeight = 0
      TabOrder = 4
    end
    object SingleFileCheckBox: TCheckBox
      Left = 145
      Top = 70
      Width = 80
      Height = 17
      Caption = #1054#1076#1080#1085' '#1092#1072#1081#1083
      TabOrder = 5
      OnClick = SingleFileCheckBoxClick
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 386
    Top = 430
  end
end
