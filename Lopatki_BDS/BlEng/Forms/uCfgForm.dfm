object CfgForm: TCfgForm
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072
  ClientHeight = 824
  ClientWidth = 1206
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object MainSplitter: TSplitter
    Left = 354
    Top = 0
    Width = 8
    Height = 738
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Beveled = True
    Color = clGray
    ParentColor = False
  end
  object SelectActionGB: TGroupBox
    Left = 0
    Top = 760
    Width = 1206
    Height = 64
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 0
    DesignSize = (
      1206
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
      Left = 1097
      Top = 27
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
  object EngGB: TGroupBox
    Left = 0
    Top = 0
    Width = 354
    Height = 738
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    Caption = #1057#1090#1088#1091#1082#1090#1091#1088#1072' '#1076#1074#1080#1078#1082#1072
    TabOrder = 1
    object EngTreeGB: TGroupBox
      Left = 2
      Top = 19
      Width = 350
      Height = 645
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      Caption = #1044#1077#1088#1077#1074#1086' '#1086#1073#1098#1077#1082#1090#1086#1074
      TabOrder = 0
      object EngTV: TTreeView
        Left = 2
        Top = 19
        Width = 346
        Height = 624
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        DragCursor = crHandPoint
        DragMode = dmAutomatic
        Indent = 19
        TabOrder = 0
        OnClick = EngTVClick
        OnDragDrop = EngTVDragDrop
        OnDragOver = EngTVDragOver
      end
    end
    object EditEngListGB: TGroupBox
      Left = 2
      Top = 664
      Width = 350
      Height = 72
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alBottom
      Caption = 'EditEngListGB'
      TabOrder = 1
      inline EditEngListFrame1: TEditEngListFrame
        Left = 2
        Top = 19
        Width = 346
        Height = 51
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        Constraints.MaxHeight = 398
        Constraints.MinHeight = 50
        TabOrder = 0
        ExplicitLeft = 2
        ExplicitTop = 19
        ExplicitWidth = 346
        ExplicitHeight = 51
        inherited ToolBar1: TToolBar
          Width = 346
          ParentShowHint = False
          ShowHint = True
          ExplicitWidth = 346
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
    Left = 362
    Top = 0
    Width = 844
    Height = 738
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 2
    object TabSheet1: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1086#1073#1098#1077#1082#1090#1086#1074
      object ObjGB: TGroupBox
        Left = 0
        Top = 0
        Width = 836
        Height = 706
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        Caption = #1042#1099#1073#1088#1072#1085' '#1086#1073#1098#1077#1082#1090
        TabOrder = 0
        inline ObjInterfaceFrame1: TObjInterfaceFrame
          Left = 2
          Top = 19
          Width = 832
          Height = 685
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 2
          ExplicitTop = 19
          ExplicitWidth = 832
          ExplicitHeight = 685
          inherited ScrollBox1: TScrollBox
            Width = 832
            Height = 685
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitWidth = 832
            ExplicitHeight = 685
            inherited MainObjGB: TGroupBox
              Width = 828
              Height = 617
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitWidth = 828
              ExplicitHeight = 617
              inherited MainObjFrame: TCompaundFrame
                Top = 19
                Width = 824
                Height = 596
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitTop = 19
                ExplicitWidth = 824
                ExplicitHeight = 596
                inherited MainObjSB: TScrollBox
                  Width = 824
                  Height = 596
                  Margins.Left = 4
                  Margins.Top = 4
                  Margins.Right = 4
                  Margins.Bottom = 4
                  ExplicitWidth = 824
                  ExplicitHeight = 596
                  inherited Splitter1: TSplitter
                    Top = 207
                    Width = 820
                    Height = 4
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    Constraints.MaxHeight = 5
                    ExplicitTop = 207
                    ExplicitWidth = 812
                    ExplicitHeight = 5
                  end
                  inherited BaseObjPropertyFrame1: TBaseObjPropertyFrame
                    Width = 820
                    Height = 207
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    Constraints.MinHeight = 84
                    Constraints.MinWidth = 383
                    ExplicitWidth = 820
                    ExplicitHeight = 207
                    inherited NameLabel: TLabel
                      Left = 4
                      Width = 82
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 4
                      ExplicitWidth = 82
                      ExplicitHeight = 17
                    end
                    inherited TypeLabel: TLabel
                      Left = 199
                      Width = 81
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 199
                      ExplicitWidth = 81
                      ExplicitHeight = 17
                    end
                    inherited TypeImage: TImage
                      Left = 365
                      Top = 12
                      Width = 42
                      Height = 42
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 365
                      ExplicitTop = 12
                      ExplicitWidth = 42
                      ExplicitHeight = 42
                    end
                    inherited Label1: TLabel
                      Left = 4
                      Top = 59
                      Width = 118
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 4
                      ExplicitTop = 59
                      ExplicitWidth = 118
                      ExplicitHeight = 17
                    end
                    inherited NameEdit: TEdit
                      Left = 4
                      Top = 26
                      Width = 158
                      Height = 25
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 4
                      ExplicitTop = 26
                      ExplicitWidth = 158
                      ExplicitHeight = 25
                    end
                    inherited TypeEdit: TEdit
                      Left = 199
                      Top = 26
                      Width = 158
                      Height = 25
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 199
                      ExplicitTop = 26
                      ExplicitWidth = 158
                      ExplicitHeight = 25
                    end
                    inherited AddFieldBtn: TButton
                      Left = 418
                      Top = 24
                      Width = 148
                      Height = 32
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 418
                      ExplicitTop = 24
                      ExplicitWidth = 148
                      ExplicitHeight = 32
                    end
                    inherited DelPropertieBtn: TButton
                      Left = 574
                      Top = 24
                      Width = 148
                      Height = 32
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 574
                      ExplicitTop = 24
                      ExplicitWidth = 148
                      ExplicitHeight = 32
                    end
                    inherited MetaDataLV: TBtnListView
                      Left = 4
                      Top = 84
                      Width = 804
                      Height = 123
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 4
                      ExplicitTop = 84
                      ExplicitWidth = 804
                      ExplicitHeight = 123
                    end
                  end
                  inherited ChanFrame1: TChanFrame
                    Top = 211
                    Width = 820
                    Height = 381
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitTop = 211
                    ExplicitWidth = 820
                    ExplicitHeight = 381
                    inherited CommonGB: TGroupBox
                      Width = 820
                      Height = 381
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitWidth = 820
                      ExplicitHeight = 381
                      inherited ImpulsCountLabel: TLabel
                        Left = 12
                        Top = 31
                        Width = 114
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 31
                        ExplicitWidth = 114
                        ExplicitHeight = 17
                      end
                      inherited ChanLVLabel: TLabel
                        Left = 199
                        Top = 31
                        Width = 134
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 199
                        ExplicitTop = 31
                        ExplicitWidth = 134
                        ExplicitHeight = 17
                      end
                      inherited Label3: TLabel
                        Left = 12
                        Top = 149
                        Width = 30
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 149
                        ExplicitWidth = 30
                        ExplicitHeight = 17
                      end
                      inherited Label4: TLabel
                        Left = 12
                        Top = 256
                        Width = 35
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 256
                        ExplicitWidth = 35
                        ExplicitHeight = 17
                      end
                      inherited OverflowLabel: TLabel
                        Left = 12
                        Top = 201
                        Width = 54
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 201
                        ExplicitWidth = 54
                        ExplicitHeight = 17
                      end
                      inherited ImpulsCountIE: TIntEdit
                        Left = 12
                        Top = 63
                        Width = 158
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 63
                        ExplicitWidth = 158
                        ExplicitHeight = 25
                      end
                      inherited ChanLV: TBtnListView
                        Left = 220
                        Top = 63
                        Width = 0
                        Height = 122
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        Columns = <
                          item
                            Caption = #8470
                            Width = 65
                          end
                          item
                            Caption = #1042#1088#1077#1084#1103' '#1074' '#1090#1080#1082#1072#1093
                            Width = 65
                          end
                          item
                            Caption = #1042#1088#1077#1084#1103', '#1089#1077#1082'.'
                            Width = 65
                          end>
                        ExplicitLeft = 220
                        ExplicitTop = 63
                        ExplicitWidth = 0
                        ExplicitHeight = 122
                      end
                      inherited ShowAllCB: TCheckBox
                        Left = 12
                        Top = 115
                        Width = 200
                        Height = 22
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 115
                        ExplicitWidth = 200
                        ExplicitHeight = 22
                      end
                      inherited TickEdit: TIntEdit
                        Left = 12
                        Top = 171
                        Width = 158
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 171
                        ExplicitWidth = 158
                        ExplicitHeight = 25
                      end
                      inherited ResIndEdit: TIntEdit
                        Left = 12
                        Top = 277
                        Width = 158
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 277
                        ExplicitWidth = 158
                        ExplicitHeight = 25
                      end
                      inherited OverflowIE: TIntEdit
                        Left = 12
                        Top = 224
                        Width = 158
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 12
                        ExplicitTop = 224
                        ExplicitWidth = 158
                        ExplicitHeight = 25
                      end
                    end
                  end
                  inherited SensorFrame1: TSensorFrame
                    Top = 211
                    Width = 820
                    Height = 381
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    Constraints.MinWidth = 347
                    ExplicitTop = 211
                    ExplicitWidth = 820
                    ExplicitHeight = 381
                    inherited SensorsGB: TGroupBox
                      Top = 33
                      Width = 820
                      Height = 348
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitTop = 33
                      ExplicitWidth = 820
                      ExplicitHeight = 348
                      inherited TypeLabel: TLabel
                        Left = 7
                        Top = 21
                        Width = 81
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 7
                        ExplicitTop = 21
                        ExplicitWidth = 81
                        ExplicitHeight = 17
                      end
                      inherited OffsetLabel: TLabel
                        Left = 177
                        Top = 21
                        Width = 130
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 177
                        ExplicitTop = 21
                        ExplicitWidth = 130
                        ExplicitHeight = 17
                      end
                      inherited ChunLabel: TLabel
                        Left = 319
                        Top = 21
                        Width = 89
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 319
                        ExplicitTop = 21
                        ExplicitWidth = 89
                        ExplicitHeight = 17
                      end
                      inherited TickCountLabel: TLabel
                        Left = 452
                        Top = 24
                        Width = 82
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 452
                        ExplicitTop = 24
                        ExplicitWidth = 82
                        ExplicitHeight = 17
                      end
                      inherited SkipBladesLabel: TLabel
                        Left = 585
                        Top = 24
                        Width = 137
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 585
                        ExplicitTop = 24
                        ExplicitWidth = 137
                        ExplicitHeight = 17
                      end
                      inherited TahoDivLabel: TLabel
                        Left = 452
                        Top = 75
                        Width = 120
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 452
                        ExplicitTop = 75
                        ExplicitWidth = 120
                        ExplicitHeight = 17
                      end
                      inherited TypeCB: TComboBox
                        Left = 7
                        Top = 43
                        Width = 162
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 7
                        ExplicitTop = 43
                        ExplicitWidth = 162
                        ExplicitHeight = 25
                      end
                      inherited OffsetFE: TFloatEdit
                        Left = 177
                        Top = 43
                        Width = 134
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 177
                        ExplicitTop = 43
                        ExplicitWidth = 134
                        ExplicitHeight = 25
                      end
                      inherited ChunIE: TIntEdit
                        Left = 320
                        Top = 43
                        Width = 123
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 320
                        ExplicitTop = 43
                        ExplicitWidth = 123
                        ExplicitHeight = 25
                      end
                      inherited StateGB: TGroupBox
                        Top = 130
                        Width = 816
                        Height = 216
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitTop = 130
                        ExplicitWidth = 816
                        ExplicitHeight = 216
                        inherited PairsLVLabel: TLabel
                          Left = 174
                          Top = 24
                          Width = 74
                          Height = 17
                          Margins.Left = 4
                          Margins.Top = 4
                          Margins.Right = 4
                          Margins.Bottom = 4
                          ExplicitLeft = 174
                          ExplicitTop = 24
                          ExplicitWidth = 74
                          ExplicitHeight = 17
                        end
                        inherited StagesLabel: TLabel
                          Left = 7
                          Top = 24
                          Width = 56
                          Height = 17
                          Margins.Left = 4
                          Margins.Top = 4
                          Margins.Right = 4
                          Margins.Bottom = 4
                          ExplicitLeft = 7
                          ExplicitTop = 24
                          ExplicitWidth = 56
                          ExplicitHeight = 17
                        end
                        inherited StageCB: TComboBox
                          Left = 4
                          Top = 47
                          Width = 162
                          Height = 25
                          Margins.Left = 4
                          Margins.Top = 4
                          Margins.Right = 4
                          Margins.Bottom = 4
                          ExplicitLeft = 4
                          ExplicitTop = 47
                          ExplicitWidth = 162
                          ExplicitHeight = 25
                        end
                        inherited PairsListView: TBtnListView
                          Left = 174
                          Top = 48
                          Width = 2248
                          Height = 160
                          Margins.Left = 4
                          Margins.Top = 4
                          Margins.Right = 4
                          Margins.Bottom = 4
                          Columns = <
                            item
                              Caption = #8470
                              Width = 65
                            end
                            item
                              Caption = #1048#1084#1103
                              Width = 65
                            end
                            item
                              Caption = #1050#1086#1088'. '#1076#1072#1090'.'
                              Width = 65
                            end
                            item
                              Caption = #1055#1077#1088'. '#1076#1072#1090'.'
                              Width = 65
                            end>
                          ExplicitLeft = 174
                          ExplicitTop = 48
                          ExplicitWidth = 2248
                          ExplicitHeight = 160
                        end
                      end
                      inherited TickCountIE: TIntEdit
                        Left = 452
                        Top = 43
                        Width = 123
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 452
                        ExplicitTop = 43
                        ExplicitWidth = 123
                        ExplicitHeight = 25
                      end
                      inherited SkipBladeIE: TIntEdit
                        Left = 585
                        Top = 43
                        Width = 116
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 585
                        ExplicitTop = 43
                        ExplicitWidth = 116
                        ExplicitHeight = 25
                      end
                      inherited EvalSkipBladesBtn: TButton
                        Left = 709
                        Top = 41
                        Width = 87
                        Height = 32
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 709
                        ExplicitTop = 41
                        ExplicitWidth = 87
                        ExplicitHeight = 32
                      end
                      inherited TahoDivEdit: TEdit
                        Left = 452
                        Top = 99
                        Width = 249
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 452
                        ExplicitTop = 99
                        ExplicitWidth = 249
                        ExplicitHeight = 25
                      end
                    end
                  end
                  inherited StageFrame1: TStageFrame
                    Top = 211
                    Width = 820
                    Height = 381
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    Constraints.MinWidth = 347
                    ExplicitTop = 211
                    ExplicitWidth = 820
                    ExplicitHeight = 381
                    inherited StageGB: TGroupBox
                      Width = 820
                      Height = 381
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitWidth = 820
                      ExplicitHeight = 381
                      inherited SignalSetupPageControl: TPageControl
                        Top = 19
                        Width = 816
                        Height = 360
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitTop = 19
                        ExplicitWidth = 816
                        ExplicitHeight = 360
                        inherited TabSheet1: TTabSheet
                          Margins.Left = 4
                          Margins.Top = 4
                          Margins.Right = 4
                          Margins.Bottom = 4
                          ExplicitTop = 28
                          ExplicitWidth = 808
                          ExplicitHeight = 328
                          inherited Splitter2: TSplitter
                            Left = 192
                            Width = 8
                            Height = 328
                            Margins.Left = 4
                            Margins.Top = 4
                            Margins.Right = 4
                            Margins.Bottom = 4
                            ExplicitLeft = 192
                            ExplicitWidth = 8
                            ExplicitHeight = 311
                          end
                          inherited BladesGB: TGroupBox
                            Width = 192
                            Height = 328
                            Margins.Left = 4
                            Margins.Top = 4
                            Margins.Right = 4
                            Margins.Bottom = 4
                            ExplicitWidth = 192
                            ExplicitHeight = 328
                            inherited Splitter1: TSplitter
                              Left = 183
                              Top = 19
                              Width = 7
                              Height = 307
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 183
                              ExplicitTop = 20
                              ExplicitWidth = 7
                              ExplicitHeight = 289
                            end
                            inherited BladesLV: TBtnListView
                              Top = 19
                              Width = 181
                              Height = 307
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              Columns = <
                                item
                                  Caption = #8470
                                  Width = 65
                                end
                                item
                                  Caption = #1055#1086#1083#1086#1078#1077#1085#1080#1077
                                  Width = 65
                                end>
                              ExplicitTop = 19
                              ExplicitWidth = 181
                              ExplicitHeight = 307
                            end
                          end
                          inherited ShapeGB: TGroupBox
                            Left = 421
                            Width = 387
                            Height = 328
                            Margins.Left = 4
                            Margins.Top = 4
                            Margins.Right = 4
                            Margins.Bottom = 4
                            ExplicitLeft = 421
                            ExplicitWidth = 387
                            ExplicitHeight = 328
                            inherited ShapeLV: TBtnListView
                              Top = 19
                              Width = 383
                              Height = 307
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              Columns = <
                                item
                                  Caption = #8470
                                  Width = 65
                                end
                                item
                                  Caption = #1055#1086#1083#1086#1078'.'
                                  Width = 65
                                end>
                              ExplicitTop = 19
                              ExplicitWidth = 383
                              ExplicitHeight = 307
                            end
                          end
                          inherited StagePropertysGB: TGroupBox
                            Left = 200
                            Width = 221
                            Height = 328
                            Margins.Left = 4
                            Margins.Top = 4
                            Margins.Right = 4
                            Margins.Bottom = 4
                            ExplicitLeft = 200
                            ExplicitWidth = 221
                            ExplicitHeight = 328
                            inherited DiametrLabel: TLabel
                              Left = 7
                              Top = 88
                              Width = 115
                              Height = 17
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 7
                              ExplicitTop = 88
                              ExplicitWidth = 115
                              ExplicitHeight = 17
                            end
                            inherited StageCountLabel: TLabel
                              Left = 7
                              Top = 144
                              Width = 98
                              Height = 17
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 7
                              ExplicitTop = 144
                              ExplicitWidth = 98
                              ExplicitHeight = 17
                            end
                            inherited TurbineLabel: TLabel
                              Left = 8
                              Top = 27
                              Width = 55
                              Height = 17
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 8
                              ExplicitTop = 27
                              ExplicitWidth = 55
                              ExplicitHeight = 17
                            end
                            inherited BladeCountIE: TIntEdit
                              Left = 7
                              Top = 165
                              Width = 147
                              Height = 25
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 7
                              ExplicitTop = 165
                              ExplicitWidth = 147
                              ExplicitHeight = 25
                            end
                            inherited DiametrFE: TFloatEdit
                              Left = 7
                              Top = 112
                              Width = 147
                              Height = 25
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 7
                              ExplicitTop = 112
                              ExplicitWidth = 147
                              ExplicitHeight = 25
                            end
                            inherited EvalShapeBtn: TButton
                              Left = 4
                              Top = 200
                              Width = 150
                              Height = 33
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 4
                              ExplicitTop = 200
                              ExplicitWidth = 150
                              ExplicitHeight = 33
                            end
                            inherited TurbineCB: TComboBox
                              Left = 4
                              Top = 52
                              Width = 150
                              Height = 25
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 4
                              ExplicitTop = 52
                              ExplicitWidth = 150
                              ExplicitHeight = 25
                            end
                            inherited EvalSensorSkipBtn: TButton
                              Left = 4
                              Top = 307
                              Width = 150
                              Height = 33
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 4
                              ExplicitTop = 307
                              ExplicitWidth = 150
                              ExplicitHeight = 33
                            end
                            inherited UseShapeAlgCB: TCheckBox
                              Left = 7
                              Top = 277
                              Width = 193
                              Height = 22
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 7
                              ExplicitTop = 277
                              ExplicitWidth = 193
                              ExplicitHeight = 22
                            end
                            inherited Button1: TButton
                              Left = 4
                              Top = 235
                              Width = 150
                              Height = 33
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 4
                              ExplicitTop = 235
                              ExplicitWidth = 150
                              ExplicitHeight = 33
                            end
                            inherited EvalSPos: TButton
                              Left = 4
                              Top = 347
                              Width = 150
                              Height = 32
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitLeft = 4
                              ExplicitTop = 347
                              ExplicitWidth = 150
                              ExplicitHeight = 32
                            end
                          end
                        end
                        inherited TabSheet2: TTabSheet
                          Margins.Left = 4
                          Margins.Top = 4
                          Margins.Right = 4
                          Margins.Bottom = 4
                          ExplicitLeft = 4
                          ExplicitTop = 28
                          ExplicitWidth = 439
                          ExplicitHeight = 251
                          inherited SensorsGB: TGroupBox
                            Height = 251
                            Margins.Left = 4
                            Margins.Top = 4
                            Margins.Right = 4
                            Margins.Bottom = 4
                            ExplicitHeight = 251
                            inherited SensorsSG: TStringGrid
                              Top = 19
                              Height = 230
                              Margins.Left = 4
                              Margins.Top = 4
                              Margins.Right = 4
                              Margins.Bottom = 4
                              ExplicitTop = 19
                              ExplicitHeight = 230
                            end
                          end
                        end
                      end
                    end
                  end
                  inherited TurbineFrame1: TTurbineFrame
                    Top = 211
                    Width = 820
                    Height = 381
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    Constraints.MinWidth = 347
                    ExplicitTop = 211
                    ExplicitWidth = 820
                    ExplicitHeight = 381
                    inherited TurbinePropGB: TGroupBox
                      Width = 820
                      Height = 381
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitWidth = 820
                      ExplicitHeight = 381
                      inherited StageCountLabel: TLabel
                        Left = 7
                        Top = 60
                        Width = 105
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 7
                        ExplicitTop = 60
                        ExplicitWidth = 105
                        ExplicitHeight = 17
                      end
                      inherited CfgLabel: TLabel
                        Left = 183
                        Top = 61
                        Width = 156
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 183
                        ExplicitTop = 61
                        ExplicitWidth = 156
                        ExplicitHeight = 17
                      end
                      inherited RecentFileLabel: TLabel
                        Left = 7
                        Top = 30
                        Width = 161
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 7
                        ExplicitTop = 30
                        ExplicitWidth = 161
                        ExplicitHeight = 17
                      end
                      inherited StageCountIE: TIntEdit
                        Left = 7
                        Top = 86
                        Width = 158
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 7
                        ExplicitTop = 86
                        ExplicitWidth = 158
                        ExplicitHeight = 25
                      end
                      inherited CfgTV: TTreeView
                        Left = 183
                        Top = 86
                        Width = 284
                        Height = 213
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 183
                        ExplicitTop = 86
                        ExplicitWidth = 284
                        ExplicitHeight = 213
                      end
                      inherited RecentFileEdit: TEdit
                        Left = 183
                        Top = 26
                        Width = 284
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 183
                        ExplicitTop = 26
                        ExplicitWidth = 284
                        ExplicitHeight = 25
                      end
                    end
                  end
                  inherited PairFrame1: TPairFrame
                    Top = 211
                    Width = 820
                    Height = 381
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    Constraints.MinWidth = 347
                    ExplicitTop = 211
                    ExplicitWidth = 820
                    ExplicitHeight = 381
                    inherited PairGB: TGroupBox
                      Width = 820
                      Height = 381
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitWidth = 820
                      ExplicitHeight = 381
                      DesignSize = (
                        820
                        381)
                      inherited StageCountLabel: TLabel
                        Left = 5
                        Top = 25
                        Width = 137
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 5
                        ExplicitTop = 25
                        ExplicitWidth = 137
                        ExplicitHeight = 17
                      end
                      inherited StageLabel: TLabel
                        Left = 197
                        Top = 25
                        Width = 55
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 197
                        ExplicitTop = 25
                        ExplicitWidth = 55
                        ExplicitHeight = 17
                      end
                      inherited SensorNameLabel: TLabel
                        Left = 411
                        Top = 25
                        Width = 82
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 411
                        ExplicitTop = 25
                        ExplicitWidth = 82
                        ExplicitHeight = 17
                      end
                      inherited BaseLabel: TLabel
                        Left = 680
                        Top = 25
                        Height = 17
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 680
                        ExplicitTop = 25
                        ExplicitHeight = 17
                      end
                      inherited SensorsLV: TBtnListView
                        Left = 5
                        Top = 95
                        Width = 471
                        Height = 127
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        Columns = <
                          item
                            Caption = #8470
                            Width = 65
                          end
                          item
                            Caption = #1048#1084#1103
                            Width = 65
                          end
                          item
                            Caption = #1058#1080#1087
                            Width = 48
                          end
                          item
                            Caption = #1063#1080#1089#1083#1086' '#1080#1084#1087'.'
                            Width = 65
                          end
                          item
                            Caption = #1055#1086#1083#1086#1078'.'
                            Width = 65
                          end>
                        ExplicitLeft = 5
                        ExplicitTop = 95
                        ExplicitWidth = 471
                        ExplicitHeight = 127
                      end
                      inherited BladeLeftIE: TIntEdit
                        Left = 5
                        Top = 50
                        Width = 158
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 5
                        ExplicitTop = 50
                        ExplicitWidth = 158
                        ExplicitHeight = 25
                      end
                      inherited StageCB: TComboBox
                        Left = 197
                        Top = 50
                        Width = 190
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 197
                        ExplicitTop = 50
                        ExplicitWidth = 190
                        ExplicitHeight = 25
                      end
                      inherited SensorsNameCB: TComboBox
                        Left = 412
                        Top = 50
                        Width = 173
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 412
                        ExplicitTop = 50
                        ExplicitWidth = 173
                        ExplicitHeight = 25
                      end
                      inherited SelectSensorsBtn: TButton
                        Left = 592
                        Top = 50
                        Width = 66
                        Height = 27
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 592
                        ExplicitTop = 50
                        ExplicitWidth = 66
                        ExplicitHeight = 27
                      end
                      inherited BaseFE: TFloatEdit
                        Left = 680
                        Top = 50
                        Width = 158
                        Height = 25
                        Margins.Left = 4
                        Margins.Top = 4
                        Margins.Right = 4
                        Margins.Bottom = 4
                        ExplicitLeft = 680
                        ExplicitTop = 50
                        ExplicitWidth = 158
                        ExplicitHeight = 25
                      end
                    end
                  end
                  inherited UTSFrame1: TUTSFrame
                    Top = 211
                    Width = 820
                    Height = 381
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitTop = 211
                    ExplicitWidth = 820
                    ExplicitHeight = 381
                    inherited UtsLabel: TLabel
                      Left = 21
                      Top = 4
                      Width = 67
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 21
                      ExplicitTop = 4
                      ExplicitWidth = 67
                      ExplicitHeight = 17
                    end
                    inherited SignalTypeLabel: TLabel
                      Left = 241
                      Top = 4
                      Width = 79
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 241
                      ExplicitTop = 4
                      ExplicitWidth = 79
                      ExplicitHeight = 17
                    end
                    inherited UTSChannel: TComboBox
                      Left = 21
                      Top = 29
                      Width = 190
                      Height = 25
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 21
                      ExplicitTop = 29
                      ExplicitWidth = 190
                      ExplicitHeight = 25
                    end
                    inherited UTSLV: TBtnListView
                      Left = 21
                      Top = 64
                      Width = 587
                      Height = 127
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 21
                      ExplicitTop = 64
                      ExplicitWidth = 587
                      ExplicitHeight = 127
                    end
                    inherited SEVCB: TComboBox
                      Left = 241
                      Top = 29
                      Width = 189
                      Height = 25
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 241
                      ExplicitTop = 29
                      ExplicitWidth = 189
                      ExplicitHeight = 25
                    end
                  end
                  inherited Platframe1: TPlatframe
                    Top = 211
                    Width = 820
                    Height = 381
                    Margins.Left = 4
                    Margins.Top = 4
                    Margins.Right = 4
                    Margins.Bottom = 4
                    ExplicitTop = 211
                    ExplicitWidth = 820
                    ExplicitHeight = 381
                    inherited BuffSizeLabel: TLabel
                      Left = 398
                      Top = 17
                      Width = 97
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 398
                      ExplicitTop = 17
                      ExplicitWidth = 97
                      ExplicitHeight = 17
                    end
                    inherited PeriodLabel: TLabel
                      Left = 199
                      Top = 17
                      Width = 129
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 199
                      ExplicitTop = 17
                      ExplicitWidth = 129
                      ExplicitHeight = 17
                    end
                    inherited Label1: TLabel
                      Left = 4
                      Top = 17
                      Width = 54
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 4
                      ExplicitTop = 17
                      ExplicitWidth = 54
                      ExplicitHeight = 17
                    end
                    inherited ModeLabel: TLabel
                      Left = 659
                      Top = 17
                      Width = 42
                      Height = 17
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 659
                      ExplicitTop = 17
                      ExplicitWidth = 42
                      ExplicitHeight = 17
                    end
                    inherited BufSizeCB: TComboBox
                      Left = 398
                      Top = 42
                      Width = 221
                      Height = 25
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 398
                      ExplicitTop = 42
                      ExplicitWidth = 221
                      ExplicitHeight = 25
                    end
                    inherited PeriodSE: TFloatSpinEdit
                      Left = 199
                      Top = 42
                      Width = 158
                      Height = 27
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 199
                      ExplicitTop = 42
                      ExplicitWidth = 158
                      ExplicitHeight = 27
                    end
                    inherited FreqFE: TFloatSpinEdit
                      Left = 4
                      Top = 42
                      Width = 158
                      Height = 27
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 4
                      ExplicitTop = 42
                      ExplicitWidth = 158
                      ExplicitHeight = 27
                    end
                    inherited ModeCB: TComboBox
                      Left = 659
                      Top = 42
                      Width = 221
                      Height = 25
                      Margins.Left = 4
                      Margins.Top = 4
                      Margins.Right = 4
                      Margins.Bottom = 4
                      ExplicitLeft = 659
                      ExplicitTop = 42
                      ExplicitWidth = 221
                      ExplicitHeight = 25
                    end
                  end
                end
              end
            end
            inherited SelectActionGB: TGroupBox
              Top = 617
              Width = 828
              Height = 64
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitTop = 617
              ExplicitWidth = 828
              ExplicitHeight = 64
              DesignSize = (
                828
                64)
              inherited CancelBtn: TButton
                Left = 10
                Top = 25
                Width = 99
                Height = 33
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 10
                ExplicitTop = 25
                ExplicitWidth = 99
                ExplicitHeight = 33
              end
              inherited ApplyBtn: TButton
                Left = 719
                Top = 27
                Width = 98
                Height = 33
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                OnClick = ObjInterfaceFrame1ApplyBtnClick
                ExplicitLeft = 719
                ExplicitTop = 27
                ExplicitWidth = 98
                ExplicitHeight = 33
              end
            end
          end
        end
      end
    end
    object TagsPage: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = #1058#1077#1075#1080
      ImageIndex = 2
      inline TagsCfgFrame1: TTagsCfgFrame
        Left = 0
        Top = 0
        Width = 836
        Height = 706
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 836
        ExplicitHeight = 706
        inherited Splitter1: TSplitter
          Left = 453
          Width = 4
          Height = 503
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ExplicitLeft = 450
          ExplicitTop = 0
          ExplicitWidth = 4
          ExplicitHeight = 498
        end
        inherited ControlGB: TGroupBox
          Top = 633
          Width = 836
          Height = 73
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ExplicitTop = 633
          ExplicitWidth = 836
          ExplicitHeight = 73
          inherited CancelBtn: TButton
            Left = 4
            Top = 25
            Width = 98
            Height = 33
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 4
            ExplicitTop = 25
            ExplicitWidth = 98
            ExplicitHeight = 33
          end
          inherited ApplyBtn: TButton
            Left = 727
            Top = 25
            Width = 98
            Height = 33
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            OnClick = TagsCfgFrame1ApplyBtnClick
            ExplicitLeft = 727
            ExplicitTop = 25
            ExplicitWidth = 98
            ExplicitHeight = 33
          end
        end
        inherited TagsLV: TBtnListView
          Width = 453
          Height = 503
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          OnChange = TagsCfgFrame1TagsLVChange
          ExplicitWidth = 453
          ExplicitHeight = 503
        end
        inherited TagPropertiesGB: TGroupBox
          Left = 457
          Width = 379
          Height = 503
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ExplicitLeft = 457
          ExplicitWidth = 379
          ExplicitHeight = 503
          inherited Splitter2: TSplitter
            Top = 19
            Width = 375
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 3
            ExplicitTop = 24
            ExplicitWidth = 374
          end
          inherited TagGB: TGroupBox
            Top = 22
            Width = 375
            Height = 479
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitTop = 22
            ExplicitWidth = 375
            ExplicitHeight = 479
            inherited TagPropertiesFrame1: TTagPropertiesFrame
              Top = 19
              Width = 371
              Height = 458
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              ExplicitTop = 19
              ExplicitWidth = 371
              ExplicitHeight = 458
              inherited TagNameLabel: TLabel
                Left = 4
                Top = 7
                Width = 57
                Height = 17
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 7
                ExplicitWidth = 57
                ExplicitHeight = 17
              end
              inherited DscLabel: TLabel
                Left = 4
                Top = 69
                Width = 95
                Height = 17
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 69
                ExplicitWidth = 95
                ExplicitHeight = 17
              end
              inherited TheresholdLabel: TLabel
                Left = 4
                Top = 184
                Width = 52
                Height = 17
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 184
                ExplicitWidth = 52
                ExplicitHeight = 17
              end
              inherited DrawObjLabel: TLabel
                Left = 4
                Top = 124
                Width = 70
                Height = 17
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 124
                ExplicitWidth = 70
                ExplicitHeight = 17
              end
              inherited TagNameEdit: TEdit
                Left = 4
                Top = 31
                Width = 361
                Height = 25
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 31
                ExplicitWidth = 361
                ExplicitHeight = 25
              end
              inherited DscEdit: TEdit
                Left = 4
                Top = 94
                Width = 361
                Height = 25
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 94
                ExplicitWidth = 361
                ExplicitHeight = 25
              end
              inherited TheresholdsLV: TBtnListView
                Left = 4
                Top = 209
                Width = 361
                Height = 304
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 209
                ExplicitWidth = 361
                ExplicitHeight = 304
              end
              inherited DrawObjEdit: TEdit
                Left = 4
                Top = 149
                Width = 299
                Height = 25
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                ExplicitLeft = 4
                ExplicitTop = 149
                ExplicitWidth = 299
                ExplicitHeight = 25
              end
              inherited DrawObjSelectBtn: TButton
                Left = 311
                Top = 146
                Width = 54
                Height = 33
                Margins.Left = 4
                Margins.Top = 4
                Margins.Right = 4
                Margins.Bottom = 4
                OnClick = TagPropertiesFrame1DrawObjSelectBtnClick
                ExplicitLeft = 311
                ExplicitTop = 146
                ExplicitWidth = 54
                ExplicitHeight = 33
              end
              inherited ToolBar: TToolBar
                Top = 419
                Width = 371
                ExplicitTop = 419
                ExplicitWidth = 371
              end
            end
          end
        end
        inherited TagsMngGB: TGroupBox
          Top = 503
          Width = 836
          Height = 130
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          ExplicitTop = 503
          ExplicitWidth = 836
          ExplicitHeight = 130
          inherited TagNameLabel: TLabel
            Left = 10
            Top = 54
            Width = 189
            Height = 17
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 10
            ExplicitTop = 54
            ExplicitWidth = 189
            ExplicitHeight = 17
          end
          inherited LogTagsCheckBox: TCheckBox
            Left = 10
            Top = 21
            Width = 159
            Height = 22
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 10
            ExplicitTop = 21
            ExplicitWidth = 159
            ExplicitHeight = 22
          end
          inherited TagsBaseEdit: TEdit
            Left = 10
            Top = 78
            Width = 691
            Height = 25
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 10
            ExplicitTop = 78
            ExplicitWidth = 691
            ExplicitHeight = 25
          end
          inherited SelectTagsBaseBtn: TButton
            Left = 709
            Top = 78
            Width = 59
            Height = 28
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            ExplicitLeft = 709
            ExplicitTop = 78
            ExplicitWidth = 59
            ExplicitHeight = 28
          end
        end
      end
    end
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 738
    Width = 1206
    Height = 22
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    SmoothReverse = True
    TabOrder = 3
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
