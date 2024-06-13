object VertexEditFrame: TVertexEditFrame
  Left = 0
  Top = 0
  Width = 603
  Height = 540
  Constraints.MinWidth = 508
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 365
    Top = 73
    Height = 467
    Align = alRight
    Color = clBackground
    ParentColor = False
    ExplicitLeft = 352
    ExplicitTop = 240
    ExplicitHeight = 100
  end
  object TopPanel: TPanel
    Left = 0
    Top = 0
    Width = 603
    Height = 73
    Align = alTop
    TabOrder = 0
    DesignSize = (
      603
      73)
    object ObjNameLabel: TLabel
      Left = 16
      Top = 11
      Width = 69
      Height = 13
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072':'
    end
    object PintNumLabel: TLabel
      Left = 152
      Top = 11
      Width = 69
      Height = 13
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072':'
    end
    object TypeCB: TCheckBox
      Left = 438
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
      Width = 121
      Height = 21
      TabOrder = 1
      Text = 'NameEdit'
    end
    object PointNumSE: TSpinEdit
      Left = 152
      Top = 33
      Width = 97
      Height = 22
      MaxValue = 100
      MinValue = 1
      TabOrder = 2
      Value = 1
    end
    object SkinCB: TCheckBox
      Left = 438
      Top = 40
      Width = 122
      Height = 17
      Anchors = [akTop, akRight]
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 3
    end
    object AddBtn: TButton
      Left = 261
      Top = 33
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 4
      OnClick = AddBtnClick
    end
  end
  object AlPanel: TPanel
    Left = 0
    Top = 73
    Width = 365
    Height = 467
    Align = alClient
    TabOrder = 1
    object VertLV: TBtnListView
      Left = 1
      Top = 1
      Width = 363
      Height = 465
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
          Caption = 'Point'
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
    end
  end
  object RightPan: TGroupBox
    Left = 368
    Top = 73
    Width = 235
    Height = 467
    Align = alRight
    Caption = #1058#1086#1095#1082#1080
    TabOrder = 2
    object Panel1: TPanel
      Left = 2
      Top = 15
      Width = 231
      Height = 183
      Align = alTop
      TabOrder = 0
      object PNameLabel: TLabel
        Left = 5
        Top = 2
        Width = 56
        Height = 13
        Caption = #1048#1084#1103' '#1090#1086#1095#1082#1080':'
      end
      object WeightLabel: TLabel
        Left = 5
        Top = 51
        Width = 54
        Height = 13
        Caption = #1042#1077#1089' '#1090#1086#1095#1082#1080':'
      end
      object TagLabel: TLabel
        Left = 6
        Top = 102
        Width = 35
        Height = 13
        Caption = #1050#1072#1085#1072#1083':'
      end
      object AxisLabel: TLabel
        Left = 124
        Top = 101
        Width = 23
        Height = 13
        Caption = #1054#1089#1100':'
      end
      object Label1: TLabel
        Left = 5
        Top = 156
        Width = 123
        Height = 13
        Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1085#1099#1077' '#1074#1077#1088#1096#1080#1085#1099':'
      end
      object PIDLab: TLabel
        Left = 125
        Top = 2
        Width = 56
        Height = 13
        Caption = #1048#1084#1103' '#1090#1086#1095#1082#1080':'
      end
      object PointNumEdit: TIntEdit
        Left = 5
        Top = 21
        Width = 84
        Height = 21
        TabOrder = 0
        Text = '000'
      end
      object PointWeight: TFloatSpinEdit
        Left = 5
        Top = 70
        Width = 84
        Height = 22
        Increment = 0.100000001490116100
        TabOrder = 1
      end
      object pIdEdit: TEdit
        Left = 125
        Top = 21
        Width = 74
        Height = 21
        TabOrder = 2
      end
      object AxisCB: TComboBox
        Left = 124
        Top = 123
        Width = 41
        Height = 21
        TabOrder = 3
        Text = '1'
      end
      object TagCB: TRcComboBox
        Left = 5
        Top = 123
        Width = 84
        Height = 21
        TabOrder = 4
        Text = 'TagCB'
      end
    end
    object SkinPointsLV: TBtnListView
      Left = 2
      Top = 198
      Width = 231
      Height = 267
      Align = alClient
      Columns = <
        item
          Caption = #8470
        end
        item
          Caption = 'ID'
        end
        item
          Caption = #1042#1077#1089
        end>
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      OnDragOver = VertLVDragOver
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
  end
end
