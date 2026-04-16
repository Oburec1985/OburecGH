object EditRepPropFrm: TEditRepPropFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1087#1080#1089#1082#1072' '#1082#1072#1085#1072#1083#1086#1074' '#1076#1083#1103' '#1086#1090#1095#1077#1090#1072
  ClientHeight = 795
  ClientWidth = 518
  Color = clBtnFace
  Constraints.MinWidth = 539
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 17
  object GroupBox1: TGroupBox
    Left = 0
    Top = 722
    Width = 518
    Height = 73
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    Caption = #1042#1099#1073#1086#1088' '#1076#1077#1081#1089#1090#1074#1080#1103
    TabOrder = 0
    object ApplyBtn: TButton
      Left = 396
      Top = 16
      Width = 98
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
  end
  object ChannelsList: TBtnListView
    Left = 0
    Top = 0
    Width = 388
    Height = 722
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    Checkboxes = True
    Columns = <
      item
        Caption = #8470
        Width = 65
      end
      item
        Caption = #1048#1084#1103
        Width = 65
      end>
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
  object Panel1: TPanel
    Left = 388
    Top = 0
    Width = 130
    Height = 722
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    TabOrder = 2
    DesignSize = (
      130
      722)
    object Label1: TLabel
      Left = 8
      Top = 10
      Width = 93
      Height = 17
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1048#1084#1103' '#1089#1074#1086#1081#1089#1090#1074#1072':'
    end
    object OnBtn: TButton
      Left = 8
      Top = 115
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1042#1082#1083#1102#1095#1080#1090#1100
      TabOrder = 0
      OnClick = OnBtnClick
    end
    object OffBtn: TButton
      Left = 8
      Top = 167
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Cancel = True
      Caption = #1042#1099#1082#1083#1102#1095#1080#1090#1100
      TabOrder = 1
      OnClick = OffBtnClick
    end
    object PropEdit: TEdit
      Left = 8
      Top = 52
      Width = 98
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 2
      Text = 'PropEdit'
    end
  end
end
