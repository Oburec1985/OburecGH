object CompaundFrame: TCompaundFrame
  Left = 0
  Top = 0
  Width = 451
  Height = 581
  Align = alClient
  TabOrder = 0
  ExplicitHeight = 304
  object MainObjSB: TScrollBox
    Left = 0
    Top = 0
    Width = 451
    Height = 581
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 304
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
      inherited TypeEdit: TEdit
        Left = 152
        ExplicitLeft = 152
      end
      inherited MetaDataLV: TBtnListView
        Width = 821
        Height = 320
        ExplicitWidth = 821
        ExplicitHeight = 320
      end
    end
    inline ChanFrame1: TChanFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 300
      Align = alClient
      TabOrder = 1
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited CommonGB: TGroupBox
        Width = 447
        Height = 300
        ExplicitWidth = 447
        ExplicitHeight = 23
        inherited ChanLVLabel: TLabel
          Left = 152
          ExplicitLeft = 152
        end
        inherited ChanLV: TBtnListView
          Left = 153
          Width = 259
          Height = 278
          ExplicitLeft = 153
          ExplicitWidth = 259
          ExplicitHeight = 1
        end
      end
    end
    inline SensorFrame1: TSensorFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 300
      Align = alClient
      Constraints.MinWidth = 265
      TabOrder = 2
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited SensorsGB: TGroupBox
        Top = 34
        Width = 447
        Align = alBottom
        ExplicitTop = -243
        ExplicitWidth = 447
        inherited StateGB: TGroupBox
          Width = 443
          ExplicitWidth = 443
          inherited StageCB: TComboBox
            Top = 36
            ExplicitTop = 36
          end
          inherited PairsListView: TBtnListView
            Top = 36
            Width = 1181
            ExplicitTop = 36
            ExplicitWidth = 1181
          end
        end
      end
    end
    inline StageFrame1: TStageFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 300
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
        Height = 300
        ExplicitWidth = 447
        ExplicitHeight = 23
        inherited SignalSetupPageControl: TPageControl
          Width = 443
          Height = 283
          ExplicitWidth = 443
          ExplicitHeight = 6
          inherited TabSheet1: TTabSheet
            ExplicitWidth = 435
            inherited Splitter2: TSplitter
              Left = 316
              Height = 255
              ExplicitLeft = 472
              ExplicitHeight = 234
            end
            inherited BladesGB: TGroupBox
              Left = 0
              Height = 255
              ExplicitLeft = 0
              inherited Splitter1: TSplitter
                Height = 238
                ExplicitLeft = 812
                ExplicitHeight = 234
              end
              inherited BladesLV: TBtnListView
                Height = 238
              end
            end
            inherited ShapeGB: TGroupBox
              Width = 113
              Height = 255
              ExplicitWidth = 113
              inherited ShapeLV: TBtnListView
                Width = 109
                Height = 238
                ExplicitWidth = 109
              end
            end
            inherited StagePropertysGB: TGroupBox
              Left = 147
              Height = 255
              ExplicitLeft = 147
            end
          end
          inherited TabSheet2: TTabSheet
            ExplicitLeft = 4
            ExplicitTop = 24
            ExplicitWidth = 439
            ExplicitHeight = 259
            inherited SensorsGB: TGroupBox
              Height = 259
              ExplicitHeight = 259
              inherited SensorsSG: TStringGrid
                Height = 242
                ExplicitHeight = 242
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
      Height = 300
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
        Height = 300
        ExplicitWidth = 447
        ExplicitHeight = 23
        inherited CfgTV: TTreeView
          Width = 685
          ExplicitWidth = 685
        end
        inherited RecentFileEdit: TEdit
          Width = 826
          ExplicitWidth = 826
        end
      end
    end
    inline PairFrame1: TPairFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 300
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
        Height = 300
        ExplicitWidth = 447
        ExplicitHeight = 23
        DesignSize = (
          447
          300)
        inherited SensorsLV: TBtnListView
          Top = 63
          Width = 828
          Height = 282
          ExplicitTop = 63
          ExplicitWidth = 828
          ExplicitHeight = 5
        end
      end
    end
    inline UTSFrame1: TUTSFrame
      Left = 0
      Top = 277
      Width = 447
      Height = 300
      Align = alClient
      TabOrder = 6
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
      inherited UTSLV: TBtnListView
        Height = 278
        ExplicitHeight = 1
      end
    end
    inline Platframe1: TPlatframe
      Left = 0
      Top = 277
      Width = 447
      Height = 300
      Align = alClient
      TabOrder = 7
      Visible = False
      ExplicitTop = 277
      ExplicitWidth = 447
      ExplicitHeight = 23
    end
  end
end
