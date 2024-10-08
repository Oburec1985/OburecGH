object GenSignalsFrm: TGenSignalsFrm
  Left = 0
  Top = 0
  ClientHeight = 421
  ClientWidth = 685
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Splitter1: TSplitter
    Left = 499
    Top = 0
    Width = 2
    Height = 421
    Align = alRight
  end
  object PropertyPanel: TPanel
    Left = 0
    Top = 0
    Width = 499
    Height = 421
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    PopupMenu = PopupMenu1
    TabOrder = 0
    object AmpLabel: TLabel
      Left = 128
      Top = 0
      Width = 177
      Height = 24
      Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1089#1080#1075#1085#1072#1083#1072
    end
    object FreqLabel: TLabel
      Left = 128
      Top = 71
      Width = 43
      Height = 24
      Caption = 'F, '#1043#1094
    end
    object PhaseLabel: TLabel
      Left = 128
      Top = 135
      Width = 105
      Height = 24
      Caption = #1060#1072#1079#1072', '#1075#1088#1072#1076'.'
    end
    object FormTimerLabel: TLabel
      Left = 8
      Top = 211
      Width = 69
      Height = 24
      Caption = 'T'#1092#1086#1088#1084':'
      Visible = False
    end
    object SysTimerLabel: TLabel
      Left = 8
      Top = 164
      Width = 46
      Height = 24
      Caption = 'Trec:'
      Visible = False
    end
    object Label1: TLabel
      Left = 128
      Top = 200
      Width = 96
      Height = 24
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077
    end
    object F2SweepLabel: TLabel
      Left = 241
      Top = 71
      Width = 54
      Height = 24
      Caption = 'F2, '#1043#1094
    end
    object SweepTimeLabel: TLabel
      Left = 347
      Top = 71
      Width = 65
      Height = 24
      Caption = 'T2, '#1089#1077#1082
    end
    object PhaseVelLabel: TLabel
      Left = 241
      Top = 136
      Width = 79
      Height = 24
      Caption = #1075#1088#1072#1076'/'#1089#1077#1082
    end
    object STypeRG: TRadioGroup
      Left = 0
      Top = 0
      Width = 105
      Height = 125
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
      Left = 128
      Top = 27
      Width = 97
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 1
      OnChange = AmpSEChange
    end
    object FreqSE: TFloatSpinEdit
      Left = 128
      Top = 96
      Width = 97
      Height = 35
      Increment = 1.000000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 2
      OnChange = FreqSEChange
    end
    object PhaseSE: TFloatSpinEdit
      Left = 128
      Top = 160
      Width = 97
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 3
      OnChange = PhaseSEChange
    end
    object OffsetFE: TFloatSpinEdit
      Left = 128
      Top = 227
      Width = 97
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 4
      OnChange = OffsetFEChange
    end
    object EnabledAlgMngCB: TCheckBox
      Left = 127
      Top = 336
      Width = 138
      Height = 17
      Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object GenDataCb: TCheckBox
      Left = 127
      Top = 305
      Width = 138
      Height = 18
      Caption = #1043#1077#1085#1077#1088#1072#1090#1086#1088
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = GenDataCbClick
    end
    object SweepSinCB: TCheckBox
      Left = 123
      Top = 269
      Width = 106
      Height = 18
      Caption = 'Sweep'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = SweepSinCBClick
    end
    object Freq2Fe: TFloatSpinEdit
      Left = 241
      Top = 96
      Width = 90
      Height = 35
      Increment = 5.000000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 8
      OnChange = Freq2FeChange
    end
    object TimeSe: TFloatSpinEdit
      Left = 344
      Top = 96
      Width = 91
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 9
      Value = 100.000000000000000000
      OnChange = TimeSeChange
    end
    object SweepLgCB: TCheckBox
      Left = 235
      Top = 268
      Width = 53
      Height = 27
      Caption = 'Lg'
      Checked = True
      State = cbChecked
      TabOrder = 10
      OnClick = SweepLgCBClick
    end
    object PhaseVelSE: TFloatSpinEdit
      Left = 241
      Top = 160
      Width = 90
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 11
      Value = 5.000000000000000000
      OnChange = PhaseVelSEChange
    end
    object ChangePhaseCB: TCheckBox
      Left = 347
      Top = 167
      Width = 142
      Height = 17
      Caption = #1052#1077#1085#1103#1090#1100' '#1092#1072#1079#1091
      Checked = True
      State = cbChecked
      TabOrder = 12
      OnClick = ChangePhaseCBClick
    end
  end
  object SignalsLB: TListBox
    Left = 501
    Top = 0
    Width = 184
    Height = 421
    Align = alRight
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
