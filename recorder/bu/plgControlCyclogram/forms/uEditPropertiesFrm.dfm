object EditPropertiesFrm: TEditPropertiesFrm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077' '#1089#1074#1086#1081#1089#1090#1074
  ClientHeight = 521
  ClientWidth = 461
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 456
    Width = 461
    Height = 65
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      461
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
      OnClick = CancelBtnClick
    end
    object ApplyBtn: TButton
      Left = 321
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
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 461
    Height = 456
    Align = alClient
    Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1089#1074#1086#1081#1089#1090#1074
    TabOrder = 1
  end
  object SG: TStringGrid
    Left = 0
    Top = 0
    Width = 461
    Height = 456
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
    TabOrder = 2
    ExplicitLeft = -30
    ExplicitTop = 79
    ExplicitWidth = 491
    ExplicitHeight = 403
    RowHeights = (
      32
      32)
  end
end
