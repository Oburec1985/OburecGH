object PeakFrm: TPeakFrm
  Left = 0
  Top = 0
  Caption = #1057#1087#1080#1089#1086#1082' '#1101#1082#1089#1090#1088#1077#1084#1091#1084#1086#1074
  ClientHeight = 467
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  TextHeight = 13
  object TrigStatusLabel: TLabel
    Left = 0
    Top = 445
    Width = 635
    Height = 22
    Align = alBottom
    AutoSize = False
    Color = 14537983
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
    Visible = False
  end
  object DebugPanel: TPanel
    Left = 0
    Top = 0
    Width = 635
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 631
    object PeakStatusLabel: TLabel
      Left = 146
      Top = 4
      Width = 260
      Height = 21
      AutoSize = False
      Caption = #1055#1086#1083#1086#1089#1099' '#1085#1077' '#1085#1072#1081#1076#1077#1085#1099
      Color = 16757940
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
    object RatioStatusLabel: TLabel
      Left = 412
      Top = 4
      Width = 145
      Height = 21
      AutoSize = False
      Caption = #1052#1080#1085'/'#1084#1072#1082#1089': -'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
    end
    object RatioLimitLabel: TLabel
      Left = 560
      Top = 8
      Width = 30
      Height = 13
      Caption = #1055#1086#1088#1086#1075
    end
    object DebugLogBtn: TButton
      Left = 6
      Top = 3
      Width = 130
      Height = 23
      Caption = #1051#1086#1075' '#1088#1072#1089#1095#1077#1090#1072
      TabOrder = 0
      OnClick = DebugLogBtnClick
    end
    object RatioLimitEdit: TEdit
      Left = 602
      Top = 4
      Width = 48
      Height = 21
      TabOrder = 1
      Text = '0,2'
      OnChange = RatioLimitEditChange
    end
  end
  object ProfileSG: TStringGridExt
    Left = 0
    Top = 30
    Width = 635
    Height = 415
    Align = alClient
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing]
    TabOrder = 1
    OnDrawCell = ProfileSGDrawCell
    ExplicitWidth = 631
    ExplicitHeight = 414
    ColWidths = (
      64
      65
      64
      64
      64)
    RowHeights = (
      24
      24
      24
      24
      24)
  end
end
