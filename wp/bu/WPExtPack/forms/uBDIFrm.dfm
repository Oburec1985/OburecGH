object BDIFrm: TBDIFrm
  Left = 0
  Top = 0
  Caption = #1041#1072#1079#1072' '#1087#1086' '#1080#1089#1087#1099#1090#1072#1085#1080#1103#1084
  ClientHeight = 658
  ClientWidth = 1094
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
    Top = 0
    Width = 336
    Height = 658
    Align = alLeft
    Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1072' '#1073#1072#1079#1099
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    ExplicitLeft = 257
    ExplicitHeight = 567
    object BaseTV: TVTree
      Left = 2
      Top = 25
      Width = 332
      Height = 527
      Align = alTop
      Alignment = taRightJustify
      DragMode = dmAutomatic
      DrawSelectionMode = smBlendedRectangle
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowImages, hoShowSortGlyphs, hoVisible]
      NodeDataSize = 28
      ParentFont = False
      TabOrder = 0
      TreeOptions.SelectionOptions = [toExtendedFocus, toMiddleClickSelect, toMultiSelect, toRightClickSelect]
      ExplicitTop = 34
      Columns = <
        item
          Position = 0
          Width = 328
          WideText = #1054#1073#1098#1077#1082#1090
        end>
    end
  end
  object SelObjLB: TListBox
    Left = 926
    Top = 0
    Width = 168
    Height = 658
    Hint = #1043#1088#1072#1092#1080#1095#1077#1089#1082#1080#1081' '#1086#1073#1098#1077#1082#1090' '#1085#1077' '#1089#1086#1079#1076#1072#1085
    Style = lbOwnerDrawFixed
    Align = alRight
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    ExplicitLeft = 847
    ExplicitHeight = 600
  end
  object TabControl: TPageControl
    Left = 336
    Top = 0
    Width = 590
    Height = 658
    ActivePage = ObjTab
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    ExplicitWidth = 609
    object ObjTab: TTabSheet
      Caption = #1054#1073#1098#1077#1082#1090' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
      ExplicitLeft = 2
      ExplicitTop = 28
      ExplicitWidth = 601
      ExplicitHeight = 630
      DesignSize = (
        582
        624)
      object UnitsXLabel: TLabel
        Left = 17
        Top = 14
        Width = 35
        Height = 23
        Caption = #1048#1084#1103
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object ObjNameEdit: TEdit
        Left = 17
        Top = 43
        Width = 533
        Height = 27
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        ExplicitWidth = 552
      end
    end
    object TestTab: TTabSheet
      Caption = #1048#1089#1087#1099#1090#1072#1085#1080#1077
      ImageIndex = 1
      ExplicitTop = 24
      ExplicitWidth = 601
      ExplicitHeight = 630
      DesignSize = (
        582
        624)
      object Label1: TLabel
        Left = 17
        Top = 14
        Width = 136
        Height = 23
        Caption = #1048#1084#1103' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object TestNameEdit: TEdit
        Left = 17
        Top = 43
        Width = 533
        Height = 27
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        ExplicitWidth = 552
      end
    end
  end
end
