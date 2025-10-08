object PressFrmFrame: TPressFrmFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  DesignSize = (
    451
    304)
  object BandLabel: TLabel
    Left = 1
    Top = 4
    Width = 21
    Height = 16
    Caption = 'B_1'
  end
  object ALabel: TLabel
    Left = 37
    Top = 4
    Width = 20
    Height = 16
    Caption = 'A1:'
  end
  object FLabel: TLabel
    Left = 126
    Top = 4
    Width = 19
    Height = 16
    Caption = 'F1:'
  end
  object FreqEdit: TEdit
    Left = 62
    Top = 3
    Width = 60
    Height = 24
    ReadOnly = True
    TabOrder = 0
    Text = 'FreqEdit'
  end
  object AmpE: TEdit
    Left = 148
    Top = 3
    Width = 62
    Height = 24
    ReadOnly = True
    TabOrder = 1
    Text = 'FreqEdit'
  end
  object ProgrBar: TProgressBar
    Left = 212
    Top = 3
    Width = 232
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
end
