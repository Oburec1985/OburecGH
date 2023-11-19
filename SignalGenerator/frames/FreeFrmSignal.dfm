object FreeFrmSignalFrame: TFreeFrmSignalFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object LengthLabel: TLabel
    Left = 11
    Top = 9
    Width = 85
    Height = 13
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100', '#1089
  end
  object FreqPeriodLabel: TLabel
    Left = 11
    Top = 60
    Width = 10
    Height = 13
    Caption = 'X:'
  end
  object PhasePeriodLabel: TLabel
    Left = 151
    Top = 60
    Width = 10
    Height = 13
    Caption = 'Y:'
  end
  object LengthFE: TFloatEdit
    Left = 11
    Top = 33
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '10'
    OnChange = LengthFEChange
  end
  object xfe: TFloatEdit
    Left = 11
    Top = 79
    Width = 121
    Height = 21
    TabOrder = 1
    Text = '0'
  end
  object yfe: TFloatEdit
    Left = 151
    Top = 79
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '10'
  end
end
