object Form1: TForm1
  Left = 294
  Top = 202
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 118
  ClientWidth = 368
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Tag = 1
    Left = 4
    Top = 36
    Width = 50
    Height = 13
    Caption = 'Copy from:'
  end
  object Label2: TLabel
    Tag = 2
    Left = 15
    Top = 60
    Width = 39
    Height = 13
    Caption = 'Copy to:'
  end
  object Button1: TButton
    Tag = 1
    Left = 288
    Top = 32
    Width = 75
    Height = 21
    Caption = 'Browse'
    TabOrder = 0
    OnClick = BrowseClick
  end
  object Edit1: TEdit
    Tag = 1
    Left = 56
    Top = 32
    Width = 229
    Height = 21
    TabOrder = 1
    Text = 'C:\'
  end
  object Edit2: TEdit
    Tag = 2
    Left = 56
    Top = 56
    Width = 229
    Height = 21
    TabOrder = 2
    Text = 'V:\'
  end
  object Button2: TButton
    Tag = 2
    Left = 288
    Top = 56
    Width = 75
    Height = 21
    Caption = 'Browse'
    TabOrder = 3
    OnClick = BrowseClick
  end
  object Button3: TButton
    Left = 140
    Top = 84
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 4
    OnClick = StartClick
  end
end
