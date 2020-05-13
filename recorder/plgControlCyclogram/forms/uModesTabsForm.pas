unit uModesTabsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uModesTabsFrame, ExtCtrls, uControlObj, uModesStepFrame;

type
  TModesTabForm = class(TForm)
    ActionPanel: TPanel;
    ModesTabFrame1: TModesTabFrame;
    Splitter1: TSplitter;
    ModesStepFrame1: TModesStepFrame;
  private
    m_mng:cControlMng;
  public
    procedure LinkMng(m:cControlMng);
    procedure Show(p:cProgramObj);
    destructor destroy;override;
  end;

var
  ModesTabForm: TModesTabForm;

implementation

{$R *.dfm}

{ TModesTabForm }

destructor TModesTabForm.destroy;
begin
  ModesTabFrame1.Destroy;
  ModesTabFrame1:=nil;
  ModesStepFrame1.Destroy;
  ModesStepFrame1:=nil;
  inherited;
end;

procedure TModesTabForm.LinkMng(m: cControlMng);
begin
  m_mng:=m;
  if m=nil then exit;
  
  ModesTabFrame1.m_stepframe:=ModesStepFrame1;
end;

procedure TModesTabForm.Show(p: cProgramObj);
begin
  ModesTabFrame1.ShowProgram(p);
  ModesStepFrame1.ShowProgram(p);
  //FormStyle:=fsStayOnTop;
  inherited show;
end;

end.
