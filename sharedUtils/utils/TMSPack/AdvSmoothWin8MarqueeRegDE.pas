{*************************************************************************}
{ TAdvSmoothWin8Marquee Reg DESIGN TIME EDITOR                       }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright �  2013                                             }
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

unit AdvSmoothWin8MarqueeRegDE;

interface
{$I TMSDEFS.INC}

uses
  Classes, AdvSmoothWin8MarqueeDE, AdvSmoothWin8Marquee,
  AdvSmoothHTMLProp,
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
  RegisterComponentEditor(TAdvSmoothWin8Marquee, TAdvSmoothWin8MarqueeEditor);
end;


end.

