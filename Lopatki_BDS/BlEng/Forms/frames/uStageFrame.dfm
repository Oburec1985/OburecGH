object StageFrame: TStageFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Constraints.MinWidth = 265
  TabOrder = 0
  TabStop = True
  Visible = False
  object StageGB: TGroupBox
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1089#1090#1091#1087#1077#1085#1080
    TabOrder = 0
    object SignalSetupPageControl: TPageControl
      Left = 2
      Top = 15
      Width = 447
      Height = 287
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1090#1091#1088#1073#1080#1085#1099
        object Splitter2: TSplitter
          Left = 169
          Top = 0
          Width = 6
          Height = 259
          ExplicitLeft = 120
          ExplicitHeight = 241
        end
        object BladesGB: TGroupBox
          Left = 175
          Top = 0
          Width = 147
          Height = 259
          Align = alLeft
          Caption = #1057#1087#1080#1089#1086#1082' '#1083#1086#1087#1072#1090#1086#1082
          TabOrder = 0
          object Splitter1: TSplitter
            Left = 140
            Top = 15
            Width = 5
            Height = 242
            Align = alRight
            ExplicitLeft = 4
          end
          object BladesLV: TBtnListView
            Left = 2
            Top = 15
            Width = 138
            Height = 242
            Align = alClient
            Columns = <
              item
                Caption = #8470
              end
              item
                Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
              end>
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClickProcess = BladesLVDblClickProcess
            BtnCol = 0
            QuoteColumnBtnClick = False
            QuoteColumnDblClick = False
            DrawColorBox = False
          end
        end
        object ShapeGB: TGroupBox
          Left = 322
          Top = 0
          Width = 117
          Height = 259
          Align = alClient
          Caption = #1060#1086#1088#1084#1072' '#1082#1086#1083#1077#1089#1072
          TabOrder = 1
          object ShapeLV: TBtnListView
            Left = 2
            Top = 15
            Width = 113
            Height = 242
            Align = alClient
            Columns = <
              item
                Caption = #8470
              end
              item
                Caption = #1055#1086#1083#1086#1078'.'
              end>
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
            BtnCol = 0
            QuoteColumnBtnClick = False
            QuoteColumnDblClick = False
            DrawColorBox = False
          end
        end
        object StagePropertysGB: TGroupBox
          Left = 0
          Top = 0
          Width = 169
          Height = 259
          Align = alLeft
          Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1089#1090#1091#1087#1077#1085#1080
          TabOrder = 2
          object DiametrLabel: TLabel
            Left = 5
            Top = 67
            Width = 88
            Height = 13
            Caption = #1044#1080#1072#1084#1077#1090#1088' '#1089#1090#1091#1087#1077#1085#1080
          end
          object StageCountLabel: TLabel
            Left = 5
            Top = 110
            Width = 75
            Height = 13
            Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082
          end
          object TurbineLabel: TLabel
            Left = 6
            Top = 21
            Width = 42
            Height = 13
            Caption = #1058#1091#1088#1073#1080#1085#1072
          end
          object BladeCountIE: TIntEdit
            Left = 5
            Top = 126
            Width = 113
            Height = 21
            TabOrder = 0
            Text = '000'
          end
          object DiametrFE: TFloatEdit
            Left = 5
            Top = 86
            Width = 113
            Height = 21
            TabOrder = 1
            Text = '0.0'
          end
          object EvalShapeBtn: TButton
            Left = 3
            Top = 153
            Width = 115
            Height = 25
            Hint = 
              #1056#1072#1089#1095#1077#1090' '#1088#1072#1089#1089#1090#1086#1103#1085#1080#1081' '#1084#1077#1078#1076#1091' '#1089#1086#1089#1077#1076#1085#1080#1084#1080' '#1083#1086#1087#1072#1090#1082#1072#1084#1080' ('#1091#1095#1080#1090#1099#1074#1072#1077#1090#1089#1103' '#1095#1080#1089#1083#1086' '#1087 +
              #1088#1086#1087#1091#1089#1082#1072#1077#1084#1099#1093' '#1083#1086#1087#1072#1090#1086#1082' '#1076#1086' 0-'#1081')'
            Caption = #1056#1072#1089#1095#1077#1090' '#1092#1086#1088#1084#1099
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
            OnClick = EvalShapeBtnClick
          end
          object TurbineCB: TComboBox
            Left = 3
            Top = 40
            Width = 115
            Height = 21
            TabOrder = 3
          end
          object EvalSensorSkipBtn: TButton
            Left = 3
            Top = 235
            Width = 115
            Height = 25
            Hint = #1056#1072#1089#1095#1077#1090' '#1088#1072#1089#1090#1086#1103#1085#1080#1103' '#1076#1086' '#1087#1077#1088#1074#1086#1081' '#1083#1086#1087#1072#1090#1082#1080' '#1080' '#1088#1072#1089#1095#1077#1090' '#1087#1088#1086#1087#1091#1089#1082#1072' '#1083#1086#1087#1072#1090#1086#1082
            Caption = #1056#1072#1089#1089#1090#1072#1074#1080#1090#1100' '#1076#1072#1090#1095#1080#1082#1080
            ParentShowHint = False
            ShowHint = True
            TabOrder = 4
            OnClick = EvalSensorskipBtnClick
          end
          object UseShapeAlgCB: TCheckBox
            Left = 5
            Top = 212
            Width = 148
            Height = 17
            Hint = #1056#1072#1089#1095#1077#1090' '#1087#1086' '#1087#1086#1083#1086#1078#1077#1085#1080#1102'/ '#1087#1086' '#1082#1086#1088#1088#1077#1083#1103#1094#1080#1103#1084' '#1089' '#1079#1072#1087#1086#1083#1085#1077#1085#1085#1086#1081' '#1092#1086#1088#1084#1086#1081
            Caption = #1056#1072#1089#1095#1077#1090' '#1087#1086' '#1092#1086#1088#1084#1077' '#1082#1086#1083#1077#1089#1072
            ParentShowHint = False
            ShowHint = True
            TabOrder = 5
          end
          object Button1: TButton
            Left = 3
            Top = 180
            Width = 115
            Height = 25
            Hint = #1056#1072#1089#1095#1077#1090' '#1087#1086#1083#1086#1078#1077#1085#1080#1081' '#1083#1086#1087#1072#1090#1086#1082' '#1087#1086' '#1092#1086#1088#1084#1077
            Caption = #1055#1077#1088#1077#1089#1095#1080#1090#1072#1090#1100' '#1087#1086#1083#1086#1078'.'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 6
            OnClick = EvalBlPos
          end
          object EvalSPos: TButton
            Left = 3
            Top = 265
            Width = 115
            Height = 25
            Hint = 
              #1056#1072#1089#1095#1077#1090' '#1087#1086#1079#1080#1094#1080#1080' '#1076#1072#1090#1095#1080#1082#1072' '#1087#1086' '#1089#1084#1077#1097#1077#1085#1080#1102' '#1076#1086' '#1087#1077#1088#1074#1086#1081' '#1083#1086#1087#1072#1090#1082#1080' '#1080' '#1095#1080#1089#1083#1091' '#1087#1088#1086 +
              #1087#1091#1089#1082#1072#1077#1084#1099#1093' '#1083#1086#1087#1072#1090#1086#1082
            Caption = #1056#1072#1089#1095#1077#1090' '#1087#1086#1079'. '#1076#1072#1090#1095#1080#1082#1072
            TabOrder = 7
            OnClick = EvalSensorPos
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = #1044#1072#1090#1095#1080#1082#1080
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 368
        object SensorsGB: TGroupBox
          Left = 0
          Top = 0
          Width = 439
          Height = 295
          Align = alClient
          Caption = #1057#1087#1080#1089#1086#1082' '#1076#1072#1090#1095#1080#1082#1086#1074
          TabOrder = 0
          ExplicitHeight = 368
          object SensorsSG: TStringGrid
            Left = 2
            Top = 15
            Width = 435
            Height = 278
            Align = alClient
            RowCount = 2
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
            TabOrder = 0
            OnSetEditText = SensorsSGSetEditText
            ExplicitHeight = 351
          end
        end
      end
    end
  end
end
