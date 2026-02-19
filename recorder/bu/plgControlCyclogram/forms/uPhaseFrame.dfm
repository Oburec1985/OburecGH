inherited PhaseFrame: TPhaseFrame
  object ChannelLabel1: TLabel [2]
    Left = 10
    Top = 106
    Width = 37
    Height = 13
    Caption = #1050#1072#1085#1072#1083'1'
  end
  object Label2: TLabel [3]
    Left = 170
    Top = 106
    Width = 33
    Height = 13
    Caption = #1042#1099#1093#1086#1076
  end
  object ChannelLabel2: TLabel [4]
    Left = 10
    Top = 159
    Width = 37
    Height = 13
    Caption = #1050#1072#1085#1072#1083'2'
  end
  object SpmPan: TPanel
    Left = 0
    Top = 208
    Width = 451
    Height = 96
    Align = alBottom
    TabOrder = 2
    object FFTCountLabel: TLabel
      Left = 8
      Top = 18
      Width = 87
      Height = 13
      Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082' '#1041#1055#1060
    end
    object dFLabel: TLabel
      Left = 170
      Top = 18
      Width = 109
      Height = 13
      Caption = #1056#1072#1079#1088#1077#1096#1077#1085#1080#1077' '#1089#1087#1077#1082#1090#1088#1072':'
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
    object dFEdit: TEdit
      Left = 170
      Top = 40
      Width = 121
      Height = 21
      TabOrder = 2
    end
  end
  object ChannelCB1: TRcComboBox
    Left = 10
    Top = 128
    Width = 145
    Height = 21
    TabOrder = 3
    OnChange = FFTCountEditChange
    OnDragDrop = ChannelCB1DragDrop
  end
  object OutChannelName: TEdit
    Left = 161
    Top = 128
    Width = 214
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 4
  end
  object ChannelCB2: TRcComboBox
    Left = 10
    Top = 181
    Width = 145
    Height = 21
    TabOrder = 5
    OnChange = FFTCountEditChange
    OnDragDrop = ChannelCB1DragDrop
  end
end
