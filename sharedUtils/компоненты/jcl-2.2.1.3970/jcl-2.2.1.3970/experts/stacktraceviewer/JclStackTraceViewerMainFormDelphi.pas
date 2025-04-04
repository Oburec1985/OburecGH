{**************************************************************************************************}
{                                                                                                  }
{ Project JEDI Code Library (JCL)                                                                  }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is JclStackTraceViewerMainFormDelphi.pas.                                      }
{                                                                                                  }
{ The Initial Developer of the Original Code is Uwe Schuster.                                      }
{ Portions created by Uwe Schuster are Copyright (C) 2009 Uwe Schuster. All rights reserved.       }
{                                                                                                  }
{ Contributor(s):                                                                                  }
{   Uwe Schuster (uschuster)                                                                       }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2009-08-25 20:22:46 +0200 (mar., 25 août 2009)                         $ }
{ Revision:      $Rev:: 2969                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclStackTraceViewerMainFormDelphi;

{$I jcl.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Docktoolform, StdCtrls, ComCtrls, Menus,
  ActnList, ToolWin, ExtCtrls, IniFiles,
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  JclStackTraceViewerOptions, JclStackTraceViewerMainFrame;

type
  TfrmStackView = class(TDockableToolbarForm)
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    MainFrame: TfrmMain;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetOptions(const Value: TExceptionViewerOption);
    function GetOptions: TExceptionViewerOption;
  public
    { Public declarations }
    procedure LoadWindowState(ADesktop: TMemIniFile); override;
    procedure SaveWindowState(ADesktop: TMemIniFile; AIsProject: Boolean); override;
    property Options: TExceptionViewerOption read GetOptions write SetOptions;
  end;

var
  frmStackView: TfrmStackView;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net:443/svnroot/jcl/tags/JCL-2.2-Build3970/jcl/experts/stacktraceviewer/JclStackTraceViewerMainFormDelphi.pas $';
    Revision: '$Revision: 2969 $';
    Date: '$Date: 2009-08-25 20:22:46 +0200 (mar., 25 août 2009) $';
    LogPath: 'JCL\experts\stacktraceviewer';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  JclOtaConsts,
  JclStackTraceViewerImpl;

{$R *.dfm}

{ TfrmStackView }

procedure TfrmStackView.FormCreate(Sender: TObject);
begin
  inherited;
  DeskSection := JclStackTraceViewerDesktopIniSection;
  AutoSave := True;
  if Assigned(StackTraceViewerExpert) then
    Icon := StackTraceViewerExpert.Icon;
end;

function TfrmStackView.GetOptions: TExceptionViewerOption;
begin
  Result := MainFrame.Options;
end;

procedure TfrmStackView.LoadWindowState(ADesktop: TMemIniFile);
begin
  inherited LoadWindowState(ADesktop);
  if Assigned(ADesktop) then
    MainFrame.LoadWindowState(ADesktop);
end;

procedure TfrmStackView.SaveWindowState(ADesktop: TMemIniFile; AIsProject: Boolean);
begin
  inherited SaveWindowState(ADesktop, AIsProject);
  if SaveStateNecessary and Assigned(ADesktop) then
    MainFrame.SaveWindowState(ADesktop, AIsProject);
end;

procedure TfrmStackView.SetOptions(const Value: TExceptionViewerOption);
begin
  MainFrame.Options := Value;
end;

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.