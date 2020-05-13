object SelectSensorsForm: TSelectSensorsForm
  Left = 0
  Top = 0
  Caption = #1042#1099#1073#1086#1088' '#1076#1072#1090#1095#1080#1082#1086#1074
  ClientHeight = 216
  ClientWidth = 282
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object SensorsLV: TBtnListView
    Left = 0
    Top = 0
    Width = 282
    Height = 167
    Align = alClient
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = #1048#1084#1103
      end>
    MultiSelect = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 167
    Width = 282
    Height = 49
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    DesignSize = (
      282
      49)
    object CancelBtn: TButton
      Left = 8
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 199
      Top = 21
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
end
