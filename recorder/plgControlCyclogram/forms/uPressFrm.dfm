object PressCamFrm: TPressCamFrm
  Left = 0
  Top = 0
  Caption = #1054#1073#1088#1072#1073#1086#1090#1082#1072' '#1076#1072#1074#1083#1077#1085#1080#1103' '#1074' '#1082#1072#1084#1077#1088#1077' '#1089#1075#1086#1088#1072#1085#1080#1103
  ClientHeight = 405
  ClientWidth = 419
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  PixelsPerInch = 96
  TextHeight = 13
  object BarGraphGB: TGroupBox
    Left = 0
    Top = 0
    Width = 419
    Height = 405
    Align = alClient
    Caption = #1055#1086#1083#1086#1089#1072' '#8470
    TabOrder = 0
    object Panel1: TPanel
      Left = 2
      Top = 283
      Width = 415
      Height = 120
      Align = alBottom
      TabOrder = 1
      object MaxLabel: TLabel
        Left = 76
        Top = 8
        Width = 49
        Height = 13
        Caption = 'Max. ampl'
      end
      object MaxFreqLabel: TLabel
        Left = 76
        Top = 35
        Width = 43
        Height = 13
        Caption = 'Max freq'
      end
      object MaxCamLabel: TLabel
        Left = 76
        Top = 62
        Width = 57
        Height = 13
        Caption = 'Max Cam'#8470
      end
      object AvgAmpLabel: TLabel
        Left = 76
        Top = 89
        Width = 44
        Height = 13
        Caption = 'Avr.Ampl'
      end
      object UnitMaxALab: TLabel
        Left = 211
        Top = 8
        Width = 46
        Height = 13
        Caption = 'psi, pk-pk'
      end
      object UnitMaxFLab: TLabel
        Left = 211
        Top = 35
        Width = 12
        Height = 13
        Caption = 'Hz'
      end
      object UnitMaxAvrALab: TLabel
        Left = 211
        Top = 86
        Width = 46
        Height = 13
        Caption = 'psi, pk-pk'
      end
      object MaxAE: TEdit
        Left = 139
        Top = 5
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 0
        Text = 'FreqEdit'
      end
      object MaxFE: TEdit
        Left = 139
        Top = 32
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 1
        Text = 'FreqEdit'
      end
      object MaxCamE: TEdit
        Left = 139
        Top = 59
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 2
        Text = 'FreqEdit'
      end
      object MaxAvrAE: TEdit
        Left = 139
        Top = 86
        Width = 66
        Height = 21
        ReadOnly = True
        TabOrder = 3
        Text = 'FreqEdit'
      end
      object AvrCB: TCheckBox
        Left = 6
        Top = 7
        Width = 51
        Height = 17
        Caption = 'AvrCB'
        TabOrder = 4
      end
      object RcComboBox1: TRcComboBox
        Left = 281
        Top = 6
        Width = 111
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 5
        Text = 'RcComboBox1'
      end
    end
    object BarPanel: TPanel
      Left = 2
      Top = 15
      Width = 415
      Height = 37
      Align = alTop
      TabOrder = 0
      inline PressFrmFrame1: TPressFrmFrame
        Left = 1
        Top = 1
        Width = 413
        Height = 35
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 413
        ExplicitHeight = 35
        DesignSize = (
          413
          35)
        inherited BandLabel: TLabel
          Left = 4
          Top = 3
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          ExplicitLeft = 4
          ExplicitTop = 3
        end
        inherited FreqEdit: TEdit
          Left = 48
          Width = 46
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          ExplicitLeft = 48
          ExplicitWidth = 46
        end
        inherited AmpE: TEdit
          Left = 99
          Top = 4
          Width = 47
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          ExplicitLeft = 99
          ExplicitTop = 4
          ExplicitWidth = 47
        end
        inherited ProgrBar: TProgressBar
          Left = 151
          Width = 261
          Height = 19
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          ExplicitLeft = 151
          ExplicitWidth = 261
          ExplicitHeight = 19
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
