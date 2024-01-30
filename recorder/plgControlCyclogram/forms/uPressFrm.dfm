object PressCamFrm: TPressCamFrm
  Left = 0
  Top = 0
  Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072' '#1076#1072#1074#1083#1077#1085#1080#1103' '#1074' '#1082#1072#1084#1077#1088#1077' '#1089#1075#1086#1088#1072#1085#1080#1103
  ClientHeight = 436
  ClientWidth = 483
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object BarGraphGB: TGroupBox
    Left = 0
    Top = 0
    Width = 483
    Height = 436
    Align = alClient
    Caption = #1055#1086#1083#1086#1089#1072' '#8470
    TabOrder = 0
    object BarPanel: TPanel
      Left = 2
      Top = 49
      Width = 479
      Height = 56
      Align = alTop
      TabOrder = 0
      object BandLabel: TLabel
        Left = 12
        Top = 16
        Width = 45
        Height = 13
        Caption = #1055#1086#1083#1086#1089#1072' 1'
      end
      object FreqEdit: TEdit
        Left = 63
        Top = 16
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 0
        Text = 'FreqEdit'
      end
      object ProgrBar: TProgressBar
        Left = 144
        Top = 16
        Width = 225
        Height = 25
        TabOrder = 1
      end
    end
    object Panel2: TPanel
      Left = 2
      Top = 15
      Width = 479
      Height = 34
      Align = alTop
      TabOrder = 1
    end
    object Panel1: TPanel
      Left = 2
      Top = 315
      Width = 479
      Height = 119
      Align = alBottom
      TabOrder = 2
      object MaxLabel: TLabel
        Left = 180
        Top = 8
        Width = 49
        Height = 13
        Caption = 'Max. ampl'
      end
      object MaxFreqLabel: TLabel
        Left = 180
        Top = 35
        Width = 43
        Height = 13
        Caption = 'Max freq'
      end
      object MaxCamLabel: TLabel
        Left = 180
        Top = 62
        Width = 57
        Height = 13
        Caption = 'Max Cam'#8470
      end
      object AvgAmpLabel: TLabel
        Left = 180
        Top = 89
        Width = 44
        Height = 13
        Caption = 'Avr.Ampl'
      end
      object UnitMaxALab: TLabel
        Left = 315
        Top = 8
        Width = 46
        Height = 13
        Caption = 'psi, pk-pk'
      end
      object UnitMaxFLab: TLabel
        Left = 315
        Top = 35
        Width = 12
        Height = 13
        Caption = 'Hz'
      end
      object UnitMaxAvrALab: TLabel
        Left = 315
        Top = 86
        Width = 46
        Height = 13
        Caption = 'psi, pk-pk'
      end
      object MaxAE: TEdit
        Left = 243
        Top = 5
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 0
        Text = 'FreqEdit'
      end
      object MaxFE: TEdit
        Left = 243
        Top = 32
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 1
        Text = 'FreqEdit'
      end
      object MaxCamE: TEdit
        Left = 243
        Top = 59
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 2
        Text = 'FreqEdit'
      end
      object MaxAvrAE: TEdit
        Left = 243
        Top = 86
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 3
        Text = 'FreqEdit'
      end
      object AvrCB: TCheckBox
        Left = 12
        Top = 8
        Width = 97
        Height = 17
        Caption = 'AvrCB'
        TabOrder = 4
      end
    end
  end
end
