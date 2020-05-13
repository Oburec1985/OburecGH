object InfoForm: TInfoForm
  Left = 0
  Top = 0
  Caption = 'InfoForm'
  ClientHeight = 457
  ClientWidth = 239
  Color = clBtnFace
  Constraints.MaxWidth = 247
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    239
    457)
  PixelsPerInch = 96
  TextHeight = 16
  object BtnListView1: TBtnListView
    Left = 0
    Top = 0
    Width = 426
    Height = 423
    Align = alCustom
    Anchors = [akLeft, akTop, akBottom]
    Checkboxes = True
    Columns = <
      item
        Caption = #1048#1084#1103' '#1086#1073#1098#1077#1082#1090#1072
        Width = 84
      end
      item
        Caption = #1058#1080#1087
        Width = 73
      end
      item
        Caption = #1055#1086#1079#1080#1094#1080#1103
        Width = 85
      end>
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
  end
  object CancelBtn: TButton
    Left = 2
    Top = 427
    Width = 75
    Height = 29
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object OkBtn: TButton
    Left = 162
    Top = 427
    Width = 75
    Height = 29
    Anchors = [akLeft, akBottom]
    Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
    ModalResult = 1
    TabOrder = 2
  end
end
