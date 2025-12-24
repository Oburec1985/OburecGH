object CompaundFrame: TCompaundFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 304
  Align = alClient
  TabOrder = 0
  object MainObjSB: TScrollBox
    Left = 0
    Top = 0
    Width = 451
    Height = 304
    Align = alClient
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 0
      Top = 274
      Width = 447
      Height = 3
      Cursor = crVSplit
      Align = alTop
      Constraints.MaxHeight = 4
      ExplicitWidth = 26
    end
    inline BaseObjPropertyFrame1: TBaseObjPropertyFrame
      Left = 0
      Top = 0
      Width = 447
      Height = 274
      Align = alTop
      Constraints.MinHeight = 64
      Constraints.MinWidth = 293
      TabOrder = 0
      TabStop = True
      Visible = False
      ExplicitWidth = 447
      ExplicitHeight = 274
      DesignSize = (
        447
        274)
      inherited TypeLabel: TLabel
        Left = 152
        ExplicitLeft = 152
      end
      inherited TypeImage: TImage
        Left = 279
        ExplicitLeft = 279
      end
      inherited NameEdit: TEdit
        Height = 24
        ExplicitHeight = 24
      end
      inherited TypeEdit: TEdit
        Left = 152
        Height = 24
        ExplicitLeft = 152
        ExplicitHeight = 24
      end
      inherited MetaDataLV: TBtnListView
        Width = 972
        Height = 320
        ExplicitWidth = 821
        ExplicitHeight = 320
      end
    end
    inline ChanFrame1: TChanFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 23
      Align = alClient
      TabOrder = 1
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited CommonGB: TGroupBox
        Width = 598
        Height = 90
        ExplicitWidth = 447
        ExplicitHeight = 23
        inherited ChanLVLabel: TLabel
          Left = 152
          ExplicitLeft = 152
        end
        inherited ImpulsCountIE: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited ChanLV: TBtnListView
          Left = 153
          Width = 410
          Height = 68
          ExplicitLeft = 153
          ExplicitWidth = 259
          ExplicitHeight = 1
        end
        inherited TickEdit: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited ResIndEdit: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited OverflowIE: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
      end
    end
    inline SensorFrame1: TSensorFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 23
      Align = alClient
      Constraints.MinWidth = 265
      TabOrder = 2
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited SensorsGB: TGroupBox
        Top = -243
        Width = 447
        Align = alBottom
        ExplicitTop = -243
        ExplicitWidth = 447
        inherited OffsetFE: TFloatEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited ChunIE: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited StateGB: TGroupBox
          Width = 443
          ExplicitWidth = 443
          inherited StageCB: TComboBox
            Top = 36
            ExplicitTop = 36
          end
          inherited PairsListView: TBtnListView
            Top = 36
            Width = 1332
            ExplicitTop = 36
            ExplicitWidth = 1181
          end
        end
        inherited TickCountIE: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited SkipBladeIE: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited TahoDivEdit: TEdit
          Height = 24
          ExplicitHeight = 24
        end
      end
    end
    inline StageFrame1: TStageFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 23
      Align = alClient
      Constraints.MinWidth = 265
      TabOrder = 3
      TabStop = True
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited StageGB: TGroupBox
        Width = 447
        Height = 23
        ExplicitWidth = 447
        ExplicitHeight = 23
        inherited SignalSetupPageControl: TPageControl
          Width = 443
          Height = 3
          ExplicitWidth = 443
          ExplicitHeight = 3
          inherited TabSheet1: TTabSheet
            ExplicitWidth = 435
            inherited Splitter2: TSplitter
              Left = 316
              ExplicitLeft = 472
              ExplicitHeight = 234
            end
            inherited BladesGB: TGroupBox
              Left = 0
              ExplicitLeft = 0
              ExplicitHeight = 9
              inherited Splitter1: TSplitter
                Height = 1
                ExplicitLeft = 140
                ExplicitHeight = 238
              end
              inherited BladesLV: TBtnListView
                Height = 1
                ExplicitHeight = 1
              end
            end
            inherited ShapeGB: TGroupBox
              Width = 113
              ExplicitWidth = 113
              ExplicitHeight = 9
              inherited ShapeLV: TBtnListView
                Width = 257
                Height = 1
                ExplicitWidth = 109
                ExplicitHeight = 233
              end
            end
            inherited StagePropertysGB: TGroupBox
              Left = 147
              ExplicitLeft = 147
            end
          end
          inherited TabSheet2: TTabSheet
            inherited SensorsGB: TGroupBox
              Width = 439
              Height = 253
              inherited SensorsSG: TStringGrid
                Width = 435
                Height = 233
              end
            end
          end
        end
      end
    end
    inline TurbineFrame1: TTurbineFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 23
      Align = alClient
      Constraints.MinWidth = 265
      TabOrder = 4
      TabStop = True
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited TurbinePropGB: TGroupBox
        Width = 447
        Height = 23
        ExplicitWidth = 447
        ExplicitHeight = 23
        inherited StageCountIE: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited CfgTV: TTreeView
          Width = 836
          ExplicitWidth = 836
        end
        inherited RecentFileEdit: TEdit
          Width = 977
          Height = 24
          ExplicitWidth = 826
          ExplicitHeight = 24
        end
      end
    end
    inline PairFrame1: TPairFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 23
      Align = alClient
      Constraints.MinWidth = 265
      TabOrder = 5
      TabStop = True
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited PairGB: TGroupBox
        Width = 447
        Height = 23
        ExplicitWidth = 447
        ExplicitHeight = 23
        DesignSize = (
          447
          23)
        inherited SensorsLV: TBtnListView
          Top = 63
          Width = 979
          Height = 349
          ExplicitTop = 63
          ExplicitWidth = 828
          ExplicitHeight = 282
        end
        inherited BladeLeftIE: TIntEdit
          Height = 24
          ExplicitHeight = 24
        end
        inherited BaseFE: TFloatEdit
          Height = 24
          ExplicitHeight = 24
        end
      end
    end
    inline UTSFrame1: TUTSFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 23
      Align = alClient
      TabOrder = 6
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited UTSLV: TBtnListView
        Height = 345
        ExplicitHeight = 278
      end
    end
    inline Platframe1: TPlatframe
      Left = 0
      Top = 277
      Width = 447
      Height = 23
      Align = alClient
      TabOrder = 7
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited PeriodSE: TFloatSpinEdit
        Height = 26
        ExplicitHeight = 26
      end
      inherited FreqFE: TFloatSpinEdit
        Height = 26
        ExplicitHeight = 26
      end
    end
  end
end
