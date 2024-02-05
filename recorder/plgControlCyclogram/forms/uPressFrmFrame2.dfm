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
    Left = 94
    Top = 4
    Width = 19
    Height = 16
    Caption = 'F1:'
  end
  object FreqEdit: TEdit
    Left = 30
    Top = 3
    Width = 60
    Height = 24
    ReadOnly = True
    TabOrder = 0
    Text = 'FreqEdit'
  end
  object AmpE: TEdit
    Left = 116
    Top = 3
    Width = 62
    Height = 24
    ReadOnly = True
    TabOrder = 1
    Text = 'FreqEdit'
  end
  object ProgrBar: TProgressBar
    Left = 184
    Top = 3
    Width = 260
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
end
