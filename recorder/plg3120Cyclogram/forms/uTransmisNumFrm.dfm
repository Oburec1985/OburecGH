object TransNumFrm: TTransNumFrm
  Left = 0
  Top = 0
  Caption = #1056#1072#1089#1095#1077#1090' '#1085#1086#1084#1077#1088#1072' '#1087#1077#1088#1077#1076#1072#1095#1080
  ClientHeight = 403
  ClientWidth = 771
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
    Width = 390
    Height = 352
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    TabOrder = 0
    object RightSplitter: TSplitter
      Left = 386
      Top = 1
      Height = 350
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alRight
      Color = clBackground
      ParentColor = False
    end
    object ChannelsSG: TStringGrid
      Left = 1
      Top = 1
      Width = 385
      Height = 350
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
    Left = 540
    Top = 0
    Width = 231
    Height = 352
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
      Height = 350
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 229
      ExplicitHeight = 350
      inherited FormChannelsGB: TGroupBox
        Width = 229
        Height = 350
        Margins.Left = 3
        Margins.Top = 3
        Margins.Right = 3
        Margins.Bottom = 3
        ExplicitWidth = 229
        ExplicitHeight = 350
        inherited ChanNamesPanel: TPanel
          Top = 14
          Width = 225
          Height = 81
          Margins.Left = 3
          Margins.Top = 3
          Margins.Right = 3
          Margins.Bottom = 3
          ExplicitTop = 14
          ExplicitWidth = 225
          ExplicitHeight = 81
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
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 4
            ExplicitTop = 6
            ExplicitWidth = 218
          end
          inherited FrmTagPropValueEdit: TEdit
            Left = 91
            Top = 62
            Width = 131
            Margins.Left = 3
            Margins.Top = 3
            Margins.Right = 3
            Margins.Bottom = 3
            ExplicitLeft = 91
            ExplicitTop = 62
            ExplicitWidth = 131
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
          Top = 95
          Width = 225
          Height = 253
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
          ExplicitTop = 95
          ExplicitWidth = 226
          ExplicitHeight = 254
        end
      end
    end
  end
  object BottomPan: TPanel
    Left = 0
    Top = 352
    Width = 771
    Height = 51
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    TabOrder = 2
    object BlockChanLabel: TLabel
      Left = 125
      Top = 5
      Width = 155
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1050#1072#1085#1072#1083' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1080' '#1090#1088#1072#1085#1089#1084#1080#1089#1089#1080#1080
    end
    object ModeLinkCb: TCheckBox
      Left = 12
      Top = 5
      Width = 109
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1057#1074#1103#1079#1100' '#1089' '#1088#1077#1078#1080#1084#1072#1084#1080
      TabOrder = 0
    end
    object BlockChanCB: TRcComboBox
      Left = 125
      Top = 22
      Width = 109
      Height = 24
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 1
      OnChange = BlockChanCBChange
      OnDragDrop = BlockChanCBDragDrop
    end
    object BlockUseCB: TCheckBox
      Left = 12
      Top = 22
      Width = 109
      Height = 13
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1059#1095#1077#1090' '#1073#1083#1086#1082#1080#1088#1086#1074#1082#1080
      TabOrder = 2
      Visible = False
    end
  end
  object ModesLV: TBtnListView
    Left = 390
    Top = 0
    Width = 150
    Height = 352
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
