object TestUDPSenderFrm: TTestUDPSenderFrm
  Left = 0
  Top = 0
  Caption = 'TestUDPSenderFrm'
  ClientHeight = 702
  ClientWidth = 942
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    942
    702)
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 32
    Top = 10
    Width = 13
    Height = 16
    Caption = 'X:'
  end
  object Label2: TLabel
    Left = 168
    Top = 10
    Width = 12
    Height = 16
    Caption = 'Y:'
  end
  object Label3: TLabel
    Left = 303
    Top = 10
    Width = 12
    Height = 16
    Caption = 'Z:'
  end
  object XcalibrLabel: TLabel
    Left = 15
    Top = 131
    Width = 13
    Height = 16
    Caption = 'X:'
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
  object Xedit: TEdit
    Left = 32
    Top = 32
    Width = 121
    Height = 24
    TabOrder = 0
    Text = '0'
    OnChange = XeditChange
  end
  object YEdit: TEdit
    Left = 168
    Top = 32
    Width = 121
    Height = 24
    TabOrder = 1
    Text = '0'
    OnChange = XeditChange
  end
  object ZEdit: TEdit
    Left = 303
    Top = 32
    Width = 121
    Height = 24
    TabOrder = 2
    Text = '0'
    OnChange = XeditChange
  end
  object StartBtn: TButton
    Left = 616
    Top = 32
    Width = 75
    Height = 25
    Caption = #1057#1090#1072#1088#1090
    TabOrder = 3
    OnClick = StartBtnClick
  end
  object StopBtn: TButton
    Left = 616
    Top = 63
    Width = 75
    Height = 25
    Caption = #1057#1090#1086#1087
    TabOrder = 4
    OnClick = StopBtnClick
  end
  object BalanceBtn: TButton
    Left = 440
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Balance'
    TabOrder = 5
    OnClick = BalanceBtnClick
  end
  object xCalibrBtn: TButton
    Left = 214
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Calibr.'
    TabOrder = 6
    OnClick = xCalibrBtnClick
  end
  object XcalibrE: TEdit
    Left = 31
    Top = 128
    Width = 70
    Height = 24
    TabOrder = 7
    Text = '90'
  end
  object KxcalibrE: TFloatSpinEdit
    Left = 134
    Top = 129
    Width = 74
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 8
  end
  object kyCalibrE: TFloatSpinEdit
    Left = 133
    Top = 164
    Width = 74
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 9
  end
  object kzCalibrE: TFloatSpinEdit
    Left = 133
    Top = 197
    Width = 74
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 10
  end
  object yCalibrBtn: TButton
    Left = 213
    Top = 164
    Width = 75
    Height = 25
    Caption = 'Calibr.'
    TabOrder = 11
    OnClick = yCalibrBtnClick
  end
  object zCalibrBtn: TButton
    Left = 213
    Top = 197
    Width = 75
    Height = 25
    Caption = 'Calibr.'
    TabOrder = 12
    OnClick = zCalibrBtnClick
  end
  object cBaseGlComponent1: cBaseGlComponent
    Left = 8
    Top = 288
    Width = 905
    Height = 406
    Anchors = [akLeft, akTop, akRight, akBottom]
    DockSite = True
    TabOrder = 13
    ShowTrasforms = True
    OnInitScene = cBaseGlComponent1InitScene
  end
  object CheckBox1: TCheckBox
    Left = 720
    Top = 36
    Width = 97
    Height = 17
    Caption = 'CheckBox1'
    TabOrder = 14
  end
  object HiEdit: TEdit
    Left = 751
    Top = 108
    Width = 121
    Height = 24
    TabOrder = 15
    Text = '0'
    OnChange = LoEditChange
  end
  object LoEdit: TEdit
    Left = 624
    Top = 108
    Width = 121
    Height = 24
    TabOrder = 16
    Text = '0'
    OnChange = LoEditChange
  end
  object Edit3: TEdit
    Left = 624
    Top = 170
    Width = 121
    Height = 24
    TabOrder = 17
    Text = '90'
    OnChange = LoEditChange
  end
  object b1e: TEdit
    Left = 624
    Top = 140
    Width = 57
    Height = 24
    TabOrder = 18
    Text = '0'
  end
  object b2E: TEdit
    Left = 687
    Top = 140
    Width = 57
    Height = 24
    TabOrder = 19
    Text = '0'
  end
  object b4e: TEdit
    Left = 813
    Top = 140
    Width = 57
    Height = 24
    TabOrder = 20
    Text = '0'
  end
  object b3e: TEdit
    Left = 750
    Top = 140
    Width = 57
    Height = 24
    TabOrder = 21
    Text = '0'
  end
  object b1re: TEdit
    Left = 624
    Top = 212
    Width = 57
    Height = 24
    TabOrder = 22
    Text = '0'
  end
  object b2re: TEdit
    Left = 687
    Top = 212
    Width = 57
    Height = 24
    TabOrder = 23
    Text = '0'
  end
  object RevBitsCB: TCheckBox
    Left = 31
    Top = 86
    Width = 97
    Height = 17
    Caption = 'ReverseBits'
    TabOrder = 24
  end
  object RevByteCB: TCheckBox
    Left = 31
    Top = 63
    Width = 97
    Height = 17
    Caption = 'ReverseByte'
    TabOrder = 25
  end
  object IdUDPServer1: TIdUDPServer
    BroadcastEnabled = True
    Bindings = <>
    DefaultPort = 0
    OnUDPRead = IdUDPServer1UDPRead
    Left = 408
    Top = 128
  end
  object IdUDPClient1: TIdUDPClient
    BroadcastEnabled = True
    Port = 1700
    Left = 304
    Top = 128
  end
  object ViewUpdateTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ViewUpdateTimerTimer
    Left = 528
    Top = 88
  end
end
