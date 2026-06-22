object PeakFrm: TPeakFrm
  Left = 0
  Top = 0
  Caption = 'Список экстремумов'
  ClientHeight = 467
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
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
    object DebugLogBtn: TButton
      Left = 6
      Top = 3
      Width = 130
      Height = 23
      Caption = 'Лог расчета'
      TabOrder = 0
      OnClick = DebugLogBtnClick
    end
    object PeakStatusLabel: TLabel
      Left = 146
      Top = 4
      Width = 260
      Height = 21
      AutoSize = False
      Caption = 'Полосы не найдены'
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
      Caption = 'Мин/макс: -'
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
      Width = 38
      Height = 13
      Caption = 'Порог'
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