// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Vcard.pas' rev: 21.00

#ifndef VcardHPP
#define VcardHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Vcardbase64.hpp>	// Pascal unit
#include <Graphics.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Vcard
{
//-- type declarations -------------------------------------------------------
#pragma option push -b-
enum TvCardVersion { vvNone, vv21, vv30, vv40 };
#pragma option pop

#pragma option push -b-
enum TvPhoneType { ptText, ptVoice, ptFax, ptCell, ptVideo, ptPager, ptTextPhone };
#pragma option pop

#pragma option push -b-
enum TvFieldType { ftHome, ftWork, ftOther };
#pragma option pop

#pragma option push -b-
enum TvFileEncoding { feExternalURL, feInternalBase64 };
#pragma option pop

#pragma option push -b-
enum TvImageType { itGIF, itJPEG, itPNG };
#pragma option pop

typedef Set<TvPhoneType, ptText, ptTextPhone>  TvPhoneTypes;

class DELPHICLASS TvAddress;
class PASCALIMPLEMENTATION TvAddress : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FStreet;
	System::UnicodeString FCountry;
	System::UnicodeString FNumber;
	System::UnicodeString FPostCode;
	System::UnicodeString FCity;
	System::UnicodeString FPOBox;
	System::UnicodeString FRegion;
	TvFieldType FAddressType;
	Classes::TStringList* FMailingLabel;
	bool FPreferred;
	void __fastcall SetMailingLabel(const Classes::TStringList* Value);
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__fastcall virtual TvAddress(Classes::TCollection* Collection);
	__fastcall virtual ~TvAddress(void);
	
__published:
	__property System::UnicodeString POBox = {read=FPOBox, write=FPOBox};
	__property System::UnicodeString Number = {read=FNumber, write=FNumber};
	__property System::UnicodeString Street = {read=FStreet, write=FStreet};
	__property System::UnicodeString City = {read=FCity, write=FCity};
	__property System::UnicodeString Region = {read=FRegion, write=FRegion};
	__property System::UnicodeString PostCode = {read=FPostCode, write=FPostCode};
	__property System::UnicodeString Country = {read=FCountry, write=FCountry};
	__property TvFieldType AddressType = {read=FAddressType, write=FAddressType, nodefault};
	__property Classes::TStringList* MailingLabel = {read=FMailingLabel, write=SetMailingLabel};
	__property bool Preferred = {read=FPreferred, write=FPreferred, nodefault};
};


class DELPHICLASS TvAddressCollection;
class DELPHICLASS TvContact;
class PASCALIMPLEMENTATION TvAddressCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TvAddress* operator[](int Index) { return Items[Index]; }
	
private:
	TvContact* FOwner;
	HIDESBASE TvAddress* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TvAddress* Value);
	
public:
	System::UnicodeString __fastcall ToXml(void);
	void __fastcall LoadFromXml(System::UnicodeString XmlData);
	__fastcall TvAddressCollection(TvContact* AOwner);
	HIDESBASE TvAddress* __fastcall Add(void);
	HIDESBASE TvAddress* __fastcall Insert(int Index);
	__property TvAddress* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TvAddressCollection(void) { }
	
};


class DELPHICLASS TvPhone;
class PASCALIMPLEMENTATION TvPhone : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FPhoneNumber;
	TvPhoneTypes FPhoneType;
	bool FPreferred;
	TvFieldType FFieldType;
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property System::UnicodeString PhoneNumber = {read=FPhoneNumber, write=FPhoneNumber};
	__property TvPhoneTypes PhoneType = {read=FPhoneType, write=FPhoneType, nodefault};
	__property TvFieldType FieldType = {read=FFieldType, write=FFieldType, nodefault};
	__property bool Preferred = {read=FPreferred, write=FPreferred, nodefault};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TvPhone(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TvPhone(void) { }
	
};


class DELPHICLASS TvPhoneCollection;
class PASCALIMPLEMENTATION TvPhoneCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TvPhone* operator[](int Index) { return Items[Index]; }
	
private:
	TvContact* FOwner;
	HIDESBASE TvPhone* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TvPhone* Value);
	
public:
	System::UnicodeString __fastcall ToXml(void);
	void __fastcall LoadFromXml(System::UnicodeString XmlData);
	__fastcall TvPhoneCollection(TvContact* AOwner);
	HIDESBASE TvPhone* __fastcall Add(void);
	HIDESBASE TvPhone* __fastcall Insert(int Index);
	__property TvPhone* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TvPhoneCollection(void) { }
	
};


