object EditPropertiesFrm: TEditPropertiesFrm
  Left = 0
  Top = 0
  Caption = 'EditPropertiesFrm'
  ClientHeight = 291
  ClientWidth = 633
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object SG: TStringGrid
    Left = 0
    Top = 0
    Width = 633
    Height = 226
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelInner = bvLowered
    BevelKind = bkFlat
    ColCount = 2
    DefaultRowHeight = 32
    RowCount = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
    ParentFont = False
    TabOrder = 0
    OnDblClick = SGDblClick
    RowHeights = (
      32
      32)
  end
  object Panel1: TPanel
    Left = 0
    Top = 226
    Width = 633
    Height = 65
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      633
      65)
    object CancelBtn: TButton
      Left = 16
      Top = 7
      Width = 113
      Height = 52
      Anchors = [akLeft, akTop, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -22
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 493
      Top = 7
      Width = 131
      Height = 52
      Anchors = [akTop, akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -22
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = ApplyBtnClick
    end
  end
end
