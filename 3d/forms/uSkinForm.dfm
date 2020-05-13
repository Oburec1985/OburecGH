object SkinFrame: TSkinFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 351
  Align = alClient
  Constraints.MinHeight = 324
  Constraints.MinWidth = 241
  TabOrder = 0
  TabStop = True
  ExplicitHeight = 324
  DesignSize = (
    451
    351)
  object Label1: TLabel
    Left = 6
    Top = 296
    Width = 53
    Height = 13
    Caption = #1042#1077#1089' '#1082#1086#1089#1090#1080':'
  end
  object BonesLV: TBtnListView
    Left = 0
    Top = 0
    Width = 451
    Height = 209
    Align = alTop
    Columns = <
      item
        Caption = #1057#1087#1080#1089#1086#1082' '#1082#1086#1089#1090#1077#1081
        Width = 150
      end
      item
        Caption = #1042#1077#1089
        Width = 87
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 209
    Width = 451
    Height = 81
    Align = alTop
    Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077'/'#1091#1076#1072#1083#1077#1085#1080#1077' '#1082#1086#1089#1090#1077#1081
    TabOrder = 1
    DesignSize = (
      451
      81)
    object BonesCB: TComboBox
      Left = 290
      Top = 22
      Width = 154
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 0
      Text = 'BonesCB'
    end
    object AddBtn: TButton
      Left = 6
      Top = 20
      Width = 67
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
    end
    object DelBtn: TButton
      Left = 6
      Top = 48
      Width = 67
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 2
    end
  end
  object FloatSpinEdit1: TFloatSpinEdit
    Left = 290
    Top = 296
    Width = 154
    Height = 22
    Anchors = [akTop, akRight]
    Increment = 0.100000001490116100
    TabOrder = 2
  end
end
