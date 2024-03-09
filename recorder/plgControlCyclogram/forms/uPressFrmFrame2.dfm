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
    Width = 17
    Height = 13
    Caption = 'A1:'
  end
  object FLabel: TLabel
    Left = 75
    Top = 4
    Width = 16
    Height = 13
    Caption = 'F1:'
  end
  object ProgrBar: TGauge
    Left = 152
    Top = 3
    Width = 289
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    ForeColor = clActiveCaption
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Progress = 0
  end
  object FreqEdit: TEdit
    Left = 95
    Top = 3
    Width = 43
    Height = 24
    ReadOnly = True
    TabOrder = 0
    Text = '0'
  end
  object AmpE: TEdit
    Left = 27
    Top = 3
    Width = 45
    Height = 24
    ReadOnly = True
    TabOrder = 1
    Text = '0'
  end
end
