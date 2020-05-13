// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Frxexportmail.pas' rev: 21.00

#ifndef FrxexportmailHPP
#define FrxexportmailHPP

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
#include <Stdctrls.hpp>	// Pascal unit
#include <Extctrls.hpp>	// Pascal unit
#include <Frxclass.hpp>	// Pascal unit
#include <Inifiles.hpp>	// Pascal unit
#include <Comctrls.hpp>	// Pascal unit
#include <Frxsmtp.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Frxexportmail
{
//-- type declarations -------------------------------------------------------
typedef System::UnicodeString __fastcall (__closure *TfrxOnSendMailEvent)(const System::UnicodeString Server, const int Port, const System::UnicodeString UserField, const System::UnicodeString PasswordField, System::WideString FromField, System::WideString ToField, System::WideString SubjectField, System::WideString CompanyField, System::WideString TextField, Classes::TStringList* FileNames, int Timeout, bool ConfurmReading);

class DELPHICLASS TfrxMailExportDialog;
class PASCALIMPLEMENTATION TfrxMailExportDialog : public Forms::TForm
{
	typedef Forms::TForm inherited;
	
__published:
	Stdctrls::TButton* OkB;
	Stdctrls::TButton* CancelB;
	Comctrls::TPageControl* PageControl1;
	Comctrls::TTabSheet* ExportSheet;
	Stdctrls::TGroupBox* MessageGroup;
	Stdctrls::TLabel* AddressLB;
	Stdctrls::TLabel* SubjectLB;
	Stdctrls::TLabel* MessageLB;
	Stdctrls::TMemo* MessageM;
	Stdctrls::TGroupBox* AttachGroup;
	Stdctrls::TComboBox* ExportsCombo;
	Stdctrls::TLabel* FormatLB;
	Stdctrls::TCheckBox* SettingCB;
	Comctrls::TTabSheet* AccountSheet;
	Stdctrls::TGroupBox* MailGroup;
	Stdctrls::TCheckBox* RememberCB;
	Stdctrls::TGroupBox* AccountGroup;
	Stdctrls::TEdit* FromNameE;
	Stdctrls::TLabel* FromNameLB;
	Stdctrls::TEdit* FromAddrE;
	Stdctrls::TLabel* FromAddrLB;
	Stdctrls::TLabel* OrgLB;
	Stdctrls::TEdit* OrgE;
	Stdctrls::TLabel* SignatureLB;
	Stdctrls::TMemo* SignatureM;
	Stdctrls::TLabel* HostLB;
	Stdctrls::TEdit* HostE;
	Stdctrls::TEdit* PortE;
	Stdctrls::TLabel* PortLB;
	Stdctrls::TLabel* LoginLB;
	Stdctrls::TEdit* LoginE;
	Stdctrls::TEdit* PasswordE;
	Stdctrls::TLabel* PasswordLB;
	Stdctrls::TButton* SignBuildBtn;
	Stdctrls::TComboBox* AddressE;
	Stdctrls::TComboBox* SubjectE;
	Stdctrls::TLabel* ReqLB;
	Stdctrls::TLabel* TimeoutLB;
	Stdctrls::TEdit* TimeoutE;
	Stdctrls::TCheckBox* ReadingCB;
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall SignBuildBtnClick(System::TObject* Sender);
	void __fastcall OkBClick(System::TObject* Sender);
	void __fastcall PortEKeyPress(System::TObject* Sender, System::WideChar &Key);
	void __fastcall FormKeyDown(System::TObject* Sender, System::Word &Key, Classes::TShiftState Shift);
public:
	/* TCustomForm.Create */ inline __fastcall virtual TfrxMailExportDialog(Classes::TComponent* AOwner) : Forms::TForm(AOwner) { }
	/* TCustomForm.CreateNew */ inline __fastcall virtual TfrxMailExportDialog(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(AOwner, Dummy) { }
	/* TCustomForm.Destroy */ inline __fastcall virtual ~TfrxMailExportDialog(void) { }
	
public:
	/* TWinControl.CreateParented */ inline __fastcall TfrxMailExportDialog(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
	
};


class DELPHICLASS TfrxMailExport;
class PASCALIMPLEMENTATION TfrxMailExport : public Frxclass::TfrxCustomExportFilter
{
	typedef Frxclass::TfrxCustomExportFilter inherited;
	
private:
	Frxclass::TfrxCustomExportFilter* FExportFilter;
	System::UnicodeString FAddress;
	System::UnicodeString FSubject;
	Classes::TStrings* FMessage;
	bool FShowExportDialog;
	bool FOldSlaveStatus;
	System::UnicodeString FFromName;
	System::UnicodeString FFromMail;
	System::UnicodeString FFromCompany;
	Classes::TStrings* FSignature;
	System::UnicodeString FSmtpHost;
	int FSmtpPort;
	System::UnicodeString FLogin;
	System::UnicodeString FPassword;
	bool FUseIniFile;
	System::UnicodeString FLogFile;
	int FTimeOut;
	bool FConfurmReading;
	TfrxOnSendMailEvent FOnSendMail;
	void __fastcall SetMessage(const Classes::TStrings* Value);
	void __fastcall SetSignature(const Classes::TStrings* Value);
	
protected:
	__property DefaultPath;
	__property Stream;
	__property CurPage;
	__property PageNumbers;
	__property FileName;
	__property UseFileCache;
	__property ExportNotPrintable = {default=0};
	
public:
	__fastcall virtual TfrxMailExport(Classes::TComponent* AOwner);
	__fastcall virtual ~TfrxMailExport(void);
	__classmethod virtual System::UnicodeString __fastcall GetDescription();
	virtual Controls::TModalResult __fastcall ShowModal(void);
	virtual bool __fastcall Start(void);
	System::UnicodeString __fastcall Mail(const System::UnicodeString Server, const int Port, const System::UnicodeString UserField, const System::UnicodeString PasswordField, System::WideString FromField, System::WideString ToField, System::WideString SubjectField, System::WideString CompanyField, System::WideString TextField, Classes::TStringList* FileNames, int Timeout = 0x3c, bool ConfurmReading = false);
	virtual void __fastcall ExportObject(Frxclass::TfrxComponent* Obj);
	__property Frxclass::TfrxCustomExportFilter* ExportFilter = {read=FExportFilter, write=FExportFilter};
	
__published:
	__property System::UnicodeString Address = {read=FAddress, write=FAddress};
	__property System::UnicodeString Subject = {read=FSubject, write=FSubject};
	__property Classes::TStrings* Lines = {read=FMessage, write=SetMessage};
	__property bool ShowExportDialog = {read=FShowExportDialog, write=FShowExportDialog, nodefault};
	__property System::UnicodeString FromMail = {read=FFromMail, write=FFromMail};
	__property System::UnicodeString FromName = {read=FFromName, write=FFromName};
	__property System::UnicodeString FromCompany = {read=FFromCompany, write=FFromCompany};
	__property Classes::TStrings* Signature = {read=FSignature, write=SetSignature};
	__property System::UnicodeString SmtpHost = {read=FSmtpHost, write=FSmtpHost};
	__property int SmtpPort = {read=FSmtpPort, write=FSmtpPort, nodefault};
	__property System::UnicodeString Login = {read=FLogin, write=FLogin};
	__property System::UnicodeString Password = {read=FPassword, write=FPassword};
	__property bool UseIniFile = {read=FUseIniFile, write=FUseIniFile, nodefault};
	__property System::UnicodeString LogFile = {read=FLogFile, write=FLogFile};
	__property int TimeOut = {read=FTimeOut, write=FTimeOut, nodefault};
	__property bool ConfurmReading = {read=FConfurmReading, write=FConfurmReading, nodefault};
	__property TfrxOnSendMailEvent OnSendMail = {read=FOnSendMail, write=FOnSendMail};
public:
	/* TfrxCustomExportFilter.CreateNoRegister */ inline __fastcall TfrxMailExport(void) : Frxclass::TfrxCustomExportFilter() { }
	
};


//-- var, const, procedure ---------------------------------------------------

}	/* namespace Frxexportmail */
using namespace Frxexportmail;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// FrxexportmailHPP
