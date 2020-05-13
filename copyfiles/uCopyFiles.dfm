object CopyFilesFrm: TCopyFilesFrm
  Left = 0
  Top = 0
  Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1085#1080#1077' '#1082#1072#1090#1072#1083#1086#1075#1086#1074' '#1080' '#1092#1072#1081#1083#1086#1074
  ClientHeight = 521
  ClientWidth = 667
  Color = clBtnFace
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
    Top = 0
    Width = 667
    Height = 250
    Align = alClient
    Caption = #1055#1077#1088#1077#1095#1077#1085#1100' '#1092#1072#1081#1083#1086#1074' '#1076#1083#1103' '#1082#1086#1087#1080#1088#1086#1074#1072#1085#1080#1103
    TabOrder = 0
    object FilesLV: TBtnListView
      Left = 2
      Top = 15
      Width = 663
      Height = 233
      Align = alClient
      Color = clWhite
      Columns = <
        item
          Caption = #8470
        end
        item
          Caption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1087#1091#1090#1100
        end
        item
          Caption = #1053#1072#1079#1085#1072#1095#1077#1085#1080#1077
        end
        item
          Caption = #1040#1090#1090#1088#1080#1073#1091#1090#1099
        end>
      MultiSelect = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = FilesLVChange
      OnKeyDown = FilesLVKeyDown
      BtnCol = 0
      QuoteColumnBtnClick = False
      QuoteColumnDblClick = False
      DrawColorBox = False
      ChangeTextColor = False
      Editable = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 250
    Width = 667
    Height = 271
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 254
    DesignSize = (
      667
      271)
    object Label1: TLabel
      Left = 10
      Top = 65
      Width = 80
      Height = 13
      Caption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1092#1072#1081#1083
    end
    object Label2: TLabel
      Left = 10
      Top = 117
      Width = 104
      Height = 13
      Caption = #1050#1072#1090#1072#1083#1086#1075' '#1085#1072#1079#1085#1072#1095#1077#1085#1080#1103
    end
    object Label3: TLabel
      Left = 10
      Top = 173
      Width = 116
      Height = 13
      Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072' '#1085#1072#1079#1085#1072#1095#1077#1085#1080#1103
    end
    object FullPathLabel: TLabel
      Left = 10
      Top = 237
      Width = 70
      Height = 13
      Caption = #1055#1086#1083#1085#1099#1081' '#1087#1091#1090#1100':'
    end
    object Label4: TLabel
      Left = 10
      Top = 12
      Width = 95
      Height = 13
      Caption = #1048#1089#1093#1086#1076#1085#1099#1081' '#1082#1072#1090#1072#1083#1086#1075
    end
    object Button1: TButton
      Left = 589
      Top = 36
      Width = 75
      Height = 41
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      TabOrder = 0
      OnClick = Button1Click
    end
    object SrcFileEdit: TEdit
      Left = 10
      Top = 83
      Width = 489
      Height = 21
      TabOrder = 1
    end
    object DstFolderEdit: TEdit
      Left = 10
      Top = 136
      Width = 489
      Height = 21
      TabOrder = 2
    end
    object DstFileEdit: TEdit
      Left = 10
      Top = 192
      Width = 489
      Height = 21
      TabOrder = 3
    end
    object SrcFolderEdit: TEdit
      Left = 10
      Top = 30
      Width = 489
      Height = 21
      TabOrder = 4
    end
    object ExecBtn: TButton
      Left = 590
      Top = 188
      Width = 75
      Height = 41
      Anchors = [akTop, akRight]
      Caption = #1042#1099#1087#1086#1083#1085#1080#1090#1100
      TabOrder = 5
      OnClick = ExecBtnClick
    end
  end
end
