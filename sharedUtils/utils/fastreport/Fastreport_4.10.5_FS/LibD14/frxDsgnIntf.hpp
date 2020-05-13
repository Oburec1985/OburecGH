// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxdsgnintf.pas' rev: 21.00

#ifndef FrxdsgnintfHPP
#define FrxdsgnintfHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit
#include <Controls.hpp>	// Pascal unit
#include <Stdctrls.hpp>	// Pascal unit
#include <Menus.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Types.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxdsgnintf
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TfrxPropertyAttribute { paValueList, paSortList, paDialog, paMultiSelect, paSubProperties, paReadOnly, paOwnerDraw };
#pragma option pop

typedef Set<TfrxPropertyAttribute, paValueList, paOwnerDraw>  TfrxPropertyAttributes;

class DELPHICLASS TfrxPropertyEditor;
class PASCALIMPLEMENTATION TfrxPropertyEditor : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Frxclass::TfrxCustomDesigner* FDesigner;
	Classes::TList* FCompList;
	Classes::TList* FPropList;
	int FItemHeight;
	Classes::TStrings* FValues;
	Typinfo::PPropInfo __fastcall GetPropInfo(void);
	Classes::TPersistent* __fastcall GetComponent(void);
	Frxclass::TfrxComponent* __fastcall GetfrComponent(void);
	
protected:
	void __fastcall GetStrProc(const System::UnicodeString s);
	System::Extended __fastcall GetFloatValue(void);
	int __fastcall GetOrdValue(void);
	System::UnicodeString __fastcall GetStrValue(void);
	System::Variant __fastcall GetVarValue(void);
	void __fastcall SetFloatValue(System::Extended Value);
	void __fastcall SetOrdValue(int Value);
	void __fastcall SetStrValue(const System::UnicodeString Value);
	void __fastcall SetVarValue(const System::Variant &Value);
	
public:
	__fastcall virtual TfrxPropertyEditor(Frxclass::TfrxCustomDesigner* Designer);
	__fastcall virtual ~TfrxPropertyEditor(void);
	virtual bool __fastcall Edit(void);
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetName(void);
	virtual int __fastcall GetExtraLBSize(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
	virtual void __fastcall OnDrawLBItem(Controls::TWinControl* Control, int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	virtual void __fastcall OnDrawItem(Graphics::TCanvas* Canvas, const Types::TRect &ARect);
	__property Classes::TPersistent* Component = {read=GetComponent};
	__property Frxclass::TfrxComponent* frComponent = {read=GetfrComponent};
	__property Frxclass::TfrxCustomDesigner* Designer = {read=FDesigner};
	__property int ItemHeight = {read=FItemHeight, write=FItemHeight, nodefault};
	__property Typinfo::PPropInfo PropInfo = {read=GetPropInfo};
	__property System::UnicodeString Value = {read=GetValue, write=SetValue};
	__property Classes::TStrings* Values = {read=FValues};
};


typedef TMetaClass* TfrxPropertyEditorClass;

class DELPHICLASS TfrxComponentEditor;
class PASCALIMPLEMENTATION TfrxComponentEditor : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	Frxclass::TfrxComponent* FComponent;
	Frxclass::TfrxCustomDesigner* FDesigner;
	Menus::TMenu* FMenu;
	
protected:
	Menus::TMenuItem* __fastcall AddItem(const System::UnicodeString Caption, int Tag, bool Checked = false);
	
public:
	__fastcall TfrxComponentEditor(Frxclass::TfrxComponent* Component, Frxclass::TfrxCustomDesigner* Designer, Menus::TMenu* Menu);
	virtual bool __fastcall Edit(void);
	virtual bool __fastcall HasEditor(void);
	virtual void __fastcall GetMenuItems(void);
	virtual bool __fastcall Execute(int Tag, bool Checked);
	__property Frxclass::TfrxComponent* Component = {read=FComponent};
	__property Frxclass::TfrxCustomDesigner* Designer = {read=FDesigner};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TfrxComponentEditor(void) { }
	
};


typedef TMetaClass* TfrxComponentEditorClass;

class DELPHICLASS TfrxIntegerProperty;
class PASCALIMPLEMENTATION TfrxIntegerProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxIntegerProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxIntegerProperty(void) { }
	
};


class DELPHICLASS TfrxFloatProperty;
class PASCALIMPLEMENTATION TfrxFloatProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxFloatProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxFloatProperty(void) { }
	
};


class DELPHICLASS TfrxCharProperty;
class PASCALIMPLEMENTATION TfrxCharProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxCharProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxCharProperty(void) { }
	
};


class DELPHICLASS TfrxStringProperty;
class PASCALIMPLEMENTATION TfrxStringProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxStringProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxStringProperty(void) { }
	
};


