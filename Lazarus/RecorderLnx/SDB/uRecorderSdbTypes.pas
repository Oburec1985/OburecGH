unit uRecorderSdbTypes;

{
  SDB (Scales DataBase) types — native Lazarus port of original Recorder COM SDB.
  Data lives under {Mera Files}\SDB\sdb.xml and folder/scale .xml + .csv pairs.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils;

const
  CSdbDescriptorFile = 'sdb.xml';
  CSdbInterpolateModuleId = '{42622BC6-8725-4EA7-9709-A96F1F382DC0}';

type
  TSdbItemKind = (sikRoot, sikFolder, sikScale);

  TSdbItemState = (sisNormal, sisLink, sisFixed);

  TSdbViewerStyle = (
    svsCloseButton,
    svsSelectCancel,
    svsSelScale,
    svsSelFolder,
    svsSelRoot
  );

  TSdbViewerStyles = set of TSdbViewerStyle;

  TSdbScaleInfo = record
    Key: string;
    Name: string;
    Description: string;
    SrcFrom: Double;
    SrcTo: Double;
    DstFrom: Double;
    DstTo: Double;
    SrcUnits: string;
    DstUnits: string;
    ModuleId: string;
    State: Integer;
    ModTime: string;
    XmlPath: string;
    CsvPath: string;
  end;

  TSdbFolderInfo = record
    Key: string;
    Name: string;
    Description: string;
    XmlPath: string;
  end;

function SdbViewerStyleToSet(ACloseButton, ASelectCancel, ASelScale, ASelFolder,
  ASelRoot: Boolean): TSdbViewerStyles;

implementation

function SdbViewerStyleToSet(ACloseButton, ASelectCancel, ASelScale, ASelFolder,
  ASelRoot: Boolean): TSdbViewerStyles;
begin
  Result := [];
  if ACloseButton then Include(Result, svsCloseButton);
  if ASelectCancel then Include(Result, svsSelectCancel);
  if ASelScale then Include(Result, svsSelScale);
  if ASelFolder then Include(Result, svsSelFolder);
  if ASelRoot then Include(Result, svsSelRoot);
end;

end.
