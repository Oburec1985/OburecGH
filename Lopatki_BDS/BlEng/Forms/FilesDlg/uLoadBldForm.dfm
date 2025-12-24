object LoadBldDlg: TLoadBldDlg
  Left = 0
  Top = 0
  Caption = 'LoadBldDlg'
  ClientHeight = 282
  ClientWidth = 787
  Color = clBtnFace
  Constraints.MinHeight = 327
  Constraints.MinWidth = 473
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object CommonGB: TGroupBox
    Left = 0
    Top = 0
    Width = 787
    Height = 282
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1079#1072#1075#1088#1091#1079#1082#1080' '#1092#1072#1081#1083#1072
    Constraints.MinHeight = 177
    TabOrder = 0
    object SelectModeRG: TRadioGroup
      Left = 3
      Top = 20
      Width = 782
      Height = 85
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alTop
      Caption = 'SelectModeRG'
      ItemIndex = 0
      Items.Strings = (
        #1057#1074#1103#1079#1072#1090#1100' '#1089' '#1090#1077#1082#1091#1097#1077#1081' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1077#1081
        #1053#1086#1074#1072#1103' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103)
      TabOrder = 0
    end
    object SelectActionGB: TGroupBox
      Left = 3
      Top = 216
      Width = 782
      Height = 64
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
      TabOrder = 1
      DesignSize = (
        783
        64)
      object CancelBtn: TButton
        Left = 10
        Top = 25
        Width = 99
        Height = 33
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1054#1090#1084#1077#1085#1072
        ModalResult = 2
        TabOrder = 0
      end
      object ApplyBtn: TButton
        Left = 682
        Top = 27
        Width = 98
        Height = 33
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Anchors = [akTop, akRight]
        Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
        ModalResult = 1
        TabOrder = 1
        ExplicitLeft = 680
      end
    end
    object SensorsGB: TGroupBox
      Left = 2
      Top = 104
      Width = 783
      Height = 112
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Caption = #1044#1072#1090#1095#1080#1082#1080
      TabOrder = 2
      ExplicitLeft = 3
      ExplicitTop = 105
      ExplicitWidth = 782
      ExplicitHeight = 111
      object SensorsLV: TBtnListView
        Left = 3
        Top = 20
        Width = 776
        Height = 89
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        Columns = <
          item
            Caption = #8470
            Width = 65
          end
          item
            Caption = #1048#1084#1103
            Width = 65
          end
          item
            Caption = #1058#1080#1087
            Width = 48
          end
          item
            Caption = #1063#1080#1089#1083#1086' '#1080#1084#1087'.'
            Width = 65
          end
          item
            Caption = #1055#1086#1083#1086#1078'.'
            Width = 65
          end>
        RowSelect = True
        TabOrder = 0
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
end
