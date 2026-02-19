object ModesStepFrame: TModesStepFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object ModesSG: TStringGrid
    Left = 0
    Top = 0
    Width = 451
    Height = 220
    Align = alClient
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 0
    OnKeyDown = ModesSGKeyDown
    OnSetEditText = ModesSGSetEditText
    ExplicitHeight = 304
    RowHeights = (
      24
      24
      24
      24
      24)
  end
end
