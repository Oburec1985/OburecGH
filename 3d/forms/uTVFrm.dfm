object SceneTVFrame: TSceneTVFrame
  Left = 0
  Top = 0
  Width = 590
  Height = 708
  Align = alClient
  TabOrder = 0
  ExplicitHeight = 304
  object Splitter1: TSplitter
    Left = 0
    Top = 219
    Width = 590
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitLeft = -3
    ExplicitTop = 125
  end
  object SceneTV: TVTree
    Left = 0
    Top = 29
    Width = 590
    Height = 190
    Align = alClient
    Alignment = taRightJustify
    DragMode = dmAutomatic
    DrawSelectionMode = smBlendedRectangle
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible]
    NodeDataSize = 32
    TabOrder = 0
    TreeOptions.SelectionOptions = [toExtendedFocus, toMiddleClickSelect, toMultiSelect, toRightClickSelect]
    ExplicitHeight = 154
    Columns = <
      item
        Position = 0
        Width = 586
        WideText = #1054#1073#1098#1077#1082#1090
      end>
  end
  object ObjectPropertyScrollBox: TScrollBox
    Left = 0
    Top = 222
    Width = 590
    Height = 486
    HorzScrollBar.ButtonSize = 10
    VertScrollBar.ButtonSize = 10
    VertScrollBar.Style = ssFlat
    Align = alBottom
    BevelInner = bvLowered
    Constraints.MinWidth = 590
    TabOrder = 1
    ExplicitTop = -182
    object BoundingGroupBox: TGroupBox
      Left = 0
      Top = 0
      Width = 586
      Height = 78
      Align = alTop
      Caption = #1054#1075#1088#1072#1085#1080#1095#1080#1074#1072#1102#1097#1080#1081' '#1086#1073#1098#1077#1084
      TabOrder = 0
      DesignSize = (
        586
        78)
      object Label9: TLabel
        Left = 7
        Top = 50
        Width = 42
        Height = 16
        Caption = #1056#1072#1079#1084#1077#1088
      end
      object Label2: TLabel
        Left = 188
        Top = 17
        Width = 22
        Height = 16
        Caption = #1058#1080#1087
      end
      object Label1: TLabel
        Left = 7
        Top = 19
        Width = 23
        Height = 16
        Caption = #1048#1084#1103
      end
      object DrawBoundsCheckBox: TCheckBox
        Left = 496
        Top = 49
        Width = 70
        Height = 17
        Anchors = [akTop, akRight]
        Caption = #1056#1080#1089#1086#1074#1072#1090#1100
        TabOrder = 0
      end
      object BoundFE: TFloatEdit
        Left = 71
        Top = 46
        Width = 105
        Height = 24
        TabOrder = 1
        Text = '0'
      end
      object TypeE: TEdit
        Left = 212
        Top = 16
        Width = 105
        Height = 24
        TabOrder = 2
      end
      object NameE: TEdit
        Left = 71
        Top = 16
        Width = 105
        Height = 24
        TabOrder = 3
      end
      object FreezCheckBox: TCheckBox
        Left = 496
        Top = 17
        Width = 70
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Freez'
        TabOrder = 4
      end
    end
    object MeshGroupBox: TGroupBox
      Left = 0
      Top = 312
      Width = 586
      Height = 38
      Align = alTop
      Caption = #1053#1086#1088#1084#1072#1083#1080
      TabOrder = 1
      DesignSize = (
        586
        38)
      object Label3: TLabel
        Left = 7
        Top = 14
        Width = 37
        Height = 16
        Caption = #1044#1083#1080#1085#1072
      end
      object DrawNormalCheckBox: TCheckBox
        Left = 496
        Top = 15
        Width = 70
        Height = 17
        Anchors = [akTop, akRight]
        Caption = #1056#1080#1089#1086#1074#1072#1090#1100
        TabOrder = 0
      end
      object NormalLengthE: TFloatEdit
        Left = 67
        Top = 10
        Width = 105
        Height = 24
        TabOrder = 1
        Text = '0'
      end
    end
    object MatrixGroupBox: TGroupBox
      Left = 0
      Top = 78
      Width = 586
      Height = 234
      Align = alTop
      Caption = 'MatrixGroupBox'
      TabOrder = 2
      DesignSize = (
        586
        234)
      object Label15: TLabel
        Left = 12
        Top = 16
        Width = 150
        Height = 16
        Caption = #1051#1086#1082#1072#1083#1100#1085#1072#1103' '#1084#1072#1090#1088#1080#1094#1072' Node'
      end
      object Label17: TLabel
        Left = 255
        Top = 16
        Width = 179
        Height = 16
        Caption = #1051#1086#1082#1072#1083#1100#1085#1072#1103' '#1084#1072#1090#1088#1080#1094#1072' LocalNode'
      end
      object Label18: TLabel
        Left = 12
        Top = 122
        Width = 187
        Height = 16
        Caption = #1056#1077#1079#1091#1083#1100#1090#1080#1088#1091#1102#1097#1072#1103' '#1084#1072#1090#1088#1080#1094#1072' Node'
      end
      object Label19: TLabel
        Left = 255
        Top = 122
        Width = 216
        Height = 16
        Caption = #1056#1077#1079#1091#1083#1100#1090#1080#1088#1091#1102#1097#1072#1103' '#1084#1072#1090#1088#1080#1094#1072' LocalNode'
      end
      object NodeMatrixLV: TBtnListView
        Left = 3
        Top = 35
        Width = 228
        Height = 81
        Columns = <
          item
            Caption = #8470
            Width = 22
          end
          item
            Caption = 'x'
            Width = 52
          end
          item
            Caption = 'y'
          end
          item
            Caption = 'z'
          end
          item
            Caption = 'pos'
          end>
        GridLines = True
        Items.ItemData = {
          03700000000400000000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF000000
          0001310000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001320000
          000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001330000000000FFFF
          FFFFFFFFFFFF00000000FFFFFFFF00000000013400}
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        BtnCol = 0
        QuoteColumnBtnClick = False
        QuoteColumnDblClick = False
        DrawColorBox = False
        ChangeTextColor = False
        Editable = False
      end
      object LocalNodeMatrixLV: TBtnListView
        Left = 246
        Top = 35
        Width = 228
        Height = 81
        Columns = <
          item
            Caption = #8470
            Width = 22
          end
          item
            Caption = 'x'
            Width = 52
          end
          item
            Caption = 'y'
          end
          item
            Caption = 'z'
          end
          item
            Caption = 'pos'
          end>
        GridLines = True
        Items.ItemData = {
          03700000000400000000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF000000
          0001330000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001340000
          000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001310000000000FFFF
          FFFFFFFFFFFF00000000FFFFFFFF00000000013200}
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        BtnCol = 0
        QuoteColumnBtnClick = False
        QuoteColumnDblClick = False
        DrawColorBox = False
        ChangeTextColor = False
        Editable = False
      end
      object NodeResMatrixLV: TBtnListView
        Left = 3
        Top = 141
        Width = 228
        Height = 81
        Columns = <
          item
            Caption = #8470
            Width = 22
          end
          item
            Caption = 'x'
            Width = 52
          end
          item
            Caption = 'y'
          end
          item
            Caption = 'z'
          end
          item
            Caption = 'pos'
          end>
        GridLines = True
        Items.ItemData = {
          03700000000400000000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF000000
          0001310000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001320000
          000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001330000000000FFFF
          FFFFFFFFFFFF00000000FFFFFFFF00000000013400}
        RowSelect = True
        TabOrder = 2
        ViewStyle = vsReport
        BtnCol = 0
        QuoteColumnBtnClick = False
        QuoteColumnDblClick = False
        DrawColorBox = False
        ChangeTextColor = False
        Editable = False
      end
      object LocalNodeResMatrixLV: TBtnListView
        Left = 246
        Top = 141
        Width = 228
        Height = 81
        Columns = <
          item
            Caption = #8470
            Width = 22
          end
          item
            Caption = 'x'
            Width = 52
          end
          item
            Caption = 'y'
          end
          item
            Caption = 'z'
          end
          item
            Caption = 'pos'
          end>
        GridLines = True
        Items.ItemData = {
          03700000000400000000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF000000
          0001310000000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001320000
          000000FFFFFFFFFFFFFFFF00000000FFFFFFFF0000000001330000000000FFFF
          FFFFFFFFFFFF00000000FFFFFFFF00000000013400}
        RowSelect = True
        TabOrder = 3
        ViewStyle = vsReport
        BtnCol = 0
        QuoteColumnBtnClick = False
        QuoteColumnDblClick = False
        DrawColorBox = False
        ChangeTextColor = False
        Editable = False
      end
      object DrawLocalCheckBox: TCheckBox
        Left = 496
        Top = 35
        Width = 98
        Height = 17
        Anchors = [akTop, akRight]
        Caption = #1051#1086#1082#1072#1083#1100#1085#1072#1103' '#1086#1089#1100
        TabOrder = 4
      end
      object DrawNodeCheckBox: TCheckBox
        Left = 496
        Top = 76
        Width = 48
        Height = 17
        Anchors = [akTop, akRight]
        Caption = #1059#1079#1077#1083
        TabOrder = 5
      end
    end
    object TabControl: TPageControl
      Left = 0
      Top = 350
      Width = 586
      Height = 132
      ActivePage = TabSheet2
      Align = alClient
      TabOrder = 3
      object TabSheet1: TTabSheet
        Caption = #1050#1072#1084#1077#1088#1072
        DesignSize = (
          578
          101)
        object Label10: TLabel
          Left = 24
          Top = 61
          Width = 96
          Height = 16
          Caption = #1052#1080#1096#1077#1085#1100' '#1082#1072#1084#1077#1088#1099
        end
        object Label6: TLabel
          Left = 209
          Top = 31
          Width = 24
          Height = 16
          Caption = 'FOV'
        end
        object Label7: TLabel
          Left = 208
          Top = 60
          Width = 38
          Height = 16
          Caption = 'Aspect'
        end
        object NearPlaneLabel: TLabel
          Left = 440
          Top = 14
          Width = 58
          Height = 16
          Caption = 'NearPlane'
        end
        object FarPlaneLabel: TLabel
          Left = 439
          Top = 38
          Width = 50
          Height = 16
          Caption = 'FarPlane'
        end
        object RightPlaneLabel: TLabel
          Left = 353
          Top = 38
          Width = 29
          Height = 16
          Caption = 'Right'
        end
        object LeftPlaneLabel: TLabel
          Left = 352
          Top = 14
          Width = 21
          Height = 16
          Caption = 'Left'
        end
        object BottomPlaneLabel: TLabel
          Left = 353
          Top = 88
          Width = 40
          Height = 16
          Caption = 'Bottom'
        end
        object TopPlaneLabel: TLabel
          Left = 352
          Top = 64
          Width = 22
          Height = 16
          Caption = 'Top'
        end
        object ActiveCheckBox: TCheckBox
          Left = 19
          Top = 10
          Width = 114
          Height = 17
          Caption = #1040#1082#1090#1080#1074#1080#1079#1080#1088#1086#1074#1072#1090#1100
          TabOrder = 0
        end
        object TargetComboBox: TComboBox
          Left = 19
          Top = 180
          Width = 133
          Height = 24
          Anchors = [akLeft, akBottom]
          TabOrder = 1
          Items.Strings = (
            #1052#1077#1096
            #1057#1074#1077#1090#1080#1083#1100#1085#1080#1082
            #1050#1072#1084#1077#1088#1072)
        end
        object FovSpinEdit: TFloatSpinEdit
          Left = 153
          Top = 30
          Width = 54
          Height = 26
          Increment = 1.000000000000000000
          TabOrder = 2
          Value = 45.000000000000000000
        end
        object AspectSpinEdit: TFloatSpinEdit
          Left = 153
          Top = 56
          Width = 54
          Height = 26
          Increment = 0.100000001490116100
          TabOrder = 3
        end
        object NearPlaneFE: TFloatSpinEdit
          Left = 384
          Top = 9
          Width = 54
          Height = 26
          Increment = 1.000000000000000000
          TabOrder = 4
          Value = 45.000000000000000000
        end
        object FarPlaneFE: TFloatSpinEdit
          Left = 384
          Top = 34
          Width = 54
          Height = 26
          Increment = 0.100000001490116100
          TabOrder = 5
        end
        object KeepQuadCheckBox: TCheckBox
          Left = 19
          Top = 42
          Width = 124
          Height = 17
          Caption = #1044#1077#1088#1078#1072#1090#1100' '#1087#1088#1086#1087#1086#1088#1094#1080#1080
          TabOrder = 6
        end
        object OrthoCheckBox: TCheckBox
          Left = 154
          Top = 10
          Width = 114
          Height = 17
          Caption = #1054#1088#1090#1086#1075#1088#1072#1092#1080#1095#1077#1089#1082#1072#1103
          TabOrder = 7
        end
        object LeftPlaneFE: TFloatSpinEdit
          Left = 298
          Top = 9
          Width = 54
          Height = 26
          Increment = 1.000000000000000000
          TabOrder = 8
          Value = 45.000000000000000000
        end
        object RightPlaneFE: TFloatSpinEdit
          Left = 298
          Top = 34
          Width = 54
          Height = 26
          Increment = 0.100000001490116100
          TabOrder = 9
        end
        object TopPlaneFE: TFloatSpinEdit
          Left = 298
          Top = 59
          Width = 54
          Height = 26
          Increment = 1.000000000000000000
          TabOrder = 10
          Value = 45.000000000000000000
        end
        object BottomPlaneFE: TFloatSpinEdit
          Left = 298
          Top = 84
          Width = 54
          Height = 26
          Increment = 0.100000001490116100
          TabOrder = 11
        end
      end
      object TabSheet2: TTabSheet
        Caption = #1043#1077#1086#1084#1077#1090#1088#1080#1103
        ImageIndex = 1
        DesignSize = (
          578
          101)
        object Label11: TLabel
          Left = 7
          Top = 30
          Width = 63
          Height = 16
          Caption = #1043#1077#1086#1084#1077#1090#1088#1080#1103
        end
        object Label12: TLabel
          Left = 7
          Top = 49
          Width = 35
          Height = 16
          Caption = #1058#1086#1095#1082#1080
        end
        object Label13: TLabel
          Left = 7
          Top = 70
          Width = 40
          Height = 16
          Caption = #1050#1072#1088#1082#1072#1089
        end
        object MaterialLabel: TLabel
          Left = 157
          Top = 34
          Width = 58
          Height = 16
          Caption = #1052#1072#1090#1077#1088#1080#1072#1083
        end
        object DefaultColorLabel: TLabel
          Left = 178
          Top = 68
          Width = 29
          Height = 16
          Caption = #1062#1074#1077#1090
        end
        object DefColorPanel: TPanel
          Left = 213
          Top = 68
          Width = 58
          Height = 22
          TabOrder = 0
        end
        object MaterialComboBox: TComboBox
          Left = 213
          Top = -47
          Width = 133
          Height = 24
          Anchors = [akLeft, akBottom]
          TabOrder = 1
          Items.Strings = (
            #1052#1077#1096
            #1057#1074#1077#1090#1080#1083#1100#1085#1080#1082
            #1050#1072#1084#1077#1088#1072)
        end
        object PointsCheckBox: TCheckBox
          Left = 75
          Top = 49
          Width = 70
          Height = 17
          Caption = #1056#1080#1089#1086#1074#1072#1090#1100
          TabOrder = 2
        end
        object GeomCheckBox: TCheckBox
          Left = 75
          Top = 29
          Width = 70
          Height = 17
          Caption = #1056#1080#1089#1086#1074#1072#1090#1100
          TabOrder = 3
        end
        object EdgesCheckBox: TCheckBox
          Left = 75
          Top = 69
          Width = 70
          Height = 17
          Caption = #1056#1080#1089#1086#1074#1072#1090#1100
          TabOrder = 4
        end
      end
      object TabSheet3: TTabSheet
        Caption = #1057#1074#1077#1090
        ImageIndex = 2
        DesignSize = (
          578
          101)
        object Label20: TLabel
          Left = 19
          Top = 17
          Width = 44
          Height = 16
          Caption = 'LightID:'
        end
        object EnableLightCheckBox: TCheckBox
          Left = 163
          Top = 16
          Width = 70
          Height = 17
          Anchors = [akTop, akRight]
          Caption = #1042#1082#1083#1102#1095#1077#1085
          TabOrder = 0
        end
        object LightIDE: TEdit
          Left = 63
          Top = 14
          Width = 121
          Height = 24
          TabOrder = 1
          Text = 'LightIDE'
        end
      end
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 590
    Height = 29
    ButtonHeight = 32
    ButtonWidth = 32
    Caption = 'ToolBar1'
    TabOrder = 2
    object ApplyBtn: TToolButton
      Left = 0
      Top = 0
      Caption = 'ApplyBtn'
      ImageIndex = 16
      OnClick = ApplyBtnClick
    end
  end
end
