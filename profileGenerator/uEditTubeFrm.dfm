object EditTubeFrm: TEditTubeFrm
  Left = 0
  Top = 0
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1090#1088#1091#1073#1086#1082' '#1076#1086#1087#1091#1089#1082#1072
  ClientHeight = 558
  ClientWidth = 744
  Color = clBtnFace
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
    Top = 379
    Width = 744
    Height = 179
    Align = alBottom
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    ExplicitTop = 385
    DesignSize = (
      744
      179)
    object Label1: TLabel
      Left = 3
      Top = 19
      Width = 69
      Height = 13
      Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
    end
    object Label2: TLabel
      Left = 3
      Top = 75
      Width = 627
      Height = 13
      Caption = 
        #1048#1084#1103' '#1090#1088#1091#1073#1082#1080' '#1076#1086#1087#1091#1089#1082#1072' ('#1088#1072#1089#1096#1080#1088#1077#1085#1080#1077' '#1080' '#1087#1091#1090#1100' '#1091#1082#1072#1079#1099#1074#1072#1090#1100' '#1085#1077' '#1090#1088#1077#1073#1091#1077#1090#1089#1103'. '#1060#1072 +
        #1081#1083' '#1076#1086#1087#1091#1089#1082#1086#1074' '#1076#1086#1083#1078#1077#1085' '#1083#1077#1078#1072#1090#1100' '#1088#1103#1076#1086#1084' '#1089' '#1092#1072#1081#1083#1086#1084' *.mera)'
    end
    object FilePath: TEdit
      Left = 3
      Top = 38
      Width = 589
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = CheckFile
    end
    object OpenBtn: TButton
      Left = 598
      Top = 38
      Width = 57
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 1
      OnClick = OpenFileBtnClick
    end
    object Button1: TButton
      Left = 661
      Top = 151
      Width = 80
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1053#1072#1079#1085#1072#1095#1080#1090#1100
      ModalResult = 1
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 3
      Top = 151
      Width = 86
      Height = 25
      Caption = #1042#1099#1093#1086#1076
      ModalResult = 2
      TabOrder = 3
    end
    object TubePath: TEdit
      Left = 3
      Top = 94
      Width = 589
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
    end
    object OpenFileBtn: TButton
      Left = 598
      Top = 94
      Width = 80
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 5
      OnClick = OpenBtnClick
    end
  end
  object SignalsLV: TBtnListView
    Left = 0
    Top = 0
    Width = 744
    Height = 379
    Align = alClient
    Columns = <
      item
        Caption = #8470
      end
      item
        Caption = #1048#1084#1103' '#1089#1080#1075#1085#1072#1083#1072
      end
      item
        Caption = #1048#1084#1103' '#1090#1088#1091#1073#1082#1080' '#1076#1086#1087#1091#1089#1082#1072
      end>
    MultiSelect = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    BtnCol = 0
    QuoteColumnBtnClick = False
    QuoteColumnDblClick = False
    DrawColorBox = False
    ExplicitHeight = 328
  end
  object OpenTubeDlg: TOpenDialog
    Left = 24
    Top = 32
  end
  object OpenFileDlg: TOpenDialog
    Left = 96
    Top = 32
  end
end
