object Snfwin: TSnfwin
  Left = 0
  Top = 0
  Caption = 'Snfwin'
  ClientHeight = 256
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 480
    Height = 211
    ActivePage = TabSheet4
    Align = alClient
    TabHeight = 22
    TabOrder = 0
    object TabSheet4: TTabSheet
      Caption = #1043#1083#1072#1074#1085#1072#1103
      ImageIndex = 3
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 472
        Height = 65
        Align = alTop
        Caption = ' '#1053#1072#1089#1090#1088#1086#1081#1082#1080' '
        TabOrder = 0
        object chkLogAll: TCheckBox
          Tag = 1
          Left = 16
          Top = 19
          Width = 113
          Height = 17
          Caption = #1042#1077#1089#1090#1080' '#1078#1091#1088#1085#1072#1083
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object chkAddToTray: TCheckBox
          Tag = 2
          Left = 16
          Top = 39
          Width = 121
          Height = 17
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1074' '#1090#1088#1077#1077
          TabOrder = 1
        end
        object chkAutoStart: TCheckBox
          Tag = 3
          Left = 184
          Top = 9
          Width = 193
          Height = 38
          Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1074#1077#1089#1090#1080' '#1078#1091#1088#1085#1072#1083' '#1087#1088#1080' '#1074#1093#1086#1076#1077' '#1074' '#1089#1080#1089#1090#1077#1084#1091
          Checked = True
          State = cbChecked
          TabOrder = 2
          WordWrap = True
        end
      end
      object GroupBox2: TGroupBox
        Left = 0
        Top = 65
        Width = 472
        Height = 114
        Align = alClient
        Caption = ' '#1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1101#1083#1077#1082#1090#1088#1086#1085#1085#1086#1081' '#1087#1086#1095#1090#1099' '
        TabOrder = 1
        object Label1: TLabel
          Left = 8
          Top = 16
          Width = 138
          Height = 13
          Caption = #1040#1076#1088#1077#1089' '#1101#1083#1077#1082#1090#1088#1086#1085#1085#1086#1081' '#1087#1086#1095#1090#1099':'
        end
        object Label2: TLabel
          Left = 8
          Top = 40
          Width = 143
          Height = 13
          Caption = #1057#1077#1088#1074#1077#1088' SMTP '#1076#1083#1103' '#1086#1090#1087#1088#1072#1074#1082#1080':'
        end
        object Label3: TLabel
          Left = 8
          Top = 64
          Width = 97
          Height = 13
          Caption = #1048#1084#1103' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103':'
        end
        object Label5: TLabel
          Left = 8
          Top = 80
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
        end
        object edMailTo: TEdit
          Left = 168
          Top = 12
          Width = 209
          Height = 21
          TabOrder = 0
          Text = 'skripn1@infoline.su'
        end
        object edSMTPServer: TEdit
          Left = 168
          Top = 36
          Width = 129
          Height = 21
          TabOrder = 1
          Text = 'mail.tut.by'
        end
        object edUserName: TEdit
          Left = 112
          Top = 60
          Width = 121
          Height = 21
          TabOrder = 2
          Text = 'samera'
        end
        object edPassword: TEdit
          Left = 112
          Top = 80
          Width = 121
          Height = 21
          PasswordChar = '*'
          TabOrder = 3
          Text = 'oburec7835'
        end
      end
    end
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 211
    Width = 480
    Height = 45
    Align = alBottom
    TabOrder = 1
    object btnStart: TButton
      Left = 0
      Top = 6
      Width = 75
      Height = 25
      Hint = #1053#1072#1095#1072#1090#1100' '#1089#1083#1091#1096#1072#1090#1100' '#1082#1083#1072#1074#1091
      Caption = #1055#1091#1089#1082
      TabOrder = 0
    end
  end
end
