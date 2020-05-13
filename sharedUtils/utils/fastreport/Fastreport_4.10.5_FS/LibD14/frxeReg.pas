
{******************************************}
{                                          }
{             FastReport v4.0              }
{         Exports Registration unit        }
{                                          }
{         Copyright (c) 1998-2008          }
{          by Alexander Fediachov,         }
{             Fast Reports Inc.            }
{                                          }
{******************************************}

unit frxeReg;

{$I frx.inc}

interface


procedure Register;

implementation

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
{$IFNDEF Delphi6}
  DsgnIntf,
{$ELSE}
  DesignIntf, DesignEditors,
{$ENDIF}
  frxExportXML, frxExportHTML, frxExportXLS, {$IFNDEF Delphi12}frxExportTXT, {$ENDIF}frxExportImage, 
  frxExportRTF, frxExportPDF, frxExportText, frxExportCSV, frxExportMail,
  frxExportODF, frxExportDBF;

{-----------------------------------------------------------------------}

procedure Register;
begin
  RegisterComponents('FastReport 4 exports',
    [TfrxPDFExport, TfrxHTMLExport, TfrxXLSExport,
    TfrxXMLExport, TfrxRTFExport, TfrxBMPExport, TfrxJPEGExport,
    TfrxTIFFExport, TfrxGIFExport, TfrxSimpleTextExport, 
    TfrxCSVExport, TfrxMailExport, {$IFNDEF Delphi12}TfrxTXTExport, {$ENDIF}TfrxODSExport, TfrxODTExport,   TfrxDBFExport ]);
end;

end.
