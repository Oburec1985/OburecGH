object GetMngObjForm: TGetMngObjForm
  Left = 0
  Top = 0
  Caption = #1042#1099#1073#1086#1088' '#1086#1073#1098#1077#1082#1090#1072
  ClientHeight = 286
  ClientWidth = 176
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ControlGB: TGroupBox
    Left = 0
    Top = 230
    Width = 176
    Height = 56
    Align = alBottom
    Caption = #1044#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    ExplicitLeft = -200
    ExplicitWidth = 455
    DesignSize = (
      176
      56)
    object ApplyBtn: TButton
      Left = 97
      Top = 19
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 176
    end
    object CancelBtn: TButton
      Left = 3
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ObjectsLV: TBtnListView
    Left = 0
    Top = 0
    Width = 176
    Height = 230
    Align = alClient
    Columns = <>
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
end
