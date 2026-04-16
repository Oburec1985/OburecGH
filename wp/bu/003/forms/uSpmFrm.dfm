object SpmFrm: TSpmFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1088#1072#1089#1095#1077#1090#1072' '#1089#1087#1077#1082#1090#1088#1072
  ClientHeight = 639
  ClientWidth = 619
  Color = clBtnFace
  Constraints.MinHeight = 260
  Constraints.MinWidth = 471
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 619
    Height = 550
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 229
    inline WPSpmFrame1: TWPSpmFrame
      Left = 1
      Top = 1
      Width = 617
      Height = 548
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      inherited WndLabel: TLabel
        Width = 58
        Height = 17
        ExplicitWidth = 58
        ExplicitHeight = 17
      end
      inherited SpmTypeLabel: TLabel
        Width = 134
        Height = 17
        ExplicitWidth = 134
        ExplicitHeight = 17
      end
      inherited SpmResLabel: TLabel
        Width = 167
        Height = 17
        ExplicitWidth = 167
        ExplicitHeight = 17
      end
      inherited NumPointsLabel: TLabel
        Width = 82
        Height = 17
        ExplicitWidth = 82
        ExplicitHeight = 17
      end
      inherited WndCB: TComboBox
        Height = 25
        ExplicitHeight = 25
      end
      inherited SpmTypeCB: TComboBox
        Height = 25
        ExplicitHeight = 25
      end
      inherited SpmResCB: TComboBox
        Height = 25
        ExplicitHeight = 25
      end
      inherited NumPointsCB: TComboBox
        Height = 25
        ExplicitHeight = 25
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 550
    Width = 619
    Height = 89
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 229
    object CancelBtn: TButton
      Left = 5
      Top = 46
      Width = 98
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 361
      Top = 46
      Width = 98
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end
