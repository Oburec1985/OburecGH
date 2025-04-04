{********************************************************************}
{                                                                    }
{ written by TMS Software                                            }
{            copyright � 2015                                        }
{            Email : info@tmssoftware.com                            }
{            Web : http://www.tmssoftware.com                        }
{                                                                    }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The complete source code remains property of the author and may    }
{ not be distributed, published, given or sold in any form as such.  }
{ No parts of the source code can be included in any other component }
{ or application without written authorization of the author.        }
{********************************************************************}

unit AdvTreeViewReg;

{$R AdvTreeView.dcr}

interface

{$I TMSDEFS.INC}

uses
  Classes, AdvTreeView, AdvDirectoryTreeView, AdvCheckedTreeView;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('TMS TreeView', [TAdvTreeView, TAdvDirectoryTreeView, TAdvCheckedTreeView]);
end;


end.
