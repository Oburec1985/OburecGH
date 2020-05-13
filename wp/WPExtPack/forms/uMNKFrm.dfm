object MNKFrm: TMNKFrm
  Left = 0
  Top = 0
  Caption = 'MNKFrm'
  ClientHeight = 139
  ClientWidth = 282
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object PolyLabel: TLabel
    Left = 177
    Top = 13
    Width = 58
    Height = 17
    Caption = #1055#1086#1083#1080#1085#1086#1084
  end
  object Label1: TLabel
    Left = 177
    Top = 48
    Width = 82
    Height = 17
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1063#1080#1089#1083#1086' '#1090#1086#1095#1077#1082
  end
  object PolySE: TSpinEdit
    Left = 10
    Top = 9
    Width = 161
    Height = 22
    MaxValue = 1000
    MinValue = 0
    TabOrder = 0
    Value = 1
  end
  object PolyCount: TIntEdit
    Left = 10
    Top = 44
    Width = 159
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 1
    Text = '100'
  end
  object ApplyBtn: TButton
    Left = 10
    Top = 80
    Width = 95
    Height = 32
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 2
  end
end
