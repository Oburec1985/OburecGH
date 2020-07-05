object demoFrm: TdemoFrm
  Left = 0
  Top = 0
  Caption = 'demoFrm'
  ClientHeight = 293
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 488
    Top = 56
    Width = 37
    Height = 16
    Caption = 'Label1'
  end
  object Button1: TButton
    Left = 48
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 216
    Top = 64
    Width = 185
    Height = 89
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Edit1: TEdit
    Left = 488
    Top = 80
    Width = 121
    Height = 24
    TabOrder = 2
    Text = 'Edit1'
  end
end
