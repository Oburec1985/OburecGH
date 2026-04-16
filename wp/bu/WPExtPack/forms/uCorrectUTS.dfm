object CorrectUTSFrm: TCorrectUTSFrm
  Left = 0
  Top = 0
  Caption = #1050#1086#1088#1088#1077#1082#1094#1080#1103' '#1074#1088#1077#1084#1077#1085#1080
  ClientHeight = 604
  ClientWidth = 1033
  Color = clBtnFace
  Constraints.MinWidth = 756
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
    Width = 1033
    Height = 604
    Align = alClient
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      1033
      604)
    object Label1: TLabel
      Left = 11
      Top = 169
      Width = 228
      Height = 23
      Caption = #1057#1080#1075#1085#1072#1083' "'#1053#1072#1095#1072#1083#1086' '#1086#1090#1089#1095#1077#1090#1072'":'
    end
    object ThresheldLabel: TLabel
      Left = 11
      Top = 233
      Width = 180
      Height = 23
      Caption = #1055#1086#1088#1086#1075#1086#1074#1086#1077' '#1079#1085#1072#1095#1077#1085#1080#1077
    end
    object Label3: TLabel
      Left = 11
      Top = 441
      Width = 186
      Height = 23
      Anchors = [akLeft, akBottom]
      Caption = #1055#1086#1087#1088#1072#1074#1082#1072' '#1074#1088#1077#1084#1077#1085#1080', '#1089
      ExplicitTop = 431
    end
    object NumFrontLabel: TLabel
      Left = 243
      Top = 441
      Width = 186
      Height = 23
      Anchors = [akLeft, akBottom]
      Caption = #1053#1086#1084#1077#1088' '#1089#1088#1072#1073#1072#1090#1099#1074#1072#1085#1080#1103
      ExplicitTop = 431
    end
    object TestTimeLabel: TLabel
      Left = 324
      Top = 236
      Width = 155
      Height = 23
      Caption = #1042#1088#1077#1084#1103' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
    end
    object AddBtn: TButton
      Left = 640
      Top = 15
      Width = 103
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 0
    end
    object DelBtn: TButton
      Left = 640
      Top = 46
      Width = 103
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 1
      OnClick = DelBtnClick
    end
    object StartSignalCB: TComboBox
      Left = 11
      Top = 195
      Width = 275
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object Memo1: TMemo
      Left = 11
      Top = 15
      Width = 623
      Height = 106
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        
          ' '#1052#1086#1076#1091#1083#1100' '#1074#1099#1087#1086#1083#1085#1103#1077#1090' '#1082#1086#1088#1088#1077#1082#1094#1080#1102' '#1074#1088#1077#1084#1077#1085#1080' UTS '#1089#1080#1075#1085#1072#1083#1086#1074' '#1085#1072' '#1074#1088#1077#1084#1103' '#1089#1090#1072#1088#1090#1072 +
          ' '#1085#1091#1083#1103'. '#1050#1086#1088#1088#1077#1082#1090#1080#1088#1091#1102#1097#1077#1077' '
        #1079#1085#1072#1095#1077#1085#1080#1077' '#1087#1080#1096#1077#1090#1089#1103' '#1074' '#1080#1085#1076#1080#1082#1072#1090#1086#1088' "'#1055#1086#1087#1088#1072#1074#1082#1072' '#1074#1088#1077#1084#1077#1085#1080'".'
        
          ' '#1045#1089#1083#1080' '#1089#1080#1075#1085#1072#1083' UTS '#1086#1090#1089#1091#1090#1089#1090#1074#1091#1077#1090' '#1076#1083#1103' '#1079#1072#1084#1077#1088#1072', '#1090#1086' '#1076#1083#1103' '#1085#1077#1075#1086' '#1073#1091#1076#1077#1090' '#1085#1072#1081#1076#1077 +
          #1085' '#1082#1072#1085#1072#1083' '#1089' '#1072#1085#1072#1083#1086#1075#1080#1095#1085#1099#1084' '#1080#1084#1077#1085#1077#1084' '#1082#1072#1082' '
        
          #1091' '#1082#1072#1085#1072#1083#1072' '#1085#1072#1095#1072#1083#1086' '#1086#1090#1089#1095#1077#1090#1072', '#1080' '#1073#1091#1076#1091#1090' '#1089#1082#1086#1088#1088#1077#1082#1090#1080#1088#1086#1074#1072#1085#1099' '#1089#1090#1072#1088#1090#1099' '#1087#1086' '#1074#1089#1077#1084' ' +
          #1082#1072#1085#1072#1083#1072#1084' ('#1073#1077#1079' '#1091#1095#1077#1090#1072' UTS)')
      ParentFont = False
      TabOrder = 3
    end
    object RadioGroup1: TRadioGroup
      Left = 11
      Top = 293
      Width = 185
      Height = 76
      ItemIndex = 0
      Items.Strings = (
        #1060#1088#1086#1085#1090
        #1057#1087#1072#1076)
      TabOrder = 4
    end
    object GroupBox2: TGroupBox
      Left = 750
      Top = 25
      Width = 281
      Height = 577
      Align = alRight
      Caption = #1055#1077#1088#1077#1095#1077#1085#1100' '#1079#1072#1084#1077#1088#1086#1074
      TabOrder = 5
      object Splitter1: TSplitter
        Left = 2
        Top = 183
        Width = 277
        Height = 3
        Cursor = crVSplit
        Align = alTop
        ExplicitTop = 173
        ExplicitWidth = 122
      end
      object Label2: TLabel
        Left = 6
        Top = 187
        Width = 273
        Height = 23
        Caption = #1050#1086#1088#1088#1077#1082#1090#1080#1088#1091#1077#1084#1099#1077' UTS '#1089#1080#1075#1085#1072#1083#1099':'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object SignalsLB: TListBox
        Left = 2
        Top = 25
        Width = 277
        Height = 158
        Hint = #1053#1077' '#1085#1072#1081#1076#1077#1085' '#1082#1072#1085#1072#1083' UTS'
        Style = lbOwnerDrawFixed
        Align = alTop
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MultiSelect = True
        ParentFont = False
        TabOrder = 0
        OnClick = SignalsLBClick
        OnDrawItem = SignalsLBDrawItem
        OnMouseMove = SignalsLBMouseMove
        ExplicitLeft = 3
        ExplicitTop = 23
      end
      object UTSLV: TBtnListView
        Left = 2
        Top = 232
        Width = 277
        Height = 343
        Align = alBottom
        Anchors = [akLeft, akTop, akRight, akBottom]
        Checkboxes = True
        Columns = <
          item
            Caption = #8470
          end
          item
            Caption = #1048#1084#1103
          end>
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        RowSelect = True
        ParentFont = False
        TabOrder = 1
        ViewStyle = vsReport
        BtnCol = 0
        QuoteColumnBtnClick = False
        QuoteColumnDblClick = False
        DrawColorBox = False
        ChangeTextColor = False
        Editable = False
      end
    end
    object ThresheldSE: TFloatSpinEdit
      Left = 11
      Top = 265
      Width = 185
      Height = 33
      Increment = 0.100000000000000000
      TabOrder = 6
      Value = 0.500000000000000000
    end
    object CancelBtn: TButton
      Left = 11
      Top = 564
      Width = 75
      Height = 29
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 7
    end
    object ApplyBtn: TButton
      Left = 644
      Top = 572
      Width = 102
      Height = 29
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 8
      OnClick = ApplyBtnClick
    end
    object ResSE: TFloatSpinEdit
      Left = 11
      Top = 463
      Width = 185
      Height = 33
      Hint = #1048#1089#1087#1086#1083#1100#1079#1091#1077#1090#1089#1103' '#1077#1089#1083#1080' '#1075#1072#1083#1086#1095#1082#1072' '#1054#1087#1088#1077#1076#1077#1083#1080#1090#1100' '#1089#1076#1074#1080#1075' '#1074' '#1082#1072#1078#1076#1086#1084' '#1079#1072#1084#1077#1088#1077' '#1089#1085#1103#1090#1072
      Anchors = [akLeft, akBottom]
      Increment = 0.100000000000000000
      TabOrder = 9
      Value = 0.500000000000000000
    end
    object EvalBtn: TButton
      Left = 642
      Top = 439
      Width = 102
      Height = 29
      Anchors = [akRight, akBottom]
      Caption = #1042#1099#1095#1080#1089#1083#1080#1090#1100
      TabOrder = 10
      OnClick = EvalBtnClick
    end
    object NotUTSShiftCB: TCheckBox
      Left = 11
      Top = 392
      Width = 283
      Height = 17
      Caption = #1057#1076#1074#1080#1075#1072#1090#1100' '#1089#1080#1075#1085#1072#1083#1099' '#1073#1077#1079' UTS'
      TabOrder = 11
    end
    object NamedShiftCB: TCheckBox
      Left = 11
      Top = 127
      Width = 502
      Height = 17
      Hint = 
        #1053#1091#1078#1085#1086' '#1074#1082#1083#1102#1095#1080#1090#1100' '#1077#1089#1083#1080' '#1079#1072#1084#1077#1088#1099' '#1085#1077' '#1089#1086#1076#1077#1088#1078#1072#1090' UTS '#1085#1086' '#1080#1084#1077#1102#1090' '#1086#1076#1085#1086#1080#1084#1077#1085#1085#1099#1081' ' +
        #1089#1080#1075#1085#1072#1083' '#1089' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1077#1081' '#1086' '#1085#1072#1095#1072#1083#1077' '#1080#1089#1087#1099#1090#1072#1085#1080#1103'. '#1045#1089#1083#1080' '#1082#1086#1088#1088#1077#1082#1090#1080#1088#1091#1077#1090#1089#1103' '#1086#1076#1080 +
        #1085' '#1079#1072#1084#1077#1088' '#1084#1086#1078#1085#1086' '#1085#1077' '#1074#1082#1083#1102#1095#1072#1090#1100'.'
      Caption = #1054#1087#1088#1077#1076#1077#1083#1080#1090#1100' '#1089#1076#1074#1080#1075' '#1074' '#1082#1072#1078#1076#1086#1084' '#1079#1072#1084#1077#1088#1077' '#1087#1086' '#1080#1084#1077#1085#1080' '#1082#1072#1085#1072#1083#1072
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
    end
    object SICONCB: TCheckBox
      Left = 327
      Top = 196
      Width = 186
      Height = 17
      Hint = 
        #1053#1091#1078#1085#1086' '#1074#1082#1083#1102#1095#1080#1090#1100' '#1077#1089#1083#1080' '#1079#1072#1084#1077#1088#1099' '#1085#1077' '#1089#1086#1076#1077#1088#1078#1072#1090' UTS '#1085#1086' '#1080#1084#1077#1102#1090' '#1086#1076#1085#1086#1080#1084#1077#1085#1085#1099#1081' ' +
        #1089#1080#1075#1085#1072#1083' '#1089' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1077#1081' '#1086' '#1085#1072#1095#1072#1083#1077' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
      Caption = #1056#1072#1089#1087#1072#1082#1086#1074#1082#1072' '#1057#1048#1050#1054#1053
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
      Visible = False
    end
    object NumFrontIE: TIntEdit
      Left = 243
      Top = 463
      Width = 121
      Height = 31
      Anchors = [akLeft, akBottom]
      TabOrder = 14
      Text = '000'
    end
    object UseDateTimeCB: TCheckBox
      Left = 11
      Top = 523
      Width = 353
      Height = 25
      Hint = #1042#1088#1077#1084#1103' '#1089#1090#1072#1088#1090#1072' '#1080#1089#1087#1099#1090#1072#1085#1080#1103' '#1087#1088#1086#1087#1080#1089#1072#1085#1086' '#1074' Mera '#1092#1072#1081#1083#1077' '#1082#1083#1102#1095' DateTime'
      Anchors = [akLeft, akBottom]
      Caption = #1059#1095#1080#1090#1099#1074#1072#1090#1100' '#1074#1088#1077#1084#1103' '#1089#1090#1072#1088#1090#1072' '#1080#1089#1087#1099#1090#1072#1085#1080#1103
      Checked = True
      State = cbChecked
      TabOrder = 15
    end
    object TestTimeEdit: TEdit
      Left = 324
      Top = 265
      Width = 158
      Height = 31
      TabOrder = 16
    end
    object TestTimeBtn: TButton
      Left = 488
      Top = 266
      Width = 102
      Height = 29
      Caption = #1054#1073#1085#1091#1083#1080#1090#1100
      TabOrder = 17
      OnClick = TestTimeBtnClick
    end
  end
end
