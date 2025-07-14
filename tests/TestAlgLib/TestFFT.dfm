object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 840
  ClientWidth = 1112
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
  object Splitter1: TSplitter
    Left = 0
    Top = 117
    Width = 1112
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 0
    ExplicitWidth = 120
  end
  object Memo1: TMemo
    Left = 184
    Top = 9
    Width = 409
    Height = 52
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object AlgLib: TButton
    Left = 9
    Top = 9
    Width = 170
    Height = 26
    Caption = 'AlgLib'
    TabOrder = 1
  end
  object SSEBtn: TButton
    Left = 9
    Top = 40
    Width = 171
    Height = 25
    Caption = 'SSE'
    TabOrder = 2
    OnClick = SSEBtnClick
  end
  object MultArraySSE: TButton
    Left = 599
    Top = 8
    Width = 169
    Height = 27
    Caption = 'MulArray SSE'
    TabOrder = 3
    OnClick = MultArraySSEClick
  end
  object cChart1: cChart
    Left = 0
    Top = 120
    Width = 1112
    Height = 720
    Cursor = crSizeAll
    Align = alBottom
    Caption = 'cChart1'
    Color = clBlack
    ParentBackground = False
    TabOrder = 4
    allowEditPages = False
    showTV = False
    showLegend = False
    selectSize = 5
  end
  object IterCountIE: TIntEdit
    Left = 773
    Top = 8
    Width = 122
    Height = 24
    TabOrder = 5
    Text = '1'
  end
  object LgyCb: TCheckBox
    Left = 600
    Top = 41
    Width = 72
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'LgyCb'
    TabOrder = 6
    OnClick = LgyCbClick
  end
  object UseShaders: TCheckBox
    Left = 680
    Top = 41
    Width = 88
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'UseShaders'
    TabOrder = 7
    OnClick = UseShadersClick
  end
  object CheckBox1: TCheckBox
    Left = 600
    Top = 72
    Width = 72
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'LgXCb'
    TabOrder = 8
    OnClick = CheckBox1Click
  end
  object SpmDxFe: TFloatEdit
    Left = 773
    Top = 41
    Width = 122
    Height = 24
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 9
    Text = '0.0'
  end
end
