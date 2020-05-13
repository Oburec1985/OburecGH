object BaseObjPropertyFrame: TBaseObjPropertyFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 177
  Align = alTop
  Constraints.MinHeight = 64
  Constraints.MinWidth = 293
  TabOrder = 0
  TabStop = True
  DesignSize = (
    451
    177)
  object NameLabel: TLabel
    Left = 3
    Top = 1
    Width = 65
    Height = 13
    Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
  end
  object TypeLabel: TLabel
    Left = 131
    Top = 1
    Width = 64
    Height = 13
    Caption = #1058#1080#1087' '#1086#1073#1098#1077#1082#1090#1072
  end
  object TypeImage: TImage
    Left = 258
    Top = 9
    Width = 32
    Height = 32
    Transparent = True
  end
  object Label1: TLabel
    Left = 3
    Top = 45
    Width = 94
    Height = 13
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1086#1073#1098#1077#1082#1090#1072
  end
  object NameEdit: TEdit
    Left = 3
    Top = 20
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object TypeEdit: TEdit
    Left = 131
    Top = 20
    Width = 121
    Height = 21
    Enabled = False
    ReadOnly = True
    TabOrder = 1
  end
  object AddFieldBtn: TButton
    Left = 320
    Top = 18
    Width = 113
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1089#1074#1086#1081#1089#1090#1074#1086
    TabOrder = 2
    OnClick = AddFieldBtnClick
  end
  object DelPropertieBtn: TButton
    Left = 439
    Top = 18
    Width = 113
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1089#1074#1086#1081#1089#1090#1074#1086
    TabOrder = 3
    OnClick = DelPropertieBtnClick
  end
  object MetaDataLV: TBtnListView
    Left = 3
    Top = 64
    Width = 435
    Height = 106
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <>
    RowSelect = True
    TabOrder = 4
    ViewStyle = vsReport
    OnDblClickProcess = MetaDataLVDblClickProcess
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ExplicitHeight = 110
  end
end
