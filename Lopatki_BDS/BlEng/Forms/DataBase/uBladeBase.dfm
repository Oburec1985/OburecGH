object BladeFrm: TBladeFrm
  Left = 0
  Top = 0
  Caption = 'BladeFrm'
  ClientHeight = 564
  ClientWidth = 812
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 161
    Top = 75
    Height = 489
    ExplicitLeft = 32
    ExplicitTop = 240
    ExplicitHeight = 100
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 75
    Width = 161
    Height = 489
    Align = alLeft
    Caption = #1057#1087#1080#1089#1086#1082' '#1086#1073#1098#1077#1082#1090#1086#1074
    TabOrder = 0
    object DBGrid1: TDBGrid
      Left = 2
      Top = 15
      Width = 157
      Height = 472
      Align = alClient
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 0
    Width = 812
    Height = 75
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 724
    DesignSize = (
      812
      75)
    object PathLabel: TLabel
      Left = 6
      Top = 9
      Width = 60
      Height = 13
      Caption = #1055#1091#1090#1100' '#1082' '#1073#1072#1079#1077
    end
    object PathE: TEdit
      Left = 6
      Top = 28
      Width = 699
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      ExplicitWidth = 611
    end
    object Button1: TButton
      Left = 726
      Top = 26
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1042#1099#1073#1088#1072#1090#1100
      TabOrder = 1
      ExplicitLeft = 638
    end
  end
  object GroupBox3: TGroupBox
    Left = 164
    Top = 75
    Width = 193
    Height = 489
    Align = alLeft
    Caption = #1057#1087#1080#1089#1086#1082' '#1048#1089#1087#1099#1090#1072#1085#1080#1081
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitHeight = 281
    object DBGrid2: TDBGrid
      Left = 2
      Top = 15
      Width = 189
      Height = 472
      Align = alClient
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
  object GroupBox4: TGroupBox
    Left = 357
    Top = 75
    Width = 455
    Height = 489
    Align = alClient
    Caption = #1057#1087#1080#1089#1086#1082' '#1048#1089#1087#1099#1090#1072#1085#1080#1081
    TabOrder = 3
    ExplicitLeft = 204
    ExplicitWidth = 193
    object DBGrid3: TDBGrid
      Left = 2
      Top = 15
      Width = 451
      Height = 472
      Align = alClient
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
end
