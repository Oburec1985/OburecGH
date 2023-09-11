object GenSignalsFrm: TGenSignalsFrm
  Left = 0
  Top = 0
  Caption = 'TGenSignalsFrm'
  ClientHeight = 284
  ClientWidth = 432
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object PropertyPanel: TPanel
    Left = 0
    Top = 0
    Width = 242
    Height = 284
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
      Top = 56
      Width = 115
      Height = 18
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1080#1075#1085#1072#1083#1072
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
      Width = 91
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
      Width = 91
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 2
      OnChange = FreqSEChange
    end
    object PhaseSE: TFloatSpinEdit
      Left = 96
      Top = 120
      Width = 91
      Height = 28
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 3
      OnChange = PhaseSEChange
    end
    object OffsetFE: TFloatSpinEdit
      Left = 96
      Top = 170
      Width = 92
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
  end
  object SignalsLB: TListBox
    Left = 242
    Top = 0
    Width = 190
    Height = 284
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    ItemHeight = 12
    PopupMenu = PopupMenu1
    TabOrder = 1
    OnClick = SignalsLBClick
  end
  object PopupMenu1: TPopupMenu
    Left = 88
    Top = 296
    object N1: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
      OnClick = N1Click
    end
  end
end
