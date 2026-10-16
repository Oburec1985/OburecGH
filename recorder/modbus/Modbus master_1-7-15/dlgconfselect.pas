unit dlgConfSelect;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, XMLRead, XMLWrite, dom, uXMLFunc;

type

  { TDlg_ConfSelect }

  TDlg_ConfSelect = class(TForm)
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    Panel1: TPanel;
    grd: TStringGrid;
    procedure FormShow(Sender: TObject);
  private
    function LoadConfigNames(fname: string): TStringList;

  public

  end;

var
  Dlg_ConfSelect: TDlg_ConfSelect;

implementation

{$R *.lfm}

uses UForm_Settings;

{ TDlg_ConfSelect }

procedure TDlg_ConfSelect.FormShow(Sender: TObject);
var
  i: integer;
  names: TStringList;
begin
  names := LoadConfigNames(SETTINGS_FNAME);

  grd.ColCount := 1;
  grd.ColWidths[0] := grd.Width - 5;
  grd.RowCount := names.Count;

  for i := 0 to names.Count - 1 do
    begin
    grd.Cells[0, i] := names[i];
    end;

  FreeAndNil(names);
end;



function Tdlg_ConfSelect.LoadConfigNames(fname: string): TStringList;
var
  names: TStringList;
  name_: string;
  i: integer;
  doc: TXMLDocument;
  root, confnode: TDOMNode;
  fs: TFileStream;
  cnflst: TDOMNodeList; //Коллекции узлов шин, устройств, тэгов
begin
  names := TStringList.Create;
  if not fileexists(fname) then Exit;

  doc := TXMLDocument.Create;
  fs := TFileStream.Create(fname, fmOpenRead);
  ReadXMLFile(doc, fs);
  FreeAndNil(fs);

  root := doc.documentElement;
  if Assigned(root) then
    begin
    cnflst := TDOMElement(root).GetElementsByTagName('Configuration');
    if Assigned(cnflst) then
      begin
      for i := 0 to cnflst.length - 1 do
        begin
        name_ := cnflst.item[i].attributes.getNamedItem('confname').nodeValue;
        names.Add(name_);
        end;
      end;
    end;
  FreeAndNil(doc);

  result := names;
end;

end.

