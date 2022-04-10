object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 467
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
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
    Width = 169
    Height = 25
    Caption = 'FFTAnalysis'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 288
    Top = 80
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
  object AlgLib: TButton
    Left = 48
    Top = 80
    Width = 169
    Height = 25
    Caption = 'AlgLib'
    TabOrder = 3
    OnClick = AlgLibClick
  end
  object SSEBtn: TButton
    Left = 48
    Top = 128
    Width = 169
    Height = 25
    Caption = 'SSE'
    TabOrder = 4
    OnClick = SSEBtnClick
  end
  object ListBox1: TListBox
    Left = 288
    Top = 200
    Width = 121
    Height = 217
    TabOrder = 5
  end
end
