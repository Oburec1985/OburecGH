object FFTFltFrm: TFFTFltFrm
  Left = 0
  Top = 0
  Caption = 'FFT '#1092#1080#1083#1100#1090#1088
  ClientHeight = 323
  ClientWidth = 899
  Color = clBtnFace
  Constraints.MinHeight = 237
  Constraints.MinWidth = 593
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object ActionPanel: TPanel
    Left = 0
    Top = 278
    Width = 899
    Height = 45
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 0
    ExplicitWidth = 762
    DesignSize = (
      899
      45)
    object ApplyBtn: TButton
      Left = 8
      Top = 9
      Width = 73
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
  end
  object RightPanel: TPanel
    Left = 655
    Top = 0
    Width = 244
    Height = 278
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 518
    object BtnListView1: TBtnListView
      Left = 1
      Top = 1
      Width = 131
      Height = 276
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      Columns = <
        item
          Caption = #1048#1085#1076'.'
          Width = 38
        end
        item
          Caption = 'F'
          Width = 38
        end
        item
          Caption = 'Scale'
          Width = 38
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
    end
    object SignalsLB: TListBox
      Left = 132
      Top = 1
      Width = 111
      Height = 276
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alRight
      ItemHeight = 12
      TabOrder = 1
      OnClick = SignalsLBClick
    end
  end
  object EditCurvePanel: TPanel
    Left = 0
    Top = 0
    Width = 157
    Height = 278
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alLeft
    TabOrder = 2
    object F1Label: TLabel
      Left = 2
      Top = 8
      Width = 73
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1053#1072#1095#1072#1083#1086' '#1087#1086#1083#1086#1089#1099
    end
    object F2Label: TLabel
      Left = 80
      Top = 8
      Width = 68
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1050#1086#1085#1077#1094' '#1087#1086#1083#1086#1089#1099
    end
    object F1indLabel: TLabel
      Left = 2
      Top = 50
      Width = 43
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1085#1076#1077#1082#1089' 1'
    end
    object F2indLabel: TLabel
      Left = 80
      Top = 50
      Width = 43
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1048#1085#1076#1077#1082#1089' 2'
    end
    object Label5: TLabel
      Left = 2
      Top = 92
      Width = 43
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1052#1072#1089#1096#1090#1072#1073
    end
    object FFTCountLabel: TLabel
      Left = 5
      Top = 176
      Width = 49
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1058#1086#1095#1077#1082' FFT'
    end
    object OffsetLabel: TLabel
      Left = 5
      Top = 216
      Width = 88
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1087#1086#1088#1094#1080#1080
    end
    object dFLabel: TLabel
      Left = 104
      Top = 196
      Width = 19
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'dF='
    end
    object F1se: TSpinEdit
      Left = 2
      Top = 24
      Width = 73
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
    object F2se: TSpinEdit
      Left = 80
      Top = 24
      Width = 73
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object Indexse_01: TSpinEdit
      Left = 2
      Top = 66
      Width = 73
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
    object Indexse_02: TSpinEdit
      Left = 80
      Top = 66
      Width = 73
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
    end
    object ScaleSE: TSpinEdit
      Left = 2
      Top = 108
      Width = 73
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
    object Установить: TButton
      Left = 2
      Top = 136
      Width = 73
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1059#1089#1090#1072#1085#1086#1074#1080#1090#1100
      TabOrder = 5
    end
    object OffsetSE: TSpinEdit
      Left = 2
      Top = 232
      Width = 74
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 2048
    end
    object pCountIE: TIntEdit
      Left = 0
      Top = 191
      Width = 73
      Height = 20
      TabOrder = 7
      Text = '512'
    end
    object pCountBtn: TSpinButton
      Left = 79
      Top = 189
      Width = 20
      Height = 25
      DownGlyph.Data = {
        0E010000424D0E01000000000000360000002800000009000000060000000100
        200000000000D800000000000000000000000000000000000000008080000080
        8000008080000080800000808000008080000080800000808000008080000080
        8000008080000080800000808000000000000080800000808000008080000080
        8000008080000080800000808000000000000000000000000000008080000080
        8000008080000080800000808000000000000000000000000000000000000000
        0000008080000080800000808000000000000000000000000000000000000000
        0000000000000000000000808000008080000080800000808000008080000080
        800000808000008080000080800000808000}
      TabOrder = 8
      UpGlyph.Data = {
        0E010000424D0E01000000000000360000002800000009000000060000000100
        200000000000D800000000000000000000000000000000000000008080000080
        8000008080000080800000808000008080000080800000808000008080000080
        8000000000000000000000000000000000000000000000000000000000000080
        8000008080000080800000000000000000000000000000000000000000000080
        8000008080000080800000808000008080000000000000000000000000000080
        8000008080000080800000808000008080000080800000808000000000000080
        8000008080000080800000808000008080000080800000808000008080000080
        800000808000008080000080800000808000}
      OnDownClick = pCountBtnDownClick
      OnUpClick = pCountBtnUpClick
    end
  end
  object ScaleCurveChart: cChart
    Left = 157
    Top = 0
    Width = 498
    Height = 278
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    Caption = 'ScaleCurveChart'
    TabOrder = 3
    allowEditPages = False
    showTV = False
    showLegend = True
    selectSize = 5
    ExplicitWidth = 361
  end
end
