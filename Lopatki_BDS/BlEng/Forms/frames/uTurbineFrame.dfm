object TurbineFrame: TTurbineFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 281
  Align = alTop
  Constraints.MinWidth = 265
  TabOrder = 0
  TabStop = True
  Visible = False
  object TurbinePropGB: TGroupBox
    Left = 0
    Top = 0
    Width = 451
    Height = 281
    Align = alClient
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1090#1091#1088#1073#1080#1085#1099
    TabOrder = 0
    ExplicitHeight = 236
    DesignSize = (
      451
      281)
    object StageCountLabel: TLabel
      Left = 5
      Top = 46
      Width = 92
      Height = 16
      Caption = #1063#1080#1089#1083#1086' '#1089#1090#1091#1087#1077#1085#1077#1081
    end
    object CfgLabel: TLabel
      Left = 140
      Top = 47
      Width = 137
      Height = 16
      Caption = #1050#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103' '#1090#1091#1088#1073#1080#1085#1099
    end
    object RecentFileLabel: TLabel
      Left = 5
      Top = 23
      Width = 150
      Height = 16
      Caption = #1053#1077#1076#1072#1074#1085#1080#1081' '#1092#1072#1081#1083' ('#1076#1072#1085#1085#1099#1077')'
    end
    object StageCountIE: TIntEdit
      Left = 5
      Top = 66
      Width = 121
      Height = 21
      Enabled = False
      ReadOnly = True
      TabOrder = 0
      Text = '000'
    end
    object CfgTV: TTreeView
      Left = 140
      Top = 66
      Width = 303
      Height = 163
      Anchors = [akLeft, akTop, akRight]
      Indent = 19
      TabOrder = 1
      OnChange = CfgTVChange
    end
    object RecentFileEdit: TEdit
      Left = 140
      Top = 20
      Width = 303
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
  end
end
