object PressFrmEdit: TPressFrmEdit
  Left = 0
  Top = 0
  Caption = 'PressFrmEdit'
  ClientHeight = 511
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  inline TagsListFrame1: TTagsListFrame
    Left = 348
    Top = 0
    Width = 285
    Height = 456
    Align = alRight
    TabOrder = 0
    ExplicitLeft = 348
    ExplicitWidth = 285
    ExplicitHeight = 456
    inherited FormChannelsGB: TGroupBox
      Width = 285
      Height = 456
      ExplicitWidth = 285
      ExplicitHeight = 456
      inherited ChanNamesPanel: TPanel
        Width = 281
        Height = 132
        ExplicitWidth = 281
        ExplicitHeight = 132
        inherited FrmTagPropLabel: TLabel
          Top = 59
          ExplicitTop = 59
        end
        inherited FrmTagPropValue: TLabel
          Left = 123
          ExplicitLeft = 123
        end
        inherited FilterEdit: TEdit
          Width = 270
          ExplicitWidth = 270
        end
        inherited FrmTagPropValueEdit: TEdit
          Left = 123
          Top = 83
          Width = 153
          ExplicitLeft = 123
          ExplicitTop = 83
          ExplicitWidth = 153
        end
        inherited FrmTagPropNameCB: TComboBox
          Top = 83
          Width = 107
          ExplicitTop = 83
          ExplicitWidth = 107
        end
      end
      inherited TagsLV: TBtnListView
        Top = 150
        Width = 281
        Height = 304
        Columns = <
          item
            Caption = #1048#1084#1103
            Width = 65
          end
          item
            Caption = #1058#1080#1087
            Width = 65
          end
          item
            Caption = 'Fs'
            Width = 51
          end>
        ExplicitTop = 150
        ExplicitWidth = 281
        ExplicitHeight = 304
      end
    end
  end
  object alClientGB: TGroupBox
    Left = 0
    Top = 0
    Width = 348
    Height = 456
    Align = alClient
    TabOrder = 1
    object TagLabel: TLabel
      Left = 9
      Top = 10
      Width = 52
      Height = 16
      Caption = #1048#1084#1103' '#1090#1077#1075#1072
    end
    object FFTCountLabel: TLabel
      Left = 9
      Top = 58
      Width = 102
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082' '#1041#1055#1060
    end
    object dFLabel: TLabel
      Left = 163
      Top = 63
      Width = 114
      Height = 16
      Caption = #1064#1072#1075' '#1087#1086' '#1095#1072#1089#1090#1086#1090#1077', '#1043#1094
    end
    object BCountLabel: TLabel
      Left = 9
      Top = 109
      Width = 73
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1087#1086#1083#1086#1089
    end
    object HHLabel: TLabel
      Left = 162
      Top = 146
      Width = 40
      Height = 16
      Caption = 'HH lev.'
    end
    object HLabel: TLabel
      Left = 163
      Top = 190
      Width = 35
      Height = 16
      Caption = 'H Lev.'
    end
    object Label2: TLabel
      Left = 9
      Top = 161
      Width = 27
      Height = 16
      Caption = 'Max.'
    end
    object TagnameCB: TRcComboBox
      Left = 9
      Top = 32
      Width = 146
      Height = 24
      TabOrder = 0
      Text = 'TagnameCB'
    end
    object FFTCountEdit: TIntEdit
      Left = 9
      Top = 80
      Width = 122
      Height = 24
      Enabled = False
      TabOrder = 1
      Text = '16384'
    end
    object FFTCountSpinBtn: TSpinButton
      Left = 136
      Top = 82
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
      OnDownClick = FFTCountSpinBtnDownClick
      OnUpClick = FFTCountSpinBtnUpClick
    end
    object FFTdX: TFloatEdit
      Left = 163
      Top = 80
      Width = 120
      Height = 24
      TabOrder = 3
      Text = '0.1'
    end
    object BCountSB: TSpinButton
      Left = 136
      Top = 129
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
      OnDownClick = BCountSBDownClick
      OnUpClick = BCountSBUpClick
    end
    object BCountIE: TIntEdit
      Left = 9
      Top = 131
      Width = 122
      Height = 24
      Enabled = False
      TabOrder = 5
      Text = '1'
    end
    object BandSG: TStringGridExt
      Left = 2
      Top = 237
      Width = 344
      Height = 217
      Align = alBottom
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedRowClick]
      TabOrder = 6
      OnKeyDown = BandSGKeyDown
      OnSelectCell = BandSGSelectCell
    end
    object HHFE: TFloatEdit
      Left = 162
      Top = 163
      Width = 120
      Height = 24
      TabOrder = 7
      Text = '0.7'
    end
    object HFE: TFloatEdit
      Left = 163
      Top = 207
      Width = 120
      Height = 24
      TabOrder = 8
      Text = '0.5'
    end
    object MaxFE: TFloatEdit
      Left = 9
      Top = 182
      Width = 122
      Height = 24
      TabOrder = 9
      Text = '10'
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 456
    Width = 633
    Height = 55
    Align = alBottom
    TabOrder = 2
    object UpdateAlgBtn: TSpeedButton
      Left = 3
      Top = 4
      Width = 64
      Height = 48
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1088#1077#1075#1091#1083#1103#1090#1086#1088
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
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
  end
end
