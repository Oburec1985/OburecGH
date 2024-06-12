object VertexEditFrame: TVertexEditFrame
  Left = 0
  Top = 0
  Width = 508
  Height = 477
  Constraints.MinWidth = 508
  TabOrder = 0
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 508
    Height = 73
    Align = alTop
    TabOrder = 0
    DesignSize = (
      508
      73)
    object ObjNameLabel: TLabel
      Left = 16
      Top = 11
      Width = 69
      Height = 13
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072':'
    end
    object SensorsLabel: TLabel
      Left = 216
      Top = 9
      Width = 69
      Height = 13
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072':'
    end
    object TypeCB: TCheckBox
      Left = 343
      Top = 12
      Width = 138
      Height = 17
      Anchors = [akTop, akRight]
      Caption = #1042#1077#1088#1096#1080#1085#1099'/'#1044#1072#1090#1095#1080#1082#1080
      TabOrder = 0
    end
    object NameEdit: TEdit
      Left = 16
      Top = 33
      Width = 177
      Height = 21
      TabOrder = 1
      Text = 'NameEdit'
    end
    object ChanCountSE: TSpinEdit
      Left = 216
      Top = 31
      Width = 121
      Height = 22
      MaxValue = 100
      MinValue = 1
      TabOrder = 2
      Value = 1
    end
    object SkinCB: TCheckBox
      Left = 343
      Top = 40
      Width = 122
      Height = 17
      Anchors = [akTop, akRight]
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 3
    end
  end
  object AlPanel: TPanel
    Left = 0
    Top = 73
    Width = 323
    Height = 404
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 508
    object VertLV: TBtnListView
      Left = 1
      Top = 1
      Width = 321
      Height = 402
      Align = alClient
      Columns = <
        item
          Caption = #8470
        end
        item
          Caption = 'Pos.'
        end
        item
          Caption = 'ID'
        end
        item
          Caption = 'S1'
        end>
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDragOver = VertLVDragOver
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
      ExplicitLeft = -4
      ExplicitTop = 6
    end
  end
  object GroupBox1: TGroupBox
    Left = 323
    Top = 73
    Width = 185
    Height = 404
    Align = alRight
    Caption = #1058#1086#1095#1082#1080
    TabOrder = 2
    ExplicitLeft = 328
    ExplicitTop = 72
    DesignSize = (
      185
      404)
    object PNameLabel: TLabel
      Left = 5
      Top = 19
      Width = 56
      Height = 13
      Caption = #1048#1084#1103' '#1090#1086#1095#1082#1080':'
    end
    object WeightLabel: TLabel
      Left = 6
      Top = 68
      Width = 54
      Height = 13
      Anchors = [akRight, akBottom]
      Caption = #1042#1077#1089' '#1090#1086#1095#1082#1080':'
    end
    object PointNumEdit: TIntEdit
      Left = 5
      Top = 38
      Width = 121
      Height = 21
      TabOrder = 0
      Text = '000'
    end
    object PointWeight: TFloatSpinEdit
      Left = 6
      Top = 87
      Width = 95
      Height = 22
      Anchors = [akRight, akBottom]
      Increment = 0.100000001490116100
      TabOrder = 1
    end
  end
end
