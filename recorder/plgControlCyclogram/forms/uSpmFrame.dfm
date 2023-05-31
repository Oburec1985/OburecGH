inherited SpmFrame: TSpmFrame
  Height = 444
  ParentBackground = False
  ParentColor = False
  object ChannelLabel: TLabel [2]
    Left = 10
    Top = 106
    Width = 31
    Height = 13
    Caption = #1050#1072#1085#1072#1083
  end
  object Label2: TLabel [3]
    Left = 170
    Top = 106
    Width = 33
    Height = 13
    Caption = #1042#1099#1093#1086#1076
  end
  object FsLabel: TLabel [4]
    Left = 218
    Top = 185
    Width = 119
    Height = 13
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1086#1087#1088#1086#1089#1072' '#1082#1072#1085#1072#1083#1072
  end
  object AHLabel: TLabel [5]
    Left = 10
    Top = 192
    Width = 78
    Height = 13
    Caption = #1050#1086#1088#1088#1077#1082#1094#1080#1103' '#1040#1063#1061
    Visible = False
  end
  inherited AlgNameEdit: TEdit
    Width = 553
    Height = 21
    ExplicitWidth = 553
    ExplicitHeight = 21
  end
  inherited OptsEdit: TEdit
    Width = 553
    Height = 21
    ExplicitWidth = 553
    ExplicitHeight = 21
  end
  object SpmPan: TPanel
    Left = 0
    Top = 291
    Width = 451
    Height = 153
    Align = alBottom
    TabOrder = 2
    ExplicitTop = 151
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
      Left = 170
      Top = 113
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
    object ResTypeRG: TRadioGroup
      Left = 297
      Top = 35
      Width = 208
      Height = 110
      Caption = #1058#1080#1087' '#1089#1087#1077#1082#1090#1088#1072
      TabOrder = 6
    end
  end
  object ChannelCB: TRcComboBox
    Left = 10
    Top = 128
    Width = 145
    Height = 21
    TabOrder = 3
    OnChange = FFTCountEditChange
    OnDragDrop = ChannelCBDragDrop
    OnDragOver = ChannelCBDragOver
  end
  object OutChannelName: TEdit
    Left = 161
    Top = 128
    Width = 400
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 4
  end
  object FsEdit: TFloatEdit
    Left = 218
    Top = 207
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 5
    Text = '0.0'
  end
  object AHComboBox: TComboBox
    Left = 10
    Top = 211
    Width = 145
    Height = 21
    TabOrder = 6
    Visible = False
  end
  object AHBtn: TButton
    Left = 161
    Top = 207
    Width = 42
    Height = 25
    Caption = '...'
    TabOrder = 7
    Visible = False
  end
end
