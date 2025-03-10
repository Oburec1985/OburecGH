object PressFrmEdit2: TPressFrmEdit2
  Left = 0
  Top = 0
  Caption = 'PressFrmEdit2'
  ClientHeight = 465
  ClientWidth = 725
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  inline TagsListFrame1: TTagsListFrame
    Left = 512
    Top = 0
    Width = 213
    Height = 423
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    TabOrder = 0
    ExplicitLeft = 512
    ExplicitWidth = 213
    ExplicitHeight = 423
    inherited FormChannelsGB: TGroupBox
      Width = 213
      Height = 423
      Margins.Left = 3
      Margins.Top = 3
      Margins.Right = 3
      Margins.Bottom = 3
      ExplicitWidth = 213
      ExplicitHeight = 423
      inherited ChanNamesPanel: TPanel
        Top = 14
        Width = 209
        Height = 99
        Margins.Left = 3
        Margins.Top = 3
        Margins.Right = 3
        Margins.Bottom = 3
        ExplicitTop = 14
        ExplicitWidth = 209
        ExplicitHeight = 99
        DesignSize = (
          209
          99)
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
          Left = 92
          Top = 45
          Width = 43
          Height = 12
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          ExplicitLeft = 92
          ExplicitTop = 45
          ExplicitWidth = 43
          ExplicitHeight = 12
        end
        inherited FilterEdit: TEdit
          Left = 4
          Top = 6
          Width = 202
          Height = 20
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          ExplicitLeft = 4
          ExplicitTop = 6
          ExplicitWidth = 202
          ExplicitHeight = 20
        end
        inherited FrmTagPropValueEdit: TEdit
          Left = 92
          Top = 62
          Width = 115
          Height = 20
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          ExplicitLeft = 92
          ExplicitTop = 62
          ExplicitWidth = 115
          ExplicitHeight = 20
        end
        inherited FrmTagPropNameCB: TComboBox
          Left = 4
          Top = 62
          Width = 80
          Height = 20
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          ExplicitLeft = 4
          ExplicitTop = 62
          ExplicitWidth = 80
          ExplicitHeight = 20
        end
        inherited ShowScalarCB: TCheckBox
          Left = 4
          Top = 29
          Width = 147
          Height = 13
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          ExplicitLeft = 4
          ExplicitTop = 29
          ExplicitWidth = 147
          ExplicitHeight = 13
        end
      end
      inherited TagsLV: TBtnListView
        Top = 113
        Width = 209
        Height = 308
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
        ExplicitTop = 113
        ExplicitWidth = 209
        ExplicitHeight = 308
      end
    end
  end
  object alClientGB: TGroupBox
    Left = 0
    Top = 0
    Width = 512
    Height = 423
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    TabOrder = 1
    object FFTCountLabel: TLabel
      Left = 190
      Top = 17
      Width = 84
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082' '#1041#1055#1060
    end
    object dFLabel: TLabel
      Left = 283
      Top = 17
      Width = 36
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1055#1086#1088#1094#1080#1103
    end
    object BCountLabel: TLabel
      Left = 189
      Top = 234
      Width = 61
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1063#1080#1089#1083#1086' '#1087#1086#1083#1086#1089
    end
    object HHLabel: TLabel
      Left = 190
      Top = 91
      Width = 33
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'HH lev.'
    end
    object HLabel: TLabel
      Left = 263
      Top = 91
      Width = 29
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'H Lev.'
    end
    object BNumLabel: TLabel
      Left = 188
      Top = 192
      Width = 69
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1053#1086#1084#1077#1088' '#1087#1086#1083#1086#1089#1099
    end
    object RefLabel: TLabel
      Left = 332
      Top = 91
      Width = 14
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Ref'
    end
    object TypeLabel: TLabel
      Left = 281
      Top = 234
      Width = 56
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1058#1080#1087' '#1086#1094#1077#1085#1082#1080
    end
    object WndLab: TLabel
      Left = 371
      Top = 192
      Width = 26
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1054#1082#1085#1086
    end
    object Label4: TLabel
      Left = 190
      Top = 134
      Width = 42
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'H_AlTag:'
    end
    object HHLab: TLabel
      Left = 186
      Top = 165
      Width = 49
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'HH_AlTag:'
    end
    object AlarmLabel: TLabel
      Left = 339
      Top = 134
      Width = 34
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1040#1074#1072#1088#1080#1103
    end
    object NormalLabel: TLabel
      Left = 351
      Top = 164
      Width = 22
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Alive'
    end
    object Splitter1: TSplitter
      Left = 171
      Top = 14
      Height = 263
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 128
      ExplicitTop = 11
      ExplicitHeight = 267
    end
    object FFTCountEdit: TIntEdit
      Left = 190
      Top = 32
      Width = 61
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Enabled = False
      TabOrder = 0
      Text = '16384'
    end
    object FFTCountSpinBtn: TSpinButton
      Left = 254
      Top = 33
      Width = 15
      Height = 18
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
      TabOrder = 1
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
      Left = 281
      Top = 32
      Width = 90
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 2
      Text = '0.1'
    end
    object BCountSB: TSpinButton
      Left = 254
      Top = 250
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
      OnDownClick = BCountSBDownClick
      OnUpClick = BCountSBUpClick
    end
    object BCountIE: TIntEdit
      Left = 190
      Top = 249
      Width = 61
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Enabled = False
      TabOrder = 4
      Text = '1'
    end
    object BandSG: TStringGridExt
      Left = 2
      Top = 277
      Width = 508
      Height = 144
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alBottom
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedRowClick]
      TabOrder = 5
      OnDrawCell = BandSGDrawCell
      OnKeyDown = BandSGKeyDown
      OnSelectCell = BandSGSelectCell
    end
    object HHFE: TFloatEdit
      Left = 190
      Top = 103
      Width = 61
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 6
      Text = '0.7'
    end
    object HFE: TFloatEdit
      Left = 263
      Top = 103
      Width = 56
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 7
      Text = '0.5'
    end
    object BNumIE: TIntEdit
      Left = 190
      Top = 208
      Width = 61
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 8
      Text = '0'
    end
    object BNumSB: TSpinButton
      Left = 254
      Top = 210
      Width = 15
      Height = 18
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
      TabOrder = 9
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
      OnDownClick = BNumSBDownClick
      OnUpClick = BNumSBUpClick
    end
    object RefFE: TFloatEdit
      Left = 331
      Top = 103
      Width = 55
      Height = 20
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 10
      Text = '0.5'
      OnChange = RefFEChange
    end
    object TypeResCB: TComboBox
      Left = 281
      Top = 250
      Width = 94
      Height = 20
      ItemIndex = 0
      TabOrder = 11
      Text = #1057#1050#1054
      Items.Strings = (
        #1057#1050#1054
        'Pk-pk')
    end
    object CreateTagsCB: TCheckBox
      Left = 280
      Top = 210
      Width = 85
      Height = 17
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1090#1077#1075#1080
      TabOrder = 12
    end
    object WndCB: TComboBox
      Left = 371
      Top = 208
      Width = 86
      Height = 20
      TabOrder = 13
      Text = 'Rectangular'
      Items.Strings = (
        'Rectangular'
        'Hamming'
        'Hanning'
        'Blackman'
        'Flattop')
    end
    object AFHcb: TCheckBox
      Left = 376
      Top = 34
      Width = 51
      Height = 17
      Caption = #1040#1063#1061
      TabOrder = 14
      OnClick = AFHcbClick
    end
    object HH_AlTagCB: TRcComboBox
      Left = 240
      Top = 162
      Width = 79
      Height = 20
      TabOrder = 15
      Text = 'HH_AlTagCB'
    end
    object H_AlTagCB: TRcComboBox
      Left = 240
      Top = 131
      Width = 79
      Height = 20
      TabOrder = 16
      Text = 'RcComboBox1'
    end
    object AlarmCB: TRcComboBox
      Left = 378
      Top = 131
      Width = 73
      Height = 20
      TabOrder = 17
      Text = 'AlarmCB'
    end
    object NormalCB: TRcComboBox
      Left = 378
      Top = 162
      Width = 73
      Height = 20
      TabOrder = 18
      Text = 'AlarmCB'
    end
    object UseRefTagCb: TCheckBox
      Left = 332
      Top = 69
      Width = 138
      Height = 17
      Caption = #1058#1077#1075' '#1076#1083#1103' '#1086#1087#1086#1088#1085#1086#1075#1086' '#1091#1088#1086#1074#1085#1103
      TabOrder = 19
      OnClick = UseRefTagCbClick
    end
    object RefTagCb: TRcComboBox
      Left = 391
      Top = 103
      Width = 73
      Height = 20
      TabOrder = 20
      Text = 'AlarmCB'
    end
    object TagsLB: TListView
      Left = 2
      Top = 14
      Width = 169
      Height = 263
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      Checkboxes = True
      Columns = <
        item
          AutoSize = True
          Caption = #1057#1080#1075#1085#1072#1083
        end>
      GridLines = True
      Items.ItemData = {
        037C0000000300000000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF000000
        000644044B04320444044B04320400000000FFFFFFFFFFFFFFFF00000000FFFF
        FFFF0000000009320430043F04320430043F04320430043F0400000000FFFFFF
        FFFFFFFFFF00000000FFFFFFFF0000000008470441043C04470441043C044704
        4104}
      TabOrder = 21
      ViewStyle = vsReport
      OnChange = TagsLBChange
      OnDragDrop = TagsLBDragDrop
      OnDragOver = TagsLBDragOver
      OnKeyDown = TagsLBKeyDown
    end
    object UseRefProfileCB: TCheckBox
      Left = 332
      Top = 46
      Width = 150
      Height = 17
      Caption = #1047#1072#1076#1072#1090#1100' '#1087#1088#1086#1092#1080#1083#1100' '#1091#1089#1090#1072#1074#1086#1082
      TabOrder = 22
      OnClick = UseRefProfileCBClick
    end
    object useAlarmsCB: TCheckBox
      Left = 189
      Top = 69
      Width = 130
      Height = 17
      Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1072#1074#1072#1088#1080#1080
      TabOrder = 23
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 423
    Width = 725
    Height = 42
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 2
    object UpdateAlgBtn: TSpeedButton
      Left = 2
      Top = 5
      Width = 48
      Height = 36
      Hint = #1054#1073#1085#1086#1074#1080#1090#1100' '#1088#1077#1075#1091#1083#1103#1090#1086#1088
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
