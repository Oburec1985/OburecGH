unit uSaveSimpleMeraFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uWPNameFilterFrame, StdCtrls;

type
  TSaveSimpleMeraFrm = class(TForm)
    Panel1: TPanel;
    WPNameFltFrame1: TWPNameFltFrame;
    Panel2: TPanel;
    CancelBtn: TButton;
    OkBtn: TButton;
  private
    m_section,
    m_cfgpath:string;
  private
    procedure Load;
  public
    procedure Init(section,cfgpath:string);
    procedure Save;
    function Showmodal(sList:TSignalArray):integer;
  end;

var
  SaveSimpleMeraFrm: TSaveSimpleMeraFrm;

implementation

{$R *.dfm}

function TSaveSimpleMeraFrm.Showmodal(sList:TSignalArray):integer;
begin
  WPNameFltFrame1.setNames(sList);
  Result:=inherited Showmodal;
end;

procedure TSaveSimpleMeraFrm.Init(section,cfgpath:string);
begin
  m_section:=section;
  m_cfgpath:=cfgpath;
  load;
end;

procedure TSaveSimpleMeraFrm.Save;
begin
  WPNameFltFrame1.SaveCfg(m_section, m_cfgpath);
end;

procedure TSaveSimpleMeraFrm.Load;
begin
  WPNameFltFrame1.ReadCfg(m_section, m_cfgpath);
end;

end.
