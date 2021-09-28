inherited TahoAlgFrame: TTahoAlgFrame
  Height = 602
  Constraints.MinHeight = 440
  ExplicitHeight = 440
  object ChannelLabel: TLabel [2]
    Left = 8
    Top = 138
    Width = 35
    Height = 16
    Caption = #1050#1072#1085#1072#1083
  end
  object Label2: TLabel [3]
    Left = 168
    Top = 138
    Width = 36
    Height = 16
    Caption = #1042#1099#1093#1086#1076
  end
  object Label5: TLabel [4]
    Left = 161
    Top = 99
    Width = 63
    Height = 16
    Caption = #1052#1080#1085'. '#1079#1085#1072#1095'.'
  end
  object FsLabel: TLabel [5]
    Left = 8
    Top = 190
    Width = 137
    Height = 16
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1086#1087#1088#1086#1089#1072' '#1082#1072#1085#1072#1083#1072
  end
  object TahoTypeCB: TCheckBox
    Left = 8
    Top = 99
    Width = 137
    Height = 17
    Caption = #1056#1072#1089#1095#1077#1090' '#1087#1086' '#1087#1086#1088#1086#1075#1072#1084
    TabOrder = 2
    OnClick = TahoTypeCBClick
  end
  object LvlPan: TPanel
    Left = 0
    Top = 298
    Width = 451
    Height = 120
    Align = alBottom
    TabOrder = 3
    ExplicitTop = 136
    object L1Label: TLabel
      Left = 8
      Top = 10
      Width = 105
      Height = 16
      Caption = #1042#1077#1088#1093#1085#1080#1081' '#1087#1086#1088#1086#1075', %'
    end
    object L2Label: TLabel
      Left = 8
      Top = 58
      Width = 103
      Height = 16
      Caption = #1053#1080#1078#1085#1080#1081' '#1087#1086#1088#1086#1075', %'
    end
    object L1Edit: TFloatEdit
      Left = 8
      Top = 32
      Width = 121
      Height = 24
      TabOrder = 0
      Text = '70'
      OnChange = L1EditChange
    end
    object L2Edit: TFloatEdit
      Left = 8
      Top = 80
      Width = 121
      Height = 24
      TabOrder = 1
      Text = '30'
      OnChange = L1EditChange
    end
  end
  object SpmPan: TPanel
    Left = 0
    Top = 418
    Width = 451
    Height = 184
    Align = alBottom
    TabOrder = 4
    ExplicitTop = 256
    object FFTCountLabel: TLabel
      Left = 8
      Top = 26
      Width = 102
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082' '#1041#1055#1060
    end
    object dXLabel: TLabel
      Left = 8
      Top = 75
      Width = 15
      Height = 16
      Caption = 'dX'
    end
    object Label3: TLabel
      Left = 168
      Top = 23
      Width = 92
      Height = 16
      Caption = #1064#1072#1075' '#1087#1086' '#1095#1072#1089#1090#1086#1090#1077
    end
    object Label4: TLabel
      Left = 159
      Top = 127
      Width = 47
      Height = 16
      Caption = #1055#1086#1083#1086#1089#1072':'
    end
    object WndLabel: TLabel
      Left = 8
      Top = 122
      Width = 29
      Height = 16
      Caption = #1054#1082#1085#1086
    end
    object AddNullCB: TCheckBox
      Left = 8
      Top = 6
      Width = 146
      Height = 17
      Caption = #1044#1086#1087#1086#1083#1085#1103#1090#1100' '#1085#1091#1083#1103#1084#1080
      TabOrder = 0
    end
    object dXEdit: TFloatEdit
      Left = 8
      Top = 96
      Width = 121
      Height = 24
      TabOrder = 1
      Text = '0.1'
      OnChange = L1EditChange
    end
    object FFTDx: TFloatEdit
      Left = 166
      Top = 48
      Width = 121
      Height = 24
      Enabled = False
      TabOrder = 2
      Text = '0.1'
      OnChange = L1EditChange
    end
    object BandF1Edit: TFloatEdit
      Left = 159
      Top = 144
      Width = 82
      Height = 24
      TabOrder = 3
      Text = '10'
      OnChange = L1EditChange
    end
    object BandF2Edit: TFloatEdit
      Left = 247
      Top = 144
      Width = 82
      Height = 24
      TabOrder = 4
      Text = '20000'
      OnChange = L1EditChange
    end
    object UseBandCB: TCheckBox
      Left = 159
      Top = 104
      Width = 146
      Height = 17
      Caption = #1048#1089#1082#1072#1090#1100' '#1074' '#1087#1086#1083#1086#1089#1077':'
      TabOrder = 5
      OnClick = L1EditChange
    end
    object FFTCountEdit: TIntEdit
      Left = 8
      Top = 48
      Width = 121
      Height = 24
      Enabled = False
      TabOrder = 6
      Text = '16384'
    end
    object FFTCountSpinBtn: TSpinButton
      Left = 135
      Top = 48
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
      TabOrder = 7
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
    object WndCB: TComboBox
      Left = 8
      Top = 144
      Width = 121
      Height = 24
      TabOrder = 8
    end
  end
  object ChannelCB: TRcComboBox
    Left = 8
    Top = 160
    Width = 145
    Height = 24
    TabOrder = 5
    OnChange = L1EditChange
    OnDragOver = ChannelCBDragOver
  end
  object OutChannelName: TEdit
    Left = 159
    Top = 160
    Width = 185
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 6
  end
  object MinValFE: TFloatEdit
    Left = 161
    Top = 117
    Width = 183
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    Text = '70'
    OnChange = L1EditChange
  end
  object FsEdit: TFloatEdit
    Left = 8
    Top = 212
    Width = 121
    Height = 24
    Enabled = False
    TabOrder = 8
    Text = '0.0'
  end
end
