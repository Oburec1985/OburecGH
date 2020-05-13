object SelAlgDlg: TSelAlgDlg
  Left = 0
  Top = 0
  Caption = #1042#1099#1073#1086#1088' '#1072#1083#1075#1086#1088#1080#1090#1084#1072
  ClientHeight = 472
  ClientWidth = 478
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  inline SelectAlgFrame1: TSelectAlgFrame
    Left = 0
    Top = 0
    Width = 478
    Height = 472
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 478
    ExplicitHeight = 472
    inherited SelAlgFrame: TGroupBox
      Width = 478
      Height = 423
      ExplicitWidth = 478
      ExplicitHeight = 423
      inherited SelAlgLV: TBtnListView
        Width = 474
        Height = 406
        ExplicitLeft = 4
        ExplicitTop = 11
        ExplicitWidth = 296
        ExplicitHeight = 406
      end
    end
    inherited SelectActionGB: TGroupBox
      Top = 423
      Width = 478
      ExplicitTop = 423
      ExplicitWidth = 478
      inherited ApplyBtn: TButton
        Left = 393
        ExplicitLeft = 393
      end
    end
  end
end
