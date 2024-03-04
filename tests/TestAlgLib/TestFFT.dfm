object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 350
  ClientWidth = 517
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Button1: TButton
    Left = 7
    Top = 24
    Width = 127
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'FFTAnalysis'
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 138
    Top = 23
    Width = 307
    Height = 151
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object AlgLib: TButton
    Left = 7
    Top = 60
    Width = 127
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'AlgLib'
    TabOrder = 2
    OnClick = AlgLibClick
  end
  object SSEBtn: TButton
    Left = 7
    Top = 96
    Width = 127
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'SSE'
    TabOrder = 3
    OnClick = SSEBtnClick
  end
  object MultArraySSE: TButton
    Left = 7
    Top = 178
    Width = 127
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'MulArray SSE'
    TabOrder = 4
    OnClick = MultArraySSEClick
  end
end
