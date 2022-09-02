object TagsListFrame: TTagsListFrame
  Left = 0
  Top = 0
  Width = 202
  Height = 445
  TabOrder = 0
  object FormChannelsGB: TGroupBox
    Left = 0
    Top = 0
    Width = 202
    Height = 445
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Caption = #1057#1087#1080#1089#1086#1082' '#1082#1072#1085#1072#1083#1086#1074
    TabOrder = 0
    object ChanNamesPanel: TPanel
      Left = 2
      Top = 18
      Width = 198
      Height = 111
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 0
      DesignSize = (
        198
        111)
      object FrmTagPropLabel: TLabel
        Left = 5
        Top = 58
        Width = 55
        Height = 16
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1057#1074#1086#1081#1089#1090#1074#1086
      end
      object FrmTagPropValue: TLabel
        Left = 121
        Top = 60
        Width = 56
        Height = 16
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1047#1085#1072#1095#1077#1085#1080#1077
      end
      object FilterEdit: TEdit
        Left = 5
        Top = 8
        Width = 187
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = FilterEditChange
      end
      object FrmTagPropValueEdit: TEdit
        Left = 121
        Top = 82
        Width = 71
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object FrmTagPropNameCB: TComboBox
        Left = 5
        Top = 82
        Width = 108
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 2
      end
    end
    object TagsLV: TBtnListView
      Left = 2
      Top = 129
      Width = 198
      Height = 314
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
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
        end>
      DragMode = dmAutomatic
      MultiSelect = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
  end
end
