object CreateObjDlg: TCreateObjDlg
  Left = 0
  Top = 0
  Width = 720
  Height = 769
  AutoScroll = True
  Caption = 'CreateObjDlg'
  Color = clBtnFace
  Constraints.MinWidth = 178
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 297
    Top = 0
    Width = 5
    Height = 682
    Color = clGray
    ParentColor = False
    ExplicitHeight = 587
  end
  object SelectObjTypeGB: TGroupBox
    Left = 0
    Top = 0
    Width = 297
    Height = 682
    Align = alLeft
    Caption = #1042#1099#1073#1086#1088' '#1057#1086#1079#1076#1072#1074#1072#1077#1084#1086#1075#1086' '#1086#1073#1098#1077#1082#1090#1072
    TabOrder = 0
    object PossibleObjLV: TListBox
      Left = 2
      Top = 15
      Width = 293
      Height = 665
      Align = alClient
      ItemHeight = 13
      Items.Strings = (
        #1058#1091#1088#1073#1080#1085#1072
        #1057#1090#1091#1087#1077#1085#1100
        #1055#1072#1088#1072' '#1076#1072#1090#1095#1080#1082#1086#1074
        #1044#1072#1090#1095#1080#1082
        #1050#1072#1085#1072#1083' '#1087#1083#1072#1090#1099
        'M2070'
        'M2081')
      TabOrder = 0
      OnClick = PossibleObjLVClick
    end
  end
  object UserBtnGB: TGroupBox
    Left = 0
    Top = 682
    Width = 712
    Height = 53
    Align = alBottom
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
    TabOrder = 1
    ExplicitWidth = 805
    DesignSize = (
      712
      53)
    object CancelBtn: TButton
      Left = 3
      Top = 20
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 0
    end
    object OkBtn: TButton
      Left = 634
      Top = 20
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      ModalResult = 1
      TabOrder = 1
      ExplicitLeft = 727
    end
  end
  object ObjPropertyGB: TGroupBox
    Left = 302
    Top = 0
    Width = 410
    Height = 682
    Align = alClient
    Caption = 'ObjPropertyGB'
    TabOrder = 2
    ExplicitWidth = 503
    inline CompaundFrame1: TCompaundFrame
      Left = 2
      Top = 15
      Width = 406
      Height = 665
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitWidth = 499
      ExplicitHeight = 665
      inherited MainObjSB: TScrollBox
        Width = 406
        Height = 665
        ExplicitWidth = 499
        ExplicitHeight = 665
        inherited Splitter1: TSplitter
          Width = 402
          ExplicitWidth = 495
        end
        inherited BaseObjPropertyFrame1: TBaseObjPropertyFrame
          Width = 402
          ExplicitWidth = 495
          inherited MetaDataLV: TBtnListView
            Width = 728
            ExplicitWidth = 821
          end
        end
        inherited ChanFrame1: TChanFrame
          Width = 402
          Height = 384
          ExplicitWidth = 495
          ExplicitHeight = 384
          inherited CommonGB: TGroupBox
            Width = 402
            Height = 384
            ExplicitWidth = 495
            ExplicitHeight = 384
            inherited ChanLV: TBtnListView
              Left = 136
              Width = 263
              Height = 333
              ExplicitLeft = 136
              ExplicitWidth = 356
              ExplicitHeight = 333
            end
          end
        end
        inherited SensorFrame1: TSensorFrame
          Width = 402
          Height = 384
          ExplicitWidth = 495
          ExplicitHeight = 384
          inherited SensorsGB: TGroupBox
            Top = 118
            Width = 402
            ExplicitTop = 118
            ExplicitWidth = 495
            inherited StateGB: TGroupBox
              Width = 398
              ExplicitWidth = 491
              inherited PairsListView: TBtnListView
                Top = 40
                Width = 456
                ExplicitTop = 40
                ExplicitWidth = 549
              end
            end
          end
        end
        inherited StageFrame1: TStageFrame
          Width = 402
          Height = 384
          ExplicitWidth = 495
          ExplicitHeight = 384
          inherited StageGB: TGroupBox
            Width = 402
            Height = 384
            ExplicitWidth = 495
            ExplicitHeight = 384
            inherited SignalSetupPageControl: TPageControl
              Width = 398
              Height = 367
              ExplicitWidth = 491
              ExplicitHeight = 367
              inherited TabSheet1: TTabSheet
                ExplicitWidth = 483
                ExplicitHeight = 339
                inherited Splitter2: TSplitter
                  Height = 339
                  ExplicitHeight = 552
                end
                inherited BladesGB: TGroupBox
                  Height = 339
                  ExplicitHeight = 339
                  inherited Splitter1: TSplitter
                    Height = 322
                    ExplicitHeight = 535
                  end
                  inherited BladesLV: TBtnListView
                    Height = 322
                    ExplicitHeight = 322
                  end
                end
                inherited ShapeGB: TGroupBox
                  Width = 68
                  Height = 339
                  ExplicitWidth = 161
                  ExplicitHeight = 339
                  inherited ShapeLV: TBtnListView
                    Width = 64
                    Height = 322
                    ExplicitWidth = 157
                    ExplicitHeight = 322
                  end
                end
                inherited StagePropertysGB: TGroupBox
                  Height = 339
                  ExplicitHeight = 339
                end
              end
            end
          end
        end
        inherited TurbineFrame1: TTurbineFrame
          Width = 402
          Height = 384
          ExplicitWidth = 495
          ExplicitHeight = 384
          inherited TurbinePropGB: TGroupBox
            Width = 402
            Height = 384
            ExplicitWidth = 495
            ExplicitHeight = 384
            inherited CfgTV: TTreeView
              Width = 254
              ExplicitWidth = 347
            end
            inherited RecentFileEdit: TEdit
              Width = 254
              ExplicitWidth = 347
            end
          end
        end
        inherited PairFrame1: TPairFrame
          Width = 402
          Height = 384
          ExplicitWidth = 495
          ExplicitHeight = 384
          inherited PairGB: TGroupBox
            Width = 402
            Height = 384
            ExplicitWidth = 495
            ExplicitHeight = 384
            inherited SensorsLV: TBtnListView
              Top = 66
              Width = 397
              ExplicitTop = 66
              ExplicitWidth = 490
            end
          end
        end
        inherited UTSFrame1: TUTSFrame
          Width = 402
          Height = 384
          ExplicitWidth = 495
          ExplicitHeight = 384
        end
        inherited Platframe1: TPlatframe
          Width = 402
          Height = 384
          ExplicitTop = 299
          ExplicitWidth = 383
          ExplicitHeight = 362
        end
      end
    end
  end
end
