object BladeForm: TBladeForm
  Left = 0
  Top = 0
  Caption = 'BladeForm'
  ClientHeight = 116
  ClientWidth = 200
  Color = clBtnFace
  Constraints.MaxHeight = 150
  Constraints.MaxWidth = 208
  Constraints.MinHeight = 150
  Constraints.MinWidth = 208
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inline BladePosFrame1: TBladePosFrame
    Left = 0
    Top = 0
    Width = 200
    Height = 116
    Align = alClient
    TabOrder = 0
    inherited PosLabel: TLabel
      Left = 7
      Top = 6
      ExplicitLeft = 7
      ExplicitTop = 6
    end
    inherited BladePosFE: TFloatEdit
      Left = 7
      Top = 25
      ExplicitLeft = 7
      ExplicitTop = 25
    end
    inherited SelectActionGB: TGroupBox
      Top = 66
      Width = 200
      ExplicitTop = 166
      inherited CancelBtn: TButton
        Left = 3
        ExplicitLeft = 3
      end
      inherited ApplyBtn: TButton
        Left = 125
      end
    end
  end
end
