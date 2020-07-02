object FFTFltFrm: TFFTFltFrm
  Left = 0
  Top = 0
  Caption = 'FFT '#1092#1080#1083#1100#1090#1088
  ClientHeight = 430
  ClientWidth = 1016
  Color = clBtnFace
  Constraints.MinHeight = 316
  Constraints.MinWidth = 790
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object ActionPanel: TPanel
    Left = 0
    Top = 371
    Width = 1016
    Height = 59
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 336
    ExplicitWidth = 772
    DesignSize = (
      1016
      59)
    object ApplyBtn: TButton
      Left = 10
      Top = 12
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
  end
  object RightPanel: TPanel
    Left = 691
    Top = 0
    Width = 325
    Height = 371
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 447
    ExplicitHeight = 336
    object BtnListView1: TBtnListView
      Left = 1
      Top = 1
      Width = 175
      Height = 369
      Align = alClient
      Columns = <
        item
          Caption = #1048#1085#1076'.'
        end
        item
          Caption = 'F'
        end
        item
          Caption = 'Scale'
        end>
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = True
      ExplicitHeight = 334
    end
    object SignalsLB: TListBox
      Left = 176
      Top = 1
      Width = 148
      Height = 369
      Align = alRight
      TabOrder = 1
      ExplicitHeight = 334
    end
  end
  object EditCurvePanel: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 371
    Align = alLeft
    TabOrder = 2
    ExplicitHeight = 336
    object F1Label: TLabel
      Left = 3
      Top = 10
      Width = 90
      Height = 16
      Caption = #1053#1072#1095#1072#1083#1086' '#1087#1086#1083#1086#1089#1099
    end
    object F2Label: TLabel
      Left = 106
      Top = 10
      Width = 82
      Height = 16
      Caption = #1050#1086#1085#1077#1094' '#1087#1086#1083#1086#1089#1099
    end
    object F1indLabel: TLabel
      Left = 3
      Top = 66
      Width = 52
      Height = 16
      Caption = #1048#1085#1076#1077#1082#1089' 1'
    end
    object F2indLabel: TLabel
      Left = 106
      Top = 66
      Width = 52
      Height = 16
      Caption = #1048#1085#1076#1077#1082#1089' 2'
    end
    object Label5: TLabel
      Left = 3
      Top = 122
      Width = 53
      Height = 16
      Caption = #1052#1072#1089#1096#1090#1072#1073
    end
    object FFTCountLabel: TLabel
      Left = 6
      Top = 234
      Width = 61
      Height = 16
      Caption = #1058#1086#1095#1077#1082' FFT'
    end
    object OffsetLabel: TLabel
      Left = 6
      Top = 288
      Width = 108
      Height = 16
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1087#1086#1088#1094#1080#1080
    end
    object dFLabel: TLabel
      Left = 114
      Top = 259
      Width = 23
      Height = 16
      Caption = 'dF='
    end
    object F1se: TSpinEdit
      Left = 3
      Top = 32
      Width = 97
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object F2se: TSpinEdit
      Left = 106
      Top = 32
      Width = 98
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object Indexse_01: TSpinEdit
      Left = 3
      Top = 88
      Width = 97
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
    object Indexse_02: TSpinEdit
      Left = 106
      Top = 88
      Width = 98
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
    end
    object ScaleSE: TSpinEdit
      Left = 3
      Top = 144
      Width = 97
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
    object Установить: TButton
      Left = 3
      Top = 181
      Width = 97
      Height = 25
      Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100
      TabOrder = 5
    end
    object PCountSE: TSpinEdit
      Left = 3
      Top = 256
      Width = 98
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 2048
      OnKeyDown = PCountSEKeyDown
      OnKeyUp = PCountSEKeyUp
    end
    object OffsetSE: TSpinEdit
      Left = 3
      Top = 310
      Width = 98
      Height = 26
      MaxValue = 0
      MinValue = 0
      TabOrder = 7
      Value = 2048
    end
  end
  object ScaleCurveChart: cChart
    Left = 209
    Top = 0
    Width = 482
    Height = 371
    Align = alClient
    Caption = 'ScaleCurveChart'
    TabOrder = 3
    allowEditPages = False
    showTV = False
    showLegend = True
    selectSize = 5
    ExplicitWidth = 238
    ExplicitHeight = 336
  end
end
