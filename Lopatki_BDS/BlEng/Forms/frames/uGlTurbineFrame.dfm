object glTurbineFrame: TglTurbineFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object EditTurbGB: TGroupBox
    Left = 0
    Top = 0
    Width = 113
    Height = 304
    Align = alLeft
    Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1089#1090#1091#1087#1077#1085#1080
    TabOrder = 0
    DesignSize = (
      113
      304)
    object BlCountLabel: TLabel
      Left = 15
      Top = 24
      Width = 79
      Height = 13
      Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082':'
    end
    object StCountLabel: TLabel
      Left = 15
      Top = 96
      Width = 84
      Height = 13
      Caption = #1063#1080#1089#1083#1086' '#1089#1090#1091#1087#1077#1085#1077#1081':'
    end
    object ApplyBtn: TButton
      Left = 15
      Top = 264
      Width = 84
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = ApplyBtnClick
    end
    object BlCountIE: TIntEdit
      Left = 15
      Top = 46
      Width = 89
      Height = 24
      TabOrder = 1
      Text = '1'
    end
    object StCountIE: TIntEdit
      Left = 21
      Top = 141
      Width = 89
      Height = 24
      TabOrder = 2
      Text = '1'
    end
  end
  object cBaseGlComponent1: cBaseGlComponent
    Left = 113
    Top = 0
    Width = 338
    Height = 304
    Align = alClient
    Caption = 'cBaseGlComponent1'
    DockSite = True
    TabOrder = 1
    ShowTrasforms = True
    ExplicitLeft = 160
    ExplicitTop = 64
    ExplicitWidth = 200
    ExplicitHeight = 200
  end
end
