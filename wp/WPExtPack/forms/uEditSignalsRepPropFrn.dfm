object EditRepPropFrm: TEditRepPropFrm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1087#1080#1089#1082#1072' '#1082#1072#1085#1072#1083#1086#1074' '#1076#1083#1103' '#1086#1090#1095#1077#1090#1072
  ClientHeight = 608
  ClientWidth = 396
  Color = clBtnFace
  Constraints.MinWidth = 412
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 552
    Width = 396
    Height = 56
    Align = alBottom
    Caption = #1042#1099#1073#1086#1088' '#1076#1077#1081#1089#1090#1074#1080#1103
    TabOrder = 0
    object ApplyBtn: TButton
      Left = 303
      Top = 12
      Width = 75
      Height = 25
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
  end
  object ChannelsList: TBtnListView
    Left = 0
    Top = 0
    Width = 297
    Height = 552
    Align = alLeft
    Checkboxes = True
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = #1048#1084#1103
      end>
    MultiSelect = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    Editable = False
  end
  object Panel1: TPanel
    Left = 297
    Top = 0
    Width = 99
    Height = 552
    Align = alClient
    TabOrder = 2
    DesignSize = (
      99
      552)
    object Label1: TLabel
      Left = 6
      Top = 8
      Width = 72
      Height = 13
      Caption = #1048#1084#1103' '#1089#1074#1086#1081#1089#1090#1074#1072':'
    end
    object OnBtn: TButton
      Left = 6
      Top = 88
      Width = 75
      Height = 25
      Caption = #1042#1082#1083#1102#1095#1080#1090#1100
      TabOrder = 0
      OnClick = OnBtnClick
    end
    object OffBtn: TButton
      Left = 6
      Top = 128
      Width = 75
      Height = 25
      Cancel = True
      Caption = #1042#1099#1082#1083#1102#1095#1080#1090#1100
      TabOrder = 1
      OnClick = OffBtnClick
    end
    object PropEdit: TEdit
      Left = 6
      Top = 40
      Width = 75
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 2
      Text = 'PropEdit'
    end
  end
end
