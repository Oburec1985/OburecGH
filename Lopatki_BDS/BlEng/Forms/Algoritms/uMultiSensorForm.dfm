object MultiSensorForm: TMultiSensorForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
  ClientHeight = 512
  ClientWidth = 439
  Color = clBtnFace
  Constraints.MinHeight = 522
  Constraints.MinWidth = 447
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
    Width = 439
    Height = 409
    Align = alTop
    Constraints.MinHeight = 409
    Constraints.MinWidth = 329
    TabOrder = 0
    ExplicitWidth = 439
    ExplicitHeight = 409
    inherited StageGB: TGroupBox
      Width = 439
      ExplicitTop = 136
      ExplicitWidth = 439
      inherited ValidBladeGB: TGroupBox
        Width = 435
        ExplicitTop = 75
        ExplicitWidth = 435
        inherited UseBladesPos: TRadioGroup
          Left = -2
          Width = 435
          ExplicitLeft = -2
          ExplicitWidth = 435
        end
      end
    end
    inherited CommonGB: TGroupBox
      Width = 439
      ExplicitWidth = 439
    end
    inherited TagsGB: TGroupBox
      Width = 439
      ExplicitWidth = 439
    end
  end
  object SensorRepOptsGB: TGroupBox
    Left = 0
    Top = 409
    Width = 439
    Height = 103
    Align = alClient
    Caption = #1054#1087#1094#1080#1080' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
    TabOrder = 1
    DesignSize = (
      439
      103)
    object BladeIndexLabel: TLabel
      Left = 3
      Top = 23
      Width = 82
      Height = 13
      Caption = #1048#1085#1076#1077#1082#1089' '#1083#1086#1087#1072#1090#1082#1080
    end
    object CancelBtn: TButton
      Left = 3
      Top = 77
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 361
      Top = 77
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
    object BladeIndexSE: TSpinEdit
      Left = 3
      Top = 42
      Width = 121
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
    object ExcludeRootCB: TCheckBox
      Left = 130
      Top = 40
      Width = 177
      Height = 17
      Caption = #1048#1089#1082#1083#1102#1095#1080#1090#1100' '#1082#1086#1088#1085#1077#1074#1099#1077' '#1076#1072#1090#1095#1080#1082#1080
      TabOrder = 3
    end
  end
end