class DELPHICLASS TfrxEnumProperty;
class PASCALIMPLEMENTATION TfrxEnumProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxEnumProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxEnumProperty(void) { }
	
};


class DELPHICLASS TfrxSetProperty;
class PASCALIMPLEMENTATION TfrxSetProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetValue(void);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxSetProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxSetProperty(void) { }
	
};


class DELPHICLASS TfrxSetElementProperty;
class PASCALIMPLEMENTATION TfrxSetElementProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
private:
	int FElement;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetName(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxSetElementProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxSetElementProperty(void) { }
	
};


class DELPHICLASS TfrxClassProperty;
class PASCALIMPLEMENTATION TfrxClassProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetValue(void);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxClassProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxClassProperty(void) { }
	
};


class DELPHICLASS TfrxComponentProperty;
class PASCALIMPLEMENTATION TfrxComponentProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxComponentProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxComponentProperty(void) { }
	
};


class DELPHICLASS TfrxNameProperty;
class PASCALIMPLEMENTATION TfrxNameProperty : public TfrxStringProperty
{
	typedef TfrxStringProperty inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxNameProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxStringProperty(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxNameProperty(void) { }
	
};


class DELPHICLASS TfrxColorProperty;
class PASCALIMPLEMENTATION TfrxColorProperty : public TfrxIntegerProperty
{
	typedef TfrxIntegerProperty inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual bool __fastcall Edit(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
	virtual void __fastcall OnDrawLBItem(Controls::TWinControl* Control, int Index, const Types::TRect &ARect, Windows::TOwnerDrawState State);
	virtual void __fastcall OnDrawItem(Graphics::TCanvas* Canvas, const Types::TRect &ARect);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxColorProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxIntegerProperty(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxColorProperty(void) { }
	
};


class DELPHICLASS TfrxFontProperty;
class PASCALIMPLEMENTATION TfrxFontProperty : public TfrxClassProperty
{
	typedef TfrxClassProperty inherited;
	
public:
	virtual bool __fastcall Edit(void);
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxFontProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxClassProperty(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxFontProperty(void) { }
	
};


class DELPHICLASS TfrxFontNameProperty;
class PASCALIMPLEMENTATION TfrxFontNameProperty : public TfrxStringProperty
{
	typedef TfrxStringProperty inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual void __fastcall GetValues(void);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxFontNameProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxStringProperty(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxFontNameProperty(void) { }
	
};


class DELPHICLASS TfrxFontCharsetProperty;
class PASCALIMPLEMENTATION TfrxFontCharsetProperty : public TfrxIntegerProperty
{
	typedef TfrxIntegerProperty inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxFontCharsetProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxIntegerProperty(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxFontCharsetProperty(void) { }
	
};


class DELPHICLASS TfrxModalResultProperty;
class PASCALIMPLEMENTATION TfrxModalResultProperty : public TfrxIntegerProperty
{
	typedef TfrxIntegerProperty inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxModalResultProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxIntegerProperty(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxModalResultProperty(void) { }
	
};


class DELPHICLASS TfrxShortCutProperty;
class PASCALIMPLEMENTATION TfrxShortCutProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxShortCutProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxShortCutProperty(void) { }
	
};


class DELPHICLASS TfrxCursorProperty;
class PASCALIMPLEMENTATION TfrxCursorProperty : public TfrxIntegerProperty
{
	typedef TfrxIntegerProperty inherited;
	
public:
	virtual TfrxPropertyAttributes __fastcall GetAttributes(void);
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall GetValues(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxCursorProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxIntegerProperty(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxCursorProperty(void) { }
	
};


class DELPHICLASS TfrxDateTimeProperty;
class PASCALIMPLEMENTATION TfrxDateTimeProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxDateTimeProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxDateTimeProperty(void) { }
	
};


class DELPHICLASS TfrxDateProperty;
class PASCALIMPLEMENTATION TfrxDateProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxDateProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxDateProperty(void) { }
	
};


class DELPHICLASS TfrxTimeProperty;
class PASCALIMPLEMENTATION TfrxTimeProperty : public TfrxPropertyEditor
{
	typedef TfrxPropertyEditor inherited;
	
public:
	virtual System::UnicodeString __fastcall GetValue(void);
	virtual void __fastcall SetValue(const System::UnicodeString Value);
public:
	/* TfrxPropertyEditor.Create */ inline __fastcall virtual TfrxTimeProperty(Frxclass::TfrxCustomDesigner* Designer) : TfrxPropertyEditor(Designer) { }
	/* TfrxPropertyEditor.Destroy */ inline __fastcall virtual ~TfrxTimeProperty(void) { }
	
};


class DELPHICLASS TfrxPropertyItem;
class DELPHICLASS TfrxPropertyList;
class PASCALIMPLEMENTATION TfrxPropertyItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	TfrxPropertyEditor* FEditor;
	bool FExpanded;
	TfrxPropertyList* FSubProperty;
	
public:
	__fastcall virtual ~TfrxPropertyItem(void);
	__property TfrxPropertyEditor* Editor = {read=FEditor};
	__property bool Expanded = {read=FExpanded, write=FExpanded, nodefault};
	__property TfrxPropertyList* SubProperty = {read=FSubProperty};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxPropertyItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	
};


class PASCALIMPLEMENTATION TfrxPropertyList : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxPropertyItem* operator[](int Index) { return Items[Index]; }
	
private:
	Classes::TPersistent* FComponent;
	Frxclass::TfrxCustomDesigner* FDesigner;
	TfrxPropertyList* FParent;
	void __fastcall AddProperties(TfrxPropertyList* PropertyList);
	void __fastcall FillProperties(Classes::TPersistent* AClass);
	void __fastcall FillCommonProperties(TfrxPropertyList* PropertyList);
	void __fastcall SetComponent(Classes::TPersistent* Value);
	TfrxPropertyItem* __fastcall GetPropertyItem(int Index);
	
public:
	__fastcall TfrxPropertyList(Frxclass::TfrxCustomDesigner* Designer);
	HIDESBASE TfrxPropertyItem* __fastcall Add(void);
	__property Classes::TPersistent* Component = {read=FComponent, write=SetComponent};
	__property TfrxPropertyItem* Items[int Index] = {read=GetPropertyItem/*, default*/};
	__property TfrxPropertyList* Parent = {read=FParent};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxPropertyList(void) { }
	
};


#pragma option push -b-
enum TfrxObjectCategory { ctData, ctReport, ctDialog, ctDMP };
#pragma option pop

typedef Set<TfrxObjectCategory, ctData, ctDMP>  TfrxObjectCategories;

class DELPHICLASS TfrxObjectItem;
class PASCALIMPLEMENTATION TfrxObjectItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	Frxclass::TfrxComponentClass ClassRef;
	Graphics::TBitmap* ButtonBmp;
	int ButtonImageIndex;
	System::UnicodeString ButtonHint;
	System::UnicodeString CategoryName;
	System::Word Flags;
	TfrxObjectCategories Category;
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxObjectItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxObjectItem(void) { }
	
};


class DELPHICLASS TfrxComponentEditorItem;
class PASCALIMPLEMENTATION TfrxComponentEditorItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	Frxclass::TfrxComponentClass ComponentClass;
	TfrxComponentEditorClass ComponentEditor;
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxComponentEditorItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxComponentEditorItem(void) { }
	
};


class DELPHICLASS TfrxPropertyEditorItem;
class PASCALIMPLEMENTATION TfrxPropertyEditorItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	Typinfo::TTypeInfo *PropertyType;
	System::TClass ComponentClass;
	System::UnicodeString PropertyName;
	TfrxPropertyEditorClass EditorClass;
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxPropertyEditorItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxPropertyEditorItem(void) { }
	
};


class DELPHICLASS TfrxExportFilterItem;
class PASCALIMPLEMENTATION TfrxExportFilterItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	Frxclass::TfrxCustomExportFilter* Filter;
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxExportFilterItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxExportFilterItem(void) { }
	
};


