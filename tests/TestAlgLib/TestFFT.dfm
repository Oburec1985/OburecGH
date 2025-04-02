object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 521
  ClientWidth = 834
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
    834
    521)
  PixelsPerInch = 96
  TextHeight = 12
  object Memo1: TMemo
    Left = 138
    Top = 7
    Width = 307
    Height = 39
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
    Left = 6
    Top = 31
    Width = 128
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
    Top = 6
    Width = 127
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'MulArray SSE'
    TabOrder = 3
    OnClick = MultArraySSEClick
  end
  object cChart1: cChart
    Left = 6
    Top = 99
    Width = 793
    Height = 398
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
    Text = '1'
  end
  object LgyCb: TCheckBox
    Left = 450
    Top = 31
    Width = 54
    Height = 17
    Caption = 'LgyCb'
    TabOrder = 6
    OnClick = LgyCbClick
  end
  object UseShaders: TCheckBox
    Left = 510
    Top = 31
    Width = 66
    Height = 17
    Caption = 'UseShaders'
    TabOrder = 7
    OnClick = UseShadersClick
  end
  object CheckBox1: TCheckBox
    Left = 450
    Top = 54
    Width = 54
    Height = 17
    Caption = 'LgXCb'
    TabOrder = 8
    OnClick = CheckBox1Click
  end
end
