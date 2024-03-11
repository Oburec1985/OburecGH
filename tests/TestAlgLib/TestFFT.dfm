object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 484
  ClientWidth = 736
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    736
    484)
  PixelsPerInch = 96
  TextHeight = 12
  object Memo1: TMemo
    Left = 138
    Top = 7
    Width = 307
    Height = 69
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object AlgLib: TButton
    Left = 7
    Top = 7
    Width = 127
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'AlgLib'
    TabOrder = 1
    OnClick = AlgLibClick
  end
  object SSEBtn: TButton
    Left = 7
    Top = 27
    Width = 127
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'SSE'
    TabOrder = 2
    OnClick = SSEBtnClick
  end
  object MultArraySSE: TButton
    Left = 449
    Top = 7
    Width = 127
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'MulArray SSE'
    TabOrder = 3
    OnClick = MultArraySSEClick
  end
  object cChart1: cChart
    Left = 7
    Top = 80
    Width = 722
    Height = 373
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'cChart1'
    TabOrder = 4
    allowEditPages = False
    showTV = False
    showLegend = False
    selectSize = 5
    ExplicitHeight = 377
  end
  object IterCountIE: TIntEdit
    Left = 580
    Top = 6
    Width = 91
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 5
    Text = '10'
  end
  object LgyCb: TCheckBox
    Left = 449
    Top = 31
    Width = 66
    Height = 17
    Caption = 'LgyCb'
    TabOrder = 6
    OnClick = LgyCbClick
  end
end