class DELPHICLASS TfrxWizardItem;
class PASCALIMPLEMENTATION TfrxWizardItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
public:
	Frxclass::TfrxWizardClass ClassRef;
	Graphics::TBitmap* ButtonBmp;
	int ButtonImageIndex;
	bool IsToolbarWizard;
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TfrxWizardItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TfrxWizardItem(void) { }
	
};


class DELPHICLASS TfrxObjectCollection;
class PASCALIMPLEMENTATION TfrxObjectCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxObjectItem* operator[](int Index) { return Items[Index]; }
	
private:
	TfrxObjectItem* __fastcall GetObjectItem(int Index);
	
public:
	__fastcall TfrxObjectCollection(void);
	void __fastcall RegisterCategory(const System::UnicodeString CategoryName, Graphics::TBitmap* ButtonBmp, const System::UnicodeString ButtonHint, int ImageIndex = 0xffffffff);
	void __fastcall RegisterObject(Frxclass::TfrxComponentClass ClassRef, Graphics::TBitmap* ButtonBmp, const System::UnicodeString CategoryName = L"");
	void __fastcall RegisterObject1(Frxclass::TfrxComponentClass ClassRef, Graphics::TBitmap* ButtonBmp, const System::UnicodeString ButtonHint = L"", const System::UnicodeString CategoryName = L"", int Flags = 0x0, int ImageIndex = 0xffffffff, TfrxObjectCategories Category = TfrxObjectCategories() );
	void __fastcall Unregister(Frxclass::TfrxComponentClass ClassRef);
	__property TfrxObjectItem* Items[int Index] = {read=GetObjectItem/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxObjectCollection(void) { }
	
};