class DELPHICLASS TvEmail;
class PASCALIMPLEMENTATION TvEmail : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FEmailAddress;
	TvFieldType FEmailType;
	bool FPreferred;
	void __fastcall SetEmailAddress(const System::UnicodeString Value);
	void __fastcall SetEmailType(const TvFieldType Value);
	void __fastcall SetPreferred(const bool Value);
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__fastcall virtual TvEmail(Classes::TCollection* Collection);
	__fastcall virtual ~TvEmail(void);
	
__published:
	__property System::UnicodeString EmailAddress = {read=FEmailAddress, write=SetEmailAddress};
	__property TvFieldType EmailType = {read=FEmailType, write=SetEmailType, nodefault};
	__property bool Preferred = {read=FPreferred, write=SetPreferred, nodefault};
};


class DELPHICLASS TvEmailCollection;
class PASCALIMPLEMENTATION TvEmailCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TvEmail* operator[](int Index) { return Items[Index]; }
	
private:
	TvContact* FOwner;
	TvEmail* __fastcall GetEmail(int Index);
	void __fastcall SetEmail(int Index, const TvEmail* Value);
	
public:
	System::UnicodeString __fastcall ToXml(void);
	void __fastcall LoadFromXml(System::UnicodeString XmlData);
	__fastcall TvEmailCollection(TvContact* AOwner);
	HIDESBASE TvEmail* __fastcall Add(void);
	HIDESBASE TvEmail* __fastcall Insert(int Index);
	__property TvEmail* Items[int Index] = {read=GetEmail, write=SetEmail/*, default*/};
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TvEmailCollection(void) { }
	
};


class DELPHICLASS TvGeoLocation;
class PASCALIMPLEMENTATION TvGeoLocation : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
private:
	double FLatitude;
	double FLongitude;
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property double Latitude = {read=FLatitude, write=FLatitude};
	__property double Longitude = {read=FLongitude, write=FLongitude};
public:
	/* TPersistent.Destroy */ inline __fastcall virtual ~TvGeoLocation(void) { }
	
public:
	/* TObject.Create */ inline __fastcall TvGeoLocation(void) : Classes::TPersistent() { }
	
};


class DELPHICLASS TvSocialItem;
class PASCALIMPLEMENTATION TvSocialItem : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FService;
	System::UnicodeString FURI;
	System::UnicodeString FUser;
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	
__published:
	__property System::UnicodeString URI = {read=FURI, write=FURI};
	__property System::UnicodeString Service = {read=FService, write=FService};
	__property System::UnicodeString User = {read=FUser, write=FUser};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TvSocialItem(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TvSocialItem(void) { }
	
};


class DELPHICLASS TvSocialProfile;
class PASCALIMPLEMENTATION TvSocialProfile : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TvSocialItem* operator[](int Index) { return Items[Index]; }
	
private:
	TvContact* FOwner;
	HIDESBASE TvSocialItem* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, const TvSocialItem* Value);
	
public:
	__fastcall TvSocialProfile(TvContact* AOwner);
	HIDESBASE TvSocialItem* __fastcall Add(void);
	HIDESBASE TvSocialItem* __fastcall Insert(int Index);
	__property TvSocialItem* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TvSocialProfile(void) { }
	
};


