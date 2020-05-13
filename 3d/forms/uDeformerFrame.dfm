object DeformerFrame: TDeformerFrame
  Left = 0
  Top = 0
  Width = 278
  Height = 435
  VertScrollBar.ButtonSize = 5
  VertScrollBar.Size = 5
  Constraints.MaxWidth = 451
  Constraints.MinHeight = 213
  Constraints.MinWidth = 260
  TabOrder = 0
  TabStop = True
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 278
    Height = 79
    Align = alTop
    Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077'/'#1091#1076#1072#1083#1077#1085#1080#1077' '#1086#1073#1098#1077#1082#1090#1086#1074
    TabOrder = 0
    DesignSize = (
      278
      79)
    object Label2: TLabel
      Left = 110
      Top = 51
      Width = 53
      Height = 13
      Anchors = [akRight, akBottom]
      Caption = #1042#1077#1089' '#1082#1086#1089#1090#1080':'
      ExplicitLeft = 92
    end
    object bonesCB: TComboBox
      Left = 107
      Top = 22
      Width = 165
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object AddMeshBtn: TButton
      Left = 6
      Top = 20
      Width = 67
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
      OnClick = AddMeshBtnClick
    end
    object DelMeshBtn: TButton
      Left = 6
      Top = 48
      Width = 67
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 2
    end
    object MeshWeight: TFloatSpinEdit
      Left = 176
      Top = 50
      Width = 96
      Height = 22
      Anchors = [akRight, akBottom]
      Increment = 0.100000001490116100
      TabOrder = 3
    end
  end
  object MeshesLV: TBtnListView
    Left = 0
    Top = 177
    Width = 278
    Height = 129
    Align = alTop
    Columns = <
      item
        Caption = #1057#1087#1080#1089#1086#1082' '#1086#1073#1098#1077#1082#1090#1086#1074
        Width = 234
      end>
    Constraints.MaxHeight = 166
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnSelectItem = MeshesLVSelectItem
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 79
    Width = 278
    Height = 98
    Align = alTop
    Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077'/'#1091#1076#1072#1083#1077#1085#1080#1077' '#1090#1086#1095#1077#1082
    TabOrder = 2
    DesignSize = (
      278
      98)
    object Label1: TLabel
      Left = 113
      Top = 70
      Width = 54
      Height = 13
      Anchors = [akRight, akBottom]
      Caption = #1042#1077#1089' '#1090#1086#1095#1082#1080':'
    end
    object Label3: TLabel
      Left = 113
      Top = 46
      Width = 50
      Height = 13
      Anchors = [akRight, akBottom]
      Caption = #8470' '#1058#1086#1095#1082#1080':'
      ExplicitLeft = 85
    end
    object Label4: TLabel
      Left = 107
      Top = 20
      Width = 67
      Height = 13
      Anchors = [akRight, akBottom]
      Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082':'
      ExplicitLeft = 79
    end
    object ComboBox1: TComboBox
      Left = 5
      Top = -27
      Width = 154
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 0
      Text = 'MeshesCB'
    end
    object Button1: TButton
      Left = 6
      Top = 20
      Width = 67
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
      OnClick = AddPointBtnClick
    end
    object Button2: TButton
      Left = 6
      Top = 48
      Width = 67
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 2
    end
    object PointWeight: TFloatSpinEdit
      Left = 177
      Top = 69
      Width = 95
      Height = 22
      Anchors = [akRight, akBottom]
      Increment = 0.100000001490116100
      TabOrder = 3
    end
    object PointIndex: TIntEdit
      Left = 177
      Top = 43
      Width = 94
      Height = 21
      Anchors = [akRight, akBottom]
      TabOrder = 4
      Text = '0'
    end
    object PointsCountEdit: TIntEdit
      Left = 177
      Top = 16
      Width = 94
      Height = 21
      Anchors = [akRight, akBottom]
      TabOrder = 5
      Text = '0'
    end
  end
  object PointsLV: TBtnListView
    Left = 0
    Top = 306
    Width = 278
    Height = 117
    Align = alTop
    Columns = <
      item
        Caption = #1057#1087#1080#1089#1086#1082' '#1090#1086#1095#1077#1082
        Width = 150
      end
      item
        Caption = #1042#1077#1089
        Width = 125
      end>
    Constraints.MaxHeight = 166
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
end
