{*************************************************************************}
{ TMS Metro Find Dialog component                                         }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright � 2012                                              }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

unit AdvMetroFindDialogReg;

interface

uses
  Classes, AdvMetroFindDialog;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS Dialogs', [TAdvMetroFindDialog]);
end;

end.