class PASCALIMPLEMENTATION TvContact : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::UnicodeString FProfession;
	System::TDateTime FBirthDay;
	System::UnicodeString FCompany;
	System::UnicodeString FNickName;
	System::UnicodeString FFullName;
	System::UnicodeString FJobTitle;
	TvEmailCollection* FEmails;
	TvPhoneCollection* FPhoneNumbers;
	System::UnicodeString FWebsiteURL;
	TvAddressCollection* FAddresses;
	System::UnicodeString FLastName;
	System::UnicodeString FFirstName;
	System::UnicodeString FNameSuffix;
	System::UnicodeString FMiddleName;
	System::UnicodeString FNamePrefix;
	TvCardVersion FvCardVersion;
	Classes::TStringList* FCategories;
	TvGeoLocation* FGeoLocation;
	TvSocialProfile* FSocialProfile;
	Classes::TStringList* FNote;
	System::TDateTime FUpdated;
	System::UnicodeString FSource;
	System::UnicodeString FID;
	System::UnicodeString FPhotoURL;
	System::UnicodeString FPhotoStr;
	System::UnicodeString FSortString;
	System::UnicodeString FTimeZone;
	TvImageType FPhotoType;
	TvFileEncoding FPhotoEncoding;
	Graphics::TPicture* FPhoto;
	System::UnicodeString FProdID;
	void __fastcall SetBirthDay(const System::TDateTime Value);
	void __fastcall SetCompany(const System::UnicodeString Value);
	void __fastcall SetFullName(const System::UnicodeString Value);
	void __fastcall SetJobTitle(const System::UnicodeString Value);
	void __fastcall SetNickName(const System::UnicodeString Value);
	void __fastcall SetFProfession(const System::UnicodeString Value);
	void __fastcall SetWebsiteURL(const System::UnicodeString Value);
	void __fastcall SetFirstName(const System::UnicodeString Value);
	void __fastcall SetLastName(const System::UnicodeString Value);
	void __fastcall SetMiddleName(const System::UnicodeString Value);
	void __fastcall SetNamePrefix(const System::UnicodeString Value);
	void __fastcall SetNameSuffix(const System::UnicodeString Value);
	void __fastcall SetvCardVersion(const TvCardVersion Value);
	void __fastcall SetCategories(const Classes::TStringList* Value);
	void __fastcall SetNote(const Classes::TStringList* Value);
	void __fastcall SetUpdated(const System::TDateTime Value);
	void __fastcall SetSource(const System::UnicodeString Value);
	void __fastcall SetID(const System::UnicodeString Value);
	void __fastcall SetPhotoURL(const System::UnicodeString Value);
	void __fastcall SetSortString(const System::UnicodeString Value);
	void __fastcall SetTimeZone(const System::UnicodeString Value);
	void __fastcall SetPhotoEncoding(const TvFileEncoding Value);
	void __fastcall SetPhotoType(const TvImageType Value);
	void __fastcall SetPhoto(const Graphics::TPicture* Value);
	void __fastcall SetAddresses(const TvAddressCollection* Value);
	void __fastcall SetEmails(const TvEmailCollection* Value);
	void __fastcall SetPhoneNumbers(const TvPhoneCollection* Value);
	void __fastcall SetSocialProfile(const TvSocialProfile* Value);
	
protected:
	__property System::UnicodeString PhotoStr = {read=FPhotoStr, write=FPhotoStr};
	void __fastcall DecodePhoto(void);
	void __fastcall EncodePhoto(void);
	
public:
	virtual void __fastcall Assign(Classes::TPersistent* Source);
	__fastcall virtual TvContact(Classes::TCollection* Collection);
	__fastcall virtual ~TvContact(void);
	
__published:
	__property System::UnicodeString ID = {read=FID, write=SetID};
	__property System::UnicodeString FirstName = {read=FFirstName, write=SetFirstName};
	__property System::UnicodeString LastName = {read=FLastName, write=SetLastName};
	__property System::UnicodeString MiddleName = {read=FMiddleName, write=SetMiddleName};
	__property System::UnicodeString NamePrefix = {read=FNamePrefix, write=SetNamePrefix};
	__property System::UnicodeString NameSuffix = {read=FNameSuffix, write=SetNameSuffix};
	__property System::UnicodeString FullName = {read=FFullName, write=SetFullName};
	__property System::UnicodeString NickName = {read=FNickName, write=SetNickName};
	__property System::UnicodeString Company = {read=FCompany, write=SetCompany};
	__property System::UnicodeString JobTitle = {read=FJobTitle, write=SetJobTitle};
	__property System::TDateTime BirthDay = {read=FBirthDay, write=SetBirthDay};
	__property System::UnicodeString Profession = {read=FProfession, write=SetFProfession};
	__property System::UnicodeString WebsiteURL = {read=FWebsiteURL, write=SetWebsiteURL};
	__property TvEmailCollection* Emails = {read=FEmails, write=SetEmails};
	__property TvPhoneCollection* PhoneNumbers = {read=FPhoneNumbers, write=SetPhoneNumbers};
	__property TvAddressCollection* Addresses = {read=FAddresses, write=SetAddresses};
	__property TvCardVersion vCardVersion = {read=FvCardVersion, write=SetvCardVersion, default=2};
	__property Classes::TStringList* Categories = {read=FCategories, write=SetCategories};
	__property TvGeoLocation* GeoLocation = {read=FGeoLocation, write=FGeoLocation};
	__property Classes::TStringList* Note = {read=FNote, write=SetNote};
	__property System::TDateTime Updated = {read=FUpdated, write=SetUpdated};
	__property System::UnicodeString Source = {read=FSource, write=SetSource};
	__property Graphics::TPicture* Photo = {read=FPhoto, write=SetPhoto};
	__property System::UnicodeString PhotoURL = {read=FPhotoURL, write=SetPhotoURL};
	__property TvFileEncoding PhotoEncoding = {read=FPhotoEncoding, write=SetPhotoEncoding, default=1};
	__property TvImageType PhotoType = {read=FPhotoType, write=SetPhotoType, default=1};
	__property System::UnicodeString ProdID = {read=FProdID, write=FProdID};
	__property TvSocialProfile* SocialProfile = {read=FSocialProfile, write=SetSocialProfile};
	__property System::UnicodeString SortString = {read=FSortString, write=SetSortString};
	__property System::UnicodeString TimeZone = {read=FTimeZone, write=SetTimeZone};
};


