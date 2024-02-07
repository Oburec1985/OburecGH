object PressFrmFrame2: TPressFrmFrame2
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  DesignSize = (
    451
    304)
  object ALabel: TLabel
    Left = 5
    Top = 4
    Width = 20
    Height = 16
    Caption = 'A1:'
  end
  object FLabel: TLabel
    Left = 75
    Top = 4
    Width = 19
    Height = 16
    Caption = 'F1:'
  end
  object FreqEdit: TEdit
    Left = 27
    Top = 3
    Width = 43
    Height = 24
    ReadOnly = True
    TabOrder = 0
    Text = '0'
  end
  object AmpE: TEdit
    Left = 97
    Top = 3
    Width = 45
    Height = 24
    ReadOnly = True
    TabOrder = 1
    Text = '0'
  end
  object ProgrBar: TProgressBar
    Left = 148
    Top = 3
    Width = 296
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
end
