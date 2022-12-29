object EvalStepCfgFrm: TEvalStepCfgFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1088#1072#1089#1095#1077#1090#1072' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1085#1072' '#1087#1077#1088#1077#1093#1086#1076#1085#1086' '#1087#1088#1086#1094#1077#1089#1089#1077
  ClientHeight = 448
  ClientWidth = 1118
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object BottomPanel: TPanel
    Left = 0
    Top = 379
    Width = 1118
    Height = 69
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 424
    ExplicitWidth = 876
  end
  object RightPanel: TPanel
    Left = 770
    Top = 0
    Width = 348
    Height = 379
    Align = alRight
    TabOrder = 1
    ExplicitLeft = 528
    ExplicitHeight = 452
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 346
      Height = 377
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 96
      ExplicitTop = -21
      inherited FormChannelsGB: TGroupBox
        Width = 346
        Height = 377
        inherited ChanNamesPanel: TPanel
          Width = 342
          inherited FilterEdit: TEdit
            Width = 331
          end
          inherited FrmTagPropValueEdit: TEdit
            Width = 215
          end
        end
        inherited TagsLV: TBtnListView
          Width = 342
          Height = 246
        end
      end
    end
  end
  object AlgsLB: TListBox
    Left = 0
    Top = 0
    Width = 249
    Height = 379
    Align = alLeft
    TabOrder = 2
    ExplicitHeight = 475
  end
  object MainPanel: TPanel
    Left = 249
    Top = 0
    Width = 521
    Height = 379
    Align = alClient
    TabOrder = 3
    ExplicitLeft = 245
    ExplicitTop = 8
    ExplicitWidth = 467
    ExplicitHeight = 475
    DesignSize = (
      521
      379)
    object InChanLabel: TLabel
      Left = 8
      Top = 108
      Width = 91
      Height = 16
      Caption = #1042#1093#1086#1076#1085#1086#1081' '#1082#1072#1085#1072#1083':'
    end
    object OutChanLabel: TLabel
      Left = 8
      Top = 186
      Width = 95
      Height = 16
      Caption = #1042#1099#1093#1086#1076#1085#1086#1081' '#1082#1072#1085#1072#1083
    end
    object FFTBlockSizeLabel: TLabel
      Left = 6
      Top = 298
      Width = 80
      Height = 16
      Caption = #1056#1072#1079#1084#1077#1088' '#1073#1083#1086#1082#1072
    end
    object FFTShiftLabel: TLabel
      Left = 198
      Top = 298
      Width = 100
      Height = 16
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1073#1083#1086#1082#1072
    end
    object FsLabel: TLabel
      Left = 198
      Top = 186
      Width = 95
      Height = 16
      Caption = #1042#1099#1093#1086#1076#1085#1086#1081' '#1082#1072#1085#1072#1083
    end
    object InChanCB: TComboBox
      Left = 8
      Top = 134
      Width = 170
      Height = 24
      TabOrder = 0
    end
    object OutChanE: TEdit
      Left = 8
      Top = 208
      Width = 170
      Height = 24
      TabOrder = 1
    end
    object FFTCb: TCheckBox
      Left = 6
      Top = 264
      Width = 97
      Height = 17
      Caption = 'FFT '#1092#1080#1083#1100#1090#1088
      TabOrder = 2
    end
    object FFTSizeSB: TSpinButton
      Left = 158
      Top = 319
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
      TabOrder = 3
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
    end
    object FFTBlockSizeIE: TIntEdit
      Left = 6
      Top = 320
      Width = 146
      Height = 24
      TabOrder = 4
      Text = '000'
    end
    object FFTShiftSB: TSpinButton
      Left = 350
      Top = 319
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
      TabOrder = 5
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
    end
    object FFTShiftIE: TIntEdit
      Left = 198
      Top = 320
      Width = 146
      Height = 24
      TabOrder = 6
      Text = '000'
    end
    object TrigGB: TGroupBox
      Left = 1
      Top = 1
      Width = 514
      Height = 88
      Anchors = [akLeft, akTop, akRight]
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1090#1088#1080#1075#1075#1077#1088#1072
      TabOrder = 7
      ExplicitWidth = 517
      object ThresholdLabel: TLabel
        Left = 4
        Top = 25
        Width = 34
        Height = 16
        Caption = #1055#1086#1088#1086#1075
      end
      object OffsetLabel: TLabel
        Left = 180
        Top = 25
        Width = 62
        Height = 16
        Caption = #1057#1084#1077#1097#1077#1085#1080#1077
      end
      object ThresholdSE: TFloatSpinEdit
        Left = 4
        Top = 47
        Width = 170
        Height = 26
        Increment = 0.100000000000000000
        TabOrder = 0
      end
      object OffsetSE: TFloatSpinEdit
        Left = 180
        Top = 47
        Width = 170
        Height = 26
        Increment = 0.100000000000000000
        TabOrder = 1
      end
    end
    object FsSE: TFloatSpinEdit
      Left = 198
      Top = 208
      Width = 172
      Height = 26
      Increment = 0.100000000000000000
      TabOrder = 8
    end
  end
end
