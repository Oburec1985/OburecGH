object LogFrame: TLogFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  OnResize = FrameResize
  object ControlGB: TGroupBox
    Left = 0
    Top = 264
    Width = 451
    Height = 40
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      451
      40)
    object FilterLabel: TLabel
      Left = 281
      Top = 9
      Width = 38
      Height = 13
      Anchors = [akTop, akRight]
      Caption = #1060#1080#1083#1100#1090#1088
      ExplicitLeft = 224
    end
    object ClearBtn: TButton
      Left = 3
      Top = 6
      Width = 75
      Height = 25
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100
      TabOrder = 0
    end
    object FilterCB: TComboBox
      Left = 335
      Top = 6
      Width = 113
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 1
      Text = 'FilterCB'
    end
  end
  object LogSg: TStringGrid
    Left = 0
    Top = 0
    Width = 451
    Height = 264
    Align = alClient
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
    TabOrder = 1
  end
end
