object TransNumFrm: TTransNumFrm
  Left = 0
  Top = 0
  Caption = #1056#1072#1089#1095#1077#1090' '#1085#1086#1084#1077#1088#1072' '#1087#1077#1088#1077#1076#1072#1095#1080
  ClientHeight = 483
  ClientWidth = 836
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object AlClientPan: TPanel
    Left = 0
    Top = 0
    Width = 455
    Height = 432
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    TabOrder = 0
    object RightSplitter: TSplitter
      Left = 451
      Top = 1
      Height = 430
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alRight
      Color = clBackground
      ParentColor = False
      ExplicitLeft = 452
    end
    object ChannelsSG: TStringGrid
      Left = 1
      Top = 1
      Width = 450
      Height = 430
      Align = alClient
      BevelInner = bvLowered
      BevelKind = bkFlat
      DefaultRowHeight = 32
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
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
    Left = 605
    Top = 0
    Width = 231
    Height = 432
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alRight
    TabOrder = 1
    inline TagsListFrame1: TTagsListFrame
      Left = 1
      Top = 1
      Width = 229
      Height = 430
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 229
      ExplicitHeight = 430
      inherited FormChannelsGB: TGroupBox
        Width = 229
        Height = 430
        Margins.Left = 3
        Margins.Top = 3
        Margins.Right = 3
        Margins.Bottom = 3
        ExplicitWidth = 229
        ExplicitHeight = 430
        inherited ChanNamesPanel: TPanel
          Top = 14
          Width = 225
          Height = 82
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          ExplicitTop = 14
          ExplicitWidth = 225
          ExplicitHeight = 82
          inherited FrmTagPropLabel: TLabel
            Left = 4
            Top = 44
            Width = 46
            Height = 12
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 44
            ExplicitWidth = 46
            ExplicitHeight = 12
          end
          inherited FrmTagPropValue: TLabel
            Left = 91
            Top = 45
            Width = 43
            Height = 12
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 91
            ExplicitTop = 45
            ExplicitWidth = 43
            ExplicitHeight = 12
          end
          inherited FilterEdit: TEdit
            Left = 4
            Top = 6
            Width = 218
            Height = 20
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 6
            ExplicitWidth = 218
            ExplicitHeight = 20
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 91
            Top = 62
            Width = 131
            Height = 20
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 91
            ExplicitTop = 62
            ExplicitWidth = 131
            ExplicitHeight = 20
          end
          inherited FrmTagPropNameCB: TComboBox
            Left = 4
            Top = 62
            Width = 81
            Height = 20
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 62
            ExplicitWidth = 81
            ExplicitHeight = 20
          end
          inherited ShowScalarCB: TCheckBox
            Left = 4
            Top = 29
            Width = 153
            Height = 13
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            ExplicitLeft = 4
            ExplicitTop = 29
            ExplicitWidth = 153
            ExplicitHeight = 13
          end
        end
        inherited TagsLV: TBtnListView
          Top = 96
          Width = 225
          Height = 332
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          Columns = <
            item
              Caption = #1048#1084#1103
              Width = 49
            end
            item
              Caption = #1058#1080#1087
              Width = 49
            end
            item
              Caption = 'Fs'
              Width = 38
            end>
          ExplicitTop = 96
          ExplicitWidth = 225
          ExplicitHeight = 332
        end
      end
    end
  end
  object BottomPan: TPanel
    Left = 0
    Top = 432
    Width = 836
    Height = 51
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 2
    object ModeLinkCb: TCheckBox
      Left = 12
      Top = 12
      Width = 109
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1074#1103#1079#1100' '#1089' '#1088#1077#1078#1080#1084#1072#1084#1080
      TabOrder = 0
    end
  end
  object ModesLV: TBtnListView
    Left = 455
    Top = 0
    Width = 150
    Height = 432
    Align = alRight
    Columns = <
      item
        Caption = #1056#1077#1078#1080#1084
        Width = 49
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
