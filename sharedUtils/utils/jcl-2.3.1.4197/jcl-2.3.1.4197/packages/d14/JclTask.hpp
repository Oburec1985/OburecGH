// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Jcltask.pas' rev: 21.00

#ifndef JcltaskHPP
#define JcltaskHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Contnrs.hpp>	// Pascal unit
#include <Mstask.hpp>	// Pascal unit
#include <Jclbase.hpp>	// Pascal unit
#include <Jclsysutils.hpp>	// Pascal unit
#include <Jclsysinfo.hpp>	// Pascal unit
#include <Jclwidestrings.hpp>	// Pascal unit
#include <Jclwin32.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------
#define _di_ITaskScheduler ITaskScheduler*
#define _di_ITask ITask*
#define _di_ITaskTrigger ITaskTrigger*
#define _di_IScheduledWorkItem IScheduledWorkItem*

namespace Jcltask
{
//-- type declarations -------------------------------------------------------
typedef DynamicArray<System::TDateTime> TDateTimeArray;

#pragma option push -b-
enum TJclScheduledTaskStatus { tsUnknown, tsReady, tsRunning, tsNotScheduled, tsHasNotRun };
#pragma option pop

#pragma option push -b-
enum TJclScheduledTaskFlag { tfInteractive, tfDeleteWhenDone, tfDisabled, tfStartOnlyIfIdle, tfKillOnIdleEndl, tfDontStartIfOnBatteries, tfKillIfGoingOnBatteries, tfRunOnlyIfDocked, tfHidden, tfRunIfConnectedToInternet, tfRestartOnIdleResume, tfSystemRequired, tfRunOnlyIfLoggedOn };
#pragma option pop

typedef Set<TJclScheduledTaskFlag, tfInteractive, tfRunOnlyIfLoggedOn>  TJclScheduledTaskFlags;

#pragma option push -b-
enum TJclScheduleTaskPropertyPage { ppTask, ppSchedule, ppSettings };
#pragma option pop

typedef Set<TJclScheduleTaskPropertyPage, ppTask, ppSettings>  TJclScheduleTaskPropertyPages;

class DELPHICLASS TJclTaskSchedule;
class DELPHICLASS TJclScheduledTask;
class PASCALIMPLEMENTATION TJclTaskSchedule : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	TJclScheduledTask* operator[](const int Idx) { return Tasks[Idx]; }
	
private:
	_di_ITaskScheduler FTaskScheduler;
	Contnrs::TObjectList* FTasks;
	System::WideString __fastcall GetTargetComputer(void);
	void __fastcall SetTargetComputer(const System::WideString Value);
	TJclScheduledTask* __fastcall GetTask(const int Idx);
	int __fastcall GetTaskCount(void);
	
public:
	__fastcall TJclTaskSchedule(const System::WideString ComputerName);
	__fastcall virtual ~TJclTaskSchedule(void);
	void __fastcall Refresh(void);
	TJclScheduledTask* __fastcall Add(const System::WideString TaskName);
	void __fastcall Delete(const int Idx);
	int __fastcall Remove(const System::WideString TaskName)/* overload */;
	int __fastcall Remove(const _di_ITask TaskIntf)/* overload */;
	int __fastcall Remove(const TJclScheduledTask* ATask)/* overload */;
	__property _di_ITaskScheduler TaskScheduler = {read=FTaskScheduler};
	__property System::WideString TargetComputer = {read=GetTargetComputer, write=SetTargetComputer};
	__property TJclScheduledTask* Tasks[const int Idx] = {read=GetTask/*, default*/};
	__property int TaskCount = {read=GetTaskCount, nodefault};
	__classmethod bool __fastcall IsRunning();
	__classmethod void __fastcall Start();
	__classmethod void __fastcall Stop();
};


