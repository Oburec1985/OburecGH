object ControlEditFrame: TControlEditFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  Constraints.MinWidth = 296
  TabOrder = 0
  object ControlPanel: TPanel
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    Constraints.MinWidth = 228
    TabOrder = 0
    object ControlNameLabel: TLabel
      Left = 3
      Top = 13
      Width = 81
      Height = 13
      Caption = #1048#1084#1103' '#1088#1077#1075#1091#1083#1103#1090#1086#1088#1072
    end
    object FeedbackLabel: TLabel
      Left = 144
      Top = 13
      Width = 81
      Height = 13
      Caption = #1054#1073#1088#1072#1090#1085#1072#1103' '#1089#1074#1103#1079#1100
    end
    object Splitter1: TSplitter
      Left = 1
      Top = 107
      Width = 449
      Height = 3
      Cursor = crVSplit
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      Color = clBlack
      Constraints.MaxHeight = 3
      ParentColor = False
      ExplicitTop = 105
    end
    object ControlsPageControl: TPageControl
      Left = 1
      Top = 110
      Width = 449
      Height = 193
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alBottom
      TabOrder = 0
    end
    object ControlNameEdit: TEdit
      Left = 3
      Top = 32
      Width = 121
      Height = 24
      TabOrder = 1
    end
    object FeedbackCB: TComboBox
      Left = 144
      Top = 32
      Width = 145
      Height = 21
      TabOrder = 2
      OnChange = FeedbackCBChange
      OnDragDrop = FeedbackCBDragDrop
      OnDragOver = FeedbackCBDragOver
    end
  end
end
