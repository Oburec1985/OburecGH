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
{ The Original Code is: JvSIMDCPUInfo.pas, released on 2005-05-09.                                 }
{                                                                                                  }
{ The Initial Developer of the Original Code is Florent Ouchet                                     }
{ [ouchet dott florent att laposte dott net]                                                       }
{ Portions created by Florent Ouchet are Copyright (C) 2004 Florent Ouchet.                        }
{ All Rights Reserved.                                                                             }
{                                                                                                  }
{ You may retrieve the latest version of this file at the Project JEDI's JCL home page,            }
{ located at http://jcl.sourceforge.net                                                            }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2009-09-14 18:00:50 +0200 (lun., 14 sept. 2009)                         $ }
{ Revision:      $Rev:: 3012                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclSIMDCpuInfo;

interface

{$I jcl.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  JclSysInfo;

type
  TJclFormCpuInfo = class(TForm)
    LabelName: TLabel;
    EditName: TEdit;
    LabelVendor: TLabel;
    EditVendor: TEdit;
    LabelFrequency: TLabel;
    EditFrequency: TEdit;
    CheckBoxMMX: TCheckBox;
    CheckBoxExMMX: TCheckBox;
    CheckBox3DNow: TCheckBox;
    CheckBoxEx3DNow: TCheckBox;
    CheckBox64Bits: TCheckBox;
    CheckBoxSSE1: TCheckBox;
    CheckBoxSSE2: TCheckBox;
    CheckBoxSSE3: TCheckBox;
    ButtonClose: TButton;
    CheckBoxSSSE3: TCheckBox;
    CheckBoxSSE4A: TCheckBox;
    CheckBoxSSE5: TCheckBox;
    CheckBoxSSE4B: TCheckBox;
    CheckBoxAVX: TCheckBox;
    CheckBoxEnabledFPU: TCheckBox;
    CheckBoxEnabledSSE: TCheckBox;
    CheckBoxEnabledAVX: TCheckBox;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    procedure Execute(const CpuInfo: TCPUInfo; const EnabledFeatures: TOSEnabledFeatures);
  end;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net:443/svnroot/jcl/tags/JCL-2.2-Build3970/jcl/experts/debug/simdview/JclSIMDCpuInfo.pas $';
    Revision: '$Revision: 3012 $';
    Date: '$Date: 2009-09-14 18:00:50 +0200 (lun., 14 sept. 2009) $';
    LogPath: 'JCL\experts\debug\simdview';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}

implementation

{$R *.dfm}

uses
  JclOtaResources;

//=== { TJclFormCpuInfo } ====================================================

procedure TJclFormCpuInfo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  // Fixing the Window Ghosting "bug"
  Params.Style := params.Style or WS_POPUP;
  if Assigned(Screen.ActiveForm) then
    Params.WndParent := Screen.ActiveForm.Handle
  else if Assigned (Application.MainForm) then
    Params.WndParent := Application.MainForm.Handle
  else
    Params.WndParent := Application.Handle;
end;

procedure TJclFormCpuInfo.Execute(const CpuInfo: TCPUInfo; const EnabledFeatures: TOSEnabledFeatures);
begin
  Caption := LoadResString(@RsCpuInfoTitle);
  LabelName.Caption := LoadResString(@RsName);
  LabelVendor.Caption := LoadResString(@RsVendor);
  LabelFrequency.Caption := LoadResString(@RsFrequency);
  CheckBoxMMX.Caption := LoadResString(@RsMMX);
  CheckBoxExMMX.Caption := LoadResString(@RsMMXExt);
  CheckBox3DNow.Caption := LoadResString(@Rs3DNow);
  CheckBoxEx3DNow.Caption := LoadResString(@Rs3DNowExt);
  CheckBox64Bits.Caption := LoadResString(@RsLong);
  CheckBoxEnabledFPU.Caption := LoadResString(@RsEnabledFPU);
  CheckBoxEnabledSSE.Caption := LoadResString(@RsEnabledSSE);
  CheckBoxEnabledAVX.Caption := LoadResString(@RsEnabledAVX);
  CheckBoxSSE1.Caption := LoadResString(@RsSSE1);
  CheckBoxSSE2.Caption := LoadResString(@RsSSE2);
  CheckBoxSSE3.Caption := LoadResString(@RsSSE3);
  CheckBoxSSSE3.Caption := LoadResString(@RsSSE3Ext);
  CheckBoxSSE4A.Caption := LoadResString(@RsSSE4A);
  CheckBoxSSE4B.Caption := LoadResString(@RsSSE4B);
  CheckBoxSSE5.Caption := LoadResString(@RsSSE5);
  CheckBoxAVX.Caption := LoadResString(@RsAVX);
  ButtonClose.Caption := LoadResString(@RsClose);

  EditName.Text := string(AnsiString(CpuInfo.CpuName));
  EditVendor.Text := string(AnsiString(CpuInfo.VendorIDString));
  EditFrequency.Text := IntToStr(CpuInfo.FrequencyInfo.NormFreq);
  CheckBoxMMX.Checked := CpuInfo.MMX;
  CheckBoxExMMX.Checked := CpuInfo.ExMMX;
  CheckBox3DNow.Checked := CpuInfo._3DNow;
  CheckBoxEx3DNow.Checked := CpuInfo.Ex3DNow;
  CheckBox64Bits.Checked := CpuInfo.Is64Bits;
  CheckBoxSSE1.Checked := sse in CpuInfo.SSE;
  CheckBoxSSE2.Checked := sse2 in CpuInfo.SSE;
  CheckBoxSSE3.Checked := sse3 in CpuInfo.SSE;
  CheckBoxSSSE3.Checked := ssse3 in CpuInfo.SSE;
  CheckBoxSSE4A.Checked := sse4A in CpuInfo.SSE;
  CheckBoxSSE4B.Checked := sse4B in CpuInfo.SSE;
  CheckBoxSSE5.Checked := sse5 in CpuInfo.SSE;
  CheckBoxAVX.Checked := avx in CpuInfo.SSE;
  CheckBoxEnabledFPU.Checked := oefFPU in EnabledFeatures;
  CheckBoxEnabledSSE.Checked := oefSSE in EnabledFeatures;
  CheckBoxEnabledAVX.Checked := oefAVX in EnabledFeatures;
  ShowModal;
end;

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.
