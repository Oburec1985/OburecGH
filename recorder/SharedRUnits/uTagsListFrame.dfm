object TagsListFrame: TTagsListFrame
  Left = 0
  Top = 0
  Width = 284
  Height = 303
  TabOrder = 0
  object FormChannelsGB: TGroupBox
    Left = 0
    Top = 0
    Width = 284
    Height = 303
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
      Width = 280
      Height = 111
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      TabOrder = 0
      DesignSize = (
        280
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
        Width = 269
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = FilterEditChange
        ExplicitWidth = 187
      end
      object FrmTagPropValueEdit: TEdit
        Left = 121
        Top = 82
        Width = 153
        Height = 24
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        ExplicitWidth = 71
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
      object ShowScalarCB: TCheckBox
        Left = 5
        Top = 39
        Width = 204
        Height = 17
        Caption = #1087#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1089#1082#1072#1083#1103#1088#1085#1099#1077' '#1090#1077#1075#1080
        TabOrder = 3
        OnClick = ShowScalarCBClick
      end
    end
    object TagsLV: TBtnListView
      Left = 2
      Top = 129
      Width = 280
      Height = 172
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
      ExplicitWidth = 198
    end
  end
end
