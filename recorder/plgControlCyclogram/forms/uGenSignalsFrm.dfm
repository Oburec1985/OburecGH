object GenSignalsFrm: TGenSignalsFrm
  Left = 0
  Top = 0
  ClientHeight = 316
  ClientWidth = 514
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object Splitter1: TSplitter
    Left = 374
    Top = 0
    Width = 2
    Height = 316
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
  end
  object PropertyPanel: TPanel
    Left = 0
    Top = 0
    Width = 374
    Height = 316
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    PopupMenu = PopupMenu1
    TabOrder = 0
    object AmpLabel: TLabel
      Left = 96
      Top = 0
      Width = 133
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1089#1080#1075#1085#1072#1083#1072
    end
    object FreqLabel: TLabel
      Left = 96
      Top = 53
      Width = 35
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'F, '#1043#1094
    end
    object PhaseLabel: TLabel
      Left = 96
      Top = 101
      Width = 78
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1060#1072#1079#1072', '#1075#1088#1072#1076'.'
    end
    object FormTimerLabel: TLabel
      Left = 6
      Top = 158
      Width = 53
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'T'#1092#1086#1088#1084':'
      Visible = False
    end
    object SysTimerLabel: TLabel
      Left = 6
      Top = 123
      Width = 35
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Trec:'
      Visible = False
    end
    object Label1: TLabel
      Left = 96
      Top = 150
      Width = 72
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077
    end
    object F2SweepLabel: TLabel
      Left = 181
      Top = 53
      Width = 43
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'F2, '#1043#1094
    end
    object SweepTimeLabel: TLabel
      Left = 260
      Top = 53
      Width = 50
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'T2, '#1089#1077#1082
    end
    object PhaseVelLabel: TLabel
      Left = 181
      Top = 102
      Width = 58
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1075#1088#1072#1076'/'#1089#1077#1082
    end
    object STypeRG: TRadioGroup
      Left = 0
      Top = 0
      Width = 79
      Height = 94
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1058#1080#1087' '#1089#1080#1075#1085#1072#1083#1072
      ItemIndex = 0
      Items.Strings = (
        #1057#1080#1085#1091#1089
        #1055#1080#1083#1072
        #1064#1059#1084)
      PopupMenu = PopupMenu1
      TabOrder = 0
    end
    object AmpSE: TFloatSpinEdit
      Left = 96
      Top = 20
      Width = 73
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 1
      OnChange = AmpSEChange
    end
    object FreqSE: TFloatSpinEdit
      Left = 96
      Top = 72
      Width = 73
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 1.000000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 2
      OnChange = FreqSEChange
    end
    object PhaseSE: TFloatSpinEdit
      Left = 96
      Top = 120
      Width = 73
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 5.000000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 3
      OnChange = PhaseSEChange
    end
    object OffsetFE: TFloatSpinEdit
      Left = 96
      Top = 170
      Width = 73
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 4
      OnChange = OffsetFEChange
    end
    object EnabledAlgMngCB: TCheckBox
      Left = 95
      Top = 252
      Width = 104
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object GenDataCb: TCheckBox
      Left = 95
      Top = 229
      Width = 104
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1043#1077#1085#1077#1088#1072#1090#1086#1088
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = GenDataCbClick
    end
    object SweepSinCB: TCheckBox
      Left = 92
      Top = 202
      Width = 80
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Sweep'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = SweepSinCBClick
    end
    object Freq2Fe: TFloatSpinEdit
      Left = 181
      Top = 72
      Width = 67
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 5.000000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 8
      OnChange = Freq2FeChange
    end
    object TimeSe: TFloatSpinEdit
      Left = 258
      Top = 72
      Width = 68
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 9
      Value = 100.000000000000000000
      OnChange = TimeSeChange
    end
    object SweepLgCB: TCheckBox
      Left = 176
      Top = 201
      Width = 40
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Lg'
      Checked = True
      State = cbChecked
      TabOrder = 10
      OnClick = SweepLgCBClick
    end
    object PhaseVelSE: TFloatSpinEdit
      Left = 181
      Top = 120
      Width = 67
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 11
      Value = 5.000000000000000000
      OnChange = PhaseVelSEChange
    end
    object ChangePhaseCB: TCheckBox
      Left = 260
      Top = 125
      Width = 107
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1052#1077#1085#1103#1090#1100' '#1092#1072#1079#1091
      Checked = True
      State = cbChecked
      TabOrder = 12
      OnClick = ChangePhaseCBClick
    end
  end
  object SignalsLB: TListBox
    Left = 376
    Top = 0
    Width = 138
    Height = 316
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    ItemHeight = 12
    PopupMenu = PopupMenu1
    TabOrder = 1
    OnClick = SignalsLBClick
    OnKeyDown = SignalsLBKeyDown
  end
  object PopupMenu1: TPopupMenu
    Left = 24
    Top = 248
    object N1: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
      OnClick = N1Click
    end
  end
end
