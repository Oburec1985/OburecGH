object CfgForm: TCfgForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
  ClientHeight = 630
  ClientWidth = 922
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object MainSplitter: TSplitter
    Left = 271
    Top = 0
    Width = 6
    Height = 564
    Beveled = True
    Color = clGray
    ParentColor = False
    ExplicitHeight = 581
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 581
    Width = 922
    Height = 49
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    DesignSize = (
      922
      49)
    object CancelBtn: TButton
      Left = 8
      Top = 19
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object ApplyBtn: TButton
      Left = 839
      Top = 21
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
    end
  end
  object EngGB: TGroupBox
    Left = 0
    Top = 0
    Width = 271
    Height = 564
    Align = alLeft
    Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1072' '#1076#1074#1080#1078#1082#1072
    TabOrder = 1
    ExplicitHeight = 581
    object EngTreeGB: TGroupBox
      Left = 2
      Top = 15
      Width = 267
      Height = 492
      Align = alClient
      Caption = #1044#1077#1088#1077#1074#1086' '#1086#1073#1098#1077#1082#1090#1086#1074
      TabOrder = 0
      ExplicitHeight = 509
      object EngTV: TTreeView
        Left = 2
        Top = 15
        Width = 263
        Height = 475
        Align = alClient
        DragCursor = crHandPoint
        DragMode = dmAutomatic
        Indent = 19
        TabOrder = 0
        OnClick = EngTVClick
        OnDragDrop = EngTVDragDrop
        OnDragOver = EngTVDragOver
        ExplicitHeight = 492
      end
    end
    object EditEngListGB: TGroupBox
      Left = 2
      Top = 507
      Width = 267
      Height = 55
      Align = alBottom
      Caption = 'EditEngListGB'
      TabOrder = 1
      ExplicitTop = 524
      inline EditEngListFrame1: TEditEngListFrame
        Left = 2
        Top = 15
        Width = 263
        Height = 38
        Align = alClient
        Constraints.MaxHeight = 304
        Constraints.MinHeight = 38
        TabOrder = 0
        ExplicitLeft = 2
        ExplicitTop = 15
        ExplicitWidth = 263
        ExplicitHeight = 38
        inherited ToolBar1: TToolBar
          Width = 263
          ParentShowHint = False
          ShowHint = True
          ExplicitWidth = 263
          inherited CreateObjBtn: TToolButton
            Hint = #1044#1086#1073#1072#1074#1080#1090#1100' '#1086#1073#1098#1077#1082#1090
            OnClick = EditEngListFrame1CreateObjBtnClick
          end
          inherited DelObjBtn: TToolButton
            Hint = #1059#1076#1072#1083#1080#1090#1100' '#1086#1073#1098#1077#1082#1090
            OnClick = EditEngListFrame1DelObjBtnClick
          end
          inherited ClearAll: TToolButton
            OnClick = EditEngListFrame1ClearAllClick
          end
        end
      end
    end
  end
  object Pages: TPageControl
    Left = 277
    Top = 0
    Width = 645
    Height = 564
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 2
    ExplicitHeight = 581
    object TabSheet1: TTabSheet
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1086#1073#1098#1077#1082#1090#1086#1074
      object ObjGB: TGroupBox
        Left = 0
        Top = 0
        Width = 637
        Height = 536
        Align = alClient
        Caption = #1042#1099#1073#1088#1072#1085' '#1086#1073#1098#1077#1082#1090
        TabOrder = 0
        inline ObjInterfaceFrame1: TObjInterfaceFrame
          Left = 2
          Top = 15
          Width = 633
          Height = 519
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 2
          ExplicitTop = 15
          ExplicitWidth = 633
          ExplicitHeight = 519
          inherited ScrollBox1: TScrollBox
            Width = 633
            Height = 519
            ExplicitWidth = 633
            ExplicitHeight = 519
            inherited MainObjGB: TGroupBox
              Width = 629
              Height = 466
              ExplicitWidth = 629
              ExplicitHeight = 466
              inherited MainObjFrame: TCompaundFrame
                Width = 625
                Height = 449
                ExplicitWidth = 625
                ExplicitHeight = 449
                inherited MainObjSB: TScrollBox
                  Width = 625
                  Height = 449
                  ExplicitWidth = 625
                  ExplicitHeight = 449
                  inherited Splitter1: TSplitter
                    Top = 158
                    Width = 621
                    Height = 4
                    ExplicitTop = 158
                    ExplicitWidth = 979
                    ExplicitHeight = 4
                  end
                  inherited BaseObjPropertyFrame1: TBaseObjPropertyFrame
                    Width = 621
                    Height = 158
                    ExplicitWidth = 621
                    ExplicitHeight = 158
                    inherited MetaDataLV: TBtnListView
                      Width = 615
                      Height = 94
                      ExplicitWidth = 615
                      ExplicitHeight = 94
                    end
                  end
                  inherited ChanFrame1: TChanFrame
                    Top = 162
                    Width = 621
                    Height = 283
                    ExplicitTop = 162
                    ExplicitWidth = 621
                    ExplicitHeight = 283
                    inherited CommonGB: TGroupBox
                      Width = 621
                      Height = 283
                      ExplicitWidth = 621
                      ExplicitHeight = 283
                      inherited ChanLV: TBtnListView
                        Left = 168
                        Width = 0
                        Height = 93
                        ExplicitLeft = 168
                        ExplicitWidth = 0
                        ExplicitHeight = 93
                      end
                    end
                  end
                  inherited SensorFrame1: TSensorFrame
                    Top = 162
                    Width = 621
                    Height = 283
                    ExplicitTop = 162
                    ExplicitWidth = 621
                    ExplicitHeight = 283
                    inherited SensorsGB: TGroupBox
                      Top = 17
                      Width = 621
                      ExplicitTop = 17
                      ExplicitWidth = 621
                      inherited StateGB: TGroupBox
                        Width = 617
                        ExplicitWidth = 617
                        inherited PairsListView: TBtnListView
                          Top = 37
                          Width = 1719
                          ExplicitTop = 37
                          ExplicitWidth = 1719
                        end
                      end
                    end
                  end
                  inherited StageFrame1: TStageFrame
                    Top = 162
                    Width = 621
                    Height = 283
                    ExplicitTop = 162
                    ExplicitWidth = 621
                    ExplicitHeight = 283
                    inherited StageGB: TGroupBox
                      Width = 621
                      Height = 283
                      ExplicitWidth = 621
                      ExplicitHeight = 283
                      inherited SignalSetupPageControl: TPageControl
                        Width = 617
                        Height = 266
                        ExplicitWidth = 617
                        ExplicitHeight = 266
                        inherited TabSheet1: TTabSheet
                          ExplicitWidth = 609
                          ExplicitHeight = 238
                          inherited Splitter2: TSplitter
                            Height = 238
                            ExplicitLeft = 147
                            ExplicitHeight = 179
                          end
                          inherited BladesGB: TGroupBox
                            Height = 238
                            ExplicitHeight = 238
                            inherited Splitter1: TSplitter
                              Height = 221
                              ExplicitLeft = 140
                              ExplicitHeight = 248
                            end
                            inherited BladesLV: TBtnListView
                              Height = 221
                              ExplicitHeight = 221
                            end
                          end
                          inherited ShapeGB: TGroupBox
                            Width = 287
                            Height = 238
                            ExplicitWidth = 287
                            ExplicitHeight = 238
                            inherited ShapeLV: TBtnListView
                              Width = 283
                              Height = 221
                              ExplicitWidth = 283
                              ExplicitHeight = 221
                            end
                          end
                          inherited StagePropertysGB: TGroupBox
                            Height = 238
                            ExplicitHeight = 238
                          end
                        end
                      end
                    end
                  end
                  inherited TurbineFrame1: TTurbineFrame
                    Top = 162
                    Width = 621
                    Height = 283
                    ExplicitTop = 162
                    ExplicitWidth = 621
                    ExplicitHeight = 283
                    inherited TurbinePropGB: TGroupBox
                      Width = 621
                      Height = 283
                      ExplicitWidth = 621
                      ExplicitHeight = 283
                      inherited CfgTV: TTreeView
                        Width = 217
                        ExplicitWidth = 217
                      end
                      inherited RecentFileEdit: TEdit
                        Width = 217
                        ExplicitWidth = 217
                      end
                    end
                  end
                  inherited PairFrame1: TPairFrame
                    Top = 162
                    Width = 621
                    Height = 283
                    ExplicitTop = 162
                    ExplicitWidth = 621
                    ExplicitHeight = 283
                    inherited PairGB: TGroupBox
                      Width = 621
                      Height = 283
                      ExplicitWidth = 621
                      ExplicitHeight = 283
                      DesignSize = (
                        621
                        283)
                      inherited SensorsLV: TBtnListView
                        Top = 73
                        Width = 360
                        Height = 97
                        ExplicitTop = 73
                        ExplicitWidth = 360
                        ExplicitHeight = 97
                      end
                    end
                  end
                  inherited UTSFrame1: TUTSFrame
                    Top = 162
                    Width = 621
                    Height = 283
                    ExplicitTop = 162
                    ExplicitWidth = 621
                    ExplicitHeight = 283
                    inherited UTSLV: TBtnListView
                      Height = 97
                      ExplicitHeight = 97
                    end
                  end
                  inherited Platframe1: TPlatframe
                    Top = 162
                    Width = 621
                    Height = 283
                    ExplicitTop = 162
                    ExplicitWidth = 621
                    ExplicitHeight = 283
                  end
                end
              end
            end
            inherited SelectActionGB: TGroupBox
              Top = 466
              Width = 629
              ExplicitTop = 466
              ExplicitWidth = 629
              DesignSize = (
                629
                49)
              inherited ApplyBtn: TButton
                Left = 550
                ExplicitLeft = 550
              end
            end
          end
        end
      end
    end
    object TagsPage: TTabSheet
      Caption = #1058#1077#1075#1080
      ImageIndex = 2
      ExplicitHeight = 553
      inline TagsCfgFrame1: TTagsCfgFrame
        Left = 0
        Top = 0
        Width = 637
        Height = 536
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 637
        ExplicitHeight = 553
        inherited Splitter1: TSplitter
          Left = 344
          Height = 381
          ExplicitLeft = 231
          ExplicitHeight = 326
        end
        inherited ControlGB: TGroupBox
          Top = 480
          Width = 637
          ExplicitTop = 497
          ExplicitWidth = 637
          inherited ApplyBtn: TButton
            Left = 556
            OnClick = TagsCfgFrame1ApplyBtnClick
            ExplicitLeft = 556
          end
        end
        inherited TagsLV: TBtnListView
          Width = 344
          Height = 381
          OnChange = TagsCfgFrame1TagsLVChange
          ExplicitWidth = 344
          ExplicitHeight = 398
        end
        inherited TagPropertiesGB: TGroupBox
          Left = 347
          Height = 381
          ExplicitLeft = 347
          ExplicitHeight = 398
          inherited TagGB: TGroupBox
            Height = 361
            ExplicitHeight = 378
            inherited TagPropertiesFrame1: TTagPropertiesFrame
              Height = 344
              ExplicitHeight = 361
              inherited TheresholdsLV: TBtnListView
                Height = 232
                ExplicitHeight = 249
              end
              inherited DrawObjSelectBtn: TButton
                OnClick = TagPropertiesFrame1DrawObjSelectBtnClick
              end
              inherited ToolBar: TToolBar
                Top = 305
                ExplicitTop = 322
              end
            end
          end
        end
        inherited TagsMngGB: TGroupBox
          Top = 381
          Width = 637
          ExplicitTop = 398
          ExplicitWidth = 637
          inherited TagsBaseEdit: TEdit
            Width = 528
            ExplicitWidth = 528
          end
          inherited SelectTagsBaseBtn: TButton
            Left = 542
            ExplicitLeft = 542
          end
        end
      end
    end
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 564
    Width = 922
    Height = 17
    Align = alBottom
    SmoothReverse = True
    TabOrder = 3
    ExplicitLeft = 2
    ExplicitTop = 62
    ExplicitWidth = 731
  end
  object MainMenu1: TMainMenu
    Left = 592
    Top = 65528
    object FileMenu: TMenuItem
      Caption = #1060#1072#1081#1083
      object OpenFileMenu: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
        OnClick = OpenFileMenuClick
      end
      object RecentFileMenu: TMenuItem
        Caption = #1053#1077#1076#1072#1074#1085#1080#1077' '#1092#1072#1081#1083#1099
        OnClick = LoadMenuClick
      end
      object SaveMenu: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1092#1072#1081#1083
        OnClick = SaveMenuClick
      end
    end
    object AlgorithmsMenu: TMenuItem
      Caption = #1040#1083#1075#1086#1088#1080#1090#1084#1099
    end
  end
  object SaveDialog: TSaveDialog
    Filter = 
      #1057#1090#1072#1088#1099#1081' '#1092#1086#1088#1084#1072#1090' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1080' (lfm)|*.lfm|'#1057#1090#1072#1088#1099#1081' '#1092#1086#1088#1084#1072#1090' '#1076#1072#1085#1085#1099#1093' (bld' +
      ')|*.bld|'#1050#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103' '#1086#1073#1086#1088#1091#1076#1086#1074#1072#1085#1080#1103' (xml)|*.xml|'#1056#1072#1089#1087#1088#1077#1076#1077#1083#1077#1085#1085#1099#1081' '#1092#1072#1081 +
      #1083' '#1076#1072#1085#1085#1099#1093' (sdt)|*.sdt'
    Left = 528
    Top = 65528
  end
  object OpenDialog: TOpenDialog
    Filter = 
      #1057#1090#1072#1088#1099#1081' '#1092#1086#1088#1084#1072#1090' '#1082#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1080' (lfm)|*.lfm|'#1057#1090#1072#1088#1099#1081' '#1092#1086#1088#1084#1072#1090' '#1076#1072#1085#1085#1099#1093' (bld' +
      ')|*.bld|'#1050#1086#1085#1092#1080#1075#1091#1088#1072#1094#1080#1103' '#1086#1073#1086#1088#1091#1076#1086#1074#1072#1085#1080#1103' (xml)|*.xml|'#1056#1072#1089#1087#1088#1077#1076#1077#1083#1077#1085#1085#1099#1081' '#1092#1072#1081 +
      #1083' '#1076#1072#1085#1085#1099#1093' (sdt)|*.sdt'
    Left = 560
    Top = 65528
  end
end
