object EditAlarmForm: TEditAlarmForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1072#1083#1072#1088#1084#1072
  ClientHeight = 316
  ClientWidth = 301
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object AlarmGB: TGroupBox
    Left = 0
    Top = 0
    Width = 301
    Height = 252
    Align = alClient
    TabOrder = 0
    inline EditAlarmFrame1: TEditAlarmFrame
      Left = 2
      Top = 15
      Width = 297
      Height = 235
      Align = alClient
      Constraints.MinHeight = 235
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 297
      ExplicitHeight = 235
      inherited DSCEdit: TEdit
        Width = 289
        ExplicitWidth = 289
      end
      inherited TypeCB: TComboBox
        Left = 132
        Width = 120
        ExplicitLeft = 132
        ExplicitWidth = 120
      end
    end
  end
  object ActionGB: TGroupBox
    Left = 0
    Top = 252
    Width = 301
    Height = 64
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    DesignSize = (
      301
      64)
    object CancelBtn: TButton
      Left = 7
      Top = 25
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 222
      Top = 25
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end
