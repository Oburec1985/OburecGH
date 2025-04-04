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
{ The Original Code is JclArraySetsTemplates.pas.                                                  }
{                                                                                                  }
{ The Initial Developer of the Original Code is Florent Ouchet                                     }
{         <outchy att users dott sourceforge dott net>                                             }
{ Portions created by Florent Ouchet are Copyright (C) of Florent Ouchet. All rights reserved.     }
{                                                                                                  }
{ Contributors:                                                                                    }
{                                                                                                  }
{**************************************************************************************************}
{                                                                                                  }
{ Last modified: $Date:: 2010-08-02 21:09:40 +0200 (lun., 02 août 2010)                         $ }
{ Revision:      $Rev:: 3273                                                                     $ }
{ Author:        $Author:: outchy                                                                $ }
{                                                                                                  }
{**************************************************************************************************}

unit JclArraySetsTemplates;

interface

{$I jcl.inc}

uses
  {$IFDEF UNITVERSIONING}
  JclUnitVersioning,
  {$ENDIF UNITVERSIONING}
  JclContainerTypes,
  JclContainerTemplates,
  JclContainer1DTemplates;

type
  (* JCLARRAYSETINT(SELFCLASSNAME, ANCESTORCLASSNAME, COLLECTIONINTERFACENAME, LISTINTERFACENAME,
                    ARRAYINTERFACENAME, SETINTERFACENAME, INTERFACEADDITIONAL, SECTIONADDITIONAL,
                    COLLECTIONFLAGS, CONSTKEYWORD, PARAMETERNAME, TYPENAME) *)
  TJclArraySetIntParams = class(TJclCollectionInterfaceParams)
  protected
    // function CodeUnit: string; override;
    function GetInterfaceAdditional: string; override;
  public
    function AliasAttributeIDs: TAllTypeAttributeIDs; override;
  published
    property SelfClassName: string index taArraySetClassName read GetTypeAttribute write SetTypeAttribute stored IsTypeAttributeStored;
    property AncestorClassName: string index taArrayListClassName read GetTypeAttribute write SetTypeAttribute stored False;
    property CollectionInterfaceName: string index taCollectionInterfaceName read GetTypeAttribute write SetTypeAttribute stored False;
    property EqualityComparerInterfaceName: string index taEqualityComparerInterfaceName read GetTypeAttribute write SetTypeAttribute stored False;
    property ComparerInterfaceName: string index taComparerInterfaceName read GetTypeAttribute write SetTypeAttribute stored False;
    property ListInterfaceName: string index taListInterfaceName read GetTypeAttribute write SetTypeAttribute stored False;
    property ArrayInterfaceName: string index taArrayInterfaceName read GetTypeAttribute write SetTypeAttribute stored False;
    property SetInterfaceName: string index taSetInterfaceName read GetTypeAttribute write SetTypeAttribute stored False;
    property InterfaceAdditional;
    property SectionAdditional;
    property CollectionFlags;
    property ConstKeyword: string index taConstKeyword read GetTypeAttribute write SetTypeAttribute stored False;
    property ParameterName: string index taParameterName read GetTypeAttribute write SetTypeAttribute stored False;
    property TypeName: string index taTypeName read GetTypeAttribute write SetTypeAttribute stored False;
  end;

 (* JCLARRAYSETIMP(SELFCLASSNAME, COLLECTIONINTERFACENAME, ITRINTERFACENAME, CONSTKEYWORD,
                   PARAMETERNAME, TYPENAME, DEFAULTVALUE, GETTERNAME) *)
  TJclArraySetImpParams = class(TJclCollectionImplementationParams)
  protected
    // function CodeUnit: string; override;
  public
    function GetConstructorParameters: string; override;
    function GetSelfClassName: string; override;
  published
    property SelfClassName: string index taArraySetClassName read GetTypeAttribute write SetTypeAttribute stored False;
    property CollectionInterfaceName: string index taCollectionInterfaceName read GetTypeAttribute write SetTypeAttribute stored False;
    property ItrInterfaceName: string index taIteratorInterfaceName read GetTypeAttribute write SetTypeAttribute stored False;
    property ConstKeyword: string index taConstKeyword read GetTypeAttribute write SetTypeAttribute stored False;
    property ParameterName: string index taParameterName read GetTypeAttribute write SetTypeAttribute stored False;
    property TypeName: string index taTypeName read GetTypeAttribute write SetTypeAttribute stored False;
    property DefaultValue: string index taDefaultValue read GetTypeAttribute write SetTypeAttribute stored False;
    property GetterName: string index taGetterName read GetTypeAttribute write SetTypeAttribute stored False;
    property MacroFooter;
  end;

{$IFDEF UNITVERSIONING}
const
  UnitVersioning: TUnitVersionInfo = (
    RCSfile: '$URL: https://jcl.svn.sourceforge.net:443/svnroot/jcl/tags/JCL-2.2-Build3970/jcl/devtools/jpp/Templates/JclArraySetsTemplates.pas $';
    Revision: '$Revision: 3273 $';
    Date: '$Date: 2010-08-02 21:09:40 +0200 (lun., 02 août 2010) $';
    LogPath: 'JCL\devtools\jpp\Templates';
    Extra: '';
    Data: nil
    );
{$ENDIF UNITVERSIONING}

implementation

uses
  SysUtils,
  JclStrings;

procedure RegisterJclContainers;
begin
  RegisterContainerParams('JCLARRAYSETINT', TJclArraySetIntParams);
  RegisterContainerParams('JCLARRAYSETIMP', TJclArraySetImpParams, TJclArraySetIntParams);
end;

//=== { TJclArraySetIntParams } ==============================================

function TJclArraySetIntParams.AliasAttributeIDs: TAllTypeAttributeIDs;
begin
  Result := [taArraySetClassName];
end;

function TJclArraySetIntParams.GetInterfaceAdditional: string;
begin
  Result := FInterfaceAdditional;
  if Result = '' then
    Result := Format('%s %s, %s,', [inherited GetInterfaceAdditional, EqualityComparerInterfaceName, ComparerInterfaceName]);
end;

//=== { TJclArraySetImpParams } ==============================================

function TJclArraySetImpParams.GetConstructorParameters: string;
begin
  Result := 'Size';
end;

function TJclArraySetImpParams.GetSelfClassName: string;
begin
  Result := SelfClassName;
end;

initialization
  RegisterJclContainers;
  {$IFDEF UNITVERSIONING}
  RegisterUnitVersion(HInstance, UnitVersioning);
  {$ENDIF UNITVERSIONING}

finalization
  {$IFDEF UNITVERSIONING}
  UnregisterUnitVersion(HInstance);
  {$ENDIF UNITVERSIONING}

end.

