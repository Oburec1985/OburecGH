object AddRZDDataFrm: TAddRZDDataFrm
  Left = 0
  Top = 0
  Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093' '#1074' '#1073#1072#1079#1091
  ClientHeight = 483
  ClientWidth = 1131
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object Splitter2: TSplitter
    Left = 553
    Top = 0
    Height = 415
    Align = alRight
  end
  object ApplyGB: TGroupBox
    Left = 0
    Top = 415
    Width = 1131
    Height = 68
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      1131
      68)
    object ApplyBtnMR: TButton
      Left = 1027
      Top = 21
      Width = 94
      Height = 40
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = ApplyBtnMRClick
    end
  end
  object LV1: TBtnListView
    Left = 0
    Top = 0
    Width = 553
    Height = 415
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Columns = <
      item
        Caption = #1060#1072#1081#1083
        Width = 65
      end
      item
        Caption = #1058#1080#1087
        Width = 65
      end>
    MultiSelect = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnChange = LV1Change
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    Editable = False
  end
  object Panel2: TPanel
    Left = 556
    Top = 0
    Width = 575
    Height = 415
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alRight
    TabOrder = 2
    DesignSize = (
      575
      415)
    object SigNameLabel: TLabel
      Left = 251
      Top = 17
      Width = 78
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1048#1084#1103' '#1079#1072#1084#1077#1088#1072':'
    end
    object Label2: TLabel
      Left = 251
      Top = 76
      Width = 80
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1055#1091#1090#1100' '#1074' '#1073#1072#1079#1077':'
    end
    object RegionLabel: TLabel
      Left = 251
      Top = 183
      Width = 114
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1059#1095#1072#1089#1090#1086#1082' '#1087#1091#1090#1080' '#8470':'
    end
    object SigName: TEdit
      Left = 251
      Top = 42
      Width = 303
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 242
      Height = 413
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      TabOrder = 1
      ExplicitHeight = 412
      object CalibrRG: TRadioGroup
        Left = 1
        Top = 116
        Width = 240
        Height = 295
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        Caption = #1058#1080#1087' '#1079#1072#1084#1077#1088#1072
        ItemIndex = 0
        Items.Strings = (
          #1042#1077#1088#1090'. '#1094#1077#1085#1090#1088'.'
          #1043#1086#1088#1080#1079'. '#1089#1080#1083#1072
          #1042#1077#1088#1090'. '#1089' '#1089#1084#1077#1097'. '#1085#1072#1088#1091#1078#1091
          #1042#1077#1088#1090'. '#1089' '#1089#1084#1077#1097'. '#1074#1085#1091#1090#1088#1100)
        TabOrder = 0
      end
      object TypeRG: TRadioGroup
        Left = 1
        Top = 1
        Width = 240
        Height = 115
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alTop
        Caption = #1058#1080#1087' '#1079#1072#1084#1077#1088#1072
        ItemIndex = 1
        Items.Strings = (
          #1047#1072#1077#1079#1076
          #1050#1072#1083#1080#1073#1088#1086#1074#1082#1072)
        TabOrder = 1
        OnClick = TypeRGClick
      end
    end
    object CalibrPanel: TPanel
      Left = 251
      Top = 256
      Width = 318
      Height = 151
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 2
      object Label1: TLabel
        Left = 3
        Top = 78
        Width = 79
        Height = 17
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = #1057#1077#1095#1077#1085#1080#1077' '#8470':'
      end
      object SegSE: TSpinEdit
        Left = -1
        Top = 103
        Width = 158
        Height = 22
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 0
      end
    end
    object BasePath: TEdit
      Left = 251
      Top = 101
      Width = 303
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
    end
    object AplyBtn1: TButton
      Left = 251
      Top = 136
      Width = 158
      Height = 41
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1053#1072#1079#1085#1072#1095#1080#1090#1100
      TabOrder = 4
      OnClick = ApplyBtnClick
    end
    object RegSE: TSpinEdit
      Left = 251
      Top = 208
      Width = 158
      Height = 22
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      MaxValue = 0
      MinValue = 0
      TabOrder = 5
      Value = 0
    end
  end
end
