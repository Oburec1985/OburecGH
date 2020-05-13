object GetSkipBladesForm: TGetSkipBladesForm
  Left = 0
  Top = 0
  Caption = #1056#1072#1089#1095#1077#1090' '#1095#1080#1089#1083#1072' '#1087#1088#1086#1087#1091#1089#1082#1072#1077#1084#1099#1093' '#1083#1086#1087#1072#1090#1086#1082
  ClientHeight = 520
  ClientWidth = 451
  Color = clBtnFace
  Constraints.MinHeight = 554
  Constraints.MinWidth = 459
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inline BaseAlgOptsFrame1: TBaseAlgOptsFrame
    Left = 0
    Top = 0
    Width = 451
    Height = 399
    Align = alTop
    Constraints.MinHeight = 399
    Constraints.MinWidth = 451
    TabOrder = 0
    ExplicitLeft = -25
    ExplicitTop = 30
  end
  object EvalSkipBladesGroupBox: TGroupBox
    Left = 0
    Top = 399
    Width = 451
    Height = 68
    Align = alClient
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1072#1083#1075#1086#1088#1080#1090#1084#1072' '#1088#1072#1089#1095#1077#1090#1072' '#1087#1088#1086#1087#1091#1089#1082#1072' '#1083#1086#1087#1072#1090#1086#1082
    TabOrder = 1
    ExplicitHeight = 74
    object SkipBladeLabel: TLabel
      Left = 11
      Top = 21
      Width = 105
      Height = 13
      Caption = #1055#1088#1086#1087#1091#1089#1090#1080#1090#1100' '#1083#1086#1087#1072#1090#1086#1082
    end
    object StepLabel: TLabel
      Left = 200
      Top = 21
      Width = 105
      Height = 13
      Caption = #1055#1088#1086#1087#1091#1089#1090#1080#1090#1100' '#1083#1086#1087#1072#1090#1086#1082
    end
    object SkipBladeIE: TIntEdit
      Left = 11
      Top = 40
      Width = 133
      Height = 21
      Enabled = False
      TabOrder = 0
      Text = '000'
    end
    object StepIntEdit: TIntEdit
      Left = 200
      Top = 40
      Width = 133
      Height = 21
      Enabled = False
      TabOrder = 1
      Text = '000'
    end
  end
  object ApplyGB: TGroupBox
    Left = 0
    Top = 467
    Width = 451
    Height = 53
    Align = alBottom
    Caption = #1042#1099#1073#1080#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 2
    ExplicitTop = 480
    DesignSize = (
      451
      53)
    object OkBtn: TButton
      Left = 373
      Top = 17
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 344
      ExplicitTop = 30
    end
    object CancelBtn: TButton
      Left = 3
      Top = 17
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 1
      ExplicitTop = 30
    end
  end
end
