object ChanFrame: TChanFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 396
  Align = alTop
  TabOrder = 0
  Visible = False
  object CommonGB: TGroupBox
    Left = 0
    Top = 0
    Width = 451
    Height = 396
    Align = alClient
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1082#1072#1085#1072#1083#1072
    TabOrder = 0
    DesignSize = (
      451
      396)
    object ImpulsCountLabel: TLabel
      Left = 9
      Top = 24
      Width = 86
      Height = 13
      Caption = #1063#1080#1089#1083#1086' '#1080#1084#1087#1091#1083#1100#1089#1086#1074
    end
    object ChanLVLabel: TLabel
      Left = 168
      Top = 24
      Width = 104
      Height = 13
      Caption = #1048#1084#1087#1091#1083#1100#1089#1099' '#1089' '#1076#1072#1090#1095#1080#1082#1072
    end
    object Label3: TLabel
      Left = 9
      Top = 114
      Width = 23
      Height = 13
      Caption = 'Ticks'
    end
    object Label4: TLabel
      Left = 9
      Top = 196
      Width = 28
      Height = 13
      Caption = 'Index'
    end
    object OverflowLabel: TLabel
      Left = 9
      Top = 154
      Width = 44
      Height = 13
      Caption = 'Overflow'
    end
    object ImpulsCountIE: TIntEdit
      Left = 9
      Top = 48
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '000'
    end
    object ChanLV: TBtnListView
      Left = 168
      Top = 48
      Width = 280
      Height = 345
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = #8470
        end
        item
          Caption = #1042#1088#1077#1084#1103' '#1074' '#1090#1080#1082#1072#1093
        end
        item
          Caption = #1042#1088#1077#1084#1103', '#1089#1077#1082'.'
        end>
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ExplicitHeight = 232
    end
    object ShowAllCB: TCheckBox
      Left = 9
      Top = 88
      Width = 153
      Height = 17
      Caption = #1054#1090#1086#1073#1088#1072#1079#1080#1090#1100' '#1074#1089#1077' '#1080#1084#1087#1091#1083#1100#1089#1099
      TabOrder = 2
      OnClick = ShowAllCBClick
    end
    object TickEdit: TIntEdit
      Left = 9
      Top = 131
      Width = 121
      Height = 21
      TabOrder = 3
      Text = '000'
      OnEnter = TickEditEnter
    end
    object ResIndEdit: TIntEdit
      Left = 9
      Top = 212
      Width = 121
      Height = 21
      Hint = #1048#1085#1076#1077#1082#1089' '#1089#1083#1077#1074#1072' '#1086#1090' '#1091#1082#1072#1079#1072#1085#1085#1086#1075#1086' '#1090#1080#1082#1072
      TabOrder = 4
      Text = '000'
    end
    object OverflowIE: TIntEdit
      Left = 9
      Top = 171
      Width = 121
      Height = 21
      TabOrder = 5
      Text = '000'
      OnEnter = TickEditEnter
    end
  end
end
