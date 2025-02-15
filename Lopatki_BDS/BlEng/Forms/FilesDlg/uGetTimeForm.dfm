object GetTimeForm: TGetTimeForm
  Left = 0
  Top = 0
  Caption = #1042#1099#1073#1086#1088' '#1089#1086#1093#1088#1072#1085#1103#1077#1084#1086#1075#1086' '#1091#1095#1072#1089#1090#1082#1072' '#1087#1086' '#1074#1088#1077#1084#1077#1085#1080
  ClientHeight = 236
  ClientWidth = 312
  Color = clBtnFace
  Constraints.MinHeight = 236
  Constraints.MinWidth = 320
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StartTimeLabel: TLabel
    Left = 8
    Top = 39
    Width = 49
    Height = 13
    Caption = #1053#1072#1095#1072#1083#1086', '#1089
  end
  object EndTimeLabel: TLabel
    Left = 8
    Top = 80
    Width = 43
    Height = 13
    Caption = #1050#1086#1085#1077#1094', '#1089
  end
  object ImpulseCountLabel: TLabel
    Left = 8
    Top = 121
    Width = 132
    Height = 13
    Caption = #1063#1080#1089#1083#1086' '#1080#1084#1087#1091#1083#1100#1089#1086#1074' '#1076#1072#1090#1095#1080#1082#1072
  end
  object SensorLabel: TLabel
    Left = 168
    Top = 36
    Width = 38
    Height = 13
    Caption = #1044#1072#1090#1095#1080#1082
  end
  object StartTimeFE: TFloatSpinEdit
    Left = 8
    Top = 55
    Width = 121
    Height = 22
    Increment = 0.100000001490116100
    TabOrder = 0
  end
  object EndTimeFE: TFloatSpinEdit
    Left = 8
    Top = 96
    Width = 121
    Height = 22
    Increment = 0.100000001490116100
    TabOrder = 1
  end
  object ImpulseCountIE: TIntEdit
    Left = 8
    Top = 140
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '000'
  end
  object SyncCB: TCheckBox
    Left = 8
    Top = 8
    Width = 161
    Height = 17
    Caption = #1057#1080#1085#1093#1088#1086#1085#1080#1079#1072#1094#1080#1103' '#1089' '#1082#1091#1088#1089#1086#1088#1086#1084
    TabOrder = 3
    OnClick = SyncCBClick
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 187
    Width = 312
    Height = 49
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 4
    DesignSize = (
      312
      49)
    object CancelBtn: TButton
      Left = 8
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 234
      Top = 21
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
  object SensorsNameCB: TComboBox
    Left = 168
    Top = 55
    Width = 132
    Height = 21
    TabOrder = 5
    OnChange = SensorsNameCBChange
  end
end