class DELPHICLASS TvContactsCollection;
class DELPHICLASS TvCard;
class PASCALIMPLEMENTATION TvContactsCollection : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TvContact* operator[](int Index) { return Items[Index]; }
	
private:
	TvCard* FOwner;
	TvContact* __fastcall GetvContact(int Index);
	void __fastcall SetvContact(int Index, const TvContact* Value);
	
public:
	__fastcall TvContactsCollection(TvCard* AOwner);
	HIDESBASE TvContact* __fastcall Add(void);
	HIDESBASE TvContact* __fastcall Insert(int Index);
	__property TvContact* Items[int Index] = {read=GetvContact, write=SetvContact/*, default*/};
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TvContactsCollection(void) { }
	
};


class PASCALIMPLEMENTATION TvCard : public Classes::TComponent
{
	typedef Classes::TComponent inherited;
	
private:
	TvContactsCollection* FvContacts;
	System::UnicodeString FProdID;
	TvContactsCollection* __fastcall GetvContacts(void);
	void __fastcall SetvContacts(const TvContactsCollection* Value);
	System::UnicodeString __fastcall GeneratevCard(TvContact* vContact);
	
public:
	__fastcall virtual TvCard(Classes::TComponent* AOwner);
	__fastcall virtual ~TvCard(void);
	void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall InsertFromStream(Classes::TStream* Stream);
	System::UnicodeString __fastcall SaveToString(void);
	void __fastcall SaveToStream(Classes::TStream* Stream);
	void __fastcall LoadFromFile(const System::UnicodeString FileName);
	void __fastcall InsertFromFile(const System::UnicodeString FileName);
	void __fastcall SaveToFile(const System::UnicodeString FileName, TvContact* vContact)/* overload */;
	void __fastcall SaveToFile(const System::UnicodeString FileName)/* overload */;
	
__published:
	__property TvContactsCollection* vContacts = {read=GetvContacts, write=SetvContacts};
	__property System::UnicodeString ProdID = {read=FProdID, write=FProdID};
};


class DELPHICLASS TFileStringList;
class PASCALIMPLEMENTATION TFileStringList : public Classes::TStringList
{
	typedef Classes::TStringList inherited;
	
private:
	int fp;
	System::UnicodeString cache;
	bool __fastcall GetEOF(void);
	
public:
	void __fastcall Reset(void);
	void __fastcall ReadLn(System::UnicodeString &s);
	void __fastcall Write(System::UnicodeString s);
	void __fastcall WriteLn(System::UnicodeString s);
	__property bool Eof = {read=GetEOF, nodefault};
public:
	/* TStringList.Create */ inline __fastcall TFileStringList(void)/* overload */ : Classes::TStringList() { }
	/* TStringList.Destroy */ inline __fastcall virtual ~TFileStringList(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt MAJ_VER = 0x1;
static const ShortInt MIN_VER = 0x1;
static const ShortInt REL_VER = 0x0;
static const ShortInt BLD_VER = 0x7;

}	/* namespace Vcard */
using namespace Vcard;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// VcardHPP
