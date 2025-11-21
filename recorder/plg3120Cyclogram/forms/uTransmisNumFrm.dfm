object TransNumFrm: TTransNumFrm
  Left = 0
  Top = 0
  Caption = #1056#1072#1089#1095#1077#1090' '#1085#1086#1084#1077#1088#1072' '#1087#1077#1088#1077#1076#1072#1095#1080
  ClientHeight = 644
  ClientWidth = 1115
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
    Width = 607
    Height = 576
    Align = alClient
    TabOrder = 0
    object RightSplitter: TSplitter
      Left = 602
      Top = 1
      Width = 4
      Height = 574
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 601
    end
    object ChannelsSG: TStringGrid
      Left = 1
      Top = 1
      Width = 601
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
      OnKeyDown = ChannelsSGKeyDown
      OnSetEditText = ChannelsSGSetEditText
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
    Left = 807
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
          Height = 109
          ExplicitWidth = 302
          ExplicitHeight = 109
          inherited FrmTagPropLabel: TLabel
            Top = 59
            ExplicitTop = 59
          end
          inherited FilterEdit: TEdit
            Width = 291
            ExplicitWidth = 291
          end
          inherited FrmTagPropValueEdit: TEdit
            Top = 83
            Width = 175
            ExplicitTop = 83
            ExplicitWidth = 175
          end
          inherited FrmTagPropNameCB: TComboBox
            Top = 83
            ExplicitTop = 83
          end
        end
        inherited TagsLV: TBtnListView
          Top = 127
          Width = 302
          Height = 445
          Columns = <
            item
              Caption = #1048#1084#1103
              Width = 65
            end
            item
              Caption = #1058#1080#1087
              Width = 65
            end
            item
              Caption = 'Fs'
              Width = 51
            end>
          ExplicitTop = 127
          ExplicitWidth = 302
          ExplicitHeight = 445
        end
      end
    end
  end
  object BottomPan: TPanel
    Left = 0
    Top = 576
    Width = 1115
    Height = 68
    Align = alBottom
    TabOrder = 2
    object BlockChanLabel: TLabel
      Left = 167
      Top = 2
      Width = 185
      Height = 16
      Caption = #1050#1072#1085#1072#1083' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1080' '#1090#1088#1072#1085#1089#1084#1080#1089#1089#1080#1080
    end
    object ModeLinkCb: TCheckBox
      Left = 16
      Top = 16
      Width = 145
      Height = 17
      Caption = #1057#1074#1103#1079#1100' '#1089' '#1088#1077#1078#1080#1084#1072#1084#1080
      TabOrder = 0
    end
    object BlockChanCB: TRcComboBox
      Left = 167
      Top = 24
      Width = 145
      Height = 24
      TabOrder = 1
      OnChange = BlockChanCBChange
      OnDragDrop = BlockChanCBDragDrop
    end
  end
  object ModesLV: TBtnListView
    Left = 607
    Top = 0
    Width = 200
    Height = 576
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    Columns = <
      item
        Caption = #1056#1077#1078#1080#1084
        Width = 65
      end>
    DragMode = dmAutomatic
    MultiSelect = True
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ChangeTextColor = False
    Editable = False
  end
end
