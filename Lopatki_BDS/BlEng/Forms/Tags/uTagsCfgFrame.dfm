object TagsCfgFrame: TTagsCfgFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 158
    Top = 0
    Height = 149
    Align = alRight
    ExplicitLeft = 136
    ExplicitTop = 160
    ExplicitHeight = 100
  end
  object ControlGB: TGroupBox
    Left = 0
    Top = 248
    Width = 451
    Height = 56
    Align = alBottom
    Caption = #1044#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    DesignSize = (
      451
      56)
    object CancelBtn: TButton
      Left = 3
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 371
      Top = 19
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
      OnClick = ApplyBtnClick
    end
  end
  object TagsLV: TBtnListView
    Left = 0
    Top = 0
    Width = 158
    Height = 149
    Align = alClient
    Checkboxes = True
    Columns = <>
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnChange = TagsLVChange
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ExplicitLeft = 1
    ExplicitTop = -6
  end
  object TagPropertiesGB: TGroupBox
    Left = 161
    Top = 0
    Width = 290
    Height = 149
    Align = alRight
    Caption = 'TagPropertiesGB'
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 2
      Top = 15
      Width = 286
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 241
      ExplicitWidth = 271
    end
    object TagGB: TGroupBox
      Left = 2
      Top = 18
      Width = 286
      Height = 129
      Align = alClient
      TabOrder = 0
      inline TagPropertiesFrame1: TTagPropertiesFrame
        Left = 2
        Top = 15
        Width = 282
        Height = 112
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 2
        ExplicitTop = 15
        ExplicitWidth = 282
        ExplicitHeight = 112
        inherited TagNameEdit: TEdit
          Width = 276
          ExplicitWidth = 276
        end
        inherited DscEdit: TEdit
          Width = 276
          ExplicitWidth = 276
        end
        inherited TheresholdsLV: TBtnListView
          Width = 276
          Height = 0
          ExplicitWidth = 276
          ExplicitHeight = 0
        end
        inherited DrawObjEdit: TEdit
          Width = 229
          ExplicitWidth = 229
        end
        inherited DrawObjSelectBtn: TButton
          Left = 238
          OnClick = TagPropertiesFrame1DrawObjSelectBtnClick
          ExplicitLeft = 238
        end
        inherited ToolBar: TToolBar
          Top = 73
          Width = 282
          ExplicitTop = 73
          ExplicitWidth = 282
          inherited AddAlarmBtn: TToolButton
            OnClick = TagPropertiesFrame1AddTagBtnClick
          end
        end
      end
    end
  end
  object TagsMngGB: TGroupBox
    Left = 0
    Top = 149
    Width = 451
    Height = 99
    Align = alBottom
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1084#1077#1085#1077#1076#1078#1077#1088#1072' '#1090#1077#1075#1086#1074
    TabOrder = 3
    DesignSize = (
      451
      99)
    object TagNameLabel: TLabel
      Left = 8
      Top = 41
      Width = 149
      Height = 13
      Caption = #1055#1091#1090#1100' '#1082' '#1073#1072#1079#1077' '#1076#1072#1085#1085#1099#1093' '#1087#1086' '#1090#1077#1075#1072#1084
    end
    object LogTagsCheckBox: TCheckBox
      Left = 8
      Top = 16
      Width = 121
      Height = 17
      Caption = #1042#1077#1089#1090#1080' '#1079#1072#1087#1080#1089#1100' '#1090#1077#1075#1086#1074
      TabOrder = 0
    end
    object TagsBaseEdit: TEdit
      Left = 8
      Top = 60
      Width = 202
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object SelectTagsBaseBtn: TButton
      Left = 216
      Top = 60
      Width = 45
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 2
      OnClick = SelectTagsBaseBtnClick
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 416
    Top = 288
  end
end
