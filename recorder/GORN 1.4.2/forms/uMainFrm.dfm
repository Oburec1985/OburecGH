object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Cursor = crHandPoint
  AlphaBlendValue = 100
  Caption = 'plgGORN'
  ClientHeight = 155
  ClientWidth = 192
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox_Main: TGroupBox
    Left = 0
    Top = 0
    Width = 192
    Height = 155
    Align = alClient
    Caption = '---'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object LabelMeasure: TLabel
      Left = 2
      Top = 95
      Width = 188
      Height = 58
      Align = alBottom
      AutoSize = False
      Caption = 'I'#1080#1079#1084' = 0 '#1040#13#10'U'#1080#1079#1084' = 0 '#1042#13#10'P'#1080#1079#1084' = 0 '#1042#1090
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitTop = 96
      ExplicitWidth = 181
    end
    object LabelEditText: TLabel
      Left = 4
      Top = 19
      Width = 61
      Height = 19
      Caption = #1059#1089#1090#1072#1074#1082#1072' '
      Enabled = False
    end
    object Button_Config: TButton
      Left = 156
      Top = 21
      Width = 29
      Height = 23
      Caption = '...'
      TabOrder = 0
      OnClick = Button_ConfigClick
    end
    object LabeledEdit_Ustavka: TLabeledEdit
      Left = 3
      Top = 38
      Width = 60
      Height = 27
      EditLabel.Width = 17
      EditLabel.Height = 19
      EditLabel.Caption = #1042#1090
      Enabled = False
      LabelPosition = lpRight
      TabOrder = 1
      Text = '0'
      OnChange = LabeledEdit_UstavkaChange
      OnKeyPress = LabeledEdit_UstavkaKeyPress
    end
    object CheckBoxON: TCheckBox
      Left = 88
      Top = 46
      Width = 97
      Height = 19
      Caption = #1087#1088#1080#1084#1077#1085#1080#1090#1100
      Enabled = False
      TabOrder = 2
      OnClick = CheckBoxONClick
    end
    object ComboBoxMode: TComboBox
      Left = 3
      Top = 66
      Width = 116
      Height = 27
      Style = csDropDownList
      Enabled = False
      ItemIndex = 2
      TabOrder = 3
      Text = #1052#1086#1097#1085#1086#1089#1090#1100
      OnChange = ComboBoxModeChange
      Items.Strings = (
        #1058#1086#1082
        #1053#1072#1087#1088#1103#1078#1077#1085#1080#1077
        #1052#1086#1097#1085#1086#1089#1090#1100)
    end
    object ComboBoxManual: TComboBox
      Left = 125
      Top = 66
      Width = 58
      Height = 27
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 4
      Text = #1072#1074#1090'.'
      OnChange = ComboBoxManualChange
      Items.Strings = (
        #1088#1091#1095#1085'.'
        #1072#1074#1090'.')
    end
    object PanelGORNPower: TPanel
      Left = 79
      Top = 21
      Width = 75
      Height = 24
      BorderStyle = bsSingle
      Caption = #1087#1080#1090#1072#1085#1080#1077
      ParentBackground = False
      TabOrder = 5
      OnClick = PanelGORNPowerClick
    end
  end
end
