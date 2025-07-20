object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 630
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
  end
  object SSEBtn: TButton
    Left = 7
    Top = 30
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
    Left = 0
    Top = 90
    Width = 834
    Height = 540
    Cursor = crSizeAll
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
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
  object SpmDxFe: TFloatEdit
    Left = 580
    Top = 31
    Width = 91
    Height = 20
    TabOrder = 9
    Text = '0.0'
  end
end
