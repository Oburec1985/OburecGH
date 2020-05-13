object EditProjForm: TEditProjForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
  ClientHeight = 721
  ClientWidth = 557
  Color = clBtnFace
  Constraints.MinHeight = 464
  Constraints.MinWidth = 568
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object ProgramEditTabList: TPageControl
    Left = 0
    Top = 0
    Width = 557
    Height = 721
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1053#1072#1090#1089#1088#1086#1081#1082#1072' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object EngGB: TGroupBox
        Left = 0
        Top = 452
        Width = 549
        Height = 95
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alTop
        Caption = #1057#1080#1089#1090#1077#1084#1072' '#1089#1086#1086#1073#1097#1077#1085#1080#1081
        TabOrder = 0
        ExplicitWidth = 547
        object WriteJournalCb: TCheckBox
          Left = 8
          Top = 25
          Width = 297
          Height = 22
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1047#1072#1087#1080#1089#1099#1074#1072#1090#1100' '#1089#1086#1073#1099#1090#1080#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1099' '#1074' '#1092#1072#1081#1083
          TabOrder = 0
        end
        object ShowMessagesCB: TCheckBox
          Left = 8
          Top = 55
          Width = 234
          Height = 22
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1074#1089#1087#1083#1099#1074#1072#1102#1097#1080#1077' '#1089#1086#1086#1073#1097#1077#1085#1080#1103
          TabOrder = 1
        end
      end
      object MainFormGB: TGroupBox
        Left = 0
        Top = 357
        Width = 549
        Height = 95
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alTop
        Caption = #1054#1090#1083#1072#1076#1082#1072
        TabOrder = 1
        ExplicitWidth = 547
        object ShowMouseInputCB: TCheckBox
          Left = 8
          Top = 25
          Width = 388
          Height = 22
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' '#1087#1072#1085#1077#1083#1100' '#1089' '#1082#1086#1086#1088#1076#1080#1085#1072#1090#1072#1084#1080' '#1084#1099#1096#1080' '#1074' '#1075#1088#1072#1092#1080#1082#1077
          TabOrder = 0
        end
        object ShowChartEventsCB: TCheckBox
          Left = 8
          Top = 55
          Width = 234
          Height = 22
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' '#1089#1086#1073#1099#1090#1080#1103' '#1075#1088#1072#1092#1080#1082#1072
          TabOrder = 1
        end
      end
      object SelectActionGB: TGroupBox
        Left = 0
        Top = 625
        Width = 549
        Height = 64
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alBottom
        Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
        TabOrder = 2
        ExplicitTop = 615
        ExplicitWidth = 547
        DesignSize = (
          549
          64)
        object CancelBtn: TButton
          Left = 10
          Top = 25
          Width = 99
          Height = 33
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1054#1090#1084#1077#1085#1072
          ModalResult = 2
          TabOrder = 0
        end
        object ApplyBtn: TButton
          Left = 445
          Top = 25
          Width = 98
          Height = 33
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Anchors = [akTop, akRight]
          Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
          ModalResult = 1
          TabOrder = 1
        end
      end
      object MainGB: TGroupBox
        Left = 0
        Top = 0
        Width = 549
        Height = 357
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alTop
        Caption = #1057#1080#1089#1090#1077#1084#1072' '#1089#1086#1086#1073#1097#1077#1085#1080#1081
        TabOrder = 3
        ExplicitWidth = 547
        DesignSize = (
          549
          357)
        object SaveFolderLabel: TLabel
          Left = 7
          Top = 280
          Width = 236
          Height = 17
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1050#1072#1090#1072#1083#1086#1075' '#1089#1086#1093#1088#1072#1085#1077#1085#1080#1103' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102':'
        end
        object DefaultCfgLabel: TLabel
          Left = 7
          Top = 78
          Width = 173
          Height = 17
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1087#1086' '#1091#1084#1086#1083#1095#1072#1085#1080#1102':'
        end
        object Label1: TLabel
          Left = 7
          Top = 22
          Width = 95
          Height = 17
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1056#1077#1078#1080#1084' '#1088#1072#1073#1086#1090#1099
        end
        object DefaultCfgBtn: TButton
          Left = 479
          Top = 103
          Width = 48
          Height = 28
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Anchors = [akTop, akRight]
          Caption = '...'
          TabOrder = 0
          OnClick = DefaultCfgBtnClick
        end
        object DefaultCfgEdit: TEdit
          Left = 7
          Top = 103
          Width = 464
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
        end
        object ReplayDataGroupBox: TGroupBox
          Left = 4
          Top = 135
          Width = 527
          Height = 127
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = #1042#1086#1089#1087#1088#1086#1080#1079#1074#1077#1076#1077#1085#1080#1077
          TabOrder = 2
          DesignSize = (
            527
            127)
          object ReplayFolderLabel: TLabel
            Left = 4
            Top = 18
            Width = 168
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Caption = #1050#1072#1090#1072#1083#1086#1075' '#1074#1086#1089#1087#1088#1086#1080#1079#1074#1077#1076#1077#1085#1080#1103
          end
          object ReplayFNameLabel: TLabel
            Left = 4
            Top = 71
            Width = 69
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Caption = #1048#1084#1103' '#1092#1072#1081#1083#1072
          end
          object ReplayFolderEdit: TEdit
            Left = 4
            Top = 39
            Width = 463
            Height = 21
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
            Text = 'ReplayFolderEdit'
          end
          object ReplayFNameEdit: TEdit
            Left = 4
            Top = 92
            Width = 463
            Height = 21
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 1
            Text = 'Edit1'
          end
          object ReplayFolderSelect: TButton
            Left = 475
            Top = 39
            Width = 48
            Height = 28
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Anchors = [akTop, akRight]
            Caption = '...'
            TabOrder = 2
            OnClick = ReplayFolderSelectClick
          end
          object ReplayFNameSelect: TButton
            Left = 475
            Top = 92
            Width = 48
            Height = 27
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Anchors = [akTop, akRight]
            Caption = '...'
            TabOrder = 3
            OnClick = ReplayFNameSelectClick
          end
        end
        object SaveFolderEdit: TEdit
          Left = 7
          Top = 301
          Width = 464
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 3
        end
        object SaveFolderBtn: TButton
          Left = 479
          Top = 301
          Width = 48
          Height = 27
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Anchors = [akTop, akRight]
          Caption = '...'
          TabOrder = 4
          OnClick = SaveFolderBtnClick
        end
        object ModeCB: TComboBox
          Left = 7
          Top = 47
          Width = 464
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 5
          Items.Strings = (
            #1044#1077#1084#1086' '#1088#1077#1078#1080#1084' ('#1074#1086#1089#1087#1088#1086#1080#1079#1074#1086#1076#1080#1090#1100' 1 '#1092#1072#1081#1083')'
            #1054#1073#1088#1072#1073#1086#1090#1082#1072' '#1085#1086#1074#1099#1093' '#1092#1072#1081#1083#1086#1074
            #1055#1086#1083#1091#1095#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093' '#1086#1090' '#1087#1083#1072#1090#1099)
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Xml '#1092#1072#1081#1083'|*.xml|bld '#1092#1072#1081#1083'|*.bld|lfm '#1092#1072#1081#1083'|*.lfm|All files|*'
    Left = 264
    Top = 372
  end
  object ReplayFolderDlg: TOpenDialog
    Left = 264
    Top = 420
  end
  object ReplayFNameDlg: TOpenDialog
    Left = 344
    Top = 372
  end
  object SaveFolderDlg: TOpenDialog
    Left = 344
    Top = 421
  end
end
