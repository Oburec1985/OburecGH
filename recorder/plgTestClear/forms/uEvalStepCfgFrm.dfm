object EvalStepCfgFrm: TEvalStepCfgFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1088#1072#1089#1095#1077#1090#1072' '#1079#1085#1072#1095#1077#1085#1080#1103' '#1085#1072' '#1087#1077#1088#1077#1093#1086#1076#1085#1086' '#1087#1088#1086#1094#1077#1089#1089#1077
  ClientHeight = 510
  ClientWidth = 831
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object BottomPanel: TPanel
    Left = 0
    Top = 468
    Width = 831
    Height = 42
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 0
  end
  object RightPanel: TPanel
    Left = 570
    Top = 0
    Width = 261
    Height = 468
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    TabOrder = 1
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 259
      Height = 466
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 259
      ExplicitHeight = 466
      inherited FormChannelsGB: TGroupBox
        Width = 259
        Height = 466
        Margins.Left = 3
        Margins.Top = 3
        Margins.Right = 3
        Margins.Bottom = 3
        ExplicitWidth = 259
        ExplicitHeight = 466
        inherited ChanNamesPanel: TPanel
          Top = 14
          Width = 255
          Height = 83
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          ExplicitTop = 14
          ExplicitWidth = 255
          ExplicitHeight = 83
          inherited FrmTagPropLabel: TLabel
            Left = 4
            Top = 44
            Width = 46
            Height = 12
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 44
            ExplicitWidth = 46
            ExplicitHeight = 12
          end
          inherited FrmTagPropValue: TLabel
            Left = 91
            Top = 45
            Width = 43
            Height = 12
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 91
            ExplicitTop = 45
            ExplicitWidth = 43
            ExplicitHeight = 12
          end
          inherited FilterEdit: TEdit
            Left = 4
            Top = 6
            Width = 248
            Height = 20
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 6
            ExplicitWidth = 248
            ExplicitHeight = 20
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 91
            Top = 62
            Width = 161
            Height = 20
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 91
            ExplicitTop = 62
            ExplicitWidth = 161
            ExplicitHeight = 20
          end
          inherited FrmTagPropNameCB: TComboBox
            Left = 4
            Top = 62
            Width = 81
            Height = 20
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 62
            ExplicitWidth = 81
            ExplicitHeight = 20
          end
        end
        inherited TagsLV: TBtnListView
          Top = 97
          Width = 255
          Height = 367
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          Columns = <
            item
              Caption = #1048#1084#1103
              Width = 49
            end
            item
              Caption = #1058#1080#1087
              Width = 49
            end
            item
              Caption = 'Fs'
              Width = 38
            end>
          ExplicitTop = 97
          ExplicitWidth = 255
          ExplicitHeight = 367
        end
      end
    end
  end
  object MainPanel: TPanel
    Left = 175
    Top = 0
    Width = 395
    Height = 468
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    TabOrder = 2
    DesignSize = (
      395
      468)
    object InChanLabel: TLabel
      Left = 6
      Top = 147
      Width = 76
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1042#1093#1086#1076#1085#1086#1081' '#1082#1072#1085#1072#1083':'
    end
    object OutChanLabel: TLabel
      Left = 6
      Top = 206
      Width = 79
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1042#1099#1093#1086#1076#1085#1086#1081' '#1082#1072#1085#1072#1083
    end
    object FFTBlockSizeLabel: TLabel
      Left = 5
      Top = 290
      Width = 65
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1056#1072#1079#1084#1077#1088' '#1073#1083#1086#1082#1072
    end
    object FFTShiftLabel: TLabel
      Left = 149
      Top = 290
      Width = 81
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1073#1083#1086#1082#1072
    end
    object FsLabel: TLabel
      Left = 149
      Top = 206
      Width = 79
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1042#1099#1093#1086#1076#1085#1086#1081' '#1082#1072#1085#1072#1083
    end
    object InFsLabel: TLabel
      Left = 149
      Top = 147
      Width = 10
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Fs'
    end
    object FFTdxLabel: TLabel
      Left = 293
      Top = 289
      Width = 30
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'FFTdX'
    end
    object UpdateAlgBtn: TSpeedButton
      Left = 317
      Top = 329
      Width = 48
      Height = 36
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100
      AllowAllUp = True
      BiDiMode = bdLeftToRight
      Flat = True
      Glyph.Data = {
        360C0000424D360C000000000000360000002800000020000000200000000100
        180000000000000C0000C40E0000C40E00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFFFFE3DDDAFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD6A588C7723CF4FD
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEAE7E8D6651CD86B23DEE6
        EBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFCC713CE07933E47A2FCAAF
        A0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD4A993DC6B24E07B37E48037C988
        5FD3CBC9D2B8ABD1B2A3D0B8ACD5CAC6E2EBF3F4FBFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFECEBECD15F1BDD7432E07B37E2813CE481
        39E78235ED8B3EEF9243F39A4BF2994AE89047D79E72CCB8AFEBF4FDFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCA7647E07D3FDF7F40DF7C39E17E3AE586
        3FE88A43EA9147EC974BF09C4FF3A354F8AA59FDB059FFB45DDB9D68D0CBCEFD
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFD4AE9BDB6F2FDE7E41E08244E28748E48947E588
        45E68B43E98F46EC954BF09B4FF3A153F6A858F8AE5DFCB461FFBD64F5AB5DC8
        B6AFFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFEDEEF0CE6027DC7A3EDE7D40E08144E28545E48949E58E
        4CE99250EB9550EE994FF09B4DF39F4FF6A552F9AC59FCB360FEB864FFBB63FC
        B15CC9B6AFFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFC7734ADB7335DC7A3EDD7C41E08042E18446E48848E58C
        4BE89250EC9551DE8B4EE1A272E4AC81E5AB7AE69F61EE9E4EFFBB66FFBD68FF
        BD68F5AD61CFCBCDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFBFCFCCB7B53D8743DDC7335DD7C3FDF7F42E08345E38847E68B
        49EB9857C7AEA4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F9FFE7C6B3E9A669FF
        BC68FFC167DE9D68E7F1F9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFEADAD3D49472D7753ADF7B3AE18242E28647E489
        49EB904ACDA892FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE8
        CABAEFA863FFC168CBAEA0FEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0E8E6D9A283D8783CE2823FE488
        47E88B47D19062F2FAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFF9FBFFE8A978E69D60E7EFF6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6F5F6DCAE93D77C
        3FE88944DE7F3ADEE5EBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFE4AC88EEE7E3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFF
        FFE0B79FDA7B38D6BCAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFEEF8FEFCFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFF5F1EFCA5D14C69D85DEE7EEFBFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFC28F77E7F2F8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFD67737E77D30D7702AC69576D7DCE0F7FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFCF8764BB6840D6DDE0FFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFDDA37BE07730E3813BE78236DC7328C88C66D1
        CECEF3FDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFEBE1DCCC5015C35723C0A699EAF7FEFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFE7CDBFDF7429E07C38E17F3BE4833DE78339E1
        7629CB8455CCBFB9EDF9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFD39E84D1561ACD5114BE6438C2A79ADFE8EDF4FE
        FFFCFFFFFEFFFFFDFFFFF9FFFFE1EAF1D56922DE7835DF7B38E07E3AE2803BE3
        833DE6843AE47A2CCD783EDED8D6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFCFFFFCD7D54D4652DD15B20CF5316C4541BC070
        47C38669C58E73C68667C77145CF5D1DDC7230DC7432DD7734DE7936DF7B38E0
        7D39E17F3BE38038D97C3EEDEEF1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0EBE9CF7447D46831D46E38D3632AD159
        1BD25918D45C1BD5611FD76625D86B2BD86E2EDA7030DB7231DC7533DD7734DE
        7836DF7935DF7631D7C3BAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFE9E6CF7B51D4662DD46E38D773
        3ED56E36D4682FD36528D36325D46526D66829D76B2BD86D2DD96F2FDA7130DB
        7331DF722CCD8E6EFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9FBFCD2997DD5723FD366
        2DD66E38D7703AD7733DD8753ED8733BD87137D87035D97235D97234DA7335DC
        7231D1733BECF2F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE9DBD5D7A2
        86CC6F3ED87843D87238D76F34D97135DC773ADD7F41DA773FDB7A41DC7A3FDC
        793CD5BFB4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFE8D9D2E2C9BCE0C1B0E1C3B2E4D0C6D4A78BDA7135D9763DDC7438CA
        8E6CFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFECE2DDD77337D86E36D07742EA
        EEF1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCD7542D96F34D3BBAEFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDAA686C8835DFDFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9F5F4F8F8F8FFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = UpdateAlgBtnClick
    end
    object BlockSizeFLabel: TLabel
      Left = 5
      Top = 326
      Width = 90
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1056#1072#1079#1084#1077#1088' '#1073#1083#1086#1082#1072', '#1089#1077#1082'.'
    end
    object OutChanE: TEdit
      Left = 6
      Top = 222
      Width = 128
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 0
    end
    object FFTCb: TCheckBox
      Left = 5
      Top = 264
      Width = 72
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'FFT '#1092#1080#1083#1100#1090#1088
      Checked = True
      State = cbChecked
      TabOrder = 1
      Visible = False
    end
    object FFTSizeSB: TSpinButton
      Left = 119
      Top = 305
      Width = 15
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
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
      TabOrder = 2
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
      OnDownClick = FFTSizeSBDownClick
      OnUpClick = FFTSizeSBUpClick
    end
    object FFTBlockSizeIE: TIntEdit
      Left = 5
      Top = 306
      Width = 109
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 3
      Text = '32'
      OnChange = FFTBlockSizeIEChange
    end
    object FFTShiftSB: TSpinButton
      Left = 263
      Top = 305
      Width = 15
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
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
      TabOrder = 4
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
      OnDownClick = FFTSizeSBDownClick
      OnUpClick = FFTSizeSBUpClick
    end
    object FFTShiftIE: TIntEdit
      Left = 149
      Top = 306
      Width = 109
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 5
      Text = '32'
    end
    object TrigGB: TGroupBox
      Left = 1
      Top = 1
      Width = 390
      Height = 142
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Anchors = [akLeft, akTop, akRight]
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1090#1088#1080#1075#1075#1077#1088#1072
      TabOrder = 6
      object ThresholdLabel: TLabel
        Left = 3
        Top = 19
        Width = 29
        Height = 12
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1086#1088#1086#1075
      end
      object OffsetLabel: TLabel
        Left = 143
        Top = 19
        Width = 49
        Height = 12
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1057#1084#1077#1097#1077#1085#1080#1077
      end
      object ThresholdSE: TFloatSpinEdit
        Left = 3
        Top = 35
        Width = 128
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Increment = 0.100000000000000000
        TabOrder = 0
      end
      object OffsetSE: TFloatSpinEdit
        Left = 143
        Top = 35
        Width = 120
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Increment = 0.100000000000000000
        TabOrder = 1
      end
      object ScalarTagCB: TCheckBox
        Left = 267
        Top = 38
        Width = 82
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1057#1082#1072#1083#1103#1088#1085#1099#1081' '#1090#1077#1075
        TabOrder = 2
      end
      object ValTypeRG: TRadioGroup
        Left = 4
        Top = 59
        Width = 135
        Height = 61
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1088#1077#1076#1085#1072#1089#1090#1088#1086#1081#1082#1072' '#1092#1080#1083#1100#1090#1088#1072
        ItemIndex = 0
        Items.Strings = (
          '- '#1052#1075#1085#1086#1074#1077#1085#1085#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077
          '- '#1057#1088#1077#1076#1085#1077#1077)
        TabOrder = 3
        OnClick = ValTypeRGClick
      end
    end
    object FsSE: TFloatSpinEdit
      Left = 149
      Top = 222
      Width = 129
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      TabOrder = 7
    end
    object InChanCB: TRcComboBox
      Left = 5
      Top = 164
      Width = 129
      Height = 20
      TabOrder = 8
    end
    object InFsFE: TFloatEdit
      Left = 149
      Top = 164
      Width = 74
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Enabled = False
      TabOrder = 9
      Text = '0.0'
    end
    object FFTdxFE: TFloatEdit
      Left = 293
      Top = 306
      Width = 74
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Enabled = False
      TabOrder = 10
      Text = '0.0'
    end
    object BlockSizeFE: TFloatEdit
      Left = 5
      Top = 341
      Width = 109
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 11
      Text = '0.0'
    end
    object FltRG: TRadioGroup
      Left = 4
      Top = 363
      Width = 164
      Height = 101
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1055#1088#1077#1076#1085#1072#1089#1090#1088#1086#1081#1082#1072' '#1092#1080#1083#1100#1090#1088#1072
      Items.Strings = (
        '- AC ('#1091#1076#1072#1083#1080#1090#1100' DC)'
        '- '#1060#1053#1063' 1/2 ('#1055#1086#1083#1086#1074#1080#1085#1072' '#1087#1086#1083#1086#1089#1099')'
        '- '#1060#1053#1063' 10 Hz'
        '- '#1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100#1089#1082#1080#1081)
      TabOrder = 12
      OnClick = FltRGClick
    end
  end
  object LeftPanel: TPanel
    Left = 0
    Top = 0
    Width = 175
    Height = 468
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alLeft
    TabOrder = 3
    object AlgsLB: TListBox
      Left = 1
      Top = 1
      Width = 173
      Height = 234
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alTop
      ItemHeight = 12
      MultiSelect = True
      TabOrder = 0
      OnClick = AlgsLBClick
      OnDragDrop = AlgsLBDragDrop
      OnDragOver = AlgsLBDragOver
      OnKeyDown = AlgsLBKeyDown
      OnMouseUp = AlgsLBMouseUp
    end
    object ScalesLV: TBtnListView
      Left = 1
      Top = 235
      Width = 173
      Height = 232
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
        end
        item
          Caption = 'Scale'
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      MultiSelect = True
      RowSelect = True
      ParentFont = False
      TabOrder = 1
      ViewStyle = vsReport
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = True
    end
  end
  object MeanGB: TGroupBox
    Left = 319
    Top = 60
    Width = 162
    Height = 61
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1059#1089#1088#1077#1076#1085#1077#1085#1080#1077
    TabOrder = 4
    Visible = False
    object TrigMeanLenLabel: TLabel
      Left = 11
      Top = 19
      Width = 52
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1083#1080#1085#1072', '#1089#1077#1082
    end
    object Label1: TLabel
      Left = 11
      Top = 42
      Width = 56
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1044#1083#1080#1085#1072', '#1090#1095#1082'.'
    end
    object TrigMeanLenFE: TFloatSpinEdit
      Left = 71
      Top = 16
      Width = 78
      Height = 21
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Increment = 0.100000000000000000
      TabOrder = 0
      OnChange = TrigMeanLenFEChange
    end
    object TrigMeanLenIE: TIntEdit
      Left = 71
      Top = 38
      Width = 78
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      Text = '000'
      OnChange = TrigMeanLenIEChange
    end
  end
end
