object ObjFrm3d: TObjFrm3d
  Left = 0
  Top = 0
  Caption = '3DFrm'
  ClientHeight = 300
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GL: cBaseGlComponent
    Left = 0
    Top = 0
    Width = 635
    Height = 169
    Align = alClient
    DockSite = True
    TabOrder = 0
    scenename = '.\files\scenes'
    resources = 
      'd:\Oburec\delphi\2011\OburecGH\recorder\plgControlCyclogram\file' +
      's\3d\resources.ini '
    ShowTrasforms = True
    OnInitScene = GLInitScene
  end
  object ToolsGB: TGroupBox
    Left = 0
    Top = 169
    Width = 635
    Height = 131
    Align = alBottom
    Caption = 'ToolsGB'
    TabOrder = 1
  end
end
