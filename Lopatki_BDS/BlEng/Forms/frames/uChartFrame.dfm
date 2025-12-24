object ChartFrame: TChartFrame
  Left = 0
  Top = 0
  Width = 1034
  Height = 626
  Align = alClient
  TabOrder = 0
  TabStop = True
  ExplicitWidth = 451
  ExplicitHeight = 304
  object formulyarsTC: TPageControl
    Left = 0
    Top = 0
    Width = 1034
    Height = 626
    ActivePage = ChartTabSheet
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 451
    ExplicitHeight = 304
    object ChartTabSheet: TTabSheet
      Caption = #1043#1088#1072#1092#1080#1082#1080
      ExplicitWidth = 443
      ExplicitHeight = 273
      object Splitter2: TSplitter
        Left = 0
        Top = 0
        Width = 5
        Height = 595
        ExplicitLeft = 148
        ExplicitTop = -24
        ExplicitHeight = 512
      end
      object cChart1: cChart
        Left = 5
        Top = 0
        Width = 1021
        Height = 595
        Cursor = crSizeAll
        Align = alClient
        Caption = 'cChart1'
        Color = clActiveCaption
        ParentBackground = False
        TabOrder = 0
        allowEditPages = False
        showTV = True
        showLegend = True
        selectSize = 5
        ExplicitLeft = 3
      end
    end
    object DigitFormTabSheet: TTabSheet
      Caption = #1062#1080#1092#1088#1086#1074#1086#1081' '#1092#1086#1088#1084#1091#1083#1103#1088
      ImageIndex = 1
      object DigitsLV: TBtnListView
        Left = 0
        Top = 0
        Width = 1026
        Height = 595
        Align = alClient
        Columns = <>
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
    end
    object VisualTabSheet: TTabSheet
      Caption = #1043#1088#1072#1092#1080#1095#1077#1089#1082#1080#1081' '#1092#1086#1088#1084#1091#1083#1103#1088
      ImageIndex = 2
      object TurbineGLGB: TGroupBox
        Left = 0
        Top = 0
        Width = 1026
        Height = 595
        Align = alClient
        TabOrder = 0
        object Splitter1: TSplitter
          Left = 2
          Top = 584
          Width = 1022
          Height = 9
          Cursor = crVSplit
          Align = alBottom
          Beveled = True
          Color = clGray
          ParentColor = False
          ExplicitLeft = 17
          ExplicitTop = 217
          ExplicitWidth = 520
        end
        inline glTurbineFrame1: TglTurbineFrame
          Left = 2
          Top = 18
          Width = 1022
          Height = 566
          Align = alClient
          TabOrder = 0
          TabStop = True
          ExplicitLeft = 2
          ExplicitTop = 18
          ExplicitWidth = 1022
          ExplicitHeight = 566
          inherited EditTurbGB: TGroupBox
            Height = 566
            ExplicitHeight = 566
            inherited ApplyBtn: TButton
              Top = 381
              OnClick = glTurbineFrame1ApplyBtnClick
              ExplicitTop = 381
            end
          end
          inherited cBaseGlComponent1: cBaseGlComponent
            Width = 909
            Height = 566
            ExplicitLeft = 113
            ExplicitTop = 0
            ExplicitWidth = 909
            ExplicitHeight = 566
          end
        end
      end
    end
    object AutoPage: TTabSheet
      Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080#1081
      ImageIndex = 3
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 1026
        Height = 29
        ButtonHeight = 26
        Caption = 'ToolBar1'
        TabOrder = 0
        object PageCountSE: TSpinEdit
          Left = 0
          Top = 0
          Width = 49
          Height = 26
          Hint = #1063#1080#1089#1083#1086' '#1089#1090#1088#1072#1085#1080#1094
          MaxValue = 16
          MinValue = 1
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          Value = 1
          OnChange = PageCountSEChange
        end
      end
      object cChart2: cChart
        Left = 0
        Top = 29
        Width = 1026
        Height = 566
        Cursor = crSizeAll
        Align = alClient
        Caption = 'cChart1'
        TabOrder = 1
        allowEditPages = False
        showTV = True
        showLegend = True
        selectSize = 5
      end
    end
  end
end
