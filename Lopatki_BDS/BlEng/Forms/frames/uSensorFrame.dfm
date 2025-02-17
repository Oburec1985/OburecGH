object SensorFrame: TSensorFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 266
  Align = alTop
  Constraints.MinWidth = 265
  TabOrder = 0
  Visible = False
  object SensorsGB: TGroupBox
    Left = 0
    Top = 0
    Width = 451
    Height = 266
    Align = alClient
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1076#1072#1090#1095#1080#1082#1072
    TabOrder = 0
    object TypeLabel: TLabel
      Left = 5
      Top = 16
      Width = 64
      Height = 13
      Caption = #1058#1080#1087' '#1076#1072#1090#1095#1080#1082#1072
    end
    object OffsetLabel: TLabel
      Left = 135
      Top = 16
      Width = 103
      Height = 13
      Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077' '#1076#1072#1090#1095#1080#1082#1072
    end
    object ChunLabel: TLabel
      Left = 244
      Top = 16
      Width = 70
      Height = 13
      Caption = #1053#1086#1084#1077#1088' '#1082#1072#1085#1072#1083#1072
    end
    object TickCountLabel: TLabel
      Left = 346
      Top = 18
      Width = 63
      Height = 13
      Caption = #1063#1080#1089#1083#1086' '#1090#1080#1082#1086#1074
    end
    object SkipBladesLabel: TLabel
      Left = 447
      Top = 18
      Width = 105
      Height = 13
      Caption = #1055#1088#1086#1087#1091#1089#1090#1080#1090#1100' '#1083#1086#1087#1072#1090#1086#1082
    end
    object TahoDivLabel: TLabel
      Left = 346
      Top = 57
      Width = 94
      Height = 13
      Caption = #1054#1090#1085#1086#1096#1077#1085#1080#1077' '#1082' '#1090#1072#1093#1086
    end
    object TypeCB: TComboBox
      Left = 5
      Top = 33
      Width = 124
      Height = 21
      TabOrder = 0
      Items.Strings = (
        #1058#1072#1093#1086
        #1050#1086#1088#1085#1077#1074#1086#1081
        #1055#1077#1088#1080#1092#1077#1088#1080#1081#1085#1099#1081)
    end
    object OffsetFE: TFloatEdit
      Left = 135
      Top = 33
      Width = 103
      Height = 21
      TabOrder = 1
      Text = '0.0'
    end
    object ChunIE: TIntEdit
      Left = 245
      Top = 33
      Width = 94
      Height = 21
      TabOrder = 2
      Text = '000'
    end
    object StateGB: TGroupBox
      Left = 2
      Top = 99
      Width = 447
      Height = 165
      Align = alBottom
      Caption = #1056#1072#1089#1086#1083#1086#1078#1077#1085#1080#1077' '#1076#1072#1090#1095#1080#1082#1072
      TabOrder = 3
      DesignSize = (
        447
        165)
      object PairsLVLabel: TLabel
        Left = 133
        Top = 18
        Width = 57
        Height = 13
        Caption = #1057#1087#1080#1089#1086#1082' '#1087#1072#1088
      end
      object StagesLabel: TLabel
        Left = 5
        Top = 18
        Width = 43
        Height = 13
        Caption = #1057#1090#1091#1087#1077#1085#1080
      end
      object StageCB: TComboBox
        Left = 3
        Top = 39
        Width = 124
        Height = 21
        TabOrder = 0
      end
      object PairsListView: TBtnListView
        Left = 133
        Top = 37
        Width = 2026
        Height = 122
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #8470
          end
          item
            Caption = #1048#1084#1103
          end
          item
            Caption = #1050#1086#1088'. '#1076#1072#1090'.'
          end
          item
            Caption = #1055#1077#1088'. '#1076#1072#1090'.'
          end>
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        BtnCol = 0
        QuoteColumnBtnClick = False
        QuoteColumnDblClick = False
        DrawColorBox = False
        ExplicitWidth = 1805
      end
    end
    object TickCountIE: TIntEdit
      Left = 346
      Top = 33
      Width = 94
      Height = 21
      TabOrder = 4
      Text = '000'
    end
    object SkipBladeIE: TIntEdit
      Left = 447
      Top = 33
      Width = 89
      Height = 21
      TabOrder = 5
      Text = '000'
    end
    object EvalSkipBladesBtn: TButton
      Left = 542
      Top = 31
      Width = 67
      Height = 25
      Hint = #1055#1077#1088#1077#1089#1095#1080#1090#1072#1090#1100' '#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1076#1072#1090#1095#1080#1082#1072' '#1074' '#1095#1080#1089#1083#1086' '#1087#1088#1086#1087#1091#1089#1082#1086#1074' '#1083#1086#1087#1072#1090#1086#1082
      Cancel = True
      Caption = #1056#1072#1089#1095#1077#1090
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = EvalSkipBladesBtnClick
    end
    object TahoDivEdit: TEdit
      Left = 346
      Top = 76
      Width = 190
      Height = 21
      TabOrder = 7
    end
  end
end
