object TransNumFrm: TTransNumFrm
  Left = 0
  Top = 0
  Caption = #1056#1072#1089#1095#1077#1090' '#1085#1086#1084#1077#1088#1072' '#1087#1077#1088#1077#1076#1072#1095#1080
  ClientHeight = 644
  ClientWidth = 1004
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object AlClientPan: TPanel
    Left = 0
    Top = 0
    Width = 696
    Height = 576
    Align = alClient
    TabOrder = 0
    object RightSplitter: TSplitter
      Left = 692
      Top = 1
      Height = 574
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 576
      ExplicitTop = 176
      ExplicitHeight = 100
    end
    object ChannelsSG: TStringGrid
      Left = 1
      Top = 1
      Width = 691
      Height = 574
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      BevelInner = bvLowered
      BevelKind = bkFlat
      DefaultRowHeight = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing, goFixedRowClick]
      ParentFont = False
      TabOrder = 0
      OnDblClick = ChannelsSGDblClick
      OnDragDrop = ChannelsSGDragDrop
      OnDragOver = ChannelsSGDragOver
      OnDrawCell = ChannelsSGDrawCell
      ColWidths = (
        64
        64
        64
        64
        64)
      RowHeights = (
        32
        32
        32
        32
        32)
    end
  end
  object RightPan: TPanel
    Left = 696
    Top = 0
    Width = 308
    Height = 576
    Align = alRight
    TabOrder = 1
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 306
      Height = 574
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 306
      ExplicitHeight = 574
      inherited FormChannelsGB: TGroupBox
        Width = 306
        Height = 574
        ExplicitWidth = 306
        ExplicitHeight = 574
        inherited ChanNamesPanel: TPanel
          Width = 302
          ExplicitWidth = 302
          inherited FilterEdit: TEdit
            Width = 291
            ExplicitWidth = 291
          end
          inherited FrmTagPropValueEdit: TEdit
            Width = 175
            ExplicitWidth = 175
          end
        end
        inherited TagsLV: TBtnListView
          Width = 302
          Height = 443
          ExplicitWidth = 302
          ExplicitHeight = 443
        end
      end
    end
  end
  object BottomPan: TPanel
    Left = 0
    Top = 576
    Width = 1004
    Height = 68
    Align = alBottom
    TabOrder = 2
  end
end
