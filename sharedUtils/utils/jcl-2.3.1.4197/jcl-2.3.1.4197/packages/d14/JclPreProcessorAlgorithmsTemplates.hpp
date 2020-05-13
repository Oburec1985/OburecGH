// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jclpreprocessoralgorithmstemplates.pas' rev: 21.00

#ifndef JclpreprocessoralgorithmstemplatesHPP
#define JclpreprocessoralgorithmstemplatesHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Jclpreprocessorcontainertypes.hpp>	// Pascal unit
#include <Jclpreprocessorcontainertemplates.hpp>	// Pascal unit
#include <Jclpreprocessorcontainer1dtemplates.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Jclpreprocessoralgorithmstemplates
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TJclAlgorithmsIntParams;
class PASCALIMPLEMENTATION TJclAlgorithmsIntParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams inherited;
	
public:
	/* TObject.Create */ inline __fastcall TJclAlgorithmsIntParams(void) : Jclpreprocessorcontainer1dtemplates::TJclContainerInterfaceParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAlgorithmsIntParams(void) { }
	
};


class DELPHICLASS TJclAlgorithmsIntProcParams;
class PASCALIMPLEMENTATION TJclAlgorithmsIntProcParams : public TJclAlgorithmsIntParams
{
	typedef TJclAlgorithmsIntParams inherited;
	
protected:
	System::UnicodeString FOverload;
	System::UnicodeString FProcName;
	virtual System::UnicodeString __fastcall GetProcName(void);
	bool __fastcall IsProcNameStored(void);
	
public:
	__property System::UnicodeString Overload = {read=FOverload, write=FOverload};
	__property System::UnicodeString ProcName = {read=GetProcName, write=FProcName, stored=IsProcNameStored};
public:
	/* TObject.Create */ inline __fastcall TJclAlgorithmsIntProcParams(void) : TJclAlgorithmsIntParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAlgorithmsIntProcParams(void) { }
	
};


class DELPHICLASS TJclAlgorithmsImpProcParams;
class PASCALIMPLEMENTATION TJclAlgorithmsImpProcParams : public Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams
{
	typedef Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams inherited;
	
protected:
	System::UnicodeString __fastcall GetProcName(void);
	void __fastcall SetProcName(const System::UnicodeString Value);
	
public:
	__property System::UnicodeString ProcName = {read=GetProcName, write=SetProcName, stored=false};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclAlgorithmsImpProcParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : Jclpreprocessorcontainer1dtemplates::TJclContainerImplementationParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclAlgorithmsImpProcParams(void) { }
	
};


class DELPHICLASS TJclMoveArrayIntParams;
class PASCALIMPLEMENTATION TJclMoveArrayIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property Overload;
	__property ProcName;
	__property System::UnicodeString DynArrayTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=17};
public:
	/* TObject.Create */ inline __fastcall TJclMoveArrayIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMoveArrayIntParams(void) { }
	
};


class DELPHICLASS TJclMoveArrayImpParams;
class PASCALIMPLEMENTATION TJclMoveArrayImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString DynArrayTypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=17};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclMoveArrayImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclMoveArrayImpParams(void) { }
	
};


class DELPHICLASS TJclIterateIntParams;
class PASCALIMPLEMENTATION TJclIterateIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property Overload;
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=21};
public:
	/* TObject.Create */ inline __fastcall TJclIterateIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIterateIntParams(void) { }
	
};


class DELPHICLASS TJclIterateImpParams;
class PASCALIMPLEMENTATION TJclIterateImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=21};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclIterateImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclIterateImpParams(void) { }
	
};


class DELPHICLASS TJclApplyIntParams;
class PASCALIMPLEMENTATION TJclApplyIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property Overload;
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=22};
public:
	/* TObject.Create */ inline __fastcall TJclApplyIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclApplyIntParams(void) { }
	
};


class DELPHICLASS TJclApplyImpParams;
class PASCALIMPLEMENTATION TJclApplyImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=22};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclApplyImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclApplyImpParams(void) { }
	
};


class DELPHICLASS TJclSimpleCompareIntParams;
class PASCALIMPLEMENTATION TJclSimpleCompareIntParams : public TJclAlgorithmsIntParams
{
	typedef TJclAlgorithmsIntParams inherited;
	
__published:
	__property System::UnicodeString ProcName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=24};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclSimpleCompareIntParams(void) : TJclAlgorithmsIntParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleCompareIntParams(void) { }
	
};


class DELPHICLASS TJclSimpleEqualityCompareIntParams;
class PASCALIMPLEMENTATION TJclSimpleEqualityCompareIntParams : public TJclAlgorithmsIntParams
{
	typedef TJclAlgorithmsIntParams inherited;
	
__published:
	__property System::UnicodeString ProcName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=26};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclSimpleEqualityCompareIntParams(void) : TJclAlgorithmsIntParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleEqualityCompareIntParams(void) { }
	
};


class DELPHICLASS TJclSimpleHashConvertIntParams;
class PASCALIMPLEMENTATION TJclSimpleHashConvertIntParams : public TJclAlgorithmsIntParams
{
	typedef TJclAlgorithmsIntParams inherited;
	
__published:
	__property System::UnicodeString ProcName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=IsTypeAttributeStored, index=28};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclSimpleHashConvertIntParams(void) : TJclAlgorithmsIntParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSimpleHashConvertIntParams(void) { }
	
};


class DELPHICLASS TJclFindIntParams;
class PASCALIMPLEMENTATION TJclFindIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
public:
	/* TObject.Create */ inline __fastcall TJclFindIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclFindIntParams(void) { }
	
};


class DELPHICLASS TJclFindImpParams;
class PASCALIMPLEMENTATION TJclFindImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclFindImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclFindImpParams(void) { }
	
};


