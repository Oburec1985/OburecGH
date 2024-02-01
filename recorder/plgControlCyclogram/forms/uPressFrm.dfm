object PressCamFrm: TPressCamFrm
  Left = 0
  Top = 0
  Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072' '#1076#1072#1074#1083#1077#1085#1080#1103' '#1074' '#1082#1072#1084#1077#1088#1077' '#1089#1075#1086#1088#1072#1085#1080#1103
  ClientHeight = 530
  ClientWidth = 548
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  PixelsPerInch = 120
  TextHeight = 17
  object BarGraphGB: TGroupBox
    Left = 0
    Top = 0
    Width = 548
    Height = 530
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Caption = #1055#1086#1083#1086#1089#1072' '#8470
    TabOrder = 0
    object Panel1: TPanel
      Left = 2
      Top = 371
      Width = 544
      Height = 157
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      TabOrder = 1
      ExplicitLeft = 4
      ExplicitTop = 373
      object MaxLabel: TLabel
        Left = 99
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
        Left = 99
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
        Left = 99
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
        Left = 99
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
        Left = 276
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
        Left = 276
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
        Left = 276
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
        Left = 182
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
        Left = 182
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
        Left = 182
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
        Left = 182
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
        Left = 8
        Top = 9
        Width = 67
        Height = 22
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'AvrCB'
        TabOrder = 4
      end
      object RcComboBox1: TRcComboBox
        Left = 368
        Top = 8
        Width = 145
        Height = 25
        TabOrder = 5
        Text = 'RcComboBox1'
      end
    end
    object BarPanel: TPanel
      Left = 2
      Top = 19
      Width = 544
      Height = 49
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 0
      inline PressFrmFrame1: TPressFrmFrame
        Left = 1
        Top = 1
        Width = 542
        Height = 47
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 489
        DesignSize = (
          542
          47)
        inherited BandLabel: TLabel
          Width = 59
          Height = 17
          ExplicitWidth = 59
          ExplicitHeight = 17
        end
        inherited FreqEdit: TEdit
          Height = 25
          ExplicitHeight = 25
        end
        inherited AmpE: TEdit
          Height = 25
          ExplicitHeight = 25
        end
        inherited ProgrBar: TProgressBar
          Width = 342
          ExplicitWidth = 342
        end
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 48
    Top = 128
    object N1: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
      OnClick = N1Click
    end
  end
end
