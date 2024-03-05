object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 651
  ClientWidth = 964
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
    Left = 9
    Top = 32
    Width = 170
    Height = 25
    Caption = 'FFTAnalysis'
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 184
    Top = 31
    Width = 409
    Height = 91
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object AlgLib: TButton
    Left = 9
    Top = 80
    Width = 170
    Height = 25
    Caption = 'AlgLib'
    TabOrder = 2
    OnClick = AlgLibClick
  end
  object SSEBtn: TButton
    Left = 9
    Top = 128
    Width = 170
    Height = 25
    Caption = 'SSE'
    TabOrder = 3
    OnClick = SSEBtnClick
  end
  object MultArraySSE: TButton
    Left = 9
    Top = 237
    Width = 170
    Height = 26
    Caption = 'MulArray SSE'
    TabOrder = 4
    OnClick = MultArraySSEClick
  end
  object cChart1: cChart
    Left = 185
    Top = 128
    Width = 688
    Height = 400
    Caption = 'cChart1'
    TabOrder = 5
    allowEditPages = False
    showTV = False
    showLegend = False
    selectSize = 5
  end
  object IterCountIE: TIntEdit
    Left = 8
    Top = 304
    Width = 121
    Height = 24
    TabOrder = 6
    Text = '10'
  end
end
