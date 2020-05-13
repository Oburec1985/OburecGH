inherited SynchroPhasePhrame: TSynchroPhasePhrame
  ExplicitHeight = 478
  object ChannelLabel: TLabel [2]
    Left = 10
    Top = 106
    Width = 31
    Height = 13
    Caption = #1050#1072#1085#1072#1083
  end
  object Label1: TLabel [3]
    Left = 178
    Top = 106
    Width = 24
    Height = 13
    Caption = #1058#1072#1093#1086
  end
  object FsLabel: TLabel [4]
    Left = 10
    Top = 162
    Width = 119
    Height = 13
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1086#1087#1088#1086#1089#1072' '#1082#1072#1085#1072#1083#1072
  end
  object Label2: TLabel [5]
    Left = 178
    Top = 162
    Width = 33
    Height = 13
    Caption = #1042#1099#1093#1086#1076
  end
  object ChannelCB: TRcComboBox
    Left = 10
    Top = 128
    Width = 145
    Height = 21
    TabOrder = 2
  end
  object TahoChannel: TRcComboBox
    Left = 178
    Top = 128
    Width = 145
    Height = 21
    TabOrder = 3
  end
  object FsEdit: TFloatEdit
    Left = 10
    Top = 184
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 4
    Text = '0.0'
  end
  object OutChannelName: TEdit
    Left = 176
    Top = 184
    Width = 261
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 5
  end
  object SpmPan: TPanel
    Left = 0
    Top = 151
    Width = 451
    Height = 153
    Align = alBottom
    TabOrder = 6
    object FFTCountLabel: TLabel
      Left = 8
      Top = 18
      Width = 87
      Height = 13
      Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082' '#1041#1055#1060
    end
    object BlockCountLabel: TLabel
      Left = 161
      Top = 91
      Width = 78
      Height = 13
      Caption = #1050#1086#1083'-'#1074#1086' '#1073#1083#1086#1082#1086#1074':'
    end
    object dFLabel: TLabel
      Left = 161
      Top = 25
      Width = 99
      Height = 13
      Caption = #1064#1072#1075' '#1087#1086' '#1095#1072#1089#1090#1086#1090#1077', '#1043#1094
    end
    object AlgDTLabel: TLabel
      Left = 8
      Top = 91
      Width = 82
      Height = 13
      Caption = #1055#1077#1088#1080#1086#1076' '#1088#1072#1089#1095#1077#1090#1072
    end
    object FFTCountEdit: TIntEdit
      Left = 8
      Top = 40
      Width = 121
      Height = 21
      Enabled = False
      TabOrder = 0
      Text = '16384'
      OnChange = FFTCountEditChange
    end
    object FFTCountSpinBtn: TSpinButton
      Left = 135
      Top = 40
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
    object AddNullCB: TCheckBox
      Left = 8
      Top = 70
      Width = 146
      Height = 17
      Caption = #1044#1086#1087#1086#1083#1085#1103#1090#1100' '#1085#1091#1083#1103#1084#1080
      TabOrder = 2
    end
    object FFTBCount: TIntEdit
      Left = 161
      Top = 112
      Width = 121
      Height = 21
      TabOrder = 3
      Text = '1'
      OnChange = FFTBCountChange
    end
    object FFTdX: TFloatEdit
      Left = 161
      Top = 42
      Width = 121
      Height = 21
      TabOrder = 4
      Text = '0.1'
    end
    object AlgDTFE: TFloatEdit
      Left = 8
      Top = 112
      Width = 121
      Height = 21
      TabOrder = 5
      Text = '0.1'
      OnChange = AlgDTFEChange
    end
  end
end
