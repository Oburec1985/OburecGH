object AlgEditFrame: TAlgEditFrame
  Left = 0
  Top = 0
  Width = 491
  Height = 416
  Align = alClient
  Constraints.MinHeight = 400
  Constraints.MinWidth = 491
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 455
    Top = 0
    Height = 416
    Color = clAppWorkSpace
    ParentColor = False
    ExplicitLeft = 24
    ExplicitTop = 168
    ExplicitHeight = 100
  end
  object CommonAlgOptsGB: TGroupBox
    Left = 0
    Top = 0
    Width = 455
    Height = 416
    Align = alLeft
    TabOrder = 0
    inline BaseAlgOptsFrame1: TBaseAlgOptsFrame
      Left = 2
      Top = 15
      Width = 451
      Height = 399
      Align = alClient
      Constraints.MinHeight = 399
      Constraints.MinWidth = 451
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 15
      ExplicitHeight = 399
      inherited CommonGB: TGroupBox
        inherited SelectSensorsBtn: TButton
          OnClick = BaseAlgOptsFrame1SelectSensorsBtnClick
        end
      end
      inherited TagsGB: TGroupBox
        Height = 206
        ExplicitHeight = 206
        inherited AlgTagList1: TAlgTagListFrame
          Height = 189
          ExplicitHeight = 189
          inherited TagListLV: TBtnListView
            Left = 0
            Height = 164
            ExplicitLeft = 0
            ExplicitHeight = 164
          end
        end
      end
    end
  end
  object SpecPropAlgGB: TGroupBox
    Left = 458
    Top = 0
    Width = 33
    Height = 416
    Align = alClient
    TabOrder = 1
  end
end
