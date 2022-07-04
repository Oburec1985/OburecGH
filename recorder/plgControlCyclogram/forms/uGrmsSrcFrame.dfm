inherited GrmsSrcFrame: TGrmsSrcFrame
  Width = 706
  Height = 616
  Constraints.MinHeight = 359
  Constraints.MinWidth = 342
  ExplicitHeight = 359
  object Label2: TLabel [2]
    Left = 10
    Top = 226
    Width = 36
    Height = 16
    Caption = #1042#1099#1093#1086#1076
  end
  object TahoLabel: TLabel [3]
    Left = 10
    Top = 163
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
  object FsLabel: TLabel [5]
    Left = 181
    Top = 165
    Width = 137
    Height = 16
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1086#1087#1088#1086#1089#1072' '#1082#1072#1085#1072#1083#1072
  end
  object AlgLabel: TLabel [6]
    Left = 183
    Top = 106
    Width = 55
    Height = 16
    Caption = #1040#1083#1075#1086#1088#1080#1090#1084
  end
  inherited AlgNameEdit: TEdit
    Width = 684
  end
  inherited OptsEdit: TEdit
    Top = 69
    Width = 684
    ExplicitTop = 69
  end
  object OutChannelName: TEdit
    Left = 10
    Top = 248
    Width = 683
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 2
    ExplicitWidth = 428
  end
  object ChannelCB: TRcComboBox
    Left = 10
    Top = 128
    Width = 145
    Height = 24
    TabOrder = 3
    OnChange = ChannelCBChange
  end
  object SpmPan: TPanel
    Left = 0
    Top = 410
    Width = 706
    Height = 206
    Align = alBottom
    TabOrder = 4
    ExplicitTop = 153
    ExplicitWidth = 451
    object FFTCountLabel: TLabel
      Left = 8
      Top = 34
      Width = 102
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082' '#1041#1055#1060
    end
    object Label1: TLabel
      Left = 8
      Top = 95
      Width = 15
      Height = 16
      Caption = 'dX'
    end
    object Label4: TLabel
      Left = 161
      Top = 119
      Width = 47
      Height = 16
      Caption = #1055#1086#1083#1086#1089#1072':'
    end
    object dFLabel: TLabel
      Left = 161
      Top = 40
      Width = 114
      Height = 16
      Caption = #1064#1072#1075' '#1087#1086' '#1095#1072#1089#1090#1086#1090#1077', '#1043#1094
    end
    object AlgDTFE: TFloatEdit
      Left = 8
      Top = 112
      Width = 121
      Height = 24
      TabOrder = 0
      Text = '0.1'
      OnChange = AlgDTFEChange
    end
    object BandF1Edit: TFloatEdit
      Left = 161
      Top = 144
      Width = 82
      Height = 24
      TabOrder = 1
      Text = '10'
      OnChange = BandF1EditChange
    end
    object BandF2Edit: TFloatEdit
      Left = 249
      Top = 144
      Width = 82
      Height = 24
      TabOrder = 2
      Text = '20000'
      OnChange = BandF2EditChange
    end
    object FFTCountEdit: TIntEdit
      Left = 8
      Top = 56
      Width = 121
      Height = 24
      Enabled = False
      TabOrder = 3
      Text = '16384'
      OnChange = FFTCountEditChange
    end
    object FFTCountSpinBtn: TSpinButton
      Left = 135
      Top = 56
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
      Top = 95
      Width = 224
      Height = 17
      Hint = 
        #1054#1087#1088#1077#1076#1077#1083#1103#1077#1090' '#1077#1076#1080#1085#1080#1094#1099' '#1074' '#1082#1086#1090#1086#1088#1099#1093' '#1080#1089#1095#1080#1089#1083#1103#1077#1090#1089#1103' '#1086#1090#1089#1090#1091#1087' '#1086#1090' '#1094#1077#1085#1090#1088#1072#1083#1100#1085#1086#1081' '#1095 +
        #1072#1089#1090#1086#1090#1099
      Caption = #1055#1086#1083#1086#1089#1072' b1*F1...b2*F1'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = PercentCBClick
    end
    object FFTdx: TFloatEdit
      Left = 161
      Top = 57
      Width = 121
      Height = 24
      TabOrder = 6
      Text = '0.1'
    end
    object AddNullCB: TCheckBox
      Left = 10
      Top = 11
      Width = 146
      Height = 17
      Caption = #1044#1086#1087#1086#1083#1085#1103#1090#1100' '#1085#1091#1083#1103#1084#1080
      TabOrder = 7
    end
    object ResTypeRG: TRadioGroup
      Left = 497
      Top = 1
      Width = 208
      Height = 204
      Align = alRight
      Caption = #1058#1080#1087' '#1089#1087#1077#1082#1090#1088#1072
      TabOrder = 8
      ExplicitLeft = 242
    end
    object TrackingCB: TCheckBox
      Left = 162
      Top = 11
      Width = 171
      Height = 17
      Hint = 
        #1054#1087#1088#1077#1076#1077#1083#1103#1077#1090' '#1077#1076#1080#1085#1080#1094#1099' '#1074' '#1082#1086#1090#1086#1088#1099#1093' '#1080#1089#1095#1080#1089#1083#1103#1077#1090#1089#1103' '#1086#1090#1089#1090#1091#1087' '#1086#1090' '#1094#1077#1085#1090#1088#1072#1083#1100#1085#1086#1081' '#1095 +
        #1072#1089#1090#1086#1090#1099
      Caption = #1057#1083#1077#1078#1077#1085#1080#1077' '#1079#1072' '#1095#1072#1089#1090#1086#1090#1086#1081
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      OnClick = PercentCBClick
    end
  end
  object TahoCB: TRcComboBox
    Left = 10
    Top = 187
    Width = 145
    Height = 24
    Hint = #1058#1088#1077#1073#1091#1077#1090#1089#1103' '#1091#1082#1072#1079#1099#1074#1072#1090#1100' '#1080#1089#1093#1086#1076#1085#1099#1081' '#1090#1077#1075'!'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnChange = TahoCBChange
  end
  object FsEdit: TFloatEdit
    Left = 181
    Top = 187
    Width = 137
    Height = 24
    Enabled = False
    TabOrder = 6
    Text = '0.0'
  end
  object AlgCB: TComboBox
    Left = 181
    Top = 128
    Width = 145
    Height = 24
    TabOrder = 7
    OnChange = AlgCBChange
  end
end