class DELPHICLASS TJclFindEqIntParams;
class PASCALIMPLEMENTATION TJclFindEqIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=25};
public:
	/* TObject.Create */ inline __fastcall TJclFindEqIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclFindEqIntParams(void) { }
	
};


class DELPHICLASS TJclFindEqImpParams;
class PASCALIMPLEMENTATION TJclFindEqImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=25};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclFindEqImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclFindEqImpParams(void) { }
	
};


class DELPHICLASS TJclCountObjectIntParams;
class PASCALIMPLEMENTATION TJclCountObjectIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
public:
	/* TObject.Create */ inline __fastcall TJclCountObjectIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCountObjectIntParams(void) { }
	
};


class DELPHICLASS TJclCountObjectImpParams;
class PASCALIMPLEMENTATION TJclCountObjectImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclCountObjectImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCountObjectImpParams(void) { }
	
};


class DELPHICLASS TJclCountObjectEqIntParams;
class PASCALIMPLEMENTATION TJclCountObjectEqIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=25};
public:
	/* TObject.Create */ inline __fastcall TJclCountObjectEqIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCountObjectEqIntParams(void) { }
	
};


class DELPHICLASS TJclCountObjectEqImpParams;
class PASCALIMPLEMENTATION TJclCountObjectEqImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=25};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclCountObjectEqImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCountObjectEqImpParams(void) { }
	
};


class DELPHICLASS TJclCopyIntParams;
class PASCALIMPLEMENTATION TJclCopyIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
public:
	/* TObject.Create */ inline __fastcall TJclCopyIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCopyIntParams(void) { }
	
};


class DELPHICLASS TJclCopyImpParams;
class PASCALIMPLEMENTATION TJclCopyImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclCopyImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclCopyImpParams(void) { }
	
};


class DELPHICLASS TJclGenerateIntParams;
class PASCALIMPLEMENTATION TJclGenerateIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclGenerateIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclGenerateIntParams(void) { }
	
};


class DELPHICLASS TJclGenerateImpParams;
class PASCALIMPLEMENTATION TJclGenerateImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclGenerateImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclGenerateImpParams(void) { }
	
};


class DELPHICLASS TJclFillIntParams;
class PASCALIMPLEMENTATION TJclFillIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
public:
	/* TObject.Create */ inline __fastcall TJclFillIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclFillIntParams(void) { }
	
};


class DELPHICLASS TJclFillImpParams;
class PASCALIMPLEMENTATION TJclFillImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString ConstKeyword = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=7};
	__property System::UnicodeString ParameterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=16};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclFillImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclFillImpParams(void) { }
	
};


class DELPHICLASS TJclReverseIntParams;
class PASCALIMPLEMENTATION TJclReverseIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
public:
	/* TObject.Create */ inline __fastcall TJclReverseIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclReverseIntParams(void) { }
	
};


class DELPHICLASS TJclReverseImpParams;
class PASCALIMPLEMENTATION TJclReverseImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
__published:
	__property ProcName;
	__property System::UnicodeString ItrInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=39};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclReverseImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclReverseImpParams(void) { }
	
};


class DELPHICLASS TJclSortIntParams;
class PASCALIMPLEMENTATION TJclSortIntParams : public TJclAlgorithmsIntProcParams
{
	typedef TJclAlgorithmsIntProcParams inherited;
	
private:
	System::UnicodeString FLeft;
	System::UnicodeString FRight;
	System::UnicodeString __fastcall GetLeft(void);
	System::UnicodeString __fastcall GetRight(void);
	bool __fastcall IsLeftStored(void);
	bool __fastcall IsRightStored(void);
	
protected:
	virtual System::UnicodeString __fastcall GetProcName(void);
	
__published:
	__property ProcName;
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString Left = {read=GetLeft, write=FLeft, stored=IsLeftStored};
	__property System::UnicodeString Right = {read=GetRight, write=FRight, stored=IsRightStored};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
public:
	/* TObject.Create */ inline __fastcall TJclSortIntParams(void) : TJclAlgorithmsIntProcParams() { }
	/* TObject.Destroy */ inline __fastcall virtual ~TJclSortIntParams(void) { }
	
};


class DELPHICLASS TJclQuickSortImpParams;
class PASCALIMPLEMENTATION TJclQuickSortImpParams : public TJclAlgorithmsImpProcParams
{
	typedef TJclAlgorithmsImpProcParams inherited;
	
private:
	System::UnicodeString __fastcall GetLeft(void);
	System::UnicodeString __fastcall GetRight(void);
	void __fastcall SetLeft(const System::UnicodeString Value);
	void __fastcall SetRight(const System::UnicodeString Value);
	
__published:
	__property ProcName;
	__property System::UnicodeString ListInterfaceName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=51};
	__property System::UnicodeString Left = {read=GetLeft, write=SetLeft, stored=false};
	__property System::UnicodeString Right = {read=GetRight, write=SetRight, stored=false};
	__property System::UnicodeString CallbackType = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=23};
	__property System::UnicodeString TypeName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=0};
	__property System::UnicodeString GetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=14};
	__property System::UnicodeString SetterName = {read=GetTypeAttribute, write=SetTypeAttribute, stored=false, index=15};
public:
	/* TJclImplementationParams.Create */ inline __fastcall TJclQuickSortImpParams(Jclpreprocessorcontainertypes::TJclInterfaceParams* AInterfaceParams) : TJclAlgorithmsImpProcParams(AInterfaceParams) { }
	
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TJclQuickSortImpParams(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jclpreprocessoralgorithmstemplates */
using namespace Jclpreprocessoralgorithmstemplates;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JclpreprocessoralgorithmstemplatesHPP
