object ObjInterfaceFrame: TObjInterfaceFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    TabOrder = 0
    object MainObjGB: TGroupBox
      Left = 0
      Top = 0
      Width = 447
      Height = 251
      Align = alClient
      Caption = #1043#1083#1072#1074#1085#1099#1081' '#1086#1073#1098#1077#1082#1090
      TabOrder = 0
      inline MainObjFrame: TCompaundFrame
        Left = 2
        Top = 15
        Width = 443
        Height = 234
        Align = alClient
        TabOrder = 0
        ExplicitLeft = 2
        ExplicitTop = 15
        ExplicitWidth = 443
        ExplicitHeight = 234
        inherited MainObjSB: TScrollBox
          Width = 443
          Height = 234
          ExplicitWidth = 443
          ExplicitHeight = 234
          inherited Splitter1: TSplitter
            Width = 422
            ExplicitWidth = 723
          end
          inherited BaseObjPropertyFrame1: TBaseObjPropertyFrame
            Width = 422
            ExplicitWidth = 422
            inherited MetaDataLV: TBtnListView
              Width = 1689
              ExplicitWidth = 1689
            end
          end
          inherited ChanFrame1: TChanFrame
            Width = 422
            Height = 0
            ExplicitWidth = 422
            ExplicitHeight = 0
            inherited CommonGB: TGroupBox
              Width = 422
              Height = 0
              ExplicitWidth = 422
              ExplicitHeight = 0
              inherited ChanLV: TBtnListView
                Width = 360
                ExplicitWidth = 360
              end
            end
          end
          inherited SensorFrame1: TSensorFrame
            Width = 422
            Height = 0
            ExplicitWidth = 422
            ExplicitHeight = 0
            inherited SensorsGB: TGroupBox
              Top = -266
              Width = 422
              ExplicitTop = -266
              ExplicitWidth = 422
              inherited StateGB: TGroupBox
                Width = 418
                ExplicitWidth = 418
                inherited PairsListView: TBtnListView
                  Width = 1916
                  ExplicitWidth = 1916
                end
              end
            end
          end
          inherited StageFrame1: TStageFrame
            Width = 422
            Height = 0
            ExplicitWidth = 422
            ExplicitHeight = 0
            inherited StageGB: TGroupBox
              Width = 422
              Height = 0
              ExplicitWidth = 422
              ExplicitHeight = 0
              inherited SignalSetupPageControl: TPageControl
                Width = 418
                Height = 100
                ExplicitWidth = 418
                ExplicitHeight = 100
                inherited TabSheet1: TTabSheet
                  ExplicitWidth = 410
                  ExplicitHeight = 72
                  inherited Splitter2: TSplitter
                    Left = 147
                    Height = 72
                    ExplicitLeft = 100
                    ExplicitHeight = 116
                  end
                  inherited BladesGB: TGroupBox
                    Height = 72
                    ExplicitHeight = 72
                    inherited Splitter1: TSplitter
                      Height = 55
                      ExplicitLeft = 440
                      ExplicitHeight = 99
                    end
                    inherited BladesLV: TBtnListView
                      Height = 55
                      ExplicitHeight = 55
                    end
                  end
                  inherited ShapeGB: TGroupBox
                    Width = 88
                    Height = 72
                    ExplicitWidth = 88
                    ExplicitHeight = 72
                    inherited ShapeLV: TBtnListView
                      Width = 84
                      Height = 55
                      ExplicitWidth = 84
                      ExplicitHeight = 55
                    end
                  end
                  inherited StagePropertysGB: TGroupBox
                    Left = 153
                    Height = 72
                    ExplicitLeft = 153
                    ExplicitHeight = 72
                  end
                end
              end
            end
          end
          inherited TurbineFrame1: TTurbineFrame
            Width = 422
            Height = 0
            Visible = True
            ExplicitWidth = 422
            ExplicitHeight = 0
            inherited TurbinePropGB: TGroupBox
              Width = 422
              Height = 0
              ExplicitWidth = 422
              ExplicitHeight = 0
              inherited CfgTV: TTreeView
                Width = 2062
                ExplicitWidth = 2062
              end
              inherited RecentFileEdit: TEdit
                Width = 2062
                ExplicitWidth = 2062
              end
            end
          end
          inherited PairFrame1: TPairFrame
            Width = 422
            Height = 0
            ExplicitWidth = 422
            ExplicitHeight = 0
            inherited PairGB: TGroupBox
              Width = 422
              Height = 0
              ExplicitWidth = 422
              ExplicitHeight = 0
              DesignSize = (
                422
                0)
              inherited SensorsLV: TBtnListView
                Width = 1280
                Height = 174
                ExplicitWidth = 1280
                ExplicitHeight = 174
              end
            end
          end
          inherited UTSFrame1: TUTSFrame
            Width = 422
            Height = 0
            ExplicitWidth = 422
            ExplicitHeight = 0
            inherited UTSLV: TBtnListView
              Height = 94
              ExplicitHeight = 94
            end
          end
          inherited Platframe1: TPlatframe
            Width = 422
            Height = 0
            ExplicitWidth = 422
            ExplicitHeight = 0
          end
        end
      end
    end
    object SelectActionGB: TGroupBox
      Left = 0
      Top = 251
      Width = 447
      Height = 49
      Align = alBottom
      Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1076#1077#1081#1089#1090#1074#1080#1077
      TabOrder = 1
      DesignSize = (
        447
        49)
      object CancelBtn: TButton
        Left = 8
        Top = 19
        Width = 75
        Height = 25
        Caption = #1054#1090#1084#1077#1085#1072
        TabOrder = 0
      end
      object ApplyBtn: TButton
        Left = 369
        Top = 21
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
        TabOrder = 1
        OnClick = ApplyBtnClick
      end
    end
  end
end
