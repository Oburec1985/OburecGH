object FreeFrmSignalFrame: TFreeFrmSignalFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object FreqLabel: TLabel
    Left = 3
    Top = 3
    Width = 69
    Height = 16
    Caption = #1063#1072#1089#1090#1086#1090#1072', '#1043#1094
  end
  object LengthLabel: TLabel
    Left = 3
    Top = 57
    Width = 97
    Height = 16
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100', '#1089
  end
  object FreqPeriodLabel: TLabel
    Left = 3
    Top = 164
    Width = 13
    Height = 16
    Caption = 'X:'
  end
  object PhasePeriodLabel: TLabel
    Left = 143
    Top = 164
    Width = 12
    Height = 16
    Caption = 'Y:'
  end
  object FreqFE: TFloatEdit
    Left = 3
    Top = 24
    Width = 121
    Height = 24
    TabOrder = 0
    Text = '1000'
  end
  object LengthFE: TFloatEdit
    Left = 3
    Top = 79
    Width = 121
    Height = 24
    TabOrder = 1
    Text = '1100'
  end
  object xfe: TFloatEdit
    Left = 3
    Top = 183
    Width = 121
    Height = 24
    TabOrder = 2
    Text = '1100'
  end
  object yfe: TFloatEdit
    Left = 143
    Top = 183
    Width = 121
    Height = 24
    TabOrder = 3
    Text = '1100'
  end
end
