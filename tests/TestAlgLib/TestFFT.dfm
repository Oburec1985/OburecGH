object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 467
  ClientWidth = 689
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
  object Button1: TButton
    Left = 48
    Top = 32
    Width = 169
    Height = 25
    Caption = 'FFTAnalysis'
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 264
    Top = 32
    Width = 409
    Height = 201
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object AlgLib: TButton
    Left = 48
    Top = 80
    Width = 169
    Height = 25
    Caption = 'AlgLib'
    TabOrder = 2
    OnClick = AlgLibClick
  end
  object SSEBtn: TButton
    Left = 48
    Top = 128
    Width = 169
    Height = 25
    Caption = 'SSE'
    TabOrder = 3
    OnClick = SSEBtnClick
  end
end
