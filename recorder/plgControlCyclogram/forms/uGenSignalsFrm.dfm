object GenSignalsFrm: TGenSignalsFrm
  Left = 0
  Top = 0
  ClientHeight = 379
  ClientWidth = 499
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
    Left = 312
    Top = 0
    Height = 379
    Align = alRight
    ExplicitLeft = 344
    ExplicitTop = 96
    ExplicitHeight = 100
  end
  object PropertyPanel: TPanel
    Left = 0
    Top = 0
    Width = 312
    Height = 379
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
      Top = 75
      Width = 151
      Height = 24
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1080#1075#1085#1072#1083#1072
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
      Width = 121
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 1
      OnChange = AmpSEChange
    end
    object FreqSE: TFloatSpinEdit
      Left = 128
      Top = 96
      Width = 121
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 2
      OnChange = FreqSEChange
    end
    object PhaseSE: TFloatSpinEdit
      Left = 128
      Top = 160
      Width = 121
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 3
      OnChange = PhaseSEChange
    end
    object OffsetFE: TFloatSpinEdit
      Left = 128
      Top = 227
      Width = 123
      Height = 35
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 4
      OnChange = OffsetFEChange
    end
    object EnabledAlgMngCB: TCheckBox
      Left = 127
      Top = 312
      Width = 138
      Height = 17
      Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072
      Checked = True
      State = cbChecked
      TabOrder = 5
      OnClick = EnabledAlgMngCBClick
    end
    object GenDataCb: TCheckBox
      Left = 127
      Top = 281
      Width = 138
      Height = 17
      Caption = #1043#1077#1085#1077#1088#1072#1090#1086#1088
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = GenDataCbClick
    end
  end
  object SignalsLB: TListBox
    Left = 315
    Top = 0
    Width = 184
    Height = 379
    Align = alRight
    PopupMenu = PopupMenu1
    TabOrder = 1
    OnClick = SignalsLBClick
  end
  object PopupMenu1: TPopupMenu
    Left = 48
    Top = 296
    object N1: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
      OnClick = N1Click
    end
  end
end
