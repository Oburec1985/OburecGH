object PressCamFrm: TPressCamFrm
  Left = 0
  Top = 0
  Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072' '#1076#1072#1074#1083#1077#1085#1080#1103' '#1074' '#1082#1072#1084#1077#1088#1077' '#1089#1075#1086#1088#1072#1085#1080#1103
  ClientHeight = 530
  ClientWidth = 530
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object BarGraphGB: TGroupBox
    Left = 0
    Top = 0
    Width = 530
    Height = 530
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Caption = #1055#1086#1083#1086#1089#1072' '#8470
    TabOrder = 0
    ExplicitWidth = 632
    ExplicitHeight = 570
    object BarPanel: TPanel
      Left = 2
      Top = 63
      Width = 526
      Height = 73
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 0
      ExplicitWidth = 628
      DesignSize = (
        526
        73)
      object BandLabel: TLabel
        Left = 16
        Top = 21
        Width = 59
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1055#1086#1083#1086#1089#1072' 1'
      end
      object FreqEdit: TEdit
        Left = 82
        Top = 21
        Width = 79
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ReadOnly = True
        TabOrder = 0
        Text = 'FreqEdit'
      end
      object ProgrBar: TProgressBar
        Left = 258
        Top = 17
        Width = 259
        Height = 33
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object AmpE: TEdit
        Left = 169
        Top = 21
        Width = 81
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ReadOnly = True
        TabOrder = 2
        Text = 'FreqEdit'
      end
    end
    object Panel2: TPanel
      Left = 2
      Top = 19
      Width = 526
      Height = 44
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 1
      ExplicitWidth = 628
    end
    object Panel1: TPanel
      Left = 2
      Top = 372
      Width = 526
      Height = 156
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      TabOrder = 2
      ExplicitTop = 412
      ExplicitWidth = 628
      object MaxLabel: TLabel
        Left = 235
        Top = 10
        Width = 62
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Max. ampl'
      end
      object MaxFreqLabel: TLabel
        Left = 235
        Top = 46
        Width = 53
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Max freq'
      end
      object MaxCamLabel: TLabel
        Left = 235
        Top = 81
        Width = 73
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Max Cam'#8470
      end
      object AvgAmpLabel: TLabel
        Left = 235
        Top = 116
        Width = 55
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Avr.Ampl'
      end
      object UnitMaxALab: TLabel
        Left = 412
        Top = 10
        Width = 59
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'psi, pk-pk'
      end
      object UnitMaxFLab: TLabel
        Left = 412
        Top = 46
        Width = 15
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Hz'
      end
      object UnitMaxAvrALab: TLabel
        Left = 412
        Top = 112
        Width = 59
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'psi, pk-pk'
      end
      object MaxAE: TEdit
        Left = 318
        Top = 7
        Width = 86
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ReadOnly = True
        TabOrder = 0
        Text = 'FreqEdit'
      end
      object MaxFE: TEdit
        Left = 318
        Top = 42
        Width = 86
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ReadOnly = True
        TabOrder = 1
        Text = 'FreqEdit'
      end
      object MaxCamE: TEdit
        Left = 318
        Top = 77
        Width = 86
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ReadOnly = True
        TabOrder = 2
        Text = 'FreqEdit'
      end
      object MaxAvrAE: TEdit
        Left = 318
        Top = 112
        Width = 86
        Height = 25
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        ReadOnly = True
        TabOrder = 3
        Text = 'FreqEdit'
      end
      object AvrCB: TCheckBox
        Left = 16
        Top = 10
        Width = 127
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'AvrCB'
        TabOrder = 4
      end
    end
  end
end
