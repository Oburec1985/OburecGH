object TestUDPSenderFrm: TTestUDPSenderFrm
  Left = 0
  Top = 0
  Caption = 'TestUDPSenderFrm'
  ClientHeight = 247
  ClientWidth = 548
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object XcalibrLabel: TLabel
    Left = 8
    Top = 131
    Width = 27
    Height = 16
    Caption = 'Deg:'
  end
  object KxLabel: TLabel
    Left = 115
    Top = 131
    Width = 13
    Height = 16
    Caption = 'X:'
  end
  object KyLabel: TLabel
    Left = 115
    Top = 167
    Width = 12
    Height = 16
    Caption = 'Y:'
  end
  object KzLabel: TLabel
    Left = 115
    Top = 205
    Width = 12
    Height = 16
    Caption = 'Z:'
  end
  object StartBtn: TButton
    Left = 264
    Top = 32
    Width = 75
    Height = 25
    Caption = #1057#1090#1072#1088#1090
    TabOrder = 0
    OnClick = StartBtnClick
  end
  object StopBtn: TButton
    Left = 345
    Top = 32
    Width = 75
    Height = 25
    Caption = #1057#1090#1086#1087
    TabOrder = 1
    OnClick = StopBtnClick
  end
  object BalanceBtn: TButton
    Left = 144
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Balance'
    TabOrder = 2
    OnClick = BalanceBtnClick
  end
  object xCalibrBtn: TButton
    Left = 210
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Calibr.'
    TabOrder = 3
    OnClick = xCalibrBtnClick
  end
  object XcalibrE: TEdit
    Left = 41
    Top = 128
    Width = 60
    Height = 24
    TabOrder = 4
    Text = '90'
  end
  object KxcalibrE: TFloatSpinEdit
    Left = 134
    Top = 129
    Width = 74
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 5
  end
  object kyCalibrE: TFloatSpinEdit
    Left = 133
    Top = 164
    Width = 74
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 6
  end
  object kzCalibrE: TFloatSpinEdit
    Left = 133
    Top = 197
    Width = 74
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 7
  end
  object yCalibrBtn: TButton
    Left = 209
    Top = 164
    Width = 75
    Height = 25
    Caption = 'Calibr.'
    TabOrder = 8
    OnClick = yCalibrBtnClick
  end
  object zCalibrBtn: TButton
    Left = 209
    Top = 197
    Width = 75
    Height = 25
    Caption = 'Calibr.'
    TabOrder = 9
    OnClick = zCalibrBtnClick
  end
  object RevBitsCB: TCheckBox
    Left = 41
    Top = 76
    Width = 97
    Height = 17
    Caption = 'ReverseBits'
    TabOrder = 11
  end
  object RevByteCB: TCheckBox
    Left = 41
    Top = 36
    Width = 97
    Height = 17
    Caption = 'ReverseByte'
    Checked = True
    State = cbChecked
    TabOrder = 10
  end
  object CheckBox1: TCheckBox
    Left = 393
    Top = 156
    Width = 97
    Height = 17
    Caption = 'Conect'
    TabOrder = 12
  end
  object IdUDPServer1: TIdUDPServer
    BroadcastEnabled = True
    Bindings = <>
    DefaultPort = 0
    ThreadedEvent = True
    OnUDPRead = IdUDPServer1UDPRead
    Left = 328
    Top = 184
  end
  object IdUDPClient1: TIdUDPClient
    BroadcastEnabled = True
    Port = 1700
    OnConnected = IdUDPClient1Connected
    Left = 328
    Top = 136
  end
  object ViewUpdateTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ViewUpdateTimerTimer
    Left = 328
    Top = 96
  end
end
