object ConstForm: TConstForm
  Left = 205
  Top = 111
  Caption = 'ConstForm'
  ClientHeight = 628
  ClientWidth = 523
  Color = clBtnFace
  Constraints.MinHeight = 549
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    523
    628)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 12
    Top = 45
    Width = 509
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    ExplicitWidth = 533
  end
  object FreqLabel: TLabel
    Left = 26
    Top = 46
    Width = 96
    Height = 13
    AutoSize = False
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1074#1088#1072#1097#1077#1085#1080#1103
  end
  object LengthLabel: TLabel
    Left = 172
    Top = 46
    Width = 73
    Height = 13
    Caption = #1044#1083#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100
  end
  object ValueLabel: TLabel
    Left = 434
    Top = 46
    Width = 75
    Height = 13
    Anchors = [akTop, akRight]
    Caption = #1056#1072#1079#1073#1088#1086#1089', '#1075#1088#1072#1076':'
  end
  object Label1: TLabel
    Left = 12
    Top = 7
    Width = 106
    Height = 13
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1089#1080#1075#1085#1072#1083#1072':'
  end
  object Label2: TLabel
    Left = 26
    Top = 61
    Width = 24
    Height = 13
    Caption = #1074#1072#1083#1072
  end
  object Label3: TLabel
    Left = 172
    Top = 62
    Width = 36
    Height = 13
    Caption = #1079#1072#1087#1080#1089#1080
  end
  object Label8: TLabel
    Left = 12
    Top = 108
    Width = 419
    Height = 13
    Caption = 
      #1042' '#1090#1072#1073#1083#1080#1094#1077' '#1086#1090#1086#1073#1088#1072#1078#1077#1085#1099' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1072#1090#1095#1080#1082#1086#1074'. '#1057#1084#1077#1097#1077#1085#1080#1077'  '#1076#1072#1090#1095#1080#1082#1072' '#1086#1087#1088#1077#1076 +
      #1077#1083#1103#1077#1090' '#1091#1075#1086#1083
  end
  object Label9: TLabel
    Left = 12
    Top = 122
    Width = 477
    Height = 13
    Caption = 
      #1089#1084#1077#1097#1077#1085#1080#1103' '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072'. '#1048#1084#1103' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072' "D0", '#1085#1086#1084#1077#1088 +
      ' '#1082#1072#1085#1072#1083#1072' 1, '#1091#1089#1080#1083#1077#1085#1080#1077' 255'
  end
  object Label4: TLabel
    Left = 279
    Top = 46
    Width = 93
    Height = 13
    Anchors = [akTop, akRight]
    Caption = #1063#1072#1089#1090#1086#1090#1072' '#1074#1080#1073#1088#1072#1094#1080#1080
  end
  object Label5: TLabel
    Left = 303
    Top = 61
    Width = 41
    Height = 13
    Anchors = [akTop, akRight]
    Caption = #1083#1086#1087#1072#1090#1086#1082
  end
  object Label12: TLabel
    Left = 15
    Top = 551
    Width = 106
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1088#1086#1090#1086#1088#1086#1074':'
    ExplicitTop = 501
  end
  object PageControl: TPageControl
    Left = 15
    Top = 141
    Width = 500
    Height = 403
    ActivePage = Rotor2
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 0
    TabStop = False
    object Rotor1: TTabSheet
      Caption = #1057#1090#1091#1087#1077#1085#1100' 1'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        492
        375)
      object Bevel2: TBevel
        Left = 3
        Top = 2
        Width = 488
        Height = 370
        Anchors = [akLeft, akTop, akRight, akBottom]
        ExplicitWidth = 517
        ExplicitHeight = 233
      end
      object Label6: TLabel
        Left = 300
        Top = 4
        Width = 76
        Height = 13
        Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082
      end
      object Label13: TLabel
        Left = 3
        Top = 4
        Width = 81
        Height = 13
        Caption = #1063#1080#1089#1083#1086' '#1076#1072#1090#1095#1080#1082#1086#1074
      end
      object SensorsListView: TBtnListView
        Left = 8
        Top = 46
        Width = 279
        Height = 321
        Hint = 
          #1042' '#1090#1072#1073#1083#1080#1094#1077' '#1086#1087#1088#1077#1076#1077#1083#1077#1085#1099' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1072#1090#1095#1080#1082#1086#1074':'#13#10'1) N0 '#1050#1072#1085#1072#1083#1072#13#10'2) '#1048#1084#1103' '#1076 +
          #1072#1090#1095#1080#1082#1072#13#10'3) '#1057#1084#1077#1097#1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1086#1087#1088#1077#1076#1077#1083#1103#1077#1090' '#1089#1084#1077#1097#1077#1085#1080#1077' '#1074' '#1075#1088#1072#1076#1091#1089#1072#1093' '#1076#1072#1090#1095#1080 +
          #1082#1072#13#10'    '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10'4) '#1053#1072' '#1082#1085#1086#1087#1082#1091' +/- '#1085#1072#1079#1085#1072#1095#1077#1085#1086' '#1091#1076 +
          #1072#1083#1077#1085#1080#1077' '#1076#1072#1090#1095#1080#1082#1072' '#1080#1079' '#1090#1072#1073#1083#1080#1094#1099
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #8470
            Width = 70
          end
          item
            Caption = #1048#1084#1103
            Width = 40
          end
          item
            Caption = #1058#1080#1087
            Width = 40
          end
          item
            Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
            Width = 100
          end
          item
            Caption = '+/-'
            Width = 35
          end>
        GridLines = True
        TabOrder = 0
        ViewStyle = vsReport
        OnAdvancedCustomDrawSubItem = SensorsListViewAdvancedCustomDrawSubItem
        OnDblClickProcess = SensorsListViewDblClickProcess
        OnColumnBtnClick = BladesListViewColumnBtnClick
        BtnCol = 4
        QuoteColumnBtnClick = True
        QuoteColumnDblClick = False
      end
      object BladesListView: TBtnListView
        Left = 290
        Top = 46
        Width = 213
        Height = 321
        Hint = 
          #1058#1072#1073#1083#1080#1094#1072' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1103' '#1083#1086#1087#1072#1090#1086#1082' '#1085#1072' '#1074#1072#1083#1091':'#13#10'1) '#1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080#13#10'2) '#1057#1084#1077#1097 +
          #1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1089#1084#1077#1097#1077#1085#1080#1077' '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10' '#1057#1085#1103#1090#1080#1077' '#1075#1072#1083#1086#1095#1082#1080 +
          ' '#1074#1085#1091#1090#1088#1080' '#1089#1090#1088#1086#1082#1080' '#1086#1079#1085#1072#1095#1072#1077#1090' '#1086#1090#1084#1077#1085#1091' '#1075#1077#1085#1077#1072#1088#1094#1080#1080' '#1074#1080#1073#1088#1072#1094#1080#1080#13#10' '#1087#1086' '#1076#1072#1085#1085#1086#1081' '#1083#1086 +
          #1087#1072#1090#1082#1080' ('#1083#1086#1087#1072#1090#1082#1072' '#1073#1091#1076#1077#1090' '#1085#1077#1087#1086#1076#1074#1080#1078#1085#1072').'
        Anchors = [akTop, akRight, akBottom]
        Checkboxes = True
        Columns = <
          item
            Caption = #8470' '#1083#1086#1087#1072#1090#1082#1080
            Width = 90
          end
          item
            Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
            Width = 98
          end>
        GridLines = True
        TabOrder = 1
        ViewStyle = vsReport
        BtnCol = -1
        QuoteColumnBtnClick = True
        QuoteColumnDblClick = False
      end
      object BladeCountIntEdit: TIntEdit
        Left = 300
        Top = 19
        Width = 75
        Height = 21
        TabOrder = 2
        Text = '10'
      end
      object ChanCountIntEdit: TIntEdit
        Left = 9
        Top = 23
        Width = 75
        Height = 21
        TabOrder = 3
        Text = '4'
      end
      object SwitchAllCheckBox1: TCheckBox
        Left = 381
        Top = 23
        Width = 209
        Height = 17
        Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1077
        TabOrder = 4
        OnClick = SwitchAllCheckBox1Click
      end
    end
    object Rotor2: TTabSheet
      Caption = #1057#1090#1091#1087#1077#1085#1100' 2'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        492
        375)
      object Label7: TLabel
        Left = 3
        Top = 4
        Width = 81
        Height = 13
        Caption = #1063#1080#1089#1083#1086' '#1076#1072#1090#1095#1080#1082#1086#1074
      end
      object Bevel3: TBevel
        Left = 3
        Top = 2
        Width = 488
        Height = 370
        Anchors = [akLeft, akTop, akRight, akBottom]
        ExplicitWidth = 517
        ExplicitHeight = 233
      end
      object Label10: TLabel
        Left = 300
        Top = 4
        Width = 76
        Height = 13
        Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082
      end
      object BladeCountIntEdit2: TIntEdit
        Left = 300
        Top = 19
        Width = 75
        Height = 21
        TabOrder = 0
        Text = '10'
      end
      object ChanCountIntEdit2: TIntEdit
        Left = 9
        Top = 23
        Width = 75
        Height = 21
        TabOrder = 1
        Text = '4'
      end
      object SensorsListView2: TBtnListView
        Left = 5
        Top = 50
        Width = 279
        Height = 321
        Hint = 
          #1042' '#1090#1072#1073#1083#1080#1094#1077' '#1086#1087#1088#1077#1076#1077#1083#1077#1085#1099' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1072#1090#1095#1080#1082#1086#1074':'#13#10'1) N0 '#1050#1072#1085#1072#1083#1072#13#10'2) '#1048#1084#1103' '#1076 +
          #1072#1090#1095#1080#1082#1072#13#10'3) '#1057#1084#1077#1097#1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1086#1087#1088#1077#1076#1077#1083#1103#1077#1090' '#1089#1084#1077#1097#1077#1085#1080#1077' '#1074' '#1075#1088#1072#1076#1091#1089#1072#1093' '#1076#1072#1090#1095#1080 +
          #1082#1072#13#10'    '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10'4) '#1053#1072' '#1082#1085#1086#1087#1082#1091' +/- '#1085#1072#1079#1085#1072#1095#1077#1085#1086' '#1091#1076 +
          #1072#1083#1077#1085#1080#1077' '#1076#1072#1090#1095#1080#1082#1072' '#1080#1079' '#1090#1072#1073#1083#1080#1094#1099
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #8470
            Width = 70
          end
          item
            Caption = #1048#1084#1103
            Width = 40
          end
          item
            Caption = #1058#1080#1087
            Width = 40
          end
          item
            Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
            Width = 100
          end
          item
            Caption = '+/-'
            Width = 35
          end>
        GridLines = True
        TabOrder = 2
        ViewStyle = vsReport
        OnAdvancedCustomDrawSubItem = SensorsListViewAdvancedCustomDrawSubItem
        OnDblClickProcess = SensorsListViewDblClickProcess
        OnColumnBtnClick = BladesListViewColumnBtnClick
        BtnCol = 4
        QuoteColumnBtnClick = True
        QuoteColumnDblClick = False
      end
      object BladesListView2: TBtnListView
        Left = 290
        Top = 46
        Width = 213
        Height = 321
        Hint = 
          #1058#1072#1073#1083#1080#1094#1072' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1103' '#1083#1086#1087#1072#1090#1086#1082' '#1085#1072' '#1074#1072#1083#1091':'#13#10'1) '#1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080#13#10'2) '#1057#1084#1077#1097 +
          #1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1089#1084#1077#1097#1077#1085#1080#1077' '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10' '#1057#1085#1103#1090#1080#1077' '#1075#1072#1083#1086#1095#1082#1080 +
          ' '#1074#1085#1091#1090#1088#1080' '#1089#1090#1088#1086#1082#1080' '#1086#1079#1085#1072#1095#1072#1077#1090' '#1086#1090#1084#1077#1085#1091' '#1075#1077#1085#1077#1072#1088#1094#1080#1080' '#1074#1080#1073#1088#1072#1094#1080#1080#13#10' '#1087#1086' '#1076#1072#1085#1085#1086#1081' '#1083#1086 +
          #1087#1072#1090#1082#1080' ('#1083#1086#1087#1072#1090#1082#1072' '#1073#1091#1076#1077#1090' '#1085#1077#1087#1086#1076#1074#1080#1078#1085#1072').'
        Anchors = [akTop, akRight, akBottom]
        Checkboxes = True
        Columns = <
          item
            Caption = #8470' '#1083#1086#1087#1072#1090#1082#1080
            Width = 90
          end
          item
            Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
            Width = 98
          end>
        GridLines = True
        TabOrder = 3
        ViewStyle = vsReport
        BtnCol = -1
        QuoteColumnBtnClick = True
        QuoteColumnDblClick = False
      end
      object SwitchAllCheckBox2: TCheckBox
        Left = 381
        Top = 23
        Width = 209
        Height = 17
        Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1077
        TabOrder = 4
        OnClick = SwitchAllCheckBox1Click
      end
    end
    object Rotor3: TTabSheet
      Caption = #1057#1090#1091#1087#1077#1085#1100' 3'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        492
        375)
      object Label11: TLabel
        Left = 3
        Top = 4
        Width = 81
        Height = 13
        Caption = #1063#1080#1089#1083#1086' '#1076#1072#1090#1095#1080#1082#1086#1074
      end
      object Label14: TLabel
        Left = 300
        Top = 4
        Width = 76
        Height = 13
        Caption = #1063#1080#1089#1083#1086' '#1083#1086#1087#1072#1090#1086#1082
      end
      object Bevel4: TBevel
        Left = 3
        Top = 2
        Width = 487
        Height = 370
        Anchors = [akLeft, akTop, akRight, akBottom]
        ExplicitWidth = 517
        ExplicitHeight = 233
      end
      object BladeCountIntEdit3: TIntEdit
        Left = 300
        Top = 19
        Width = 75
        Height = 21
        TabOrder = 0
        Text = '10'
      end
      object ChanCountIntEdit3: TIntEdit
        Left = 9
        Top = 23
        Width = 75
        Height = 21
        TabOrder = 1
        Text = '4'
      end
      object SensorsListView3: TBtnListView
        Left = 8
        Top = 46
        Width = 280
        Height = 321
        Hint = 
          #1042' '#1090#1072#1073#1083#1080#1094#1077' '#1086#1087#1088#1077#1076#1077#1083#1077#1085#1099' '#1087#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1072#1090#1095#1080#1082#1086#1074':'#13#10'1) N0 '#1050#1072#1085#1072#1083#1072#13#10'2) '#1048#1084#1103' '#1076 +
          #1072#1090#1095#1080#1082#1072#13#10'3) '#1057#1084#1077#1097#1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1086#1087#1088#1077#1076#1077#1083#1103#1077#1090' '#1089#1084#1077#1097#1077#1085#1080#1077' '#1074' '#1075#1088#1072#1076#1091#1089#1072#1093' '#1076#1072#1090#1095#1080 +
          #1082#1072#13#10'    '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10'4) '#1053#1072' '#1082#1085#1086#1087#1082#1091' +/- '#1085#1072#1079#1085#1072#1095#1077#1085#1086' '#1091#1076 +
          #1072#1083#1077#1085#1080#1077' '#1076#1072#1090#1095#1080#1082#1072' '#1080#1079' '#1090#1072#1073#1083#1080#1094#1099
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #8470
            Width = 70
          end
          item
            Caption = #1048#1084#1103
            Width = 40
          end
          item
            Caption = #1058#1080#1087
            Width = 40
          end
          item
            Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
            Width = 100
          end
          item
            Caption = '+/-'
            Width = 35
          end>
        GridLines = True
        TabOrder = 2
        ViewStyle = vsReport
        OnAdvancedCustomDrawSubItem = SensorsListViewAdvancedCustomDrawSubItem
        OnDblClickProcess = SensorsListViewDblClickProcess
        OnColumnBtnClick = BladesListViewColumnBtnClick
        BtnCol = 4
        QuoteColumnBtnClick = True
        QuoteColumnDblClick = False
      end
      object BladesListView3: TBtnListView
        Left = 292
        Top = 46
        Width = 194
        Height = 321
        Hint = 
          #1058#1072#1073#1083#1080#1094#1072' '#1088#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1103' '#1083#1086#1087#1072#1090#1086#1082' '#1085#1072' '#1074#1072#1083#1091':'#13#10'1) '#1053#1086#1084#1077#1088' '#1083#1086#1087#1072#1090#1082#1080#13#10'2) '#1057#1084#1077#1097 +
          #1077#1085#1080#1077', '#1075#1088#1072#1076' - '#1089#1084#1077#1097#1077#1085#1080#1077' '#1086#1090#1085#1086#1089#1080#1090#1077#1083#1100#1085#1086' '#1090#1072#1093#1086' '#1076#1072#1090#1095#1080#1082#1072#13#10' '#1057#1085#1103#1090#1080#1077' '#1075#1072#1083#1086#1095#1082#1080 +
          ' '#1074#1085#1091#1090#1088#1080' '#1089#1090#1088#1086#1082#1080' '#1086#1079#1085#1072#1095#1072#1077#1090' '#1086#1090#1084#1077#1085#1091' '#1075#1077#1085#1077#1072#1088#1094#1080#1080' '#1074#1080#1073#1088#1072#1094#1080#1080#13#10' '#1087#1086' '#1076#1072#1085#1085#1086#1081' '#1083#1086 +
          #1087#1072#1090#1082#1080' ('#1083#1086#1087#1072#1090#1082#1072' '#1073#1091#1076#1077#1090' '#1085#1077#1087#1086#1076#1074#1080#1078#1085#1072').'
        Anchors = [akTop, akRight, akBottom]
        Checkboxes = True
        Columns = <
          item
            Caption = #8470' '#1083#1086#1087#1072#1090#1082#1080
            Width = 90
          end
          item
            Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
            Width = 98
          end>
        GridLines = True
        TabOrder = 3
        ViewStyle = vsReport
        BtnCol = -1
        QuoteColumnBtnClick = True
        QuoteColumnDblClick = False
      end
      object SwitchAllCheckBox3: TCheckBox
        Left = 382
        Top = 23
        Width = 209
        Height = 17
        Caption = #1042#1099#1076#1077#1083#1080#1090#1100' '#1074#1089#1077
        TabOrder = 4
        OnClick = SwitchAllCheckBox1Click
      end
    end
  end
  object CancelBtn: TButton
    Left = 13
    Top = 598
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'CancelBtn'
    ModalResult = 2
    TabOrder = 1
    WordWrap = True
  end
  object FreqEdit: TFloatEdit
    Left = 26
    Top = 78
    Width = 75
    Height = 21
    TabOrder = 2
    Text = '1'
  end
  object AddBtn: TButton
    Left = 440
    Top = 595
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'AddBtn'
    TabOrder = 3
    WordWrap = True
    OnClick = AddBtnClick
  end
  object Button2: TButton
    Left = 240
    Top = 598
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'SaveConfBtn'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    WordWrap = True
  end
  object ValueEdit: TFloatEdit
    Left = 434
    Top = 78
    Width = 81
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 5
    Text = '1'
  end
  object LengthEdit: TFloatEdit
    Left = 172
    Top = 78
    Width = 75
    Height = 21
    TabOrder = 6
    Text = '4'
  end
  object GenBldDataBtn: TButton
    Left = 365
    Top = 547
    Width = 150
    Height = 28
    Anchors = [akRight, akBottom]
    Caption = #1057#1075#1077#1085#1077#1088#1080#1090#1100' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1102
    TabOrder = 7
    OnClick = GenBldDataBtnClick
  end
  object variatefreqCheckBox: TCheckBox
    Left = 137
    Top = 6
    Width = 209
    Height = 17
    Caption = #1052#1077#1085#1103#1090#1100' '#1095#1072#1089#1090#1086#1090#1091' '#1089#1086' '#1074#1088#1077#1084#1077#1085#1077#1084' (/1.01)'
    TabOrder = 8
  end
  object VibrationFloatEdit: TFloatEdit
    Left = 287
    Top = 78
    Width = 81
    Height = 21
    Anchors = [akTop, akRight]
    TabOrder = 9
    Text = '1'
  end
  object RotorCountComboBox: TComboBox
    Left = 120
    Top = 551
    Width = 38
    Height = 21
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    TabOrder = 10
    Text = '1'
    OnChange = RotorCountComboBoxChange
    Items.Strings = (
      '1'
      '2'
      '3')
  end
  object GenFreqBtn: TButton
    Left = 434
    Top = 6
    Width = 80
    Height = 33
    Anchors = [akTop, akRight]
    Caption = #1047#1072#1076#1072#1090#1100' '#1095#1072#1089#1090#1086#1090#1091
    TabOrder = 11
    WordWrap = True
    OnClick = GenFreqBtnClick
  end
  object ProgressBar1: TProgressBar
    Left = 19
    Top = 577
    Width = 486
    Height = 8
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 12
  end
end
