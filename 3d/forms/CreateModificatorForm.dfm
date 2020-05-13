object cCreateModificatorForm: TcCreateModificatorForm
  Left = 0
  Top = 0
  Caption = 'CreateModificatorForm'
  ClientHeight = 442
  ClientWidth = 278
  Color = clBtnFace
  Constraints.MaxWidth = 286
  Constraints.MinHeight = 114
  Constraints.MinWidth = 178
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 278
    Height = 57
    Align = alTop
    Caption = #1044#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    DesignSize = (
      278
      57)
    object CancelBtn: TButton
      Left = 7
      Top = 24
      Width = 73
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 197
      Top = 24
      Width = 73
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1057#1086#1079#1076#1072#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
  object ModificatorsLV: TBtnListView
    Left = 0
    Top = 57
    Width = 278
    Height = 385
    Align = alClient
    Columns = <
      item
        Caption = #1048#1084#1103' '#1084#1086#1076#1080#1092#1080#1082#1072#1090#1086#1088#1072
        Width = 274
      end>
    TabOrder = 1
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
  end
end