class DELPHICLASS TJclTaskTrigger;
class PASCALIMPLEMENTATION TJclTaskTrigger : public Classes::TCollectionItem
{
	typedef Classes::TCollectionItem inherited;
	
private:
	_di_ITaskTrigger FTaskTrigger;
	void __fastcall SetTaskTrigger(const _di_ITaskTrigger Value);
	_TASK_TRIGGER __fastcall GetTrigger(void);
	void __fastcall SetTrigger(const _TASK_TRIGGER &Value);
	System::WideString __fastcall GetTriggerString(void);
	
public:
	__property _di_ITaskTrigger TaskTrigger = {read=FTaskTrigger};
	__property _TASK_TRIGGER Trigger = {read=GetTrigger, write=SetTrigger};
	__property System::WideString TriggerString = {read=GetTriggerString};
public:
	/* TCollectionItem.Create */ inline __fastcall virtual TJclTaskTrigger(Classes::TCollection* Collection) : Classes::TCollectionItem(Collection) { }
	/* TCollectionItem.Destroy */ inline __fastcall virtual ~TJclTaskTrigger(void) { }
	
};


class DELPHICLASS TJclTaskTriggers;
class DELPHICLASS TJclScheduledWorkItem;
class PASCALIMPLEMENTATION TJclTaskTriggers : public Classes::TCollection
{
	typedef Classes::TCollection inherited;
	
public:
	TJclTaskTrigger* operator[](int Index) { return Items[Index]; }
	
public:
	TJclScheduledWorkItem* FWorkItem;
	HIDESBASE TJclTaskTrigger* __fastcall GetItem(int Index);
	HIDESBASE void __fastcall SetItem(int Index, TJclTaskTrigger* Value);
	
protected:
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
	
public:
	__fastcall TJclTaskTriggers(TJclScheduledWorkItem* AWorkItem);
	HIDESBASE TJclTaskTrigger* __fastcall Add(_di_ITaskTrigger ATrigger)/* overload */;
	HIDESBASE TJclTaskTrigger* __fastcall Add(void)/* overload */;
	TJclTaskTrigger* __fastcall AddItem(TJclTaskTrigger* Item, int Index);
	HIDESBASE TJclTaskTrigger* __fastcall Insert(int Index);
	__property TJclTaskTrigger* Items[int Index] = {read=GetItem, write=SetItem/*, default*/};
public:
	/* TCollection.Destroy */ inline __fastcall virtual ~TJclTaskTriggers(void) { }
	
};


class PASCALIMPLEMENTATION TJclScheduledWorkItem : public Classes::TPersistent
{
	typedef Classes::TPersistent inherited;
	
public:
	TJclTaskTrigger* operator[](const int Idx) { return Triggers[Idx]; }
	
private:
	_di_IScheduledWorkItem FScheduledWorkItem;
	System::WideString FTaskName;
	Classes::TMemoryStream* FData;
	TJclTaskTriggers* FTriggers;
	System::WideString __fastcall GetAccountName(void);
	void __fastcall SetAccountName(const System::WideString Value);
	void __fastcall SetPassword(const System::WideString Value);
	System::WideString __fastcall GetComment(void);
	void __fastcall SetComment(const System::WideString Value);
	System::WideString __fastcall GetCreator(void);
	void __fastcall SetCreator(const System::WideString Value);
	unsigned __fastcall GetExitCode(void);
	System::Word __fastcall GetDeadlineMinutes(void);
	System::Word __fastcall GetIdleMinutes(void);
	_SYSTEMTIME __fastcall GetMostRecentRunTime(void);
	_SYSTEMTIME __fastcall GetNextRunTime(void);
	TJclScheduledTaskStatus __fastcall GetStatus(void);
	System::Word __fastcall GetErrorRetryCount(void);
	void __fastcall SetErrorRetryCount(const System::Word Value);
	System::Word __fastcall GetErrorRetryInterval(void);
	void __fastcall SetErrorRetryInterval(const System::Word Value);
	TJclScheduledTaskFlags __fastcall GetFlags(void);
	void __fastcall SetFlags(const TJclScheduledTaskFlags Value);
	Classes::TStream* __fastcall GetData(void);
	void __fastcall SetData(const Classes::TStream* Value);
	TJclTaskTrigger* __fastcall GetTrigger(const int Idx);
	int __fastcall GetTriggerCount(void);
	
public:
	__fastcall TJclScheduledWorkItem(const System::WideString ATaskName, const _di_IScheduledWorkItem AScheduledWorkItem);
	__fastcall virtual ~TJclScheduledWorkItem(void);
	void __fastcall Save(void);
	void __fastcall Refresh(void);
	void __fastcall Run(void);
	void __fastcall Terminate(void);
	void __fastcall SetAccountInformation(const System::WideString Name, const System::WideString Password);
	TDateTimeArray __fastcall GetRunTimes(const System::TDateTime BeginTime, const System::TDateTime EndTime = 0.000000E+00);
	__property _di_IScheduledWorkItem ScheduledWorkItem = {read=FScheduledWorkItem};
	__property System::WideString TaskName = {read=FTaskName, write=FTaskName};
	__property System::WideString AccountName = {read=GetAccountName, write=SetAccountName};
	__property System::WideString Password = {write=SetPassword};
	__property System::WideString Comment = {read=GetComment, write=SetComment};
	__property System::WideString Creator = {read=GetCreator, write=SetCreator};
	__property System::Word ErrorRetryCount = {read=GetErrorRetryCount, write=SetErrorRetryCount, nodefault};
	__property System::Word ErrorRetryInterval = {read=GetErrorRetryInterval, write=SetErrorRetryInterval, nodefault};
	__property unsigned ExitCode = {read=GetExitCode, nodefault};
	__property Classes::TStream* OwnerData = {read=GetData, write=SetData};
	__property System::Word IdleMinutes = {read=GetIdleMinutes, nodefault};
	__property System::Word DeadlineMinutes = {read=GetDeadlineMinutes, nodefault};
	__property _SYSTEMTIME MostRecentRunTime = {read=GetMostRecentRunTime};
	__property _SYSTEMTIME NextRunTime = {read=GetNextRunTime};
	__property TJclScheduledTaskStatus Status = {read=GetStatus, nodefault};
	__property TJclScheduledTaskFlags Flags = {read=GetFlags, write=SetFlags, nodefault};
	__property TJclTaskTrigger* Triggers[const int Idx] = {read=GetTrigger/*, default*/};
	__property int TriggerCount = {read=GetTriggerCount, nodefault};
};


