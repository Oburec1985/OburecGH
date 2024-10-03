object GetMngObjForm: TGetMngObjForm
  Left = 0
  Top = 0
  Caption = #1042#1099#1073#1086#1088' '#1086#1073#1098#1077#1082#1090#1072
  ClientHeight = 374
  ClientWidth = 230
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object ControlGB: TGroupBox
    Left = 0
    Top = 301
    Width = 230
    Height = 73
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    Caption = #1044#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    DesignSize = (
      230
      73)
    object ApplyBtn: TButton
      Left = 127
      Top = 25
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
    end
    object CancelBtn: TButton
      Left = 4
      Top = 25
      Width = 98
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ObjectsLV: TBtnListView
    Left = 0
    Top = 0
    Width = 230
    Height = 301
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Columns = <>
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
