object EditDrawObjFrame: TEditDrawObjFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object DrawObjGB: TGroupBox
    Left = 0
    Top = 0
    Width = 451
    Height = 113
    Align = alTop
    Caption = #1054#1073#1097#1080#1077' '#1089#1074#1086#1081#1089#1090#1074#1072
    TabOrder = 0
    inline DrawObjFrame1: TDrawObjFrame
      Left = 2
      Top = 18
      Width = 447
      Height = 93
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 18
      ExplicitWidth = 447
      ExplicitHeight = 93
    end
  end
  object TrendGB: TGroupBox
    Left = 0
    Top = 113
    Width = 451
    Height = 185
    Align = alTop
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1090#1088#1077#1085#1076#1072
    TabOrder = 1
    inline TrendFrame1: TTrendFrame
      Left = 2
      Top = 18
      Width = 447
      Height = 165
      Align = alClient
      Constraints.MinHeight = 304
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 18
      ExplicitWidth = 447
      ExplicitHeight = 165
      inherited PointGB: TGroupBox
        Width = 447
        Height = 165
        ExplicitWidth = 447
        ExplicitHeight = 168
      end
    end
  end
  object GistGB: TGroupBox
    Left = 0
    Top = 298
    Width = 451
    Height = 159
    Align = alTop
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1075#1080#1089#1090#1086#1075#1088#1072#1084#1084#1099
    TabOrder = 2
    inline GistFrame1: TGistFrame
      Left = 2
      Top = 18
      Width = 447
      Height = 139
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 18
      ExplicitWidth = 447
      ExplicitHeight = 139
    end
  end
end
