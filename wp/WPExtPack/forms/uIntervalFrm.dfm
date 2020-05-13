object IntervalFrm: TIntervalFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1080#1085#1090#1077#1088#1074#1072#1083#1072
  ClientHeight = 300
  ClientWidth = 597
  Color = clBtnFace
  Constraints.MinHeight = 338
  Constraints.MinWidth = 613
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inline IntervalFrame1: TIntervalFrame
    Left = 0
    Top = 0
    Width = 597
    Height = 202
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 597
    inherited StartCB: TComboBox
      OnChange = nil
    end
    inherited StopCB: TComboBox
      OnChange = nil
    end
    inherited StartE: TFloatEdit
      OnChange = nil
    end
    inherited StopE: TFloatEdit
      OnChange = nil
    end
    inherited ModeRG: TRadioGroup
      OnClick = nil
      ExplicitTop = 0
      ExplicitHeight = 202
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 232
    Width = 597
    Height = 68
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      597
      68)
    object CancelBtn: TButton
      Left = 4
      Top = 35
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 511
      Top = 35
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end
