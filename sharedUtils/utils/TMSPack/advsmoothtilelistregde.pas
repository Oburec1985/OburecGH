{*************************************************************************}
{ TAdvSmoothTileListRegDE Reg DESIGN TIME EDITOR                          }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright �  2011                                             }
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

unit AdvSmoothTileListRegDE;

interface
{$I TMSDEFS.INC}

uses
  Classes, AdvSmoothTileListDE, ImgList, AdvSmoothTileList,
{$IFDEF DELPHI6_LVL}
  DesignIntf, DesignEditors
{$ELSE}
  DsgnIntf
{$ENDIF}
  ;


procedure Register;

implementation


procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TImageIndex), TAdvSmoothTileContent, 'ImageIndex', TAdvSmoothTileListImageIndexProperty);
  RegisterComponentEditor(TAdvSmoothTileList, TAdvSmoothTileListEditor);
end;


end.

