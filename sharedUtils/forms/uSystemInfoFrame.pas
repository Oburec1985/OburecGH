unit uSystemInfoFrame;

interface

uses
  Windows, Classes, Graphics, Forms, StdCtrls, DCL_MYOWN, uPlatformInfo,
  Controls, ExtCtrls, ComCtrls, uBtnListView, uEventList;

type
  TSystemInfoFrame = class(TFrame)
    CommonInfoGB: TGroupBox;
    MemoryUseLabel: TLabel;
    kByteLabel: TLabel;
    CPULabel: TLabel;
    PercentLabel2: TLabel;
    CPUIE: TIntEdit;
    MemoryUseFE: TFloatEdit;
    OsVersionLabel: TLabel;
    Splitter1: TSplitter;
    GlGB: TGroupBox;
    GLExtGB: TGroupBox;
    ExtListView: TListView;
    CommonGlInfoGB: TGroupBox;
    GLLabel: TLabel;
    GlVisibleCheckBox: TCheckBox;
    Button1: TButton;
    procedure GlVisibleCheckBoxClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    plInfo:cPlatform;
  private
    procedure showOsinfo;
    procedure showGlInfo;
    // событие по которому происходит обновление общей информации ()
    procedure updateOsinfo(sender:tobject);
  public
    procedure lincevents(e:ceventlist;eventtype:cardinal);
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

implementation

{$R *.dfm}

procedure TSystemInfoFrame.GlVisibleCheckBoxClick(Sender: TObject);
begin
  GlGB.Visible:=GlVisibleCheckBox.Checked;
end;

procedure TSystemInfoFrame.Button1Click(Sender: TObject);
begin
  updateOsinfo(nil);
end;

constructor TSystemInfoFrame.create(aowner:tcomponent);
begin
  inherited;
  showGlInfo;
  showOsinfo;
  plInfo:=cPlatform.create;
end;

destructor TSystemInfoFrame.destroy;
begin
  plInfo.destroy;
  inherited;
end;

procedure TSystemInfoFrame.showOsinfo;
begin
  OsVersionLabel.Caption:=GetOsVersion;
  updateOsinfo(nil);
end;

procedure TSystemInfoFrame.updateOsinfo(sender:tobject);
begin
  // отобразить потери памяти на процесс
  MemoryUseFE.FloatNum:=GetProcMem;
end;

procedure TSystemInfoFrame.showGlInfo;
begin
  gllabel.Caption:=GetGlVersion;
  // отобразить поддерживаемые расширения ogl
  plInfo.ShowExtInListView(ExtListView);
end;

procedure TSystemInfoFrame.lincevents(e:ceventlist;eventtype:cardinal);
begin
  e.AddEvent(name+' UpdataOsInfo', eventtype, updateOsinfo);
end;

end.
