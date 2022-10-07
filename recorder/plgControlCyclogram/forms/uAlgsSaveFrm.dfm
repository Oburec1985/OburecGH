object SaveAlgsFrm: TSaveAlgsFrm
  Left = 0
  Top = 0
  Caption = #1057#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074' '#1088#1072#1089#1095#1077#1090#1072
  ClientHeight = 479
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object ActionPanel: TPanel
    Left = 0
    Top = 424
    Width = 490
    Height = 55
    Align = alBottom
    TabOrder = 0
    ExplicitWidth = 364
    DesignSize = (
      490
      55)
    object Label3: TLabel
      Left = 4
      Top = 16
      Width = 32
      Height = 16
      Caption = #1055#1091#1090#1100':'
    end
    object BaseFolderEdit: TEdit
      Left = 61
      Top = 6
      Width = 317
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object mdbBtn: TButton
      Left = 384
      Top = 6
      Width = 106
      Height = 30
      Anchors = [akTop, akRight]
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 1
      OnClick = mdbBtnClick
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 490
    Height = 424
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 152
    ExplicitTop = 240
    ExplicitWidth = 185
    ExplicitHeight = 41
    object SignalsLV: TBtnListView
      Left = 1
      Top = 1
      Width = 488
      Height = 422
      Align = alClient
      Columns = <
        item
          Caption = #8470
        end
        item
          Caption = #1048#1084#1103' '#1089#1080#1075#1085#1072#1083#1072
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
      ExplicitLeft = 2
      ExplicitTop = 2
    end
  end
end