class PASCALIMPLEMENTATION TJclScheduledTask : public TJclScheduledWorkItem
{
	typedef TJclScheduledWorkItem inherited;
	
private:
	System::WideString __fastcall GetApplicationName(void);
	void __fastcall SetApplicationName(const System::WideString Value);
	unsigned __fastcall GetMaxRunTime(void);
	void __fastcall SetMaxRunTime(const unsigned Value);
	System::WideString __fastcall GetParameters(void);
	void __fastcall SetParameters(const System::WideString Value);
	unsigned __fastcall GetPriority(void);
	void __fastcall SetPriority(const unsigned Value);
	unsigned __fastcall GetTaskFlags(void);
	void __fastcall SetTaskFlags(const unsigned Value);
	System::WideString __fastcall GetWorkingDirectory(void);
	void __fastcall SetWorkingDirectory(const System::WideString Value);
	_di_ITask __fastcall GetTask(void);
	
public:
	bool __fastcall ShowPage(TJclScheduleTaskPropertyPages Pages = (TJclScheduleTaskPropertyPages() << ppTask << ppSchedule << ppSettings ));
	__property _di_ITask Task = {read=GetTask};
	__property System::WideString ApplicationName = {read=GetApplicationName, write=SetApplicationName};
	__property System::WideString WorkingDirectory = {read=GetWorkingDirectory, write=SetWorkingDirectory};
	__property unsigned MaxRunTime = {read=GetMaxRunTime, write=SetMaxRunTime, nodefault};
	__property System::WideString Parameters = {read=GetParameters, write=SetParameters};
	__property unsigned Priority = {read=GetPriority, write=SetPriority, nodefault};
	__property unsigned TaskFlags = {read=GetTaskFlags, write=SetTaskFlags, nodefault};
public:
	/* TJclScheduledWorkItem.Create */ inline __fastcall TJclScheduledTask(const System::WideString ATaskName, const _di_IScheduledWorkItem AScheduledWorkItem) : TJclScheduledWorkItem(ATaskName, AScheduledWorkItem) { }
	/* TJclScheduledWorkItem.Destroy */ inline __fastcall virtual ~TJclScheduledTask(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
#define JclScheduleTaskAllPages (Set<TJclScheduleTaskPropertyPage, ppTask, ppSettings> () << ppTask << ppSchedule << ppSettings )
#define LocalSystemAccount L"SYSTEM"
#define InfiniteTime  (0.000000E+00)
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Jcltask */
using namespace Jcltask;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// JcltaskHPP
