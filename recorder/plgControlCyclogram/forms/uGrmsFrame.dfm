inherited GRmsFrame: TGRmsFrame
  Height = 426
  object Label2: TLabel [2]
    Left = 170
    Top = 106
    Width = 36
    Height = 16
    Caption = #1042#1099#1093#1086#1076
  end
  object TahoLabel: TLabel [3]
    Left = 10
    Top = 155
    Width = 33
    Height = 16
    Caption = #1058#1072#1093#1086':'
  end
  object ChannelLabel: TLabel [4]
    Left = 10
    Top = 106
    Width = 35
    Height = 16
    Caption = #1050#1072#1085#1072#1083
  end
  object OutChannelName: TEdit
    Left = 161
    Top = 128
    Width = 214
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 2
  end
  object UseTahoCB: TCheckBox
    Left = 161
    Top = 181
    Width = 146
    Height = 17
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1090#1072#1093#1086
    TabOrder = 3
    OnClick = FFTCountEditChange
  end
  object SpmPan: TPanel
    Left = 0
    Top = 291
    Width = 451
    Height = 135
    Align = alBottom
    TabOrder = 4
    ExplicitTop = 169
    object FFTCountLabel: TLabel
      Left = 8
      Top = 18
      Width = 102
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082' '#1041#1055#1060
    end
    object Label1: TLabel
      Left = 8
      Top = 67
      Width = 15
      Height = 16
      Caption = 'dX'
    end
    object Label4: TLabel
      Left = 161
      Top = 71
      Width = 47
      Height = 16
      Caption = #1055#1086#1083#1086#1089#1072':'
    end
    object FFTdX: TFloatEdit
      Left = 8
      Top = 88
      Width = 121
      Height = 24
      TabOrder = 0
      Text = '0.1'
      OnChange = FFTCountEditChange
    end
    object BandF1Edit: TFloatEdit
      Left = 161
      Top = 88
      Width = 82
      Height = 24
      TabOrder = 1
      Text = '10'
      OnChange = FFTCountEditChange
    end
    object BandF2Edit: TFloatEdit
      Left = 249
      Top = 88
      Width = 82
      Height = 24
      TabOrder = 2
      Text = '20000'
      OnChange = FFTCountEditChange
    end
    object FFTCountEdit: TIntEdit
      Left = 8
      Top = 40
      Width = 121
      Height = 24
      Enabled = False
      TabOrder = 3
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
      OnDownClick = FFTCountSpinBtnDownClick
      OnUpClick = FFTCountSpinBtnUpClick
    end
    object PercentCB: TCheckBox
      Left = 161
      Top = 48
      Width = 45
      Height = 17
      Caption = '%'
      TabOrder = 5
      OnClick = FFTCountEditChange
    end
  end
  object ChannelCB: TRcComboBox
    Left = 10
    Top = 128
    Width = 145
    Height = 24
    TabOrder = 5
    OnChange = FFTCountEditChange
  end
  object TahoCB: TRcComboBox
    Left = 10
    Top = 179
    Width = 145
    Height = 24
    TabOrder = 6
    OnChange = FFTCountEditChange
  end
end
