object BladePosFrame: TBladePosFrame
  Left = 0
  Top = 0
  Width = 320
  Height = 120
  Align = alClient
  TabOrder = 0
  object PosLabel: TLabel
    Left = 3
    Top = 5
    Width = 102
    Height = 13
    Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077' '#1083#1086#1087#1072#1090#1082#1080
  end
  object BladePosFE: TFloatEdit
    Left = 3
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '0.0'
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 70
    Width = 320
    Height = 50
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    ExplicitTop = 96
    DesignSize = (
      320
      50)
    object CancelBtn: TButton
      Left = 8
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 245
      Top = 19
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end
