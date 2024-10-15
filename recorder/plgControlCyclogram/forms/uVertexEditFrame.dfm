object VertexEditFrame: TVertexEditFrame
  Left = 0
  Top = 0
  Width = 594
  Height = 540
  Constraints.MinWidth = 508
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 356
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
    Width = 594
    Height = 73
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 603
    DesignSize = (
      594
      73)
    object ObjNameLabel: TLabel
      Left = 16
      Top = 11
      Width = 79
      Height = 16
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072':'
    end
    object PintNumLabel: TLabel
      Left = 152
      Top = 11
      Width = 79
      Height = 16
      Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072':'
    end
    object NameEdit: TEdit
      Left = 16
      Top = 33
      Width = 121
      Height = 24
      TabOrder = 0
      Text = 'NameEdit'
    end
    object PointNumSE: TSpinEdit
      Left = 152
      Top = 33
      Width = 97
      Height = 26
      MaxValue = 100
      MinValue = 1
      TabOrder = 1
      Value = 1
      OnChange = PointNumSEChange
    end
    object SkinCB: TCheckBox
      Left = 429
      Top = 40
      Width = 122
      Height = 17
      Anchors = [akTop, akRight]
      Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
      TabOrder = 2
      ExplicitLeft = 438
    end
    object AddBtn: TButton
      Left = 255
      Top = 33
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 3
      OnClick = AddBtnClick
    end
  end
  object AlPanel: TPanel
    Left = 0
    Top = 73
    Width = 356
    Height = 467
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 365
    object VertLV: TBtnListView
      Left = 1
      Top = 1
      Width = 354
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
      ExplicitWidth = 363
    end
  end
  object RightPan: TGroupBox
    Left = 359
    Top = 73
    Width = 235
    Height = 467
    Align = alRight
    Caption = #1058#1086#1095#1082#1080
    TabOrder = 2
    ExplicitLeft = 368
    object Panel1: TPanel
      Left = 2
      Top = 18
      Width = 231
      Height = 183
      Align = alTop
      TabOrder = 0
      object WeightLabel: TLabel
        Left = 5
        Top = 51
        Width = 62
        Height = 16
        Caption = #1042#1077#1089' '#1090#1086#1095#1082#1080':'
      end
      object TagLabel: TLabel
        Left = 6
        Top = 102
        Width = 40
        Height = 16
        Caption = #1050#1072#1085#1072#1083':'
      end
      object AxisLabel: TLabel
        Left = 100
        Top = 101
        Width = 27
        Height = 16
        Caption = #1054#1089#1100':'
      end
      object Label1: TLabel
        Left = 5
        Top = 156
        Width = 144
        Height = 16
        Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1085#1099#1077' '#1074#1077#1088#1096#1080#1085#1099':'
      end
      object PIDLab: TLabel
        Left = 4
        Top = 2
        Width = 65
        Height = 16
        Caption = #1048#1084#1103' '#1090#1086#1095#1082#1080':'
      end
      object PointWeight: TFloatSpinEdit
        Left = 5
        Top = 70
        Width = 84
        Height = 26
        Increment = 0.100000001490116100
        TabOrder = 0
      end
      object pIdEdit: TEdit
        Left = 4
        Top = 21
        Width = 85
        Height = 24
        TabOrder = 1
      end
      object AxisCB: TComboBox
        Left = 100
        Top = 123
        Width = 41
        Height = 24
        TabOrder = 2
        Text = '1'
      end
      object TagCB: TRcComboBox
        Left = 5
        Top = 123
        Width = 84
        Height = 24
        TabOrder = 3
        Text = 'TagCB'
      end
      object ChangePBtn: TButton
        Left = 100
        Top = 70
        Width = 75
        Height = 25
        Caption = #1048#1079#1084#1077#1085#1080#1090#1100
        TabOrder = 4
        OnClick = ChangePBtnClick
      end
    end
    object SkinPointsLV: TBtnListView
      Left = 2
      Top = 201
      Width = 231
      Height = 264
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
