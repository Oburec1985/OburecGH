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
{ The Original Code is Vector.pas.                                                                 }
{                                                                                                  }
{ The Initial Developer of the Original Code is Jean-Philippe BEMPEL aka RDM. Portions created by  }
{ Jean-Philippe BEMPEL are Copyright (C) Jean-Philippe BEMPEL (rdm_30 att yahoo dott com)          }
{ All rights reserved.                                                                             }
{                                                                                                  }
{ Contributors:                                                                                    }
{   Daniele Teti (dade2004)                                                                        }
{   Robert Marquardt (marquardt)                                                                   }
{   Robert Rossmair (rrossmair)                                                                    }
{   Florent Ouchet (outchy)                                                                        }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ The Delphi Container Library                                                                     }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2011-03-15 16:07:53 +0100 (mar., 15 mars 2011)                          $ }
{ Revision:      $Rev:: 3511                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclVectors;

{$I jcl.inc}

interface

uses
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  JclAlgorithms,
  Classes,
  JclBase, JclAbstractContainers, JclContainerIntf, JclSynch;
{$I containers\JclContainerCommon.imp}
{$I containers\JclVectors.imp}
{$I containers\JclVectors.int}
type
  TItrStart = (isFirst, isLast);
(*$JPPLOOP ALLTYPEINDEX ALLTYPECOUNT
  {$JPPEXPANDMACRO JCLVECTORINT(,,,,,,,,,,,,,,,)}

  {$JPPEXPANDMACRO JCLVECTORITRINT(,,,,,,,)}

*)
  {$IFDEF SUPPORTS_GENERICS}
  //DOM-IGNORE-BEGIN

  TJclVectorIterator<T> = class;

  (*$JPPEXPANDMACRO JCLVECTORINT(TJclVector<T>,TJclAbstractContainer<T>,IJclCollection<T>,IJclList<T>,IJclArray<T>,IJclIterator<T>, IJclItemOwner<T>\, IJclEqualityComparer<T>\,,

protected
  type
    TDynArray = array of T;
    TVectorIterator = TJclVectorIterator<T>;
  procedure MoveArray(var List: TDynArray; FromIndex, ToIndex, Count: Integer);,,; AOwnsItems: Boolean,const ,AItem,T,TDynArray,GetItem,SetItem)*)

  (*$JPPEXPANDMACRO JCLVECTORITRINT(TJclVectorIterator<T>,IJclIterator<T>,IJclList<T>,const ,AItem,T,GetItem,SetItem)*)

  // E = External helper to compare items for equality (GetHashCode is not used)
  TJclVectorE<T> = class(TJclVector<T>, {$IFDEF THREADSAFE} IJclLockable, {$ENDIF THREADSAFE}
    IJclIntfCloneable, IJclCloneable, IJclPackable, IJclGrowable, IJclBaseContainer,
    IJclCollection<T>, IJclList<T>, IJclArray<T>, IJclItemOwner<T>)
  private
    FEqualityComparer: IJclEqualityComparer<T>;
  protected
    procedure AssignPropertiesTo(Dest: TJclAbstractContainerBase); override;
    function CreateEmptyContainer: TJclAbstractContainerBase; override;
  public
    constructor Create(const AEqualityComparer: IJclEqualityComparer<T>; ACapacity: Integer; AOwnsItems: Boolean);
    { IJclEqualityComparer<T> }
    function ItemsEqual(const A, B: T): Boolean; override;
    property EqualityComparer: IJclEqualityComparer<T> read FEqualityComparer write FEqualityComparer;
  end;

  // F = Function to compare items for equality
  TJclVectorF<T> = class(TJclVector<T>, {$IFDEF THREADSAFE} IJclLockable, {$ENDIF THREADSAFE}
    IJclIntfCloneable, IJclCloneable, IJclPackable, IJclGrowable, IJclBaseContainer,
    IJclCollection<T>, IJclList<T>, IJclArray<T>, IJclItemOwner<T>)
  protected
    function CreateEmptyContainer: TJclAbstractContainerBase; override;
  public
    constructor Create(const AEqualityCompare: TEqualityCompare<T>; ACapacity: Integer; AOwnsItems: Boolean);
  end;

  // I = Items can compare themselves to an other for equality
  TJclVectorI<T: IEquatable<T>> = class(TJclVector<T>, {$IFDEF THREADSAFE} IJclLockable, {$ENDIF THREADSAFE}
    IJclIntfCloneable, IJclCloneable, IJclPackable, IJclGrowable, IJclBaseContainer,
    IJclCollection<T>, IJclList<T>, IJclArray<T>, IJclItemOwner<T>)
  protected
    function CreateEmptyContainer: TJclAbstractContainerBase; override;
  public
    { IJclEqualityComparer<T> }
    function ItemsEqual(const A, B: T): Boolean; override;
  end;

  //DOM-IGNORE-END
  {$ENDIF SUPPORTS_GENERICS}

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net:443/svnroot/jcl/tags/JCL-2.3-Build4197/jcl/source/prototypes/JclVectors.pas $';
    Revision: '$Revision: 3511 $';
    Date: '$Date: 2011-03-15 16:07:53 +0100 (mar., 15 mars 2011) $';
    LogPath: 'JCL\source\common';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  SysUtils;

(*$JPPLOOP TRUETYPEINDEX TRUETYPECOUNT
{$JPPEXPANDMACRO JCLVECTORIMP(,,,,,,,,,,,,,)}

{$JPPEXPANDMACRO JCLVECTORITRIMP(,,,,,,,)}

*)
{$IFDEF SUPPORTS_GENERICS}
//DOM-IGNORE-BEGIN

(*$JPPEXPANDMACRO JCLVECTORIMP(TJclVector<T>,IJclCollection<T>,IJclList<T>,IJclIterator<T>,TVectorIterator,; AOwnsItems: Boolean,AOwnsItems,const ,AItem,T,Default(T),GetItem,SetItem,FreeItem)*)

(*$JPPEXPANDMACRO JCLVECTORITRIMP(TJclVectorIterator<T>,IJclIterator<T>,IJclList<T>,const ,AItem,T,GetItem,SetItem)*)

procedure TJclVector<T>.MoveArray(var List: TDynArray; FromIndex, ToIndex, Count: Integer);
var
  I: Integer;
begin
  if FromIndex < ToIndex then
  begin
    for I := Count - 1 downto 0 do
      List[ToIndex + I] := List[FromIndex + I];

    if (ToIndex - FromIndex) < Count then
      // overlapped source and target
      for I := 0 to ToIndex - FromIndex - 1 do
        List[FromIndex + I] := Default(T)
    else
      // independant
      for I := 0 to Count - 1 do
        List[FromIndex + I] := Default(T);
  end
  else
  begin
    for I := 0 to Count - 1 do
      List[ToIndex + I] := List[FromIndex + I];

    if (FromIndex - ToIndex) < Count then
      // overlapped source and target
      for I := Count - FromIndex + ToIndex to Count - 1 do
        List[FromIndex + I] := Default(T)
    else
      // independant
      for I := 0 to Count - 1 do
        List[FromIndex + I] := Default(T);
  end; 
end;

//=== { TJclVectorE<T> } =====================================================

constructor TJclVectorE<T>.Create(const AEqualityComparer: IJclEqualityComparer<T>; ACapacity: Integer;
  AOwnsItems: Boolean);
begin
  inherited Create(ACapacity, AOwnsItems);
  FEqualityComparer := AEqualityComparer;
end;

procedure TJclVectorE<T>.AssignPropertiesTo(Dest: TJclAbstractContainerBase);
begin
  inherited AssignPropertiesTo(Dest);
  if Dest is TJclVectorE<T> then
    TJclVectorE<T>(Dest).FEqualityComparer := FEqualityComparer;
end;

function TJclVectorE<T>.CreateEmptyContainer: TJclAbstractContainerBase;
begin
  Result := TJclVectorE<T>.Create(EqualityComparer, FSize, False);
  AssignPropertiesTo(Result);
end;

function TJclVectorE<T>.ItemsEqual(const A, B: T): Boolean;
begin
  if EqualityComparer <> nil then
    Result := EqualityComparer.ItemsEqual(A, B)
  else
    Result := inherited ItemsEqual(A, B);
end;

//=== { TJclVectorF<T> } =====================================================

constructor TJclVectorF<T>.Create(const AEqualityCompare: TEqualityCompare<T>; ACapacity: Integer;
  AOwnsItems: Boolean);
begin
  inherited Create(ACapacity, AOwnsItems);
  SetEqualityCompare(AEqualityCompare);
end;

function TJclVectorF<T>.CreateEmptyContainer: TJclAbstractContainerBase;
begin
  Result := TJclVectorF<T>.Create(EqualityCompare, FSize, False);
  AssignPropertiesTo(Result);
end;

//=== { TJclVectorI<T> } =====================================================

function TJclVectorI<T>.CreateEmptyContainer: TJclAbstractContainerBase;
begin
  Result := TJclVectorI<T>.Create(FSize, False);
  AssignPropertiesTo(Result);
end;

function TJclVectorI<T>.ItemsEqual(const A, B: T): Boolean;
begin
  if Assigned(FEqualityCompare) then
    Result := FEqualityCompare(A, B)
  else
  if Assigned(FCompare) then
    Result := FCompare(A, B) = 0
  else
    Result := A.Equals(B);
end;

//DOM-IGNORE-END
{$ENDIF SUPPORTS_GENERICS}

{$IFDEF UNITVERSIONING}
initialization
  RegisterUnitVersion(HInstance, UnitVersioning);

finalization
  UnregisterUnitVersion(HInstance);
{$ENDIF UNITVERSIONING}

end.

