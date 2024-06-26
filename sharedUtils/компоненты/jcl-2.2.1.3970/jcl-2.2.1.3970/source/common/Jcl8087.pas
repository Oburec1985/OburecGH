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
{ The Original Code is Jcl8087.pas                                                                 }
{                                                                                                  }
{ The Initial Developer of the Original Code is Marcel van Brakel.                                 }
{ Portions created by Marcel van Brakel are Copyright Marcel van Brakel. All rights reserved.      }
{                                                                                                  }
{ Contributor(s):                                                                                  }
{   Marcel van Brakel                                                                              }
{   ESB Consultancy                                                                                }
{   Robert Marquardt (marquardt)                                                                   }
{   Robert Rossmair (rrossmair)                                                                    }
{   Matthias Thoma (mthoma)                                                                        }
{   Petr Vones                                                                                     }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ This unit contains various routine for manipulating the math coprocessor. This includes such     }
{ things as querying and setting the rounding precision of  floating point operations and          }
{ retrieving the coprocessor's status word.                                                        }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2009-08-09 15:08:29 +0200 (dim., 09 août 2009)                         $ }
{ Revision:      $Rev:: 2921                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

unit Jcl8087;

{$I jcl.inc}

interface

{$IFDEF UNITVERSIONING}
uses
  JclUnitVersioning;
{$ENDIF UNITVERSIONING}

type
  T8087Precision = (pcSingle, pcReserved, pcDouble, pcExtended);
  T8087Rounding = (rcNearestOrEven, rcDownInfinity, rcUpInfinity, rcChopOrTruncate);
  T8087Infinity = (icProjective, icAffine);
  T8087Exception = (emInvalidOp, emDenormalizedOperand, emZeroDivide, emOverflow,
    emUnderflow, emPrecision);
  T8087Exceptions = set of T8087Exception;

const
  All8087Exceptions = [Low(T8087Exception)..High(T8087Exception)];

function Get8087ControlWord: Word;
function Get8087Infinity: T8087Infinity;
function Get8087Precision: T8087Precision;
function Get8087Rounding: T8087Rounding;
function Get8087StatusWord(ClearExceptions: Boolean): Word;

function Set8087Infinity(const Infinity: T8087Infinity): T8087Infinity;
function Set8087Precision(const Precision: T8087Precision): T8087Precision;
function Set8087Rounding(const Rounding: T8087Rounding): T8087Rounding;
function Set8087ControlWord(const Control: Word): Word;

function ClearPending8087Exceptions: T8087Exceptions;
function GetPending8087Exceptions: T8087Exceptions;
function GetMasked8087Exceptions: T8087Exceptions;
function SetMasked8087Exceptions(Exceptions: T8087Exceptions; ClearBefore: Boolean = True): T8087Exceptions;
function Mask8087Exceptions(Exceptions: T8087Exceptions): T8087Exceptions;
function Unmask8087Exceptions(Exceptions: T8087Exceptions; ClearBefore: Boolean = True): T8087Exceptions;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net:443/svnroot/jcl/tags/JCL-2.2-Build3970/jcl/source/common/Jcl8087.pas $';
    Revision: '$Revision: 2921 $';
    Date: '$Date: 2009-08-09 15:08:29 +0200 (dim., 09 août 2009) $';
    LogPath: 'JCL\source\common';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}

implementation

const
  X87ExceptBits = $3F;

function Get8087ControlWord: Word;
begin
  asm
          FSTCW   Result
          FWAIT
  end;
end;

function Get8087Infinity: T8087Infinity;
begin
  Result := T8087Infinity((Get8087ControlWord and $1000) shr 12);
end;

function Get8087Precision: T8087Precision;
begin
  Result := T8087Precision((Get8087ControlWord and $0300) shr 8);
end;

function Get8087Rounding: T8087Rounding;
begin
  Result := T8087Rounding((Get8087ControlWord and $0C00) shr 10);
end;

function Get8087StatusWord(ClearExceptions: Boolean): Word;
begin
  if ClearExceptions then
  asm
          FSTSW   Result                    //   get status word (clears exceptions)
  end
  else
  asm
          FNSTSW  Result                    //   get status word (without clearing exceptions)
  end;
end;

function Set8087Infinity(const Infinity: T8087Infinity): T8087Infinity;
var
  CW: Word;
begin
  CW := Get8087ControlWord;
  Result := T8087Infinity((CW and $1000) shr 12);
  Set8087ControlWord((CW and $EFFF) or (Word(Infinity) shl 12));
end;

function Set8087Precision(const Precision: T8087Precision): T8087Precision;
var
  CW: Word;
begin
  CW := Get8087ControlWord;
  Result := T8087Precision((CW and $0300) shr 8);
  Set8087ControlWord((CW and $FCFF) or (Word(Precision) shl 8));
end;

function Set8087Rounding(const Rounding: T8087Rounding): T8087Rounding;
var
  CW: Word;
begin
  CW := Get8087ControlWord;
  Result := T8087Rounding((CW and $0C00) shr 10);
  Set8087ControlWord((CW and $F3FF) or (Word(Rounding) shl 10));
end;

function Set8087ControlWord(const Control: Word): Word;
begin
  asm
          FNCLEX
          FSTCW   Result    // save the old control word
          FLDCW   Control   // load the new control word
  end;
end;

function ClearPending8087Exceptions: T8087Exceptions;
var
  SW: Word;
begin
  asm
          FNSTSW  SW
          AND     SW, X87ExceptBits
          FNCLEX
  end;
  Result := [];
  if (SW and $01) <> 0 then
    Include(Result, emInvalidOp);
  if (SW and $02) <> 0 then
    Include(Result, emDenormalizedOperand);
  if (SW and $04) <> 0 then
    Include(Result, emZeroDivide);
  if (SW and $08) <> 0 then
    Include(Result, emOverflow);
  if (SW and $10) <> 0 then
    Include(Result, emUnderflow);
  if (SW and $20) <> 0 then
    Include(Result, emPrecision);
end;

function GetPending8087Exceptions: T8087Exceptions;
var
  SW: Word;
begin
  asm
          FNSTSW  SW
          AND     SW, X87ExceptBits
  end;
  Result := [];
  if (SW and $01) <> 0 then
    Include(Result, emInvalidOp);
  if (SW and $02) <> 0 then
    Include(Result, emDenormalizedOperand);
  if (SW and $04) <> 0 then
    Include(Result, emZeroDivide);
  if (SW and $08) <> 0 then
    Include(Result, emOverflow);
  if (SW and $10) <> 0 then
    Include(Result, emUnderflow);
  if (SW and $20) <> 0 then
    Include(Result, emPrecision);
end;

function GetMasked8087Exceptions: T8087Exceptions;
var
  CW: Word;
begin
  asm
          FSTCW   CW
          AND     CW, X87ExceptBits
  end;
  Result := [];
  if (CW and $01) <> 0 then
    Include(Result, emInvalidOp);
  if (CW and $02) <> 0 then
    Include(Result, emDenormalizedOperand);
  if (CW and $04) <> 0 then
    Include(Result, emZeroDivide);
  if (CW and $08) <> 0 then
    Include(Result, emOverflow);
  if (CW and $10) <> 0 then
    Include(Result, emUnderflow);
  if (CW and $20) <> 0 then
    Include(Result, emPrecision);
end;

function SetMasked8087Exceptions(Exceptions: T8087Exceptions; ClearBefore: Boolean): T8087Exceptions;
var
  OldCW, NewCW: Word;
begin
  if ClearBefore then
  asm
        FNCLEX                     // clear pending exceptions
  end;
  NewCW := 0;
  if emInvalidOp in Exceptions then
    NewCW := NewCW or $01;
  if emDenormalizedOperand in Exceptions then
    NewCW := NewCW or $02;
  if emZeroDivide in Exceptions then
    NewCW := NewCW or $04;
  if emOverflow in Exceptions then
    NewCW := NewCW or $08;
  if emUnderflow in Exceptions then
    NewCW := NewCW or $10;
  if emPrecision in Exceptions then
    NewCW := NewCW or $20;
  asm
        FSTCW   OldCW
        FWAIT
        MOV     AX, OldCW
        AND     AX, NOT X87ExceptBits  // mask exception mask bits 0..5
        OR      NewCW, AX
        FLDCW   NewCW
  end;
  Result := [];
  if (OldCW and $01) <> 0 then
    Include(Result, emInvalidOp);
  if (OldCW and $02) <> 0 then
    Include(Result, emDenormalizedOperand);
  if (OldCW and $04) <> 0 then
    Include(Result, emZeroDivide);
  if (OldCW and $08) <> 0 then
    Include(Result, emOverflow);
  if (OldCW and $10) <> 0 then
    Include(Result, emUnderflow);
  if (OldCW and $20) <> 0 then
    Include(Result, emPrecision);
end;

function Mask8087Exceptions(Exceptions: T8087Exceptions): T8087Exceptions;
begin
  Result := GetMasked8087Exceptions;
  Exceptions := Exceptions + Result;
  SetMasked8087Exceptions(Exceptions, False);
end;

function Unmask8087Exceptions(Exceptions: T8087Exceptions; ClearBefore: Boolean): T8087Exceptions;
begin
  Result := GetMasked8087Exceptions;
  Exceptions := Result - Exceptions;
  SetMasked8087Exceptions(Exceptions, ClearBefore);
end;

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.
