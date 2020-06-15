object GenSignalsFrm: TGenSignalsFrm
  Left = 0
  Top = 0
  Caption = 'TGenSignalsFrm'
  ClientHeight = 201
  ClientWidth = 445
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object PropertyPanel: TPanel
    Left = 0
    Top = 0
    Width = 288
    Height = 201
    Align = alClient
    PopupMenu = PopupMenu1
    TabOrder = 0
    object AmpLabel: TLabel
      Left = 128
      Top = 4
      Width = 113
      Height = 16
      Caption = #1040#1084#1087#1083#1080#1090#1091#1076#1072' '#1089#1080#1075#1085#1072#1083#1072
    end
    object FreqLabel: TLabel
      Left = 128
      Top = 53
      Width = 97
      Height = 16
      Caption = #1063#1072#1089#1090#1086#1090#1072' '#1089#1080#1075#1085#1072#1083#1072
    end
    object PhaseLabel: TLabel
      Left = 128
      Top = 108
      Width = 68
      Height = 16
      Caption = #1060#1072#1079#1072', '#1075#1088#1072#1076'.'
    end
    object FormTimerLabel: TLabel
      Left = 8
      Top = 120
      Width = 45
      Height = 16
      Caption = 'T'#1092#1086#1088#1084':'
    end
    object SysTimerLabel: TLabel
      Left = 8
      Top = 152
      Width = 31
      Height = 16
      Caption = 'Trec:'
    end
    object STypeRG: TRadioGroup
      Left = 0
      Top = 0
      Width = 105
      Height = 105
      Caption = #1058#1080#1087' '#1089#1080#1075#1085#1072#1083#1072
      Items.Strings = (
        #1057#1080#1085#1091#1089
        #1055#1080#1083#1072
        #1064#1059#1084)
      PopupMenu = PopupMenu1
      TabOrder = 0
    end
    object AmpSE: TFloatSpinEdit
      Left = 128
      Top = 26
      Width = 121
      Height = 26
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 1
      OnChange = AmpSEChange
    end
    object FreqSE: TFloatSpinEdit
      Left = 128
      Top = 75
      Width = 121
      Height = 26
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 2
    end
    object PhaseSE: TFloatSpinEdit
      Left = 128
      Top = 130
      Width = 121
      Height = 26
      Increment = 0.100000000000000000
      PopupMenu = PopupMenu1
      TabOrder = 3
      OnChange = PhaseSEChange
    end
  end
  object SignalsLB: TListBox
    Left = 288
    Top = 0
    Width = 157
    Height = 201
    Align = alRight
    PopupMenu = PopupMenu1
    TabOrder = 1
    OnClick = SignalsLBClick
  end
  object PopupMenu1: TPopupMenu
    Left = 72
    Top = 144
    object N1: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
      OnClick = N1Click
    end
  end
end