class DELPHICLASS TfrxComponentEditorCollection;
class PASCALIMPLEMENTATION TfrxComponentEditorCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxComponentEditorItem* operator[](int Index) { return Items[Index]; }
	
private:
	TfrxComponentEditorItem* __fastcall GetComponentEditorItem(int Index);
	
public:
	__fastcall TfrxComponentEditorCollection(void);
	void __fastcall Register(Frxclass::TfrxComponentClass ComponentClass, TfrxComponentEditorClass ComponentEditor);
	void __fastcall UnRegister(TfrxComponentEditorClass ComponentEditor);
	TfrxComponentEditor* __fastcall GetComponentEditor(Frxclass::TfrxComponent* Component, Frxclass::TfrxCustomDesigner* Designer, Menus::TMenu* Menu);
	__property TfrxComponentEditorItem* Items[int Index] = {read=GetComponentEditorItem/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxComponentEditorCollection(void) { }
	
};


class DELPHICLASS TfrxPropertyEditorCollection;
class PASCALIMPLEMENTATION TfrxPropertyEditorCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxPropertyEditorItem* operator[](int Index) { return Items[Index]; }
	
private:
	int FEventEditorItem;
	TfrxPropertyEditorItem* __fastcall GetPropertyEditorItem(int Index);
	
public:
	__fastcall TfrxPropertyEditorCollection(void);
	void __fastcall Register(Typinfo::PTypeInfo PropertyType, System::TClass ComponentClass, const System::UnicodeString PropertyName, TfrxPropertyEditorClass EditorClass);
	void __fastcall RegisterEventEditor(TfrxPropertyEditorClass EditorClass);
	void __fastcall UnRegister(TfrxPropertyEditorClass EditorClass);
	int __fastcall GetPropertyEditor(Typinfo::PTypeInfo PropertyType, Classes::TPersistent* Component, System::UnicodeString PropertyName);
	__property TfrxPropertyEditorItem* Items[int Index] = {read=GetPropertyEditorItem/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxPropertyEditorCollection(void) { }
	
};


class DELPHICLASS TfrxExportFilterCollection;
class PASCALIMPLEMENTATION TfrxExportFilterCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxExportFilterItem* operator[](int Index) { return Items[Index]; }
	
private:
	TfrxExportFilterItem* __fastcall GetExportFilterItem(int Index);
	
public:
	__fastcall TfrxExportFilterCollection(void);
	void __fastcall Register(Frxclass::TfrxCustomExportFilter* Filter);
	void __fastcall Unregister(Frxclass::TfrxCustomExportFilter* Filter);
	__property TfrxExportFilterItem* Items[int Index] = {read=GetExportFilterItem/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxExportFilterCollection(void) { }
	
};


class DELPHICLASS TfrxWizardCollection;
class PASCALIMPLEMENTATION TfrxWizardCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TfrxWizardItem* operator[](int Index) { return Items[Index]; }
	
private:
	TfrxWizardItem* __fastcall GetWizardItem(int Index);
	
public:
	__fastcall TfrxWizardCollection(void);
	void __fastcall Register(Frxclass::TfrxWizardClass ClassRef, Graphics::TBitmap* ButtonBmp, bool IsToolbarWizard = false);
	void __fastcall Register1(Frxclass::TfrxWizardClass ClassRef, int ImageIndex);
	void __fastcall Unregister(Frxclass::TfrxWizardClass ClassRef);
	__property TfrxWizardItem* Items[int Index] = {read=GetWizardItem/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TfrxWizardCollection(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall frxHideProperties(System::TClass ComponentClass, const System::UnicodeString Properties);
extern PACKAGE TfrxPropertyList* __fastcall frxCreatePropertyList(Classes::TList* ComponentList, Frxclass::TfrxCustomDesigner* Designer);
extern PACKAGE TfrxObjectCollection* __fastcall frxObjects(void);
extern PACKAGE TfrxComponentEditorCollection* __fastcall frxComponentEditors(void);
extern PACKAGE TfrxPropertyEditorCollection* __fastcall frxPropertyEditors(void);
extern PACKAGE TfrxExportFilterCollection* __fastcall frxExportFilters(void);
extern PACKAGE TfrxWizardCollection* __fastcall frxWizards(void);

}	/* namespace Frxdsgnintf */
using namespace Frxdsgnintf;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxdsgnintfHPP
