// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxxmlserializer.pas' rev: 21.00

#ifndef FrxxmlserializerHPP
#define FrxxmlserializerHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Forms.hpp>	// Pascal unit
#include <Dialogs.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Frxxml.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxxmlserializer
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *TfrxGetAncestorEvent)(const System::UnicodeString ComponentName, Classes::TPersistent* &Ancestor);

class DELPHICLASS TfrxXMLSerializer;
class PASCALIMPLEMENTATION TfrxXMLSerializer : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Classes::TStringList* FErrors;
	Classes::TList* FFixups;
	Frxclass::TfrxComponent* FOwner;
	Classes::TReader* FReader;
	Classes::TMemoryStream* FReaderStream;
	bool FSerializeDefaultValues;
	Classes::TStream* FStream;
	bool FOldFormat;
	TfrxGetAncestorEvent FOnGetAncestor;
	void __fastcall AddFixup(Classes::TPersistent* Obj, Typinfo::PPropInfo p, System::UnicodeString Value);
	void __fastcall ClearFixups(void);
	void __fastcall FixupReferences(void);
	
public:
	__fastcall TfrxXMLSerializer(Classes::TStream* Stream);
	__fastcall virtual ~TfrxXMLSerializer(void);
	System::UnicodeString __fastcall ObjToXML(Classes::TPersistent* Obj, const System::UnicodeString Add = L"", Classes::TPersistent* Ancestor = (Classes::TPersistent*)(0x0));
	Frxclass::TfrxComponent* __fastcall ReadComponent(Frxclass::TfrxComponent* Root);
	Frxclass::TfrxComponent* __fastcall ReadComponentStr(Frxclass::TfrxComponent* Root, System::UnicodeString s, bool DontFixup = false);
	System::UnicodeString __fastcall WriteComponentStr(Frxclass::TfrxComponent* c);
	void __fastcall ReadRootComponent(Frxclass::TfrxComponent* Root, Frxxml::TfrxXMLItem* XMLItem = (Frxxml::TfrxXMLItem*)(0x0));
	void __fastcall CopyFixupList(Classes::TList* FixList);
	void __fastcall ReadPersistentStr(Classes::TComponent* Root, Classes::TPersistent* Obj, const System::UnicodeString s);
	void __fastcall WriteComponent(Frxclass::TfrxComponent* c);
	void __fastcall WriteRootComponent(Frxclass::TfrxComponent* Root, bool SaveChildren = true, Frxxml::TfrxXMLItem* XMLItem = (Frxxml::TfrxXMLItem*)(0x0), bool Streaming = false);
	void __fastcall XMLToObj(const System::UnicodeString s, Classes::TPersistent* Obj);
	__property Classes::TStringList* Errors = {read=FErrors};
	__property Frxclass::TfrxComponent* Owner = {read=FOwner, write=FOwner};
	__property Classes::TStream* Stream = {read=FStream};
	__property bool SerializeDefaultValues = {read=FSerializeDefaultValues, write=FSerializeDefaultValues, nodefault};
	__property TfrxGetAncestorEvent OnGetAncestor = {read=FOnGetAncestor, write=FOnGetAncestor};
	__property bool OldFormat = {read=FOldFormat, write=FOldFormat, nodefault};
};


class DELPHICLASS TfrxFixupItem;
class PASCALIMPLEMENTATION TfrxFixupItem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	Classes::TPersistent* Obj;
	Typinfo::TPropInfo *PropInfo;
	System::UnicodeString Value;
public:
	/* TObject.Create */ inline __fastcall TfrxFixupItem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxFixupItem(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxxmlserializer */
using namespace Frxxmlserializer;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxxmlserializerHPP
