object TestUDPSenderFrm: TTestUDPSenderFrm
  Left = 0
  Top = 0
  Caption = 'TestUDPSenderFrm'
  ClientHeight = 702
  ClientWidth = 1068
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
    1068
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
  object Label4: TLabel
    Left = 307
    Top = 130
    Width = 13
    Height = 16
    Caption = 'X:'
  end
  object Label5: TLabel
    Left = 307
    Top = 166
    Width = 12
    Height = 16
    Caption = 'Y:'
  end
  object Label6: TLabel
    Left = 307
    Top = 204
    Width = 12
    Height = 16
    Caption = 'Z:'
  end
  object Label7: TLabel
    Left = 547
    Top = 130
    Width = 13
    Height = 16
    Caption = 'X:'
  end
  object Label8: TLabel
    Left = 547
    Top = 166
    Width = 12
    Height = 16
    Caption = 'Y:'
  end
  object Label9: TLabel
    Left = 547
    Top = 204
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
    Left = 210
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
    Left = 209
    Top = 164
    Width = 75
    Height = 25
    Caption = 'Calibr.'
    TabOrder = 11
    OnClick = yCalibrBtnClick
  end
  object zCalibrBtn: TButton
    Left = 209
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
    Width = 1031
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
    Left = 927
    Top = 32
    Width = 110
    Height = 24
    TabOrder = 15
    Text = '0'
    OnChange = LoEditChange
  end
  object LoEdit: TEdit
    Left = 808
    Top = 32
    Width = 110
    Height = 24
    TabOrder = 16
    Text = '0'
    OnChange = LoEditChange
  end
  object Edit3: TEdit
    Left = 808
    Top = 94
    Width = 110
    Height = 24
    TabOrder = 17
    Text = '90'
    OnChange = LoEditChange
  end
  object b1e: TEdit
    Left = 808
    Top = 64
    Width = 46
    Height = 24
    TabOrder = 18
    Text = '0'
  end
  object b2E: TEdit
    Left = 871
    Top = 64
    Width = 46
    Height = 24
    TabOrder = 19
    Text = '0'
  end
  object b4e: TEdit
    Left = 989
    Top = 64
    Width = 46
    Height = 24
    TabOrder = 20
    Text = '0'
  end
  object b3e: TEdit
    Left = 926
    Top = 64
    Width = 46
    Height = 24
    TabOrder = 21
    Text = '0'
  end
  object b1re: TEdit
    Left = 808
    Top = 128
    Width = 46
    Height = 24
    TabOrder = 22
    Text = '0'
  end
  object b2re: TEdit
    Left = 871
    Top = 128
    Width = 46
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
  object x1e: TFloatSpinEdit
    Left = 326
    Top = 128
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 26
  end
  object x2e: TFloatSpinEdit
    Left = 325
    Top = 163
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 27
  end
  object x3e: TFloatSpinEdit
    Left = 325
    Top = 196
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 28
  end
  object y1e: TFloatSpinEdit
    Left = 396
    Top = 128
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 29
  end
  object y2e: TFloatSpinEdit
    Left = 395
    Top = 163
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 30
  end
  object y3e: TFloatSpinEdit
    Left = 395
    Top = 196
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 31
  end
  object z1e: TFloatSpinEdit
    Left = 466
    Top = 128
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 32
  end
  object z2e: TFloatSpinEdit
    Left = 465
    Top = 163
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 33
  end
  object z3e: TFloatSpinEdit
    Left = 465
    Top = 196
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 34
  end
  object CalX1: TFloatSpinEdit
    Left = 566
    Top = 128
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 35
  end
  object CalX2: TFloatSpinEdit
    Left = 565
    Top = 163
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 36
  end
  object CalX3: TFloatSpinEdit
    Left = 565
    Top = 196
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 37
  end
  object CalY1: TFloatSpinEdit
    Left = 636
    Top = 128
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 38
  end
  object CalY2: TFloatSpinEdit
    Left = 635
    Top = 163
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 39
  end
  object CalY3: TFloatSpinEdit
    Left = 635
    Top = 196
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 40
  end
  object CalZ1: TFloatSpinEdit
    Left = 706
    Top = 128
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 41
  end
  object CalZ2: TFloatSpinEdit
    Left = 705
    Top = 163
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 42
  end
  object CalZ3: TFloatSpinEdit
    Left = 705
    Top = 196
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 43
  end
  object BuildMatrix: TButton
    Left = 326
    Top = 240
    Width = 135
    Height = 25
    Caption = 'BuildCalibrM'
    TabOrder = 44
    OnClick = BuildMatrixClick
  end
  object Test_x: TFloatSpinEdit
    Left = 809
    Top = 172
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 45
  end
  object Test_y: TFloatSpinEdit
    Left = 808
    Top = 207
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 46
  end
  object Test_z: TFloatSpinEdit
    Left = 808
    Top = 240
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 47
  end
  object out_x: TFloatSpinEdit
    Left = 890
    Top = 172
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 48
  end
  object out_y: TFloatSpinEdit
    Left = 889
    Top = 207
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 49
  end
  object out_z: TFloatSpinEdit
    Left = 889
    Top = 240
    Width = 66
    Height = 26
    Increment = 0.100000000000000000
    TabOrder = 50
  end
  object TestBtn: TButton
    Left = 973
    Top = 240
    Width = 62
    Height = 25
    Caption = 'Test'
    TabOrder = 51
    OnClick = TestBtnClick
  end
  object IdUDPServer1: TIdUDPServer
    BroadcastEnabled = True
    Bindings = <>
    DefaultPort = 0
    OnUDPRead = IdUDPServer1UDPRead
    Left = 56
    Top = 560
  end
  object IdUDPClient1: TIdUDPClient
    BroadcastEnabled = True
    Port = 1700
    Left = 56
    Top = 512
  end
  object ViewUpdateTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ViewUpdateTimerTimer
    Left = 56
    Top = 472
  end
end
