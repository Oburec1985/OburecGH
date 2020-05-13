// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Mscorlib_tlb.pas' rev: 21.00

#ifndef Mscorlib_tlbHPP
#define Mscorlib_tlbHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Jclunitversioning.hpp>	// Pascal unit
#include <Activex.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Mscorlib_tlb
{
//-- type declarations -------------------------------------------------------
typedef Activex::TOleEnum LoaderOptimization;

typedef Activex::TOleEnum AttributeTargets;

typedef Activex::TOleEnum DayOfWeek;

typedef Activex::TOleEnum SpecialFolder;

typedef Activex::TOleEnum PlatformID;

typedef Activex::TOleEnum TypeCode;

typedef Activex::TOleEnum ApartmentState;

typedef Activex::TOleEnum ThreadPriority;

typedef Activex::TOleEnum ThreadState;

typedef Activex::TOleEnum SymAddressKind;

typedef Activex::TOleEnum AssemblyNameFlags;

typedef Activex::TOleEnum BindingFlags;

typedef Activex::TOleEnum CallingConventions;

typedef Activex::TOleEnum EventAttributes;

typedef Activex::TOleEnum FieldAttributes;

typedef Activex::TOleEnum ResourceLocation;

typedef Activex::TOleEnum MemberTypes;

typedef Activex::TOleEnum MethodAttributes;

typedef Activex::TOleEnum MethodImplAttributes;

typedef Activex::TOleEnum ParameterAttributes;

typedef Activex::TOleEnum PropertyAttributes;

typedef Activex::TOleEnum ResourceAttributes;

typedef Activex::TOleEnum TypeAttributes;

typedef Activex::TOleEnum StreamingContextStates;

typedef Activex::TOleEnum CalendarWeekRule;

typedef Activex::TOleEnum CompareOptions;

typedef Activex::TOleEnum CultureTypes;

typedef Activex::TOleEnum DateTimeStyles;

typedef Activex::TOleEnum GregorianCalendarTypes;

typedef Activex::TOleEnum NumberStyles;

typedef Activex::TOleEnum UnicodeCategory;

typedef Activex::TOleEnum RegistryHive;

typedef Activex::TOleEnum FromBase64TransformMode;

typedef Activex::TOleEnum CipherMode;

typedef Activex::TOleEnum PaddingMode;

typedef Activex::TOleEnum CspProviderFlags;

typedef Activex::TOleEnum CryptoStreamMode;

typedef Activex::TOleEnum PolicyStatementAttribute;

typedef Activex::TOleEnum PrincipalPolicy;

typedef Activex::TOleEnum WindowsAccountType;

typedef Activex::TOleEnum WindowsBuiltInRole;

typedef Activex::TOleEnum ComInterfaceType;

typedef Activex::TOleEnum ClassInterfaceType;

typedef Activex::TOleEnum IDispatchImplType;

typedef Activex::TOleEnum TypeLibTypeFlags;

typedef Activex::TOleEnum TypeLibFuncFlags;

typedef Activex::TOleEnum TypeLibVarFlags;

typedef Activex::TOleEnum VarEnum;

typedef Activex::TOleEnum UnmanagedType;

typedef Activex::TOleEnum CallingConvention;

typedef Activex::TOleEnum CharSet;

typedef Activex::TOleEnum ComMemberType;

typedef Activex::TOleEnum GCHandleType;

typedef Activex::TOleEnum AssemblyRegistrationFlags;

typedef Activex::TOleEnum TypeLibImporterFlags;

typedef Activex::TOleEnum TypeLibExporterFlags;

typedef Activex::TOleEnum ImporterEventKind;

typedef Activex::TOleEnum ExporterEventKind;

typedef Activex::TOleEnum LayoutKind;

typedef Activex::TOleEnum FileAccess;

typedef Activex::TOleEnum FileMode;

typedef Activex::TOleEnum FileShare;

typedef Activex::TOleEnum FileAttributes;

typedef Activex::TOleEnum SeekOrigin;

typedef Activex::TOleEnum MethodImplOptions;

typedef Activex::TOleEnum MethodCodeType;

typedef Activex::TOleEnum EnvironmentPermissionAccess;

typedef Activex::TOleEnum FileDialogPermissionAccess;

typedef Activex::TOleEnum FileIOPermissionAccess;

typedef Activex::TOleEnum IsolatedStorageContainment;

typedef Activex::TOleEnum PermissionState;

typedef Activex::TOleEnum SecurityAction;

typedef Activex::TOleEnum ReflectionPermissionFlag;

typedef Activex::TOleEnum RegistryPermissionAccess;

typedef Activex::TOleEnum SecurityPermissionFlag;

typedef Activex::TOleEnum UIPermissionWindow;

typedef Activex::TOleEnum UIPermissionClipboard;

typedef Activex::TOleEnum PolicyLevelType;

typedef Activex::TOleEnum SecurityZone;

typedef Activex::TOleEnum WellKnownObjectMode;

typedef Activex::TOleEnum ActivatorLevel;

typedef Activex::TOleEnum ServerProcessing;

typedef Activex::TOleEnum LeaseState;

typedef Activex::TOleEnum SoapOption;

typedef Activex::TOleEnum XmlFieldOrderOption;

typedef Activex::TOleEnum IsolatedStorageScope;

typedef Activex::TOleEnum FormatterTypeStyle;

typedef Activex::TOleEnum FormatterAssemblyStyle;

typedef Activex::TOleEnum TypeFilterLevel;

typedef Activex::TOleEnum AssemblyBuilderAccess;

typedef Activex::TOleEnum PEFileKinds;

typedef Activex::TOleEnum OpCodeType;

typedef Activex::TOleEnum StackBehaviour;

typedef Activex::TOleEnum OperandType;

typedef Activex::TOleEnum FlowControl;

typedef Activex::TOleEnum PackingSize;

typedef Activex::TOleEnum AssemblyHashAlgorithm;

typedef Activex::TOleEnum AssemblyVersionCompatibility;

__interface _AppDomain;
typedef System::DelphiInterface<_AppDomain> _di__AppDomain;
typedef _di__AppDomain AppDomain;

__interface IRegistrationServices;
typedef System::DelphiInterface<IRegistrationServices> _di_IRegistrationServices;
typedef _di_IRegistrationServices RegistrationServices;

__interface ITypeLibConverter;
typedef System::DelphiInterface<ITypeLibConverter> _di_ITypeLibConverter;
typedef _di_ITypeLibConverter TypeLibConverter;

__interface IAppDomainSetup;
typedef System::DelphiInterface<IAppDomainSetup> _di_IAppDomainSetup;
typedef _di_IAppDomainSetup AppDomainSetup;

__interface _Object;
typedef System::DelphiInterface<_Object> _di__Object;
typedef _di__Object Object_;

__interface _Array;
typedef System::DelphiInterface<_Array> _di__Array;
typedef _di__Array Array_;

__interface _String;
typedef System::DelphiInterface<_String> _di__String;
typedef _di__String String_;

__interface _StringBuilder;
typedef System::DelphiInterface<_StringBuilder> _di__StringBuilder;
typedef _di__StringBuilder StringBuilder;

__interface _Exception;
typedef System::DelphiInterface<_Exception> _di__Exception;
typedef _di__Exception Exception;

__interface _ValueType;
typedef System::DelphiInterface<_ValueType> _di__ValueType;
typedef _di__ValueType ValueType;

__interface _SystemException;
typedef System::DelphiInterface<_SystemException> _di__SystemException;
typedef _di__SystemException SystemException;

__interface _OutOfMemoryException;
typedef System::DelphiInterface<_OutOfMemoryException> _di__OutOfMemoryException;
typedef _di__OutOfMemoryException OutOfMemoryException;

__interface _StackOverflowException;
typedef System::DelphiInterface<_StackOverflowException> _di__StackOverflowException;
typedef _di__StackOverflowException StackOverflowException;

__interface _ExecutionEngineException;
typedef System::DelphiInterface<_ExecutionEngineException> _di__ExecutionEngineException;
typedef _di__ExecutionEngineException ExecutionEngineException;

__interface _Delegate;
typedef System::DelphiInterface<_Delegate> _di__Delegate;
typedef _di__Delegate Delegate;

__interface _MulticastDelegate;
typedef System::DelphiInterface<_MulticastDelegate> _di__MulticastDelegate;
typedef _di__MulticastDelegate MulticastDelegate;

__interface _Enum;
typedef System::DelphiInterface<_Enum> _di__Enum;
typedef _di__Enum Enum;

__interface _MemberAccessException;
typedef System::DelphiInterface<_MemberAccessException> _di__MemberAccessException;
typedef _di__MemberAccessException MemberAccessException;

__interface _Activator;
typedef System::DelphiInterface<_Activator> _di__Activator;
typedef _di__Activator Activator;

__interface _ApplicationException;
typedef System::DelphiInterface<_ApplicationException> _di__ApplicationException;
typedef _di__ApplicationException ApplicationException;

__interface _EventArgs;
typedef System::DelphiInterface<_EventArgs> _di__EventArgs;
typedef _di__EventArgs EventArgs;

__interface _ResolveEventArgs;
typedef System::DelphiInterface<_ResolveEventArgs> _di__ResolveEventArgs;
typedef _di__ResolveEventArgs ResolveEventArgs;

__interface _AssemblyLoadEventArgs;
typedef System::DelphiInterface<_AssemblyLoadEventArgs> _di__AssemblyLoadEventArgs;
typedef _di__AssemblyLoadEventArgs AssemblyLoadEventArgs;

__interface _ResolveEventHandler;
typedef System::DelphiInterface<_ResolveEventHandler> _di__ResolveEventHandler;
typedef _di__ResolveEventHandler ResolveEventHandler;

__interface _AssemblyLoadEventHandler;
typedef System::DelphiInterface<_AssemblyLoadEventHandler> _di__AssemblyLoadEventHandler;
typedef _di__AssemblyLoadEventHandler AssemblyLoadEventHandler;

__interface _MarshalByRefObject;
typedef System::DelphiInterface<_MarshalByRefObject> _di__MarshalByRefObject;
typedef _di__MarshalByRefObject MarshalByRefObject;

__interface _CrossAppDomainDelegate;
typedef System::DelphiInterface<_CrossAppDomainDelegate> _di__CrossAppDomainDelegate;
typedef _di__CrossAppDomainDelegate CrossAppDomainDelegate;

__interface _Attribute;
typedef System::DelphiInterface<_Attribute> _di__Attribute;
typedef _di__Attribute Attribute;

__interface _LoaderOptimizationAttribute;
typedef System::DelphiInterface<_LoaderOptimizationAttribute> _di__LoaderOptimizationAttribute;
typedef _di__LoaderOptimizationAttribute LoaderOptimizationAttribute;

__interface _AppDomainUnloadedException;
typedef System::DelphiInterface<_AppDomainUnloadedException> _di__AppDomainUnloadedException;
typedef _di__AppDomainUnloadedException AppDomainUnloadedException;

__interface _ArgumentException;
typedef System::DelphiInterface<_ArgumentException> _di__ArgumentException;
typedef _di__ArgumentException ArgumentException;

__interface _ArgumentNullException;
typedef System::DelphiInterface<_ArgumentNullException> _di__ArgumentNullException;
typedef _di__ArgumentNullException ArgumentNullException;

__interface _ArgumentOutOfRangeException;
typedef System::DelphiInterface<_ArgumentOutOfRangeException> _di__ArgumentOutOfRangeException;
typedef _di__ArgumentOutOfRangeException ArgumentOutOfRangeException;

__interface _ArithmeticException;
typedef System::DelphiInterface<_ArithmeticException> _di__ArithmeticException;
typedef _di__ArithmeticException ArithmeticException;

__interface _ArrayTypeMismatchException;
typedef System::DelphiInterface<_ArrayTypeMismatchException> _di__ArrayTypeMismatchException;
typedef _di__ArrayTypeMismatchException ArrayTypeMismatchException;

__interface _AsyncCallback;
typedef System::DelphiInterface<_AsyncCallback> _di__AsyncCallback;
typedef _di__AsyncCallback AsyncCallback;

__interface _AttributeUsageAttribute;
typedef System::DelphiInterface<_AttributeUsageAttribute> _di__AttributeUsageAttribute;
typedef _di__AttributeUsageAttribute AttributeUsageAttribute;

__interface _BadImageFormatException;
typedef System::DelphiInterface<_BadImageFormatException> _di__BadImageFormatException;
typedef _di__BadImageFormatException BadImageFormatException;

__interface _BitConverter;
typedef System::DelphiInterface<_BitConverter> _di__BitConverter;
typedef _di__BitConverter BitConverter;

__interface _Buffer;
typedef System::DelphiInterface<_Buffer> _di__Buffer;
typedef _di__Buffer Buffer;

__interface _CannotUnloadAppDomainException;
typedef System::DelphiInterface<_CannotUnloadAppDomainException> _di__CannotUnloadAppDomainException;
typedef _di__CannotUnloadAppDomainException CannotUnloadAppDomainException;

__interface _CharEnumerator;
typedef System::DelphiInterface<_CharEnumerator> _di__CharEnumerator;
typedef _di__CharEnumerator CharEnumerator;

__interface _CLSCompliantAttribute;
typedef System::DelphiInterface<_CLSCompliantAttribute> _di__CLSCompliantAttribute;
typedef _di__CLSCompliantAttribute CLSCompliantAttribute;

__interface _TypeUnloadedException;
typedef System::DelphiInterface<_TypeUnloadedException> _di__TypeUnloadedException;
typedef _di__TypeUnloadedException TypeUnloadedException;

__interface _Console;
typedef System::DelphiInterface<_Console> _di__Console;
typedef _di__Console Console;

__interface _ContextMarshalException;
typedef System::DelphiInterface<_ContextMarshalException> _di__ContextMarshalException;
typedef _di__ContextMarshalException ContextMarshalException;

__interface _Convert;
typedef System::DelphiInterface<_Convert> _di__Convert;
typedef _di__Convert Convert;

__interface _ContextBoundObject;
typedef System::DelphiInterface<_ContextBoundObject> _di__ContextBoundObject;
typedef _di__ContextBoundObject ContextBoundObject;

__interface _ContextStaticAttribute;
typedef System::DelphiInterface<_ContextStaticAttribute> _di__ContextStaticAttribute;
typedef _di__ContextStaticAttribute ContextStaticAttribute;

__interface _TimeZone;
typedef System::DelphiInterface<_TimeZone> _di__TimeZone;
typedef _di__TimeZone TimeZone;

__interface _DBNull;
typedef System::DelphiInterface<_DBNull> _di__DBNull;
typedef _di__DBNull DBNull;

__interface _Binder;
typedef System::DelphiInterface<_Binder> _di__Binder;
typedef _di__Binder Binder;

__interface _DivideByZeroException;
typedef System::DelphiInterface<_DivideByZeroException> _di__DivideByZeroException;
typedef _di__DivideByZeroException DivideByZeroException;

__interface _DuplicateWaitObjectException;
typedef System::DelphiInterface<_DuplicateWaitObjectException> _di__DuplicateWaitObjectException;
typedef _di__DuplicateWaitObjectException DuplicateWaitObjectException;

__interface _TypeLoadException;
typedef System::DelphiInterface<_TypeLoadException> _di__TypeLoadException;
typedef _di__TypeLoadException TypeLoadException;

__interface _EntryPointNotFoundException;
typedef System::DelphiInterface<_EntryPointNotFoundException> _di__EntryPointNotFoundException;
typedef _di__EntryPointNotFoundException EntryPointNotFoundException;

__interface _DllNotFoundException;
typedef System::DelphiInterface<_DllNotFoundException> _di__DllNotFoundException;
typedef _di__DllNotFoundException DllNotFoundException;

__interface _Environment;
typedef System::DelphiInterface<_Environment> _di__Environment;
typedef _di__Environment Environment;

__interface _EventHandler;
typedef System::DelphiInterface<_EventHandler> _di__EventHandler;
typedef _di__EventHandler EventHandler;

__interface _FieldAccessException;
typedef System::DelphiInterface<_FieldAccessException> _di__FieldAccessException;
typedef _di__FieldAccessException FieldAccessException;

__interface _FlagsAttribute;
typedef System::DelphiInterface<_FlagsAttribute> _di__FlagsAttribute;
typedef _di__FlagsAttribute FlagsAttribute;

__interface _FormatException;
typedef System::DelphiInterface<_FormatException> _di__FormatException;
typedef _di__FormatException FormatException;

__interface _GC;
typedef System::DelphiInterface<_GC> _di__GC;
typedef _di__GC GC;

__interface _IndexOutOfRangeException;
typedef System::DelphiInterface<_IndexOutOfRangeException> _di__IndexOutOfRangeException;
typedef _di__IndexOutOfRangeException IndexOutOfRangeException;

__interface _InvalidCastException;
typedef System::DelphiInterface<_InvalidCastException> _di__InvalidCastException;
typedef _di__InvalidCastException InvalidCastException;

__interface _InvalidOperationException;
typedef System::DelphiInterface<_InvalidOperationException> _di__InvalidOperationException;
typedef _di__InvalidOperationException InvalidOperationException;

__interface _InvalidProgramException;
typedef System::DelphiInterface<_InvalidProgramException> _di__InvalidProgramException;
typedef _di__InvalidProgramException InvalidProgramException;

__interface _LocalDataStoreSlot;
typedef System::DelphiInterface<_LocalDataStoreSlot> _di__LocalDataStoreSlot;
typedef _di__LocalDataStoreSlot LocalDataStoreSlot;

__interface _Math;
typedef System::DelphiInterface<_Math> _di__Math;
typedef _di__Math Math;

__interface _MethodAccessException;
typedef System::DelphiInterface<_MethodAccessException> _di__MethodAccessException;
typedef _di__MethodAccessException MethodAccessException;

__interface _MissingMemberException;
typedef System::DelphiInterface<_MissingMemberException> _di__MissingMemberException;
typedef _di__MissingMemberException MissingMemberException;

__interface _MissingFieldException;
typedef System::DelphiInterface<_MissingFieldException> _di__MissingFieldException;
typedef _di__MissingFieldException MissingFieldException;

__interface _MissingMethodException;
typedef System::DelphiInterface<_MissingMethodException> _di__MissingMethodException;
typedef _di__MissingMethodException MissingMethodException;

__interface _MulticastNotSupportedException;
typedef System::DelphiInterface<_MulticastNotSupportedException> _di__MulticastNotSupportedException;
typedef _di__MulticastNotSupportedException MulticastNotSupportedException;

__interface _NonSerializedAttribute;
typedef System::DelphiInterface<_NonSerializedAttribute> _di__NonSerializedAttribute;
typedef _di__NonSerializedAttribute NonSerializedAttribute;

__interface _NotFiniteNumberException;
typedef System::DelphiInterface<_NotFiniteNumberException> _di__NotFiniteNumberException;
typedef _di__NotFiniteNumberException NotFiniteNumberException;

__interface _NotImplementedException;
typedef System::DelphiInterface<_NotImplementedException> _di__NotImplementedException;
typedef _di__NotImplementedException NotImplementedException;

__interface _NotSupportedException;
typedef System::DelphiInterface<_NotSupportedException> _di__NotSupportedException;
typedef _di__NotSupportedException NotSupportedException;

__interface _NullReferenceException;
typedef System::DelphiInterface<_NullReferenceException> _di__NullReferenceException;
typedef _di__NullReferenceException NullReferenceException;

__interface _ObjectDisposedException;
typedef System::DelphiInterface<_ObjectDisposedException> _di__ObjectDisposedException;
typedef _di__ObjectDisposedException ObjectDisposedException;

__interface _ObsoleteAttribute;
typedef System::DelphiInterface<_ObsoleteAttribute> _di__ObsoleteAttribute;
typedef _di__ObsoleteAttribute ObsoleteAttribute;

__interface _OperatingSystem;
typedef System::DelphiInterface<_OperatingSystem> _di__OperatingSystem;
typedef _di__OperatingSystem OperatingSystem;

__interface _OverflowException;
typedef System::DelphiInterface<_OverflowException> _di__OverflowException;
typedef _di__OverflowException OverflowException;

__interface _ParamArrayAttribute;
typedef System::DelphiInterface<_ParamArrayAttribute> _di__ParamArrayAttribute;
typedef _di__ParamArrayAttribute ParamArrayAttribute;

__interface _PlatformNotSupportedException;
typedef System::DelphiInterface<_PlatformNotSupportedException> _di__PlatformNotSupportedException;
typedef _di__PlatformNotSupportedException PlatformNotSupportedException;

__interface _Random;
typedef System::DelphiInterface<_Random> _di__Random;
typedef _di__Random Random;

__interface _RankException;
typedef System::DelphiInterface<_RankException> _di__RankException;
typedef _di__RankException RankException;

__interface _MemberInfo;
typedef System::DelphiInterface<_MemberInfo> _di__MemberInfo;
typedef _di__MemberInfo MemberInfo;

__interface _Type;
typedef System::DelphiInterface<_Type> _di__Type;
typedef _di__Type Type_;

__interface _SerializableAttribute;
typedef System::DelphiInterface<_SerializableAttribute> _di__SerializableAttribute;
typedef _di__SerializableAttribute SerializableAttribute;

__interface _TypeInitializationException;
typedef System::DelphiInterface<_TypeInitializationException> _di__TypeInitializationException;
typedef _di__TypeInitializationException TypeInitializationException;

__interface _UnauthorizedAccessException;
typedef System::DelphiInterface<_UnauthorizedAccessException> _di__UnauthorizedAccessException;
typedef _di__UnauthorizedAccessException UnauthorizedAccessException;

__interface _UnhandledExceptionEventArgs;
typedef System::DelphiInterface<_UnhandledExceptionEventArgs> _di__UnhandledExceptionEventArgs;
typedef _di__UnhandledExceptionEventArgs UnhandledExceptionEventArgs;

__interface _UnhandledExceptionEventHandler;
typedef System::DelphiInterface<_UnhandledExceptionEventHandler> _di__UnhandledExceptionEventHandler;
typedef _di__UnhandledExceptionEventHandler UnhandledExceptionEventHandler;

__interface _Version;
typedef System::DelphiInterface<_Version> _di__Version;
typedef _di__Version Version;

__interface _WeakReference;
typedef System::DelphiInterface<_WeakReference> _di__WeakReference;
typedef _di__WeakReference WeakReference;

__interface _WaitHandle;
typedef System::DelphiInterface<_WaitHandle> _di__WaitHandle;
typedef _di__WaitHandle WaitHandle;

__interface _AutoResetEvent;
typedef System::DelphiInterface<_AutoResetEvent> _di__AutoResetEvent;
typedef _di__AutoResetEvent AutoResetEvent;

__interface _CompressedStack;
typedef System::DelphiInterface<_CompressedStack> _di__CompressedStack;
typedef _di__CompressedStack CompressedStack;

__interface _Interlocked;
typedef System::DelphiInterface<_Interlocked> _di__Interlocked;
typedef _di__Interlocked Interlocked;

__interface _ManualResetEvent;
typedef System::DelphiInterface<_ManualResetEvent> _di__ManualResetEvent;
typedef _di__ManualResetEvent ManualResetEvent;

__interface _Monitor;
typedef System::DelphiInterface<_Monitor> _di__Monitor;
typedef _di__Monitor Monitor;

__interface _Mutex;
typedef System::DelphiInterface<_Mutex> _di__Mutex;
typedef _di__Mutex Mutex;

__interface _Overlapped;
typedef System::DelphiInterface<_Overlapped> _di__Overlapped;
typedef _di__Overlapped Overlapped;

__interface _ReaderWriterLock;
typedef System::DelphiInterface<_ReaderWriterLock> _di__ReaderWriterLock;
typedef _di__ReaderWriterLock ReaderWriterLock;

__interface _SynchronizationLockException;
typedef System::DelphiInterface<_SynchronizationLockException> _di__SynchronizationLockException;
typedef _di__SynchronizationLockException SynchronizationLockException;

__interface _Thread;
typedef System::DelphiInterface<_Thread> _di__Thread;
typedef _di__Thread Thread;

__interface _ThreadAbortException;
typedef System::DelphiInterface<_ThreadAbortException> _di__ThreadAbortException;
typedef _di__ThreadAbortException ThreadAbortException;

__interface _STAThreadAttribute;
typedef System::DelphiInterface<_STAThreadAttribute> _di__STAThreadAttribute;
typedef _di__STAThreadAttribute STAThreadAttribute;

__interface _MTAThreadAttribute;
typedef System::DelphiInterface<_MTAThreadAttribute> _di__MTAThreadAttribute;
typedef _di__MTAThreadAttribute MTAThreadAttribute;

__interface _ThreadInterruptedException;
typedef System::DelphiInterface<_ThreadInterruptedException> _di__ThreadInterruptedException;
typedef _di__ThreadInterruptedException ThreadInterruptedException;

__interface _RegisteredWaitHandle;
typedef System::DelphiInterface<_RegisteredWaitHandle> _di__RegisteredWaitHandle;
typedef _di__RegisteredWaitHandle RegisteredWaitHandle;

__interface _WaitCallback;
typedef System::DelphiInterface<_WaitCallback> _di__WaitCallback;
typedef _di__WaitCallback WaitCallback;

__interface _WaitOrTimerCallback;
typedef System::DelphiInterface<_WaitOrTimerCallback> _di__WaitOrTimerCallback;
typedef _di__WaitOrTimerCallback WaitOrTimerCallback;

__interface _IOCompletionCallback;
typedef System::DelphiInterface<_IOCompletionCallback> _di__IOCompletionCallback;
typedef _di__IOCompletionCallback IOCompletionCallback;

__interface _ThreadPool;
typedef System::DelphiInterface<_ThreadPool> _di__ThreadPool;
typedef _di__ThreadPool ThreadPool;

__interface _ThreadStart;
typedef System::DelphiInterface<_ThreadStart> _di__ThreadStart;
typedef _di__ThreadStart ThreadStart;

__interface _ThreadStateException;
typedef System::DelphiInterface<_ThreadStateException> _di__ThreadStateException;
typedef _di__ThreadStateException ThreadStateException;

__interface _ThreadStaticAttribute;
typedef System::DelphiInterface<_ThreadStaticAttribute> _di__ThreadStaticAttribute;
typedef _di__ThreadStaticAttribute ThreadStaticAttribute;

__interface _Timeout;
typedef System::DelphiInterface<_Timeout> _di__Timeout;
typedef _di__Timeout Timeout;

__interface _TimerCallback;
typedef System::DelphiInterface<_TimerCallback> _di__TimerCallback;
typedef _di__TimerCallback TimerCallback;

__interface _Timer;
typedef System::DelphiInterface<_Timer> _di__Timer;
typedef _di__Timer Timer;

__interface _ArrayList;
typedef System::DelphiInterface<_ArrayList> _di__ArrayList;
typedef _di__ArrayList ArrayList;

__interface _BitArray;
typedef System::DelphiInterface<_BitArray> _di__BitArray;
typedef _di__BitArray BitArray;

__interface _CaseInsensitiveComparer;
typedef System::DelphiInterface<_CaseInsensitiveComparer> _di__CaseInsensitiveComparer;
typedef _di__CaseInsensitiveComparer CaseInsensitiveComparer;

__interface _CaseInsensitiveHashCodeProvider;
typedef System::DelphiInterface<_CaseInsensitiveHashCodeProvider> _di__CaseInsensitiveHashCodeProvider;
typedef _di__CaseInsensitiveHashCodeProvider CaseInsensitiveHashCodeProvider;

__interface _CollectionBase;
typedef System::DelphiInterface<_CollectionBase> _di__CollectionBase;
typedef _di__CollectionBase CollectionBase;

__interface _Comparer;
typedef System::DelphiInterface<_Comparer> _di__Comparer;
typedef _di__Comparer Comparer;

__interface _DictionaryBase;
typedef System::DelphiInterface<_DictionaryBase> _di__DictionaryBase;
typedef _di__DictionaryBase DictionaryBase;

__interface _Hashtable;
typedef System::DelphiInterface<_Hashtable> _di__Hashtable;
typedef _di__Hashtable Hashtable;

__interface _Queue;
typedef System::DelphiInterface<_Queue> _di__Queue;
typedef _di__Queue Queue;

__interface _ReadOnlyCollectionBase;
typedef System::DelphiInterface<_ReadOnlyCollectionBase> _di__ReadOnlyCollectionBase;
typedef _di__ReadOnlyCollectionBase ReadOnlyCollectionBase;

__interface _SortedList;
typedef System::DelphiInterface<_SortedList> _di__SortedList;
typedef _di__SortedList SortedList;

__interface _Stack;
typedef System::DelphiInterface<_Stack> _di__Stack;
typedef _di__Stack Stack;

__interface _ConditionalAttribute;
typedef System::DelphiInterface<_ConditionalAttribute> _di__ConditionalAttribute;
typedef _di__ConditionalAttribute ConditionalAttribute;

__interface _Debugger;
typedef System::DelphiInterface<_Debugger> _di__Debugger;
typedef _di__Debugger Debugger;

__interface _DebuggerStepThroughAttribute;
typedef System::DelphiInterface<_DebuggerStepThroughAttribute> _di__DebuggerStepThroughAttribute;
typedef _di__DebuggerStepThroughAttribute DebuggerStepThroughAttribute;

__interface _DebuggerHiddenAttribute;
typedef System::DelphiInterface<_DebuggerHiddenAttribute> _di__DebuggerHiddenAttribute;
typedef _di__DebuggerHiddenAttribute DebuggerHiddenAttribute;

__interface _DebuggableAttribute;
typedef System::DelphiInterface<_DebuggableAttribute> _di__DebuggableAttribute;
typedef _di__DebuggableAttribute DebuggableAttribute;

__interface _StackTrace;
typedef System::DelphiInterface<_StackTrace> _di__StackTrace;
typedef _di__StackTrace StackTrace;

__interface _StackFrame;
typedef System::DelphiInterface<_StackFrame> _di__StackFrame;
typedef _di__StackFrame StackFrame;

__interface _SymDocumentType;
typedef System::DelphiInterface<_SymDocumentType> _di__SymDocumentType;
typedef _di__SymDocumentType SymDocumentType;

__interface _SymLanguageType;
typedef System::DelphiInterface<_SymLanguageType> _di__SymLanguageType;
typedef _di__SymLanguageType SymLanguageType;

__interface _SymLanguageVendor;
typedef System::DelphiInterface<_SymLanguageVendor> _di__SymLanguageVendor;
typedef _di__SymLanguageVendor SymLanguageVendor;

__interface _AmbiguousMatchException;
typedef System::DelphiInterface<_AmbiguousMatchException> _di__AmbiguousMatchException;
typedef _di__AmbiguousMatchException AmbiguousMatchException;

__interface _ModuleResolveEventHandler;
typedef System::DelphiInterface<_ModuleResolveEventHandler> _di__ModuleResolveEventHandler;
typedef _di__ModuleResolveEventHandler ModuleResolveEventHandler;

__interface _Assembly;
typedef System::DelphiInterface<_Assembly> _di__Assembly;
typedef _di__Assembly Assembly;

__interface _AssemblyCultureAttribute;
typedef System::DelphiInterface<_AssemblyCultureAttribute> _di__AssemblyCultureAttribute;
typedef _di__AssemblyCultureAttribute AssemblyCultureAttribute;

__interface _AssemblyVersionAttribute;
typedef System::DelphiInterface<_AssemblyVersionAttribute> _di__AssemblyVersionAttribute;
typedef _di__AssemblyVersionAttribute AssemblyVersionAttribute;

__interface _AssemblyKeyFileAttribute;
typedef System::DelphiInterface<_AssemblyKeyFileAttribute> _di__AssemblyKeyFileAttribute;
typedef _di__AssemblyKeyFileAttribute AssemblyKeyFileAttribute;

__interface _AssemblyKeyNameAttribute;
typedef System::DelphiInterface<_AssemblyKeyNameAttribute> _di__AssemblyKeyNameAttribute;
typedef _di__AssemblyKeyNameAttribute AssemblyKeyNameAttribute;

__interface _AssemblyDelaySignAttribute;
typedef System::DelphiInterface<_AssemblyDelaySignAttribute> _di__AssemblyDelaySignAttribute;
typedef _di__AssemblyDelaySignAttribute AssemblyDelaySignAttribute;

__interface _AssemblyAlgorithmIdAttribute;
typedef System::DelphiInterface<_AssemblyAlgorithmIdAttribute> _di__AssemblyAlgorithmIdAttribute;
typedef _di__AssemblyAlgorithmIdAttribute AssemblyAlgorithmIdAttribute;

__interface _AssemblyFlagsAttribute;
typedef System::DelphiInterface<_AssemblyFlagsAttribute> _di__AssemblyFlagsAttribute;
typedef _di__AssemblyFlagsAttribute AssemblyFlagsAttribute;

__interface _AssemblyFileVersionAttribute;
typedef System::DelphiInterface<_AssemblyFileVersionAttribute> _di__AssemblyFileVersionAttribute;
typedef _di__AssemblyFileVersionAttribute AssemblyFileVersionAttribute;

__interface _AssemblyName;
typedef System::DelphiInterface<_AssemblyName> _di__AssemblyName;
typedef _di__AssemblyName AssemblyName;

__interface _AssemblyNameProxy;
typedef System::DelphiInterface<_AssemblyNameProxy> _di__AssemblyNameProxy;
typedef _di__AssemblyNameProxy AssemblyNameProxy;

__interface _AssemblyCopyrightAttribute;
typedef System::DelphiInterface<_AssemblyCopyrightAttribute> _di__AssemblyCopyrightAttribute;
typedef _di__AssemblyCopyrightAttribute AssemblyCopyrightAttribute;

__interface _AssemblyTrademarkAttribute;
typedef System::DelphiInterface<_AssemblyTrademarkAttribute> _di__AssemblyTrademarkAttribute;
typedef _di__AssemblyTrademarkAttribute AssemblyTrademarkAttribute;

__interface _AssemblyProductAttribute;
typedef System::DelphiInterface<_AssemblyProductAttribute> _di__AssemblyProductAttribute;
typedef _di__AssemblyProductAttribute AssemblyProductAttribute;

__interface _AssemblyCompanyAttribute;
typedef System::DelphiInterface<_AssemblyCompanyAttribute> _di__AssemblyCompanyAttribute;
typedef _di__AssemblyCompanyAttribute AssemblyCompanyAttribute;

__interface _AssemblyDescriptionAttribute;
typedef System::DelphiInterface<_AssemblyDescriptionAttribute> _di__AssemblyDescriptionAttribute;
typedef _di__AssemblyDescriptionAttribute AssemblyDescriptionAttribute;

__interface _AssemblyTitleAttribute;
typedef System::DelphiInterface<_AssemblyTitleAttribute> _di__AssemblyTitleAttribute;
typedef _di__AssemblyTitleAttribute AssemblyTitleAttribute;

__interface _AssemblyConfigurationAttribute;
typedef System::DelphiInterface<_AssemblyConfigurationAttribute> _di__AssemblyConfigurationAttribute;
typedef _di__AssemblyConfigurationAttribute AssemblyConfigurationAttribute;

__interface _AssemblyDefaultAliasAttribute;
typedef System::DelphiInterface<_AssemblyDefaultAliasAttribute> _di__AssemblyDefaultAliasAttribute;
typedef _di__AssemblyDefaultAliasAttribute AssemblyDefaultAliasAttribute;

__interface _AssemblyInformationalVersionAttribute;
typedef System::DelphiInterface<_AssemblyInformationalVersionAttribute> _di__AssemblyInformationalVersionAttribute;
typedef _di__AssemblyInformationalVersionAttribute AssemblyInformationalVersionAttribute;

__interface _CustomAttributeFormatException;
typedef System::DelphiInterface<_CustomAttributeFormatException> _di__CustomAttributeFormatException;
typedef _di__CustomAttributeFormatException CustomAttributeFormatException;

__interface _MethodBase;
typedef System::DelphiInterface<_MethodBase> _di__MethodBase;
typedef _di__MethodBase MethodBase;

__interface _ConstructorInfo;
typedef System::DelphiInterface<_ConstructorInfo> _di__ConstructorInfo;
typedef _di__ConstructorInfo ConstructorInfo;

__interface _DefaultMemberAttribute;
typedef System::DelphiInterface<_DefaultMemberAttribute> _di__DefaultMemberAttribute;
typedef _di__DefaultMemberAttribute DefaultMemberAttribute;

__interface _EventInfo;
typedef System::DelphiInterface<_EventInfo> _di__EventInfo;
typedef _di__EventInfo EventInfo;

__interface _FieldInfo;
typedef System::DelphiInterface<_FieldInfo> _di__FieldInfo;
typedef _di__FieldInfo FieldInfo;

__interface _InvalidFilterCriteriaException;
typedef System::DelphiInterface<_InvalidFilterCriteriaException> _di__InvalidFilterCriteriaException;
typedef _di__InvalidFilterCriteriaException InvalidFilterCriteriaException;

__interface _ManifestResourceInfo;
typedef System::DelphiInterface<_ManifestResourceInfo> _di__ManifestResourceInfo;
typedef _di__ManifestResourceInfo ManifestResourceInfo;

__interface _MemberFilter;
typedef System::DelphiInterface<_MemberFilter> _di__MemberFilter;
typedef _di__MemberFilter MemberFilter;

__interface _MethodInfo;
typedef System::DelphiInterface<_MethodInfo> _di__MethodInfo;
typedef _di__MethodInfo MethodInfo;

__interface _Missing;
typedef System::DelphiInterface<_Missing> _di__Missing;
typedef _di__Missing Missing;

__interface _Module;
typedef System::DelphiInterface<_Module> _di__Module;
typedef _di__Module Module;

__interface _ParameterInfo;
typedef System::DelphiInterface<_ParameterInfo> _di__ParameterInfo;
typedef _di__ParameterInfo ParameterInfo;

__interface _Pointer;
typedef System::DelphiInterface<_Pointer> _di__Pointer;
typedef _di__Pointer __Pointer;

__interface _PropertyInfo;
typedef System::DelphiInterface<_PropertyInfo> _di__PropertyInfo;
typedef _di__PropertyInfo PropertyInfo;

__interface _ReflectionTypeLoadException;
typedef System::DelphiInterface<_ReflectionTypeLoadException> _di__ReflectionTypeLoadException;
typedef _di__ReflectionTypeLoadException ReflectionTypeLoadException;

__interface _StrongNameKeyPair;
typedef System::DelphiInterface<_StrongNameKeyPair> _di__StrongNameKeyPair;
typedef _di__StrongNameKeyPair StrongNameKeyPair;

__interface _TargetException;
typedef System::DelphiInterface<_TargetException> _di__TargetException;
typedef _di__TargetException TargetException;

__interface _TargetInvocationException;
typedef System::DelphiInterface<_TargetInvocationException> _di__TargetInvocationException;
typedef _di__TargetInvocationException TargetInvocationException;

__interface _TargetParameterCountException;
typedef System::DelphiInterface<_TargetParameterCountException> _di__TargetParameterCountException;
typedef _di__TargetParameterCountException TargetParameterCountException;

__interface _TypeDelegator;
typedef System::DelphiInterface<_TypeDelegator> _di__TypeDelegator;
typedef _di__TypeDelegator TypeDelegator;

__interface _TypeFilter;
typedef System::DelphiInterface<_TypeFilter> _di__TypeFilter;
typedef _di__TypeFilter TypeFilter;

__interface _UnmanagedMarshal;
typedef System::DelphiInterface<_UnmanagedMarshal> _di__UnmanagedMarshal;
typedef _di__UnmanagedMarshal UnmanagedMarshal;

__interface _Formatter;
typedef System::DelphiInterface<_Formatter> _di__Formatter;
typedef _di__Formatter Formatter;

__interface _FormatterConverter;
typedef System::DelphiInterface<_FormatterConverter> _di__FormatterConverter;
typedef _di__FormatterConverter FormatterConverter;

__interface _FormatterServices;
typedef System::DelphiInterface<_FormatterServices> _di__FormatterServices;
typedef _di__FormatterServices FormatterServices;

__interface _ObjectIDGenerator;
typedef System::DelphiInterface<_ObjectIDGenerator> _di__ObjectIDGenerator;
typedef _di__ObjectIDGenerator ObjectIDGenerator;

__interface _ObjectManager;
typedef System::DelphiInterface<_ObjectManager> _di__ObjectManager;
typedef _di__ObjectManager ObjectManager;

__interface _SerializationBinder;
typedef System::DelphiInterface<_SerializationBinder> _di__SerializationBinder;
typedef _di__SerializationBinder SerializationBinder;

__interface _SerializationInfo;
typedef System::DelphiInterface<_SerializationInfo> _di__SerializationInfo;
typedef _di__SerializationInfo SerializationInfo;

__interface _SerializationInfoEnumerator;
typedef System::DelphiInterface<_SerializationInfoEnumerator> _di__SerializationInfoEnumerator;
typedef _di__SerializationInfoEnumerator SerializationInfoEnumerator;

__interface _SerializationException;
typedef System::DelphiInterface<_SerializationException> _di__SerializationException;
typedef _di__SerializationException SerializationException;

__interface _SurrogateSelector;
typedef System::DelphiInterface<_SurrogateSelector> _di__SurrogateSelector;
typedef _di__SurrogateSelector SurrogateSelector;

__interface _Calendar;
typedef System::DelphiInterface<_Calendar> _di__Calendar;
typedef _di__Calendar Calendar;

__interface _CompareInfo;
typedef System::DelphiInterface<_CompareInfo> _di__CompareInfo;
typedef _di__CompareInfo CompareInfo;

__interface _CultureInfo;
typedef System::DelphiInterface<_CultureInfo> _di__CultureInfo;
typedef _di__CultureInfo CultureInfo;

__interface _DateTimeFormatInfo;
typedef System::DelphiInterface<_DateTimeFormatInfo> _di__DateTimeFormatInfo;
typedef _di__DateTimeFormatInfo DateTimeFormatInfo;

__interface _DaylightTime;
typedef System::DelphiInterface<_DaylightTime> _di__DaylightTime;
typedef _di__DaylightTime DaylightTime;

__interface _GregorianCalendar;
typedef System::DelphiInterface<_GregorianCalendar> _di__GregorianCalendar;
typedef _di__GregorianCalendar GregorianCalendar;

__interface _HebrewCalendar;
typedef System::DelphiInterface<_HebrewCalendar> _di__HebrewCalendar;
typedef _di__HebrewCalendar HebrewCalendar;

__interface _HijriCalendar;
typedef System::DelphiInterface<_HijriCalendar> _di__HijriCalendar;
typedef _di__HijriCalendar HijriCalendar;

__interface _JapaneseCalendar;
typedef System::DelphiInterface<_JapaneseCalendar> _di__JapaneseCalendar;
typedef _di__JapaneseCalendar JapaneseCalendar;

__interface _JulianCalendar;
typedef System::DelphiInterface<_JulianCalendar> _di__JulianCalendar;
typedef _di__JulianCalendar JulianCalendar;

__interface _KoreanCalendar;
typedef System::DelphiInterface<_KoreanCalendar> _di__KoreanCalendar;
typedef _di__KoreanCalendar KoreanCalendar;

__interface _RegionInfo;
typedef System::DelphiInterface<_RegionInfo> _di__RegionInfo;
typedef _di__RegionInfo RegionInfo;

__interface _SortKey;
typedef System::DelphiInterface<_SortKey> _di__SortKey;
typedef _di__SortKey SortKey;

__interface _StringInfo;
typedef System::DelphiInterface<_StringInfo> _di__StringInfo;
typedef _di__StringInfo StringInfo;

__interface _TaiwanCalendar;
typedef System::DelphiInterface<_TaiwanCalendar> _di__TaiwanCalendar;
typedef _di__TaiwanCalendar TaiwanCalendar;

__interface _TextElementEnumerator;
typedef System::DelphiInterface<_TextElementEnumerator> _di__TextElementEnumerator;
typedef _di__TextElementEnumerator TextElementEnumerator;

__interface _TextInfo;
typedef System::DelphiInterface<_TextInfo> _di__TextInfo;
typedef _di__TextInfo TextInfo;

__interface _ThaiBuddhistCalendar;
typedef System::DelphiInterface<_ThaiBuddhistCalendar> _di__ThaiBuddhistCalendar;
typedef _di__ThaiBuddhistCalendar ThaiBuddhistCalendar;

__interface _NumberFormatInfo;
typedef System::DelphiInterface<_NumberFormatInfo> _di__NumberFormatInfo;
typedef _di__NumberFormatInfo NumberFormatInfo;

__interface _Encoding;
typedef System::DelphiInterface<_Encoding> _di__Encoding;
typedef _di__Encoding Encoding;

__interface _System_Text_Decoder;
typedef System::DelphiInterface<_System_Text_Decoder> _di__System_Text_Decoder;
typedef _di__System_Text_Decoder System_Text_Decoder;

__interface _System_Text_Encoder;
typedef System::DelphiInterface<_System_Text_Encoder> _di__System_Text_Encoder;
typedef _di__System_Text_Encoder System_Text_Encoder;

__interface _ASCIIEncoding;
typedef System::DelphiInterface<_ASCIIEncoding> _di__ASCIIEncoding;
typedef _di__ASCIIEncoding ASCIIEncoding;

__interface _UnicodeEncoding;
typedef System::DelphiInterface<_UnicodeEncoding> _di__UnicodeEncoding;
typedef _di__UnicodeEncoding UnicodeEncoding;

__interface _UTF7Encoding;
typedef System::DelphiInterface<_UTF7Encoding> _di__UTF7Encoding;
typedef _di__UTF7Encoding UTF7Encoding;

__interface _UTF8Encoding;
typedef System::DelphiInterface<_UTF8Encoding> _di__UTF8Encoding;
typedef _di__UTF8Encoding UTF8Encoding;

__interface _MissingManifestResourceException;
typedef System::DelphiInterface<_MissingManifestResourceException> _di__MissingManifestResourceException;
typedef _di__MissingManifestResourceException MissingManifestResourceException;

__interface _NeutralResourcesLanguageAttribute;
typedef System::DelphiInterface<_NeutralResourcesLanguageAttribute> _di__NeutralResourcesLanguageAttribute;
typedef _di__NeutralResourcesLanguageAttribute NeutralResourcesLanguageAttribute;

__interface _ResourceManager;
typedef System::DelphiInterface<_ResourceManager> _di__ResourceManager;
typedef _di__ResourceManager ResourceManager;

__interface _ResourceReader;
typedef System::DelphiInterface<_ResourceReader> _di__ResourceReader;
typedef _di__ResourceReader ResourceReader;

__interface _ResourceSet;
typedef System::DelphiInterface<_ResourceSet> _di__ResourceSet;
typedef _di__ResourceSet ResourceSet;

__interface _ResourceWriter;
typedef System::DelphiInterface<_ResourceWriter> _di__ResourceWriter;
typedef _di__ResourceWriter ResourceWriter;

__interface _SatelliteContractVersionAttribute;
typedef System::DelphiInterface<_SatelliteContractVersionAttribute> _di__SatelliteContractVersionAttribute;
typedef _di__SatelliteContractVersionAttribute SatelliteContractVersionAttribute;

__interface _Registry;
typedef System::DelphiInterface<_Registry> _di__Registry;
typedef _di__Registry Registry;

__interface _RegistryKey;
typedef System::DelphiInterface<_RegistryKey> _di__RegistryKey;
typedef _di__RegistryKey RegistryKey;

__interface _X509Certificate;
typedef System::DelphiInterface<_X509Certificate> _di__X509Certificate;
typedef _di__X509Certificate X509Certificate;

__interface _AsymmetricAlgorithm;
typedef System::DelphiInterface<_AsymmetricAlgorithm> _di__AsymmetricAlgorithm;
typedef _di__AsymmetricAlgorithm AsymmetricAlgorithm;

__interface _AsymmetricKeyExchangeDeformatter;
typedef System::DelphiInterface<_AsymmetricKeyExchangeDeformatter> _di__AsymmetricKeyExchangeDeformatter;
typedef _di__AsymmetricKeyExchangeDeformatter AsymmetricKeyExchangeDeformatter;

__interface _AsymmetricKeyExchangeFormatter;
typedef System::DelphiInterface<_AsymmetricKeyExchangeFormatter> _di__AsymmetricKeyExchangeFormatter;
typedef _di__AsymmetricKeyExchangeFormatter AsymmetricKeyExchangeFormatter;

__interface _AsymmetricSignatureDeformatter;
typedef System::DelphiInterface<_AsymmetricSignatureDeformatter> _di__AsymmetricSignatureDeformatter;
typedef _di__AsymmetricSignatureDeformatter AsymmetricSignatureDeformatter;

__interface _AsymmetricSignatureFormatter;
typedef System::DelphiInterface<_AsymmetricSignatureFormatter> _di__AsymmetricSignatureFormatter;
typedef _di__AsymmetricSignatureFormatter AsymmetricSignatureFormatter;

__interface _ToBase64Transform;
typedef System::DelphiInterface<_ToBase64Transform> _di__ToBase64Transform;
typedef _di__ToBase64Transform ToBase64Transform;

__interface _FromBase64Transform;
typedef System::DelphiInterface<_FromBase64Transform> _di__FromBase64Transform;
typedef _di__FromBase64Transform FromBase64Transform;

__interface _KeySizes;
typedef System::DelphiInterface<_KeySizes> _di__KeySizes;
typedef _di__KeySizes KeySizes;

__interface _CryptographicException;
typedef System::DelphiInterface<_CryptographicException> _di__CryptographicException;
typedef _di__CryptographicException CryptographicException;

__interface _CryptographicUnexpectedOperationException;
typedef System::DelphiInterface<_CryptographicUnexpectedOperationException> _di__CryptographicUnexpectedOperationException;
typedef _di__CryptographicUnexpectedOperationException CryptographicUnexpectedOperationException;

__interface _CryptoAPITransform;
typedef System::DelphiInterface<_CryptoAPITransform> _di__CryptoAPITransform;
typedef _di__CryptoAPITransform CryptoAPITransform;

__interface _CspParameters;
typedef System::DelphiInterface<_CspParameters> _di__CspParameters;
typedef _di__CspParameters CspParameters;

__interface _CryptoConfig;
typedef System::DelphiInterface<_CryptoConfig> _di__CryptoConfig;
typedef _di__CryptoConfig CryptoConfig;

__interface _Stream;
typedef System::DelphiInterface<_Stream> _di__Stream;
typedef _di__Stream Stream;

__interface _CryptoStream;
typedef System::DelphiInterface<_CryptoStream> _di__CryptoStream;
typedef _di__CryptoStream CryptoStream;

__interface _SymmetricAlgorithm;
typedef System::DelphiInterface<_SymmetricAlgorithm> _di__SymmetricAlgorithm;
typedef _di__SymmetricAlgorithm SymmetricAlgorithm;

__interface _DES;
typedef System::DelphiInterface<_DES> _di__DES;
typedef _di__DES DES;

__interface _DESCryptoServiceProvider;
typedef System::DelphiInterface<_DESCryptoServiceProvider> _di__DESCryptoServiceProvider;
typedef _di__DESCryptoServiceProvider DESCryptoServiceProvider;

__interface _DeriveBytes;
typedef System::DelphiInterface<_DeriveBytes> _di__DeriveBytes;
typedef _di__DeriveBytes DeriveBytes;

__interface _DSA;
typedef System::DelphiInterface<_DSA> _di__DSA;
typedef _di__DSA DSA;

__interface _DSACryptoServiceProvider;
typedef System::DelphiInterface<_DSACryptoServiceProvider> _di__DSACryptoServiceProvider;
typedef _di__DSACryptoServiceProvider DSACryptoServiceProvider;

__interface _DSASignatureDeformatter;
typedef System::DelphiInterface<_DSASignatureDeformatter> _di__DSASignatureDeformatter;
typedef _di__DSASignatureDeformatter DSASignatureDeformatter;

__interface _DSASignatureFormatter;
typedef System::DelphiInterface<_DSASignatureFormatter> _di__DSASignatureFormatter;
typedef _di__DSASignatureFormatter DSASignatureFormatter;

__interface _HashAlgorithm;
typedef System::DelphiInterface<_HashAlgorithm> _di__HashAlgorithm;
typedef _di__HashAlgorithm HashAlgorithm;

__interface _KeyedHashAlgorithm;
typedef System::DelphiInterface<_KeyedHashAlgorithm> _di__KeyedHashAlgorithm;
typedef _di__KeyedHashAlgorithm KeyedHashAlgorithm;

__interface _HMACSHA1;
typedef System::DelphiInterface<_HMACSHA1> _di__HMACSHA1;
typedef _di__HMACSHA1 HMACSHA1;

__interface _MACTripleDES;
typedef System::DelphiInterface<_MACTripleDES> _di__MACTripleDES;
typedef _di__MACTripleDES MACTripleDES;

__interface _MD5;
typedef System::DelphiInterface<_MD5> _di__MD5;
typedef _di__MD5 MD5;

__interface _MD5CryptoServiceProvider;
typedef System::DelphiInterface<_MD5CryptoServiceProvider> _di__MD5CryptoServiceProvider;
typedef _di__MD5CryptoServiceProvider MD5CryptoServiceProvider;

__interface _MaskGenerationMethod;
typedef System::DelphiInterface<_MaskGenerationMethod> _di__MaskGenerationMethod;
typedef _di__MaskGenerationMethod MaskGenerationMethod;

__interface _PasswordDeriveBytes;
typedef System::DelphiInterface<_PasswordDeriveBytes> _di__PasswordDeriveBytes;
typedef _di__PasswordDeriveBytes PasswordDeriveBytes;

__interface _PKCS1MaskGenerationMethod;
typedef System::DelphiInterface<_PKCS1MaskGenerationMethod> _di__PKCS1MaskGenerationMethod;
typedef _di__PKCS1MaskGenerationMethod PKCS1MaskGenerationMethod;

__interface _RC2;
typedef System::DelphiInterface<_RC2> _di__RC2;
typedef _di__RC2 RC2;

__interface _RC2CryptoServiceProvider;
typedef System::DelphiInterface<_RC2CryptoServiceProvider> _di__RC2CryptoServiceProvider;
typedef _di__RC2CryptoServiceProvider RC2CryptoServiceProvider;

__interface _RandomNumberGenerator;
typedef System::DelphiInterface<_RandomNumberGenerator> _di__RandomNumberGenerator;
typedef _di__RandomNumberGenerator RandomNumberGenerator;

__interface _RNGCryptoServiceProvider;
typedef System::DelphiInterface<_RNGCryptoServiceProvider> _di__RNGCryptoServiceProvider;
typedef _di__RNGCryptoServiceProvider RNGCryptoServiceProvider;

__interface _RSA;
typedef System::DelphiInterface<_RSA> _di__RSA;
typedef _di__RSA RSA;

__interface _RSACryptoServiceProvider;
typedef System::DelphiInterface<_RSACryptoServiceProvider> _di__RSACryptoServiceProvider;
typedef _di__RSACryptoServiceProvider RSACryptoServiceProvider;

__interface _RSAOAEPKeyExchangeDeformatter;
typedef System::DelphiInterface<_RSAOAEPKeyExchangeDeformatter> _di__RSAOAEPKeyExchangeDeformatter;
typedef _di__RSAOAEPKeyExchangeDeformatter RSAOAEPKeyExchangeDeformatter;

__interface _RSAOAEPKeyExchangeFormatter;
typedef System::DelphiInterface<_RSAOAEPKeyExchangeFormatter> _di__RSAOAEPKeyExchangeFormatter;
typedef _di__RSAOAEPKeyExchangeFormatter RSAOAEPKeyExchangeFormatter;

__interface _RSAPKCS1KeyExchangeDeformatter;
typedef System::DelphiInterface<_RSAPKCS1KeyExchangeDeformatter> _di__RSAPKCS1KeyExchangeDeformatter;
typedef _di__RSAPKCS1KeyExchangeDeformatter RSAPKCS1KeyExchangeDeformatter;

__interface _RSAPKCS1KeyExchangeFormatter;
typedef System::DelphiInterface<_RSAPKCS1KeyExchangeFormatter> _di__RSAPKCS1KeyExchangeFormatter;
typedef _di__RSAPKCS1KeyExchangeFormatter RSAPKCS1KeyExchangeFormatter;

__interface _RSAPKCS1SignatureDeformatter;
typedef System::DelphiInterface<_RSAPKCS1SignatureDeformatter> _di__RSAPKCS1SignatureDeformatter;
typedef _di__RSAPKCS1SignatureDeformatter RSAPKCS1SignatureDeformatter;

__interface _RSAPKCS1SignatureFormatter;
typedef System::DelphiInterface<_RSAPKCS1SignatureFormatter> _di__RSAPKCS1SignatureFormatter;
typedef _di__RSAPKCS1SignatureFormatter RSAPKCS1SignatureFormatter;

__interface _Rijndael;
typedef System::DelphiInterface<_Rijndael> _di__Rijndael;
typedef _di__Rijndael Rijndael;

__interface _RijndaelManaged;
typedef System::DelphiInterface<_RijndaelManaged> _di__RijndaelManaged;
typedef _di__RijndaelManaged RijndaelManaged;

__interface _SHA1;
typedef System::DelphiInterface<_SHA1> _di__SHA1;
typedef _di__SHA1 SHA1;

__interface _SHA1CryptoServiceProvider;
typedef System::DelphiInterface<_SHA1CryptoServiceProvider> _di__SHA1CryptoServiceProvider;
typedef _di__SHA1CryptoServiceProvider SHA1CryptoServiceProvider;

__interface _SHA1Managed;
typedef System::DelphiInterface<_SHA1Managed> _di__SHA1Managed;
typedef _di__SHA1Managed SHA1Managed;

__interface _SHA256;
typedef System::DelphiInterface<_SHA256> _di__SHA256;
typedef _di__SHA256 SHA256;

__interface _SHA256Managed;
typedef System::DelphiInterface<_SHA256Managed> _di__SHA256Managed;
typedef _di__SHA256Managed SHA256Managed;

__interface _SHA384;
typedef System::DelphiInterface<_SHA384> _di__SHA384;
typedef _di__SHA384 SHA384;

__interface _SHA384Managed;
typedef System::DelphiInterface<_SHA384Managed> _di__SHA384Managed;
typedef _di__SHA384Managed SHA384Managed;

__interface _SHA512;
typedef System::DelphiInterface<_SHA512> _di__SHA512;
typedef _di__SHA512 SHA512;

__interface _SHA512Managed;
typedef System::DelphiInterface<_SHA512Managed> _di__SHA512Managed;
typedef _di__SHA512Managed SHA512Managed;

__interface _SignatureDescription;
typedef System::DelphiInterface<_SignatureDescription> _di__SignatureDescription;
typedef _di__SignatureDescription SignatureDescription;

__interface _TripleDES;
typedef System::DelphiInterface<_TripleDES> _di__TripleDES;
typedef _di__TripleDES TripleDES;

__interface _TripleDESCryptoServiceProvider;
typedef System::DelphiInterface<_TripleDESCryptoServiceProvider> _di__TripleDESCryptoServiceProvider;
typedef _di__TripleDESCryptoServiceProvider TripleDESCryptoServiceProvider;

__interface _AllMembershipCondition;
typedef System::DelphiInterface<_AllMembershipCondition> _di__AllMembershipCondition;
typedef _di__AllMembershipCondition AllMembershipCondition;

__interface _ApplicationDirectory;
typedef System::DelphiInterface<_ApplicationDirectory> _di__ApplicationDirectory;
typedef _di__ApplicationDirectory ApplicationDirectory;

__interface _ApplicationDirectoryMembershipCondition;
typedef System::DelphiInterface<_ApplicationDirectoryMembershipCondition> _di__ApplicationDirectoryMembershipCondition;
typedef _di__ApplicationDirectoryMembershipCondition ApplicationDirectoryMembershipCondition;

__interface _CodeGroup;
typedef System::DelphiInterface<_CodeGroup> _di__CodeGroup;
typedef _di__CodeGroup CodeGroup;

__interface _Evidence;
typedef System::DelphiInterface<_Evidence> _di__Evidence;
typedef _di__Evidence Evidence;

__interface _FileCodeGroup;
typedef System::DelphiInterface<_FileCodeGroup> _di__FileCodeGroup;
typedef _di__FileCodeGroup FileCodeGroup;

__interface _FirstMatchCodeGroup;
typedef System::DelphiInterface<_FirstMatchCodeGroup> _di__FirstMatchCodeGroup;
typedef _di__FirstMatchCodeGroup FirstMatchCodeGroup;

__interface _Hash;
typedef System::DelphiInterface<_Hash> _di__Hash;
typedef _di__Hash Hash;

__interface _HashMembershipCondition;
typedef System::DelphiInterface<_HashMembershipCondition> _di__HashMembershipCondition;
typedef _di__HashMembershipCondition HashMembershipCondition;

__interface _NetCodeGroup;
typedef System::DelphiInterface<_NetCodeGroup> _di__NetCodeGroup;
typedef _di__NetCodeGroup NetCodeGroup;

__interface _PermissionRequestEvidence;
typedef System::DelphiInterface<_PermissionRequestEvidence> _di__PermissionRequestEvidence;
typedef _di__PermissionRequestEvidence PermissionRequestEvidence;

__interface _PolicyException;
typedef System::DelphiInterface<_PolicyException> _di__PolicyException;
typedef _di__PolicyException PolicyException;

__interface _PolicyLevel;
typedef System::DelphiInterface<_PolicyLevel> _di__PolicyLevel;
typedef _di__PolicyLevel PolicyLevel;

__interface _PolicyStatement;
typedef System::DelphiInterface<_PolicyStatement> _di__PolicyStatement;
typedef _di__PolicyStatement PolicyStatement;

__interface _Publisher;
typedef System::DelphiInterface<_Publisher> _di__Publisher;
typedef _di__Publisher Publisher;

__interface _PublisherMembershipCondition;
typedef System::DelphiInterface<_PublisherMembershipCondition> _di__PublisherMembershipCondition;
typedef _di__PublisherMembershipCondition PublisherMembershipCondition;

__interface _Site;
typedef System::DelphiInterface<_Site> _di__Site;
typedef _di__Site Site;

__interface _SiteMembershipCondition;
typedef System::DelphiInterface<_SiteMembershipCondition> _di__SiteMembershipCondition;
typedef _di__SiteMembershipCondition SiteMembershipCondition;

__interface _StrongName;
typedef System::DelphiInterface<_StrongName> _di__StrongName;
typedef _di__StrongName StrongName;

__interface _StrongNameMembershipCondition;
typedef System::DelphiInterface<_StrongNameMembershipCondition> _di__StrongNameMembershipCondition;
typedef _di__StrongNameMembershipCondition StrongNameMembershipCondition;

__interface _UnionCodeGroup;
typedef System::DelphiInterface<_UnionCodeGroup> _di__UnionCodeGroup;
typedef _di__UnionCodeGroup UnionCodeGroup;

__interface _Url;
typedef System::DelphiInterface<_Url> _di__Url;
typedef _di__Url Url;

__interface _UrlMembershipCondition;
typedef System::DelphiInterface<_UrlMembershipCondition> _di__UrlMembershipCondition;
typedef _di__UrlMembershipCondition UrlMembershipCondition;

__interface _Zone;
typedef System::DelphiInterface<_Zone> _di__Zone;
typedef _di__Zone Zone;

__interface _ZoneMembershipCondition;
typedef System::DelphiInterface<_ZoneMembershipCondition> _di__ZoneMembershipCondition;
typedef _di__ZoneMembershipCondition ZoneMembershipCondition;

__interface _GenericIdentity;
typedef System::DelphiInterface<_GenericIdentity> _di__GenericIdentity;
typedef _di__GenericIdentity GenericIdentity;

__interface _GenericPrincipal;
typedef System::DelphiInterface<_GenericPrincipal> _di__GenericPrincipal;
typedef _di__GenericPrincipal GenericPrincipal;

__interface _WindowsIdentity;
typedef System::DelphiInterface<_WindowsIdentity> _di__WindowsIdentity;
typedef _di__WindowsIdentity WindowsIdentity;

__interface _WindowsImpersonationContext;
typedef System::DelphiInterface<_WindowsImpersonationContext> _di__WindowsImpersonationContext;
typedef _di__WindowsImpersonationContext WindowsImpersonationContext;

__interface _WindowsPrincipal;
typedef System::DelphiInterface<_WindowsPrincipal> _di__WindowsPrincipal;
typedef _di__WindowsPrincipal WindowsPrincipal;

__interface _DispIdAttribute;
typedef System::DelphiInterface<_DispIdAttribute> _di__DispIdAttribute;
typedef _di__DispIdAttribute DispIdAttribute;

__interface _InterfaceTypeAttribute;
typedef System::DelphiInterface<_InterfaceTypeAttribute> _di__InterfaceTypeAttribute;
typedef _di__InterfaceTypeAttribute InterfaceTypeAttribute;

__interface _ClassInterfaceAttribute;
typedef System::DelphiInterface<_ClassInterfaceAttribute> _di__ClassInterfaceAttribute;
typedef _di__ClassInterfaceAttribute ClassInterfaceAttribute;

__interface _ComVisibleAttribute;
typedef System::DelphiInterface<_ComVisibleAttribute> _di__ComVisibleAttribute;
typedef _di__ComVisibleAttribute ComVisibleAttribute;

__interface _LCIDConversionAttribute;
typedef System::DelphiInterface<_LCIDConversionAttribute> _di__LCIDConversionAttribute;
typedef _di__LCIDConversionAttribute LCIDConversionAttribute;

__interface _ComRegisterFunctionAttribute;
typedef System::DelphiInterface<_ComRegisterFunctionAttribute> _di__ComRegisterFunctionAttribute;
typedef _di__ComRegisterFunctionAttribute ComRegisterFunctionAttribute;

__interface _ComUnregisterFunctionAttribute;
typedef System::DelphiInterface<_ComUnregisterFunctionAttribute> _di__ComUnregisterFunctionAttribute;
typedef _di__ComUnregisterFunctionAttribute ComUnregisterFunctionAttribute;

__interface _ProgIdAttribute;
typedef System::DelphiInterface<_ProgIdAttribute> _di__ProgIdAttribute;
typedef _di__ProgIdAttribute ProgIdAttribute;

__interface _ImportedFromTypeLibAttribute;
typedef System::DelphiInterface<_ImportedFromTypeLibAttribute> _di__ImportedFromTypeLibAttribute;
typedef _di__ImportedFromTypeLibAttribute ImportedFromTypeLibAttribute;

__interface _IDispatchImplAttribute;
typedef System::DelphiInterface<_IDispatchImplAttribute> _di__IDispatchImplAttribute;
typedef _di__IDispatchImplAttribute IDispatchImplAttribute;

__interface _ComSourceInterfacesAttribute;
typedef System::DelphiInterface<_ComSourceInterfacesAttribute> _di__ComSourceInterfacesAttribute;
typedef _di__ComSourceInterfacesAttribute ComSourceInterfacesAttribute;

__interface _ComConversionLossAttribute;
typedef System::DelphiInterface<_ComConversionLossAttribute> _di__ComConversionLossAttribute;
typedef _di__ComConversionLossAttribute ComConversionLossAttribute;

__interface _TypeLibTypeAttribute;
typedef System::DelphiInterface<_TypeLibTypeAttribute> _di__TypeLibTypeAttribute;
typedef _di__TypeLibTypeAttribute TypeLibTypeAttribute;

__interface _TypeLibFuncAttribute;
typedef System::DelphiInterface<_TypeLibFuncAttribute> _di__TypeLibFuncAttribute;
typedef _di__TypeLibFuncAttribute TypeLibFuncAttribute;

__interface _TypeLibVarAttribute;
typedef System::DelphiInterface<_TypeLibVarAttribute> _di__TypeLibVarAttribute;
typedef _di__TypeLibVarAttribute TypeLibVarAttribute;

__interface _MarshalAsAttribute;
typedef System::DelphiInterface<_MarshalAsAttribute> _di__MarshalAsAttribute;
typedef _di__MarshalAsAttribute MarshalAsAttribute;

__interface _ComImportAttribute;
typedef System::DelphiInterface<_ComImportAttribute> _di__ComImportAttribute;
typedef _di__ComImportAttribute ComImportAttribute;

__interface _GuidAttribute;
typedef System::DelphiInterface<_GuidAttribute> _di__GuidAttribute;
typedef _di__GuidAttribute GuidAttribute;

__interface _PreserveSigAttribute;
typedef System::DelphiInterface<_PreserveSigAttribute> _di__PreserveSigAttribute;
typedef _di__PreserveSigAttribute PreserveSigAttribute;

__interface _InAttribute;
typedef System::DelphiInterface<_InAttribute> _di__InAttribute;
typedef _di__InAttribute InAttribute;

__interface _OutAttribute;
typedef System::DelphiInterface<_OutAttribute> _di__OutAttribute;
typedef _di__OutAttribute OutAttribute;

__interface _OptionalAttribute;
typedef System::DelphiInterface<_OptionalAttribute> _di__OptionalAttribute;
typedef _di__OptionalAttribute OptionalAttribute;

__interface _DllImportAttribute;
typedef System::DelphiInterface<_DllImportAttribute> _di__DllImportAttribute;
typedef _di__DllImportAttribute DllImportAttribute;

__interface _StructLayoutAttribute;
typedef System::DelphiInterface<_StructLayoutAttribute> _di__StructLayoutAttribute;
typedef _di__StructLayoutAttribute StructLayoutAttribute;

__interface _FieldOffsetAttribute;
typedef System::DelphiInterface<_FieldOffsetAttribute> _di__FieldOffsetAttribute;
typedef _di__FieldOffsetAttribute FieldOffsetAttribute;

__interface _ComAliasNameAttribute;
typedef System::DelphiInterface<_ComAliasNameAttribute> _di__ComAliasNameAttribute;
typedef _di__ComAliasNameAttribute ComAliasNameAttribute;

__interface _AutomationProxyAttribute;
typedef System::DelphiInterface<_AutomationProxyAttribute> _di__AutomationProxyAttribute;
typedef _di__AutomationProxyAttribute AutomationProxyAttribute;

__interface _PrimaryInteropAssemblyAttribute;
typedef System::DelphiInterface<_PrimaryInteropAssemblyAttribute> _di__PrimaryInteropAssemblyAttribute;
typedef _di__PrimaryInteropAssemblyAttribute PrimaryInteropAssemblyAttribute;

__interface _CoClassAttribute;
typedef System::DelphiInterface<_CoClassAttribute> _di__CoClassAttribute;
typedef _di__CoClassAttribute CoClassAttribute;

__interface _ComEventInterfaceAttribute;
typedef System::DelphiInterface<_ComEventInterfaceAttribute> _di__ComEventInterfaceAttribute;
typedef _di__ComEventInterfaceAttribute ComEventInterfaceAttribute;

__interface _TypeLibVersionAttribute;
typedef System::DelphiInterface<_TypeLibVersionAttribute> _di__TypeLibVersionAttribute;
typedef _di__TypeLibVersionAttribute TypeLibVersionAttribute;

__interface _ComCompatibleVersionAttribute;
typedef System::DelphiInterface<_ComCompatibleVersionAttribute> _di__ComCompatibleVersionAttribute;
typedef _di__ComCompatibleVersionAttribute ComCompatibleVersionAttribute;

__interface _BestFitMappingAttribute;
typedef System::DelphiInterface<_BestFitMappingAttribute> _di__BestFitMappingAttribute;
typedef _di__BestFitMappingAttribute BestFitMappingAttribute;

__interface _ExternalException;
typedef System::DelphiInterface<_ExternalException> _di__ExternalException;
typedef _di__ExternalException ExternalException;

__interface _COMException;
typedef System::DelphiInterface<_COMException> _di__COMException;
typedef _di__COMException COMException;

__interface _CurrencyWrapper;
typedef System::DelphiInterface<_CurrencyWrapper> _di__CurrencyWrapper;
typedef _di__CurrencyWrapper CurrencyWrapper;

__interface _DispatchWrapper;
typedef System::DelphiInterface<_DispatchWrapper> _di__DispatchWrapper;
typedef _di__DispatchWrapper DispatchWrapper;

__interface _ErrorWrapper;
typedef System::DelphiInterface<_ErrorWrapper> _di__ErrorWrapper;
typedef _di__ErrorWrapper ErrorWrapper;

__interface _ExtensibleClassFactory;
typedef System::DelphiInterface<_ExtensibleClassFactory> _di__ExtensibleClassFactory;
typedef _di__ExtensibleClassFactory ExtensibleClassFactory;

__interface _InvalidComObjectException;
typedef System::DelphiInterface<_InvalidComObjectException> _di__InvalidComObjectException;
typedef _di__InvalidComObjectException InvalidComObjectException;

__interface _InvalidOleVariantTypeException;
typedef System::DelphiInterface<_InvalidOleVariantTypeException> _di__InvalidOleVariantTypeException;
typedef _di__InvalidOleVariantTypeException InvalidOleVariantTypeException;

__interface _Marshal;
typedef System::DelphiInterface<_Marshal> _di__Marshal;
typedef _di__Marshal Marshal;

__interface _MarshalDirectiveException;
typedef System::DelphiInterface<_MarshalDirectiveException> _di__MarshalDirectiveException;
typedef _di__MarshalDirectiveException MarshalDirectiveException;

__interface _ObjectCreationDelegate;
typedef System::DelphiInterface<_ObjectCreationDelegate> _di__ObjectCreationDelegate;
typedef _di__ObjectCreationDelegate ObjectCreationDelegate;

__interface _RuntimeEnvironment;
typedef System::DelphiInterface<_RuntimeEnvironment> _di__RuntimeEnvironment;
typedef _di__RuntimeEnvironment RuntimeEnvironment;

__interface _SafeArrayRankMismatchException;
typedef System::DelphiInterface<_SafeArrayRankMismatchException> _di__SafeArrayRankMismatchException;
typedef _di__SafeArrayRankMismatchException SafeArrayRankMismatchException;

__interface _SafeArrayTypeMismatchException;
typedef System::DelphiInterface<_SafeArrayTypeMismatchException> _di__SafeArrayTypeMismatchException;
typedef _di__SafeArrayTypeMismatchException SafeArrayTypeMismatchException;

__interface _SEHException;
typedef System::DelphiInterface<_SEHException> _di__SEHException;
typedef _di__SEHException SEHException;

__interface _UnknownWrapper;
typedef System::DelphiInterface<_UnknownWrapper> _di__UnknownWrapper;
typedef _di__UnknownWrapper UnknownWrapper;

__interface _BinaryReader;
typedef System::DelphiInterface<_BinaryReader> _di__BinaryReader;
typedef _di__BinaryReader BinaryReader;

__interface _BinaryWriter;
typedef System::DelphiInterface<_BinaryWriter> _di__BinaryWriter;
typedef _di__BinaryWriter BinaryWriter;

__interface _BufferedStream;
typedef System::DelphiInterface<_BufferedStream> _di__BufferedStream;
typedef _di__BufferedStream BufferedStream;

__interface _Directory;
typedef System::DelphiInterface<_Directory> _di__Directory;
typedef _di__Directory Directory;

__interface _FileSystemInfo;
typedef System::DelphiInterface<_FileSystemInfo> _di__FileSystemInfo;
typedef _di__FileSystemInfo FileSystemInfo;

__interface _DirectoryInfo;
typedef System::DelphiInterface<_DirectoryInfo> _di__DirectoryInfo;
typedef _di__DirectoryInfo DirectoryInfo;

__interface _IOException;
typedef System::DelphiInterface<_IOException> _di__IOException;
typedef _di__IOException IOException;

__interface _DirectoryNotFoundException;
typedef System::DelphiInterface<_DirectoryNotFoundException> _di__DirectoryNotFoundException;
typedef _di__DirectoryNotFoundException DirectoryNotFoundException;

__interface _EndOfStreamException;
typedef System::DelphiInterface<_EndOfStreamException> _di__EndOfStreamException;
typedef _di__EndOfStreamException EndOfStreamException;

__interface _File;
typedef System::DelphiInterface<_File> _di__File;
typedef _di__File File_;

__interface _FileInfo;
typedef System::DelphiInterface<_FileInfo> _di__FileInfo;
typedef _di__FileInfo FileInfo;

__interface _FileLoadException;
typedef System::DelphiInterface<_FileLoadException> _di__FileLoadException;
typedef _di__FileLoadException FileLoadException;

__interface _FileNotFoundException;
typedef System::DelphiInterface<_FileNotFoundException> _di__FileNotFoundException;
typedef _di__FileNotFoundException FileNotFoundException;

__interface _FileStream;
typedef System::DelphiInterface<_FileStream> _di__FileStream;
typedef _di__FileStream FileStream;

__interface _MemoryStream;
typedef System::DelphiInterface<_MemoryStream> _di__MemoryStream;
typedef _di__MemoryStream MemoryStream;

__interface _Path;
typedef System::DelphiInterface<_Path> _di__Path;
typedef _di__Path Path;

__interface _PathTooLongException;
typedef System::DelphiInterface<_PathTooLongException> _di__PathTooLongException;
typedef _di__PathTooLongException PathTooLongException;

__interface _TextReader;
typedef System::DelphiInterface<_TextReader> _di__TextReader;
typedef _di__TextReader TextReader;

__interface _StreamReader;
typedef System::DelphiInterface<_StreamReader> _di__StreamReader;
typedef _di__StreamReader StreamReader;

__interface _TextWriter;
typedef System::DelphiInterface<_TextWriter> _di__TextWriter;
typedef _di__TextWriter TextWriter;

__interface _StreamWriter;
typedef System::DelphiInterface<_StreamWriter> _di__StreamWriter;
typedef _di__StreamWriter StreamWriter;

__interface _StringReader;
typedef System::DelphiInterface<_StringReader> _di__StringReader;
typedef _di__StringReader StringReader;

__interface _StringWriter;
typedef System::DelphiInterface<_StringWriter> _di__StringWriter;
typedef _di__StringWriter StringWriter;

__interface _AccessedThroughPropertyAttribute;
typedef System::DelphiInterface<_AccessedThroughPropertyAttribute> _di__AccessedThroughPropertyAttribute;
typedef _di__AccessedThroughPropertyAttribute AccessedThroughPropertyAttribute;

__interface _CallConvCdecl;
typedef System::DelphiInterface<_CallConvCdecl> _di__CallConvCdecl;
typedef _di__CallConvCdecl CallConvCdecl;

__interface _CallConvStdcall;
typedef System::DelphiInterface<_CallConvStdcall> _di__CallConvStdcall;
typedef _di__CallConvStdcall CallConvStdcall;

__interface _CallConvThiscall;
typedef System::DelphiInterface<_CallConvThiscall> _di__CallConvThiscall;
typedef _di__CallConvThiscall CallConvThiscall;

__interface _CallConvFastcall;
typedef System::DelphiInterface<_CallConvFastcall> _di__CallConvFastcall;
typedef _di__CallConvFastcall CallConvFastcall;

__interface _RuntimeHelpers;
typedef System::DelphiInterface<_RuntimeHelpers> _di__RuntimeHelpers;
typedef _di__RuntimeHelpers RuntimeHelpers;

__interface _CustomConstantAttribute;
typedef System::DelphiInterface<_CustomConstantAttribute> _di__CustomConstantAttribute;
typedef _di__CustomConstantAttribute CustomConstantAttribute;

__interface _DateTimeConstantAttribute;
typedef System::DelphiInterface<_DateTimeConstantAttribute> _di__DateTimeConstantAttribute;
typedef _di__DateTimeConstantAttribute DateTimeConstantAttribute;

__interface _DiscardableAttribute;
typedef System::DelphiInterface<_DiscardableAttribute> _di__DiscardableAttribute;
typedef _di__DiscardableAttribute DiscardableAttribute;

__interface _DecimalConstantAttribute;
typedef System::DelphiInterface<_DecimalConstantAttribute> _di__DecimalConstantAttribute;
typedef _di__DecimalConstantAttribute DecimalConstantAttribute;

__interface _CompilationRelaxationsAttribute;
typedef System::DelphiInterface<_CompilationRelaxationsAttribute> _di__CompilationRelaxationsAttribute;
typedef _di__CompilationRelaxationsAttribute CompilationRelaxationsAttribute;

__interface _CompilerGlobalScopeAttribute;
typedef System::DelphiInterface<_CompilerGlobalScopeAttribute> _di__CompilerGlobalScopeAttribute;
typedef _di__CompilerGlobalScopeAttribute CompilerGlobalScopeAttribute;

__interface _IDispatchConstantAttribute;
typedef System::DelphiInterface<_IDispatchConstantAttribute> _di__IDispatchConstantAttribute;
typedef _di__IDispatchConstantAttribute IDispatchConstantAttribute;

__interface _IndexerNameAttribute;
typedef System::DelphiInterface<_IndexerNameAttribute> _di__IndexerNameAttribute;
typedef _di__IndexerNameAttribute IndexerNameAttribute;

__interface _IsVolatile;
typedef System::DelphiInterface<_IsVolatile> _di__IsVolatile;
typedef _di__IsVolatile IsVolatile;

__interface _IUnknownConstantAttribute;
typedef System::DelphiInterface<_IUnknownConstantAttribute> _di__IUnknownConstantAttribute;
typedef _di__IUnknownConstantAttribute IUnknownConstantAttribute;

__interface _MethodImplAttribute;
typedef System::DelphiInterface<_MethodImplAttribute> _di__MethodImplAttribute;
typedef _di__MethodImplAttribute MethodImplAttribute;

__interface _RequiredAttributeAttribute;
typedef System::DelphiInterface<_RequiredAttributeAttribute> _di__RequiredAttributeAttribute;
typedef _di__RequiredAttributeAttribute RequiredAttributeAttribute;

__interface _PermissionSet;
typedef System::DelphiInterface<_PermissionSet> _di__PermissionSet;
typedef _di__PermissionSet PermissionSet;

__interface _NamedPermissionSet;
typedef System::DelphiInterface<_NamedPermissionSet> _di__NamedPermissionSet;
typedef _di__NamedPermissionSet NamedPermissionSet;

__interface _SecurityElement;
typedef System::DelphiInterface<_SecurityElement> _di__SecurityElement;
typedef _di__SecurityElement SecurityElement;

__interface _XmlSyntaxException;
typedef System::DelphiInterface<_XmlSyntaxException> _di__XmlSyntaxException;
typedef _di__XmlSyntaxException XmlSyntaxException;

__interface _CodeAccessPermission;
typedef System::DelphiInterface<_CodeAccessPermission> _di__CodeAccessPermission;
typedef _di__CodeAccessPermission CodeAccessPermission;

__interface _EnvironmentPermission;
typedef System::DelphiInterface<_EnvironmentPermission> _di__EnvironmentPermission;
typedef _di__EnvironmentPermission EnvironmentPermission;

__interface _FileDialogPermission;
typedef System::DelphiInterface<_FileDialogPermission> _di__FileDialogPermission;
typedef _di__FileDialogPermission FileDialogPermission;

__interface _FileIOPermission;
typedef System::DelphiInterface<_FileIOPermission> _di__FileIOPermission;
typedef _di__FileIOPermission FileIOPermission;

__interface _IsolatedStoragePermission;
typedef System::DelphiInterface<_IsolatedStoragePermission> _di__IsolatedStoragePermission;
typedef _di__IsolatedStoragePermission IsolatedStoragePermission;

__interface _IsolatedStorageFilePermission;
typedef System::DelphiInterface<_IsolatedStorageFilePermission> _di__IsolatedStorageFilePermission;
typedef _di__IsolatedStorageFilePermission IsolatedStorageFilePermission;

__interface _SecurityAttribute;
typedef System::DelphiInterface<_SecurityAttribute> _di__SecurityAttribute;
typedef _di__SecurityAttribute SecurityAttribute;

__interface _CodeAccessSecurityAttribute;
typedef System::DelphiInterface<_CodeAccessSecurityAttribute> _di__CodeAccessSecurityAttribute;
typedef _di__CodeAccessSecurityAttribute CodeAccessSecurityAttribute;

__interface _EnvironmentPermissionAttribute;
typedef System::DelphiInterface<_EnvironmentPermissionAttribute> _di__EnvironmentPermissionAttribute;
typedef _di__EnvironmentPermissionAttribute EnvironmentPermissionAttribute;

__interface _FileDialogPermissionAttribute;
typedef System::DelphiInterface<_FileDialogPermissionAttribute> _di__FileDialogPermissionAttribute;
typedef _di__FileDialogPermissionAttribute FileDialogPermissionAttribute;

__interface _FileIOPermissionAttribute;
typedef System::DelphiInterface<_FileIOPermissionAttribute> _di__FileIOPermissionAttribute;
typedef _di__FileIOPermissionAttribute FileIOPermissionAttribute;

__interface _PrincipalPermissionAttribute;
typedef System::DelphiInterface<_PrincipalPermissionAttribute> _di__PrincipalPermissionAttribute;
typedef _di__PrincipalPermissionAttribute PrincipalPermissionAttribute;

__interface _ReflectionPermissionAttribute;
typedef System::DelphiInterface<_ReflectionPermissionAttribute> _di__ReflectionPermissionAttribute;
typedef _di__ReflectionPermissionAttribute ReflectionPermissionAttribute;

__interface _RegistryPermissionAttribute;
typedef System::DelphiInterface<_RegistryPermissionAttribute> _di__RegistryPermissionAttribute;
typedef _di__RegistryPermissionAttribute RegistryPermissionAttribute;

__interface _SecurityPermissionAttribute;
typedef System::DelphiInterface<_SecurityPermissionAttribute> _di__SecurityPermissionAttribute;
typedef _di__SecurityPermissionAttribute SecurityPermissionAttribute;

__interface _UIPermissionAttribute;
typedef System::DelphiInterface<_UIPermissionAttribute> _di__UIPermissionAttribute;
typedef _di__UIPermissionAttribute UIPermissionAttribute;

__interface _ZoneIdentityPermissionAttribute;
typedef System::DelphiInterface<_ZoneIdentityPermissionAttribute> _di__ZoneIdentityPermissionAttribute;
typedef _di__ZoneIdentityPermissionAttribute ZoneIdentityPermissionAttribute;

__interface _StrongNameIdentityPermissionAttribute;
typedef System::DelphiInterface<_StrongNameIdentityPermissionAttribute> _di__StrongNameIdentityPermissionAttribute;
typedef _di__StrongNameIdentityPermissionAttribute StrongNameIdentityPermissionAttribute;

__interface _SiteIdentityPermissionAttribute;
typedef System::DelphiInterface<_SiteIdentityPermissionAttribute> _di__SiteIdentityPermissionAttribute;
typedef _di__SiteIdentityPermissionAttribute SiteIdentityPermissionAttribute;

__interface _UrlIdentityPermissionAttribute;
typedef System::DelphiInterface<_UrlIdentityPermissionAttribute> _di__UrlIdentityPermissionAttribute;
typedef _di__UrlIdentityPermissionAttribute UrlIdentityPermissionAttribute;

__interface _PublisherIdentityPermissionAttribute;
typedef System::DelphiInterface<_PublisherIdentityPermissionAttribute> _di__PublisherIdentityPermissionAttribute;
typedef _di__PublisherIdentityPermissionAttribute PublisherIdentityPermissionAttribute;

__interface _IsolatedStoragePermissionAttribute;
typedef System::DelphiInterface<_IsolatedStoragePermissionAttribute> _di__IsolatedStoragePermissionAttribute;
typedef _di__IsolatedStoragePermissionAttribute IsolatedStoragePermissionAttribute;

__interface _IsolatedStorageFilePermissionAttribute;
typedef System::DelphiInterface<_IsolatedStorageFilePermissionAttribute> _di__IsolatedStorageFilePermissionAttribute;
typedef _di__IsolatedStorageFilePermissionAttribute IsolatedStorageFilePermissionAttribute;

__interface _PermissionSetAttribute;
typedef System::DelphiInterface<_PermissionSetAttribute> _di__PermissionSetAttribute;
typedef _di__PermissionSetAttribute PermissionSetAttribute;

__interface _PublisherIdentityPermission;
typedef System::DelphiInterface<_PublisherIdentityPermission> _di__PublisherIdentityPermission;
typedef _di__PublisherIdentityPermission PublisherIdentityPermission;

__interface _ReflectionPermission;
typedef System::DelphiInterface<_ReflectionPermission> _di__ReflectionPermission;
typedef _di__ReflectionPermission ReflectionPermission;

__interface _RegistryPermission;
typedef System::DelphiInterface<_RegistryPermission> _di__RegistryPermission;
typedef _di__RegistryPermission RegistryPermission;

__interface _PrincipalPermission;
typedef System::DelphiInterface<_PrincipalPermission> _di__PrincipalPermission;
typedef _di__PrincipalPermission PrincipalPermission;

__interface _SecurityPermission;
typedef System::DelphiInterface<_SecurityPermission> _di__SecurityPermission;
typedef _di__SecurityPermission SecurityPermission;

__interface _SiteIdentityPermission;
typedef System::DelphiInterface<_SiteIdentityPermission> _di__SiteIdentityPermission;
typedef _di__SiteIdentityPermission SiteIdentityPermission;

__interface _StrongNameIdentityPermission;
typedef System::DelphiInterface<_StrongNameIdentityPermission> _di__StrongNameIdentityPermission;
typedef _di__StrongNameIdentityPermission StrongNameIdentityPermission;

__interface _StrongNamePublicKeyBlob;
typedef System::DelphiInterface<_StrongNamePublicKeyBlob> _di__StrongNamePublicKeyBlob;
typedef _di__StrongNamePublicKeyBlob StrongNamePublicKeyBlob;

__interface _UIPermission;
typedef System::DelphiInterface<_UIPermission> _di__UIPermission;
typedef _di__UIPermission UIPermission;

__interface _UrlIdentityPermission;
typedef System::DelphiInterface<_UrlIdentityPermission> _di__UrlIdentityPermission;
typedef _di__UrlIdentityPermission UrlIdentityPermission;

__interface _ZoneIdentityPermission;
typedef System::DelphiInterface<_ZoneIdentityPermission> _di__ZoneIdentityPermission;
typedef _di__ZoneIdentityPermission ZoneIdentityPermission;

__interface _SuppressUnmanagedCodeSecurityAttribute;
typedef System::DelphiInterface<_SuppressUnmanagedCodeSecurityAttribute> _di__SuppressUnmanagedCodeSecurityAttribute;
typedef _di__SuppressUnmanagedCodeSecurityAttribute SuppressUnmanagedCodeSecurityAttribute;

__interface _UnverifiableCodeAttribute;
typedef System::DelphiInterface<_UnverifiableCodeAttribute> _di__UnverifiableCodeAttribute;
typedef _di__UnverifiableCodeAttribute UnverifiableCodeAttribute;

__interface _AllowPartiallyTrustedCallersAttribute;
typedef System::DelphiInterface<_AllowPartiallyTrustedCallersAttribute> _di__AllowPartiallyTrustedCallersAttribute;
typedef _di__AllowPartiallyTrustedCallersAttribute AllowPartiallyTrustedCallersAttribute;

__interface _SecurityException;
typedef System::DelphiInterface<_SecurityException> _di__SecurityException;
typedef _di__SecurityException SecurityException;

__interface _SecurityManager;
typedef System::DelphiInterface<_SecurityManager> _di__SecurityManager;
typedef _di__SecurityManager SecurityManager;

__interface _VerificationException;
typedef System::DelphiInterface<_VerificationException> _di__VerificationException;
typedef _di__VerificationException VerificationException;

__interface _ContextAttribute;
typedef System::DelphiInterface<_ContextAttribute> _di__ContextAttribute;
typedef _di__ContextAttribute ContextAttribute;

__interface _AsyncResult;
typedef System::DelphiInterface<_AsyncResult> _di__AsyncResult;
typedef _di__AsyncResult AsyncResult;

__interface _CallContext;
typedef System::DelphiInterface<_CallContext> _di__CallContext;
typedef _di__CallContext CallContext;

__interface _LogicalCallContext;
typedef System::DelphiInterface<_LogicalCallContext> _di__LogicalCallContext;
typedef _di__LogicalCallContext LogicalCallContext;

__interface _ChannelServices;
typedef System::DelphiInterface<_ChannelServices> _di__ChannelServices;
typedef _di__ChannelServices ChannelServices;

__interface _ClientChannelSinkStack;
typedef System::DelphiInterface<_ClientChannelSinkStack> _di__ClientChannelSinkStack;
typedef _di__ClientChannelSinkStack ClientChannelSinkStack;

__interface _ServerChannelSinkStack;
typedef System::DelphiInterface<_ServerChannelSinkStack> _di__ServerChannelSinkStack;
typedef _di__ServerChannelSinkStack ServerChannelSinkStack;

__interface _InternalMessageWrapper;
typedef System::DelphiInterface<_InternalMessageWrapper> _di__InternalMessageWrapper;
typedef _di__InternalMessageWrapper InternalMessageWrapper;

__interface _MethodCallMessageWrapper;
typedef System::DelphiInterface<_MethodCallMessageWrapper> _di__MethodCallMessageWrapper;
typedef _di__MethodCallMessageWrapper MethodCallMessageWrapper;

__interface _ClientSponsor;
typedef System::DelphiInterface<_ClientSponsor> _di__ClientSponsor;
typedef _di__ClientSponsor ClientSponsor;

__interface _CrossContextDelegate;
typedef System::DelphiInterface<_CrossContextDelegate> _di__CrossContextDelegate;
typedef _di__CrossContextDelegate CrossContextDelegate;

__interface _Context;
typedef System::DelphiInterface<_Context> _di__Context;
typedef _di__Context Context;

__interface _ContextProperty;
typedef System::DelphiInterface<_ContextProperty> _di__ContextProperty;
typedef _di__ContextProperty ContextProperty;

__interface _EnterpriseServicesHelper;
typedef System::DelphiInterface<_EnterpriseServicesHelper> _di__EnterpriseServicesHelper;
typedef _di__EnterpriseServicesHelper EnterpriseServicesHelper;

__interface _Header;
typedef System::DelphiInterface<_Header> _di__Header;
typedef _di__Header Header;

__interface _HeaderHandler;
typedef System::DelphiInterface<_HeaderHandler> _di__HeaderHandler;
typedef _di__HeaderHandler HeaderHandler;

__interface _ChannelDataStore;
typedef System::DelphiInterface<_ChannelDataStore> _di__ChannelDataStore;
typedef _di__ChannelDataStore ChannelDataStore;

__interface _TransportHeaders;
typedef System::DelphiInterface<_TransportHeaders> _di__TransportHeaders;
typedef _di__TransportHeaders TransportHeaders;

__interface _SinkProviderData;
typedef System::DelphiInterface<_SinkProviderData> _di__SinkProviderData;
typedef _di__SinkProviderData SinkProviderData;

__interface _BaseChannelObjectWithProperties;
typedef System::DelphiInterface<_BaseChannelObjectWithProperties> _di__BaseChannelObjectWithProperties;
typedef _di__BaseChannelObjectWithProperties BaseChannelObjectWithProperties;

__interface _BaseChannelSinkWithProperties;
typedef System::DelphiInterface<_BaseChannelSinkWithProperties> _di__BaseChannelSinkWithProperties;
typedef _di__BaseChannelSinkWithProperties BaseChannelSinkWithProperties;

__interface _BaseChannelWithProperties;
typedef System::DelphiInterface<_BaseChannelWithProperties> _di__BaseChannelWithProperties;
typedef _di__BaseChannelWithProperties BaseChannelWithProperties;

__interface _LifetimeServices;
typedef System::DelphiInterface<_LifetimeServices> _di__LifetimeServices;
typedef _di__LifetimeServices LifetimeServices;

__interface _ReturnMessage;
typedef System::DelphiInterface<_ReturnMessage> _di__ReturnMessage;
typedef _di__ReturnMessage ReturnMessage;

__interface _MethodCall;
typedef System::DelphiInterface<_MethodCall> _di__MethodCall;
typedef _di__MethodCall MethodCall;

__interface _ConstructionCall;
typedef System::DelphiInterface<_ConstructionCall> _di__ConstructionCall;
typedef _di__ConstructionCall ConstructionCall;

__interface _MethodResponse;
typedef System::DelphiInterface<_MethodResponse> _di__MethodResponse;
typedef _di__MethodResponse MethodResponse;

__interface _ConstructionResponse;
typedef System::DelphiInterface<_ConstructionResponse> _di__ConstructionResponse;
typedef _di__ConstructionResponse ConstructionResponse;

__interface _MethodReturnMessageWrapper;
typedef System::DelphiInterface<_MethodReturnMessageWrapper> _di__MethodReturnMessageWrapper;
typedef _di__MethodReturnMessageWrapper MethodReturnMessageWrapper;

__interface _ObjectHandle;
typedef System::DelphiInterface<_ObjectHandle> _di__ObjectHandle;
typedef _di__ObjectHandle ObjectHandle;

__interface _ObjRef;
typedef System::DelphiInterface<_ObjRef> _di__ObjRef;
typedef _di__ObjRef ObjRef;

__interface _OneWayAttribute;
typedef System::DelphiInterface<_OneWayAttribute> _di__OneWayAttribute;
typedef _di__OneWayAttribute OneWayAttribute;

__interface _ProxyAttribute;
typedef System::DelphiInterface<_ProxyAttribute> _di__ProxyAttribute;
typedef _di__ProxyAttribute ProxyAttribute;

__interface _RealProxy;
typedef System::DelphiInterface<_RealProxy> _di__RealProxy;
typedef _di__RealProxy RealProxy;

__interface _SoapAttribute;
typedef System::DelphiInterface<_SoapAttribute> _di__SoapAttribute;
typedef _di__SoapAttribute SoapAttribute;

__interface _SoapTypeAttribute;
typedef System::DelphiInterface<_SoapTypeAttribute> _di__SoapTypeAttribute;
typedef _di__SoapTypeAttribute SoapTypeAttribute;

__interface _SoapMethodAttribute;
typedef System::DelphiInterface<_SoapMethodAttribute> _di__SoapMethodAttribute;
typedef _di__SoapMethodAttribute SoapMethodAttribute;

__interface _SoapFieldAttribute;
typedef System::DelphiInterface<_SoapFieldAttribute> _di__SoapFieldAttribute;
typedef _di__SoapFieldAttribute SoapFieldAttribute;

__interface _SoapParameterAttribute;
typedef System::DelphiInterface<_SoapParameterAttribute> _di__SoapParameterAttribute;
typedef _di__SoapParameterAttribute SoapParameterAttribute;

__interface _RemotingConfiguration;
typedef System::DelphiInterface<_RemotingConfiguration> _di__RemotingConfiguration;
typedef _di__RemotingConfiguration RemotingConfiguration;

__interface _System_Runtime_Remoting_TypeEntry;
typedef System::DelphiInterface<_System_Runtime_Remoting_TypeEntry> _di__System_Runtime_Remoting_TypeEntry;
typedef _di__System_Runtime_Remoting_TypeEntry System_Runtime_Remoting_TypeEntry;

__interface _ActivatedClientTypeEntry;
typedef System::DelphiInterface<_ActivatedClientTypeEntry> _di__ActivatedClientTypeEntry;
typedef _di__ActivatedClientTypeEntry ActivatedClientTypeEntry;

__interface _ActivatedServiceTypeEntry;
typedef System::DelphiInterface<_ActivatedServiceTypeEntry> _di__ActivatedServiceTypeEntry;
typedef _di__ActivatedServiceTypeEntry ActivatedServiceTypeEntry;

__interface _WellKnownClientTypeEntry;
typedef System::DelphiInterface<_WellKnownClientTypeEntry> _di__WellKnownClientTypeEntry;
typedef _di__WellKnownClientTypeEntry WellKnownClientTypeEntry;

__interface _WellKnownServiceTypeEntry;
typedef System::DelphiInterface<_WellKnownServiceTypeEntry> _di__WellKnownServiceTypeEntry;
typedef _di__WellKnownServiceTypeEntry WellKnownServiceTypeEntry;

__interface _RemotingException;
typedef System::DelphiInterface<_RemotingException> _di__RemotingException;
typedef _di__RemotingException RemotingException;

__interface _ServerException;
typedef System::DelphiInterface<_ServerException> _di__ServerException;
typedef _di__ServerException ServerException;

__interface _RemotingTimeoutException;
typedef System::DelphiInterface<_RemotingTimeoutException> _di__RemotingTimeoutException;
typedef _di__RemotingTimeoutException RemotingTimeoutException;

__interface _RemotingServices;
typedef System::DelphiInterface<_RemotingServices> _di__RemotingServices;
typedef _di__RemotingServices RemotingServices;

__interface _InternalRemotingServices;
typedef System::DelphiInterface<_InternalRemotingServices> _di__InternalRemotingServices;
typedef _di__InternalRemotingServices InternalRemotingServices;

__interface _MessageSurrogateFilter;
typedef System::DelphiInterface<_MessageSurrogateFilter> _di__MessageSurrogateFilter;
typedef _di__MessageSurrogateFilter MessageSurrogateFilter;

__interface _RemotingSurrogateSelector;
typedef System::DelphiInterface<_RemotingSurrogateSelector> _di__RemotingSurrogateSelector;
typedef _di__RemotingSurrogateSelector RemotingSurrogateSelector;

__interface _SoapServices;
typedef System::DelphiInterface<_SoapServices> _di__SoapServices;
typedef _di__SoapServices SoapServices;

__interface _SoapDateTime;
typedef System::DelphiInterface<_SoapDateTime> _di__SoapDateTime;
typedef _di__SoapDateTime SoapDateTime;

__interface _SoapDuration;
typedef System::DelphiInterface<_SoapDuration> _di__SoapDuration;
typedef _di__SoapDuration SoapDuration;

__interface _SoapTime;
typedef System::DelphiInterface<_SoapTime> _di__SoapTime;
typedef _di__SoapTime SoapTime;

__interface _SoapDate;
typedef System::DelphiInterface<_SoapDate> _di__SoapDate;
typedef _di__SoapDate SoapDate;

__interface _SoapYearMonth;
typedef System::DelphiInterface<_SoapYearMonth> _di__SoapYearMonth;
typedef _di__SoapYearMonth SoapYearMonth;

__interface _SoapYear;
typedef System::DelphiInterface<_SoapYear> _di__SoapYear;
typedef _di__SoapYear SoapYear;

__interface _SoapMonthDay;
typedef System::DelphiInterface<_SoapMonthDay> _di__SoapMonthDay;
typedef _di__SoapMonthDay SoapMonthDay;

__interface _SoapDay;
typedef System::DelphiInterface<_SoapDay> _di__SoapDay;
typedef _di__SoapDay SoapDay;

__interface _SoapMonth;
typedef System::DelphiInterface<_SoapMonth> _di__SoapMonth;
typedef _di__SoapMonth SoapMonth;

__interface _SoapHexBinary;
typedef System::DelphiInterface<_SoapHexBinary> _di__SoapHexBinary;
typedef _di__SoapHexBinary SoapHexBinary;

__interface _SoapBase64Binary;
typedef System::DelphiInterface<_SoapBase64Binary> _di__SoapBase64Binary;
typedef _di__SoapBase64Binary SoapBase64Binary;

__interface _SoapInteger;
typedef System::DelphiInterface<_SoapInteger> _di__SoapInteger;
typedef _di__SoapInteger SoapInteger;

__interface _SoapPositiveInteger;
typedef System::DelphiInterface<_SoapPositiveInteger> _di__SoapPositiveInteger;
typedef _di__SoapPositiveInteger SoapPositiveInteger;

__interface _SoapNonPositiveInteger;
typedef System::DelphiInterface<_SoapNonPositiveInteger> _di__SoapNonPositiveInteger;
typedef _di__SoapNonPositiveInteger SoapNonPositiveInteger;

__interface _SoapNonNegativeInteger;
typedef System::DelphiInterface<_SoapNonNegativeInteger> _di__SoapNonNegativeInteger;
typedef _di__SoapNonNegativeInteger SoapNonNegativeInteger;

__interface _SoapNegativeInteger;
typedef System::DelphiInterface<_SoapNegativeInteger> _di__SoapNegativeInteger;
typedef _di__SoapNegativeInteger SoapNegativeInteger;

__interface _SoapAnyUri;
typedef System::DelphiInterface<_SoapAnyUri> _di__SoapAnyUri;
typedef _di__SoapAnyUri SoapAnyUri;

__interface _SoapQName;
typedef System::DelphiInterface<_SoapQName> _di__SoapQName;
typedef _di__SoapQName SoapQName;

__interface _SoapNotation;
typedef System::DelphiInterface<_SoapNotation> _di__SoapNotation;
typedef _di__SoapNotation SoapNotation;

__interface _SoapNormalizedString;
typedef System::DelphiInterface<_SoapNormalizedString> _di__SoapNormalizedString;
typedef _di__SoapNormalizedString SoapNormalizedString;

__interface _SoapToken;
typedef System::DelphiInterface<_SoapToken> _di__SoapToken;
typedef _di__SoapToken SoapToken;

__interface _SoapLanguage;
typedef System::DelphiInterface<_SoapLanguage> _di__SoapLanguage;
typedef _di__SoapLanguage SoapLanguage;

__interface _SoapName;
typedef System::DelphiInterface<_SoapName> _di__SoapName;
typedef _di__SoapName SoapName;

__interface _SoapIdrefs;
typedef System::DelphiInterface<_SoapIdrefs> _di__SoapIdrefs;
typedef _di__SoapIdrefs SoapIdrefs;

__interface _SoapEntities;
typedef System::DelphiInterface<_SoapEntities> _di__SoapEntities;
typedef _di__SoapEntities SoapEntities;

__interface _SoapNmtoken;
typedef System::DelphiInterface<_SoapNmtoken> _di__SoapNmtoken;
typedef _di__SoapNmtoken SoapNmtoken;

__interface _SoapNmtokens;
typedef System::DelphiInterface<_SoapNmtokens> _di__SoapNmtokens;
typedef _di__SoapNmtokens SoapNmtokens;

__interface _SoapNcName;
typedef System::DelphiInterface<_SoapNcName> _di__SoapNcName;
typedef _di__SoapNcName SoapNcName;

__interface _SoapId;
typedef System::DelphiInterface<_SoapId> _di__SoapId;
typedef _di__SoapId SoapId;

__interface _SoapIdref;
typedef System::DelphiInterface<_SoapIdref> _di__SoapIdref;
typedef _di__SoapIdref SoapIdref;

__interface _SoapEntity;
typedef System::DelphiInterface<_SoapEntity> _di__SoapEntity;
typedef _di__SoapEntity SoapEntity;

__interface _SynchronizationAttribute;
typedef System::DelphiInterface<_SynchronizationAttribute> _di__SynchronizationAttribute;
typedef _di__SynchronizationAttribute SynchronizationAttribute;

__interface _TrackingServices;
typedef System::DelphiInterface<_TrackingServices> _di__TrackingServices;
typedef _di__TrackingServices TrackingServices;

__interface _UrlAttribute;
typedef System::DelphiInterface<_UrlAttribute> _di__UrlAttribute;
typedef _di__UrlAttribute UrlAttribute;

__interface _IsolatedStorage;
typedef System::DelphiInterface<_IsolatedStorage> _di__IsolatedStorage;
typedef _di__IsolatedStorage IsolatedStorage;

__interface _IsolatedStorageFile;
typedef System::DelphiInterface<_IsolatedStorageFile> _di__IsolatedStorageFile;
typedef _di__IsolatedStorageFile IsolatedStorageFile;

__interface _IsolatedStorageFileStream;
typedef System::DelphiInterface<_IsolatedStorageFileStream> _di__IsolatedStorageFileStream;
typedef _di__IsolatedStorageFileStream IsolatedStorageFileStream;

__interface _IsolatedStorageException;
typedef System::DelphiInterface<_IsolatedStorageException> _di__IsolatedStorageException;
typedef _di__IsolatedStorageException IsolatedStorageException;

__interface _InternalRM;
typedef System::DelphiInterface<_InternalRM> _di__InternalRM;
typedef _di__InternalRM InternalRM;

__interface _InternalST;
typedef System::DelphiInterface<_InternalST> _di__InternalST;
typedef _di__InternalST InternalST;

__interface _SoapMessage;
typedef System::DelphiInterface<_SoapMessage> _di__SoapMessage;
typedef _di__SoapMessage SoapMessage;

__interface _SoapFault;
typedef System::DelphiInterface<_SoapFault> _di__SoapFault;
typedef _di__SoapFault SoapFault;

__interface _ServerFault;
typedef System::DelphiInterface<_ServerFault> _di__ServerFault;
typedef _di__ServerFault ServerFault;

__interface _BinaryFormatter;
typedef System::DelphiInterface<_BinaryFormatter> _di__BinaryFormatter;
typedef _di__BinaryFormatter BinaryFormatter;

__interface _AssemblyBuilder;
typedef System::DelphiInterface<_AssemblyBuilder> _di__AssemblyBuilder;
typedef _di__AssemblyBuilder AssemblyBuilder;

__interface _ConstructorBuilder;
typedef System::DelphiInterface<_ConstructorBuilder> _di__ConstructorBuilder;
typedef _di__ConstructorBuilder ConstructorBuilder;

__interface _EventBuilder;
typedef System::DelphiInterface<_EventBuilder> _di__EventBuilder;
typedef _di__EventBuilder EventBuilder;

__interface _FieldBuilder;
typedef System::DelphiInterface<_FieldBuilder> _di__FieldBuilder;
typedef _di__FieldBuilder FieldBuilder;

__interface _ILGenerator;
typedef System::DelphiInterface<_ILGenerator> _di__ILGenerator;
typedef _di__ILGenerator ILGenerator;

__interface _LocalBuilder;
typedef System::DelphiInterface<_LocalBuilder> _di__LocalBuilder;
typedef _di__LocalBuilder LocalBuilder;

__interface _MethodBuilder;
typedef System::DelphiInterface<_MethodBuilder> _di__MethodBuilder;
typedef _di__MethodBuilder MethodBuilder;

__interface _CustomAttributeBuilder;
typedef System::DelphiInterface<_CustomAttributeBuilder> _di__CustomAttributeBuilder;
typedef _di__CustomAttributeBuilder CustomAttributeBuilder;

__interface _MethodRental;
typedef System::DelphiInterface<_MethodRental> _di__MethodRental;
typedef _di__MethodRental MethodRental;

__interface _ModuleBuilder;
typedef System::DelphiInterface<_ModuleBuilder> _di__ModuleBuilder;
typedef _di__ModuleBuilder ModuleBuilder;

__interface _OpCodes;
typedef System::DelphiInterface<_OpCodes> _di__OpCodes;
typedef _di__OpCodes OpCodes;

__interface _ParameterBuilder;
typedef System::DelphiInterface<_ParameterBuilder> _di__ParameterBuilder;
typedef _di__ParameterBuilder ParameterBuilder;

__interface _PropertyBuilder;
typedef System::DelphiInterface<_PropertyBuilder> _di__PropertyBuilder;
typedef _di__PropertyBuilder PropertyBuilder;

__interface _SignatureHelper;
typedef System::DelphiInterface<_SignatureHelper> _di__SignatureHelper;
typedef _di__SignatureHelper SignatureHelper;

__interface _TypeBuilder;
typedef System::DelphiInterface<_TypeBuilder> _di__TypeBuilder;
typedef _di__TypeBuilder TypeBuilder;

__interface _EnumBuilder;
typedef System::DelphiInterface<_EnumBuilder> _di__EnumBuilder;
typedef _di__EnumBuilder EnumBuilder;

#pragma pack(push,1)
struct DateTime
{
	
public:
	__int64 ticks;
};
#pragma pack(pop)


#pragma pack(push,1)
struct ArgIterator
{
	
public:
	int ArgCookie;
	int SigPtr;
	int ArgPtr;
	int RemainingArgs;
};
#pragma pack(pop)


#pragma pack(push,1)
struct _Boolean
{
	
public:
	int m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct _Byte
{
	
public:
	System::Byte m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct _Char
{
	
public:
	System::Byte m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct Decimal
{
	
public:
	int flags;
	int hi;
	int lo;
	int mid;
};
#pragma pack(pop)


#pragma pack(push,1)
struct _Double
{
	
public:
	double m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct Guid
{
	
public:
	int _a;
	short _b;
	short _c;
	System::Byte _d;
	System::Byte _e;
	System::Byte _f;
	System::Byte _g;
	System::Byte _h;
	System::Byte _i;
	System::Byte _j;
	System::Byte _k;
};
#pragma pack(pop)


#pragma pack(push,1)
struct Int16
{
	
public:
	short m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct Int32
{
	
public:
	int m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct _Int64
{
	
public:
	__int64 m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct IntPtr
{
	
public:
	void *m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct RuntimeArgumentHandle
{
	
public:
	int m_ptr;
};
#pragma pack(pop)


#pragma pack(push,1)
struct RuntimeFieldHandle
{
	
public:
	int m_ptr;
};
#pragma pack(pop)


#pragma pack(push,1)
struct RuntimeMethodHandle
{
	
public:
	int m_ptr;
};
#pragma pack(pop)


#pragma pack(push,1)
struct RuntimeTypeHandle
{
	
public:
	int m_ptr;
};
#pragma pack(pop)


#pragma pack(push,1)
struct SByte
{
	
public:
	System::ShortInt m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct _Single
{
	
public:
	float m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct TimeSpan
{
	
public:
	__int64 _ticks;
};
#pragma pack(pop)


#pragma pack(push,1)
struct TypedReference
{
	
public:
	int value;
	int Type_;
};
#pragma pack(pop)


#pragma pack(push,1)
struct UInt16
{
	
public:
	System::Word m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct UInt32
{
	
public:
	unsigned m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct UInt64
{
	
public:
	unsigned __int64 m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct UIntPtr
{
	
public:
	void *m_value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct Void
{
	
};
#pragma pack(pop)


#pragma pack(push,1)
struct LockCookie
{
	
public:
	int _dwFlags;
	int _dwWriterSeqNum;
	int _wReaderAndWriterLevel;
	int _dwThreadID;
};
#pragma pack(pop)


#pragma pack(push,1)
struct GCHandle
{
	
public:
	int m_handle;
};
#pragma pack(pop)


#pragma pack(push,1)
struct DictionaryEntry
{
	
public:
	System::_di_IInterface _key;
	System::_di_IInterface _value;
};
#pragma pack(pop)


#pragma pack(push,1)
struct SymbolToken
{
	
public:
	int m_token;
};
#pragma pack(pop)


#pragma pack(push,1)
struct InterfaceMapping
{
	
public:
	_di__Type TargetType;
	_di__Type interfaceType;
	tagSAFEARRAY *TargetMethods;
	tagSAFEARRAY *InterfaceMethods;
};
#pragma pack(pop)


#pragma pack(push,1)
struct ParameterModifier
{
	
public:
	tagSAFEARRAY *_byRef;
};
#pragma pack(pop)


#pragma pack(push,1)
struct SerializationEntry
{
	
public:
	_di__Type m_type;
	System::_di_IInterface m_value;
	System::WideChar *m_name;
};
#pragma pack(pop)


#pragma pack(push,1)
struct StreamingContext
{
	
public:
	System::_di_IInterface m_additionalContext;
	Activex::TOleEnum m_state;
};
#pragma pack(pop)


#pragma pack(push,1)
struct DSAParameters
{
	
public:
	tagSAFEARRAY *P;
	tagSAFEARRAY *Q;
	tagSAFEARRAY *G;
	tagSAFEARRAY *y;
	tagSAFEARRAY *J;
	tagSAFEARRAY *x;
	tagSAFEARRAY *Seed;
	int Counter;
};
#pragma pack(pop)


#pragma pack(push,1)
struct RSAParameters
{
	
public:
	tagSAFEARRAY *Exponent;
	tagSAFEARRAY *Modulus;
	tagSAFEARRAY *P;
	tagSAFEARRAY *Q;
	tagSAFEARRAY *DP;
	tagSAFEARRAY *DQ;
	tagSAFEARRAY *InverseQ;
	tagSAFEARRAY *D;
};
#pragma pack(pop)


#pragma pack(push,1)
struct ArrayWithOffset
{
	
public:
	System::_di_IInterface m_array;
	int m_offset;
	int m_count;
};
#pragma pack(pop)


#pragma pack(push,1)
struct NativeOverlapped
{
	
public:
	int InternalLow;
	int InternalHigh;
	int OffsetLow;
	int OffsetHigh;
	int EventHandle;
	int ReservedCOR1;
	GCHandle ReservedCOR2;
	int ReservedCOR3;
	GCHandle ReservedClasslib;
};
#pragma pack(pop)


#pragma pack(push,1)
struct HandleRef
{
	
public:
	System::_di_IInterface m_wrapper;
	int m_handle;
};
#pragma pack(pop)


#pragma pack(push,1)
struct EventToken
{
	
public:
	int m_event;
};
#pragma pack(pop)


#pragma pack(push,1)
struct FieldToken
{
	
public:
	int m_fieldTok;
	System::_di_IInterface m_class;
};
#pragma pack(pop)


#pragma pack(push,1)
struct Label_
{
	
public:
	int m_label;
};
#pragma pack(pop)


#pragma pack(push,1)
struct MethodToken
{
	
public:
	int m_method;
};
#pragma pack(pop)


#pragma pack(push,1)
struct OpCode
{
	
public:
	System::WideChar *m_stringname;
	Activex::TOleEnum m_pop;
	Activex::TOleEnum m_push;
	Activex::TOleEnum m_operand;
	Activex::TOleEnum m_type;
	int m_size;
	System::Byte m_s1;
	System::Byte m_s2;
	Activex::TOleEnum m_ctrl;
	int m_endsUncondJmpBlk;
	int m_stackChange;
};
#pragma pack(pop)


#pragma pack(push,1)
struct ParameterToken
{
	
public:
	int m_tkParameter;
};
#pragma pack(pop)


#pragma pack(push,1)
struct PropertyToken
{
	
public:
	int m_property;
};
#pragma pack(pop)


#pragma pack(push,1)
struct SignatureToken
{
	
public:
	int m_signature;
	_di__ModuleBuilder m_moduleBuilder;
};
#pragma pack(pop)


#pragma pack(push,1)
struct StringToken
{
	
public:
	int m_string;
};
#pragma pack(pop)


#pragma pack(push,1)
struct TypeToken
{
	
public:
	int m_class;
};
#pragma pack(pop)


#pragma pack(push,1)
struct AssemblyHash
{
	
public:
	Activex::TOleEnum _Algorithm;
	tagSAFEARRAY *_value;
};
#pragma pack(pop)


__interface  INTERFACE_UUID("{65074F7F-63C0-304E-AF0A-D51741CB4A8D}") _Object  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
};

__interface ICloneable;
typedef System::DelphiInterface<ICloneable> _di_ICloneable;
__interface  INTERFACE_UUID("{0CB251A7-3AB3-3B5C-A0B8-9DDF88824B85}") ICloneable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Clone(System::OleVariant &__Clone_result) = 0 ;
};

__interface IEnumerable;
typedef System::DelphiInterface<IEnumerable> _di_IEnumerable;
__interface  INTERFACE_UUID("{496B0ABE-CDEE-11D3-88E8-00902754C43A}") IEnumerable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetEnumerator(_di_IEnumVARIANT &__GetEnumerator_result) = 0 ;
};

__interface ICollection;
typedef System::DelphiInterface<ICollection> _di_ICollection;
__interface  INTERFACE_UUID("{DE8DB6F8-D101-3A92-8D1C-E72E5F10E992}") ICollection  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall CopyTo(const _di__Array Array_, int index) = 0 ;
	virtual HRESULT __safecall Get_Count(int &__Get_Count_result) = 0 ;
	virtual HRESULT __safecall Get_SyncRoot(System::OleVariant &__Get_SyncRoot_result) = 0 ;
	virtual HRESULT __safecall Get_IsSynchronized(System::WordBool &__Get_IsSynchronized_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_Count() { int __r; HRESULT __hr = Get_Count(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int Count = {read=_scw_Get_Count};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_SyncRoot() { System::OleVariant __r; HRESULT __hr = Get_SyncRoot(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant SyncRoot = {read=_scw_Get_SyncRoot};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSynchronized() { System::WordBool __r; HRESULT __hr = Get_IsSynchronized(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSynchronized = {read=_scw_Get_IsSynchronized};
};

__interface IList;
typedef System::DelphiInterface<IList> _di_IList;
__interface  INTERFACE_UUID("{7BCFA00F-F764-3113-9140-3BBD127A96BB}") IList  : public IDispatch 
{
	
public:
	System::OleVariant operator[](int index) { return Item[index]; }
	
public:
	virtual HRESULT __safecall Get_Item(int index, System::OleVariant &__Get_Item_result) = 0 ;
	virtual HRESULT __safecall _Set_Item(int index, const System::OleVariant pRetVal) = 0 ;
	virtual HRESULT __safecall Add(const System::OleVariant value, int &__Add_result) = 0 ;
	virtual HRESULT __safecall Contains(const System::OleVariant value, System::WordBool &__Contains_result) = 0 ;
	virtual HRESULT __safecall Clear(void) = 0 ;
	virtual HRESULT __safecall Get_IsReadOnly(System::WordBool &__Get_IsReadOnly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFixedSize(System::WordBool &__Get_IsFixedSize_result) = 0 ;
	virtual HRESULT __safecall IndexOf(const System::OleVariant value, int &__IndexOf_result) = 0 ;
	virtual HRESULT __safecall Insert(int index, const System::OleVariant value) = 0 ;
	virtual HRESULT __safecall Remove(const System::OleVariant value) = 0 ;
	virtual HRESULT __safecall RemoveAt(int index) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_Item(int index) { System::OleVariant __r; HRESULT __hr = Get_Item(index, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant Item[int index] = {read=_scw_Get_Item, write=_Set_Item/*, default*/};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsReadOnly() { System::WordBool __r; HRESULT __hr = Get_IsReadOnly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsReadOnly = {read=_scw_Get_IsReadOnly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFixedSize() { System::WordBool __r; HRESULT __hr = Get_IsFixedSize(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFixedSize = {read=_scw_Get_IsFixedSize};
};

__interface  INTERFACE_UUID("{2B67CECE-71C3-36A9-A136-925CCC1935A8}") _Array  : public IDispatch 
{
	
};

__interface IEnumerator;
typedef System::DelphiInterface<IEnumerator> _di_IEnumerator;
__interface  INTERFACE_UUID("{496B0ABF-CDEE-11D3-88E8-00902754C43A}") IEnumerator  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall MoveNext(System::WordBool &__MoveNext_result) = 0 ;
	virtual HRESULT __safecall Get_Current(System::OleVariant &__Get_Current_result) = 0 ;
	virtual HRESULT __safecall Reset(void) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_Current() { System::OleVariant __r; HRESULT __hr = Get_Current(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant Current = {read=_scw_Get_Current};
};

__interface IComparable;
typedef System::DelphiInterface<IComparable> _di_IComparable;
__interface  INTERFACE_UUID("{DEB0E770-91FD-3CF6-9A6C-E6A3656F3965}") IComparable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall CompareTo(const System::OleVariant obj, int &__CompareTo_result) = 0 ;
};

__interface IConvertible;
typedef System::DelphiInterface<IConvertible> _di_IConvertible;
__interface IFormatProvider;
typedef System::DelphiInterface<IFormatProvider> _di_IFormatProvider;
__interface  INTERFACE_UUID("{805E3B62-B5E9-393D-8941-377D8BF4556B}") IConvertible  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetTypeCode(Activex::TOleEnum &__GetTypeCode_result) = 0 ;
	virtual HRESULT __safecall ToBoolean(const _di_IFormatProvider provider, System::WordBool &__ToBoolean_result) = 0 ;
	virtual HRESULT __safecall ToChar(const _di_IFormatProvider provider, System::Word &__ToChar_result) = 0 ;
	virtual HRESULT __safecall ToSByte(const _di_IFormatProvider provider, System::ShortInt &__ToSByte_result) = 0 ;
	virtual HRESULT __safecall ToByte(const _di_IFormatProvider provider, System::Byte &__ToByte_result) = 0 ;
	virtual HRESULT __safecall ToInt16(const _di_IFormatProvider provider, short &__ToInt16_result) = 0 ;
	virtual HRESULT __safecall ToUInt16(const _di_IFormatProvider provider, System::Word &__ToUInt16_result) = 0 ;
	virtual HRESULT __safecall ToInt32(const _di_IFormatProvider provider, int &__ToInt32_result) = 0 ;
	virtual HRESULT __safecall ToUInt32(const _di_IFormatProvider provider, unsigned &__ToUInt32_result) = 0 ;
	virtual HRESULT __safecall ToInt64(const _di_IFormatProvider provider, __int64 &__ToInt64_result) = 0 ;
	virtual HRESULT __safecall ToUInt64(const _di_IFormatProvider provider, unsigned __int64 &__ToUInt64_result) = 0 ;
	virtual HRESULT __safecall ToSingle(const _di_IFormatProvider provider, float &__ToSingle_result) = 0 ;
	virtual HRESULT __safecall ToDouble(const _di_IFormatProvider provider, double &__ToDouble_result) = 0 ;
	virtual HRESULT __safecall ToDecimal(const _di_IFormatProvider provider, tagDEC &__ToDecimal_result) = 0 ;
	virtual HRESULT __safecall ToDateTime(const _di_IFormatProvider provider, System::TDateTime &__ToDateTime_result) = 0 ;
	virtual HRESULT __safecall Get_ToString(const _di_IFormatProvider provider, System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall ToType(const _di__Type conversionType, const _di_IFormatProvider provider, System::OleVariant &__ToType_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString(const _di_IFormatProvider provider) { System::WideString __r; HRESULT __hr = Get_ToString(provider, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString[const _di_IFormatProvider provider] = {read=_scw_Get_ToString};
};

__interface  INTERFACE_UUID("{36936699-FC79-324D-AB43-E33C1F94E263}") _String  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9FB09782-8D39-3B0C-B79E-F7A37A65B3DA}") _StringBuilder  : public IDispatch 
{
	
};

__interface ISerializable;
typedef System::DelphiInterface<ISerializable> _di_ISerializable;
__interface  INTERFACE_UUID("{D0EEAA62-3D30-3EE2-B896-A2F34DDA47D8}") ISerializable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetObjectData(const _di__SerializationInfo info, const StreamingContext Context) = 0 ;
};

__interface  INTERFACE_UUID("{B36B5C63-42EF-38BC-A07E-0B34C98F164A}") _Exception  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_Message(System::WideString &__Get_Message_result) = 0 ;
	virtual HRESULT __safecall GetBaseException(_di__Exception &__GetBaseException_result) = 0 ;
	virtual HRESULT __safecall Get_StackTrace(System::WideString &__Get_StackTrace_result) = 0 ;
	virtual HRESULT __safecall Get_HelpLink(System::WideString &__Get_HelpLink_result) = 0 ;
	virtual HRESULT __safecall Set_HelpLink(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __safecall Get_Source(System::WideString &__Get_Source_result) = 0 ;
	virtual HRESULT __safecall Set_Source(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __safecall GetObjectData(const _di__SerializationInfo info, const StreamingContext Context) = 0 ;
	virtual HRESULT __safecall Get_InnerException(_di__Exception &__Get_InnerException_result) = 0 ;
	virtual HRESULT __safecall Get_TargetSite(_di__MethodBase &__Get_TargetSite_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Message() { System::WideString __r; HRESULT __hr = Get_Message(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Message = {read=_scw_Get_Message};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_StackTrace() { System::WideString __r; HRESULT __hr = Get_StackTrace(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString StackTrace = {read=_scw_Get_StackTrace};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_HelpLink() { System::WideString __r; HRESULT __hr = Get_HelpLink(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString HelpLink = {read=_scw_Get_HelpLink};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Source() { System::WideString __r; HRESULT __hr = Get_Source(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Source = {read=_scw_Get_Source};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Exception _scw_Get_InnerException() { _di__Exception __r; HRESULT __hr = Get_InnerException(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Exception InnerException = {read=_scw_Get_InnerException};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__MethodBase _scw_Get_TargetSite() { _di__MethodBase __r; HRESULT __hr = Get_TargetSite(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__MethodBase TargetSite = {read=_scw_Get_TargetSite};
};

__interface  INTERFACE_UUID("{139E041D-0E41-39F5-A302-C4387E9D0A6C}") _ValueType  : public IDispatch 
{
	
};

__interface IFormattable;
typedef System::DelphiInterface<IFormattable> _di_IFormattable;
__interface  INTERFACE_UUID("{9A604EE7-E630-3DED-9444-BAAE247075AB}") IFormattable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(const System::WideString format, const _di_IFormatProvider formatProvider, System::WideString &__Get_ToString_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString(const System::WideString format, const _di_IFormatProvider formatProvider) { System::WideString __r; HRESULT __hr = Get_ToString(format, formatProvider, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString[const System::WideString format][const _di_IFormatProvider formatProvider] = {read=_scw_Get_ToString};
};

__interface  INTERFACE_UUID("{4C482CC2-68E9-37C6-8353-9A94BD2D7F0B}") _SystemException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CF3EDB7E-0574-3383-A44F-292F7C145DB4}") _OutOfMemoryException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9CF4339A-2911-3B8A-8F30-E5C6B5BE9A29}") _StackOverflowException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CCF0139C-79F7-3D0A-AFFE-2B0762C65B07}") _ExecutionEngineException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FB6AB00F-5096-3AF8-A33D-D7885A5FA829}") _Delegate  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall GetInvocationList(Activex::PSafeArray &__GetInvocationList_result) = 0 ;
	virtual HRESULT __safecall Clone(System::OleVariant &__Clone_result) = 0 ;
	virtual HRESULT __safecall GetObjectData(const _di__SerializationInfo info, const StreamingContext Context) = 0 ;
	virtual HRESULT __safecall DynamicInvoke(Activex::PSafeArray args, System::OleVariant &__DynamicInvoke_result) = 0 ;
	virtual HRESULT __safecall Get_Method(_di__MethodInfo &__Get_Method_result) = 0 ;
	virtual HRESULT __safecall Get_Target(System::OleVariant &__Get_Target_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__MethodInfo _scw_Get_Method() { _di__MethodInfo __r; HRESULT __hr = Get_Method(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__MethodInfo Method = {read=_scw_Get_Method};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_Target() { System::OleVariant __r; HRESULT __hr = Get_Target(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant Target = {read=_scw_Get_Target};
};

__interface  INTERFACE_UUID("{16FE0885-9129-3884-A232-90B58C5B2AA9}") _MulticastDelegate  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D09D1E04-D590-39A3-B517-B734A49A9277}") _Enum  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7EABA4E2-1259-3CF2-B084-9854278E5897}") _MemberAccessException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{03973551-57A1-3900-A2B5-9083E3FF2943}") _Activator  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D81130BF-D627-3B91-A7C7-CEA597093464}") _ApplicationException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1F9EC719-343A-3CB3-8040-3927626777C1}") _EventArgs  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{98947CF0-77E7-328E-B709-5DD1AA1C9C96}") _ResolveEventArgs  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7A0325F0-22C2-31F9-8823-9B8AEE9456B1}") _AssemblyLoadEventArgs  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8E54A9CC-7AA4-34CA-985B-BD7D7527B110}") _ResolveEventHandler  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DEECE11F-A893-3E35-A4C3-DAB7FA0911EB}") _AssemblyLoadEventHandler  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2C358E27-8C1A-3C03-B086-A40465625557}") _MarshalByRefObject  : public IDispatch 
{
	
};

__interface IPrincipal;
typedef System::DelphiInterface<IPrincipal> _di_IPrincipal;
__interface  INTERFACE_UUID("{05F696DC-2B29-3663-AD8B-C4389CF2A713}") _AppDomain  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant other, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall InitializeLifetimeService(System::OleVariant &__InitializeLifetimeService_result) = 0 ;
	virtual HRESULT __safecall GetLifetimeService(System::OleVariant &__GetLifetimeService_result) = 0 ;
	virtual HRESULT __safecall Get_Evidence(_di__Evidence &__Get_Evidence_result) = 0 ;
	virtual HRESULT __safecall add_DomainUnload(const _di__EventHandler value) = 0 ;
	virtual HRESULT __safecall remove_DomainUnload(const _di__EventHandler value) = 0 ;
	virtual HRESULT __safecall add_AssemblyLoad(const _di__AssemblyLoadEventHandler value) = 0 ;
	virtual HRESULT __safecall remove_AssemblyLoad(const _di__AssemblyLoadEventHandler value) = 0 ;
	virtual HRESULT __safecall add_ProcessExit(const _di__EventHandler value) = 0 ;
	virtual HRESULT __safecall remove_ProcessExit(const _di__EventHandler value) = 0 ;
	virtual HRESULT __safecall add_TypeResolve(const _di__ResolveEventHandler value) = 0 ;
	virtual HRESULT __safecall remove_TypeResolve(const _di__ResolveEventHandler value) = 0 ;
	virtual HRESULT __safecall add_ResourceResolve(const _di__ResolveEventHandler value) = 0 ;
	virtual HRESULT __safecall remove_ResourceResolve(const _di__ResolveEventHandler value) = 0 ;
	virtual HRESULT __safecall add_AssemblyResolve(const _di__ResolveEventHandler value) = 0 ;
	virtual HRESULT __safecall remove_AssemblyResolve(const _di__ResolveEventHandler value) = 0 ;
	virtual HRESULT __safecall add_UnhandledException(const _di__UnhandledExceptionEventHandler value) = 0 ;
	virtual HRESULT __safecall remove_UnhandledException(const _di__UnhandledExceptionEventHandler value) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly(const _di__AssemblyName name, Activex::TOleEnum access, _di__AssemblyBuilder &__DefineDynamicAssembly_result) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly_2(const _di__AssemblyName name, Activex::TOleEnum access, const System::WideString dir, _di__AssemblyBuilder &__DefineDynamicAssembly_2_result) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly_3(const _di__AssemblyName name, Activex::TOleEnum access, const _di__Evidence Evidence, _di__AssemblyBuilder &__DefineDynamicAssembly_3_result) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly_4(const _di__AssemblyName name, Activex::TOleEnum access, const _di__PermissionSet requiredPermissions, const _di__PermissionSet optionalPermissions, const _di__PermissionSet refusedPermissions, _di__AssemblyBuilder &__DefineDynamicAssembly_4_result) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly_5(const _di__AssemblyName name, Activex::TOleEnum access, const System::WideString dir, const _di__Evidence Evidence, _di__AssemblyBuilder &__DefineDynamicAssembly_5_result) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly_6(const _di__AssemblyName name, Activex::TOleEnum access, const System::WideString dir, const _di__PermissionSet requiredPermissions, const _di__PermissionSet optionalPermissions, const _di__PermissionSet refusedPermissions, _di__AssemblyBuilder &__DefineDynamicAssembly_6_result) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly_7(const _di__AssemblyName name, Activex::TOleEnum access, const _di__Evidence Evidence, const _di__PermissionSet requiredPermissions, const _di__PermissionSet optionalPermissions, const _di__PermissionSet refusedPermissions, _di__AssemblyBuilder &__DefineDynamicAssembly_7_result) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly_8(const _di__AssemblyName name, Activex::TOleEnum access, const System::WideString dir, const _di__Evidence Evidence, const _di__PermissionSet requiredPermissions, const _di__PermissionSet optionalPermissions, const _di__PermissionSet refusedPermissions, _di__AssemblyBuilder &__DefineDynamicAssembly_8_result) = 0 ;
	virtual HRESULT __safecall DefineDynamicAssembly_9(const _di__AssemblyName name, Activex::TOleEnum access, const System::WideString dir, const _di__Evidence Evidence, const _di__PermissionSet requiredPermissions, const _di__PermissionSet optionalPermissions, const _di__PermissionSet refusedPermissions, System::WordBool IsSynchronized, _di__AssemblyBuilder &__DefineDynamicAssembly_9_result) = 0 ;
	virtual HRESULT __safecall CreateInstance(const System::WideString AssemblyName, const System::WideString typeName, _di__ObjectHandle &__CreateInstance_result) = 0 ;
	virtual HRESULT __safecall CreateInstanceFrom(const System::WideString assemblyFile, const System::WideString typeName, _di__ObjectHandle &__CreateInstanceFrom_result) = 0 ;
	virtual HRESULT __safecall CreateInstance_2(const System::WideString AssemblyName, const System::WideString typeName, Activex::PSafeArray activationAttributes, _di__ObjectHandle &__CreateInstance_2_result) = 0 ;
	virtual HRESULT __safecall CreateInstanceFrom_2(const System::WideString assemblyFile, const System::WideString typeName, Activex::PSafeArray activationAttributes, _di__ObjectHandle &__CreateInstanceFrom_2_result) = 0 ;
	virtual HRESULT __safecall CreateInstance_3(const System::WideString AssemblyName, const System::WideString typeName, System::WordBool ignoreCase, Activex::TOleEnum bindingAttr, const _di__Binder Binder, Activex::PSafeArray args, const _di__CultureInfo culture, Activex::PSafeArray activationAttributes, const _di__Evidence securityAttributes, _di__ObjectHandle &__CreateInstance_3_result) = 0 ;
	virtual HRESULT __safecall CreateInstanceFrom_3(const System::WideString assemblyFile, const System::WideString typeName, System::WordBool ignoreCase, Activex::TOleEnum bindingAttr, const _di__Binder Binder, Activex::PSafeArray args, const _di__CultureInfo culture, Activex::PSafeArray activationAttributes, const _di__Evidence securityAttributes, _di__ObjectHandle &__CreateInstanceFrom_3_result) = 0 ;
	virtual HRESULT __safecall Load(const _di__AssemblyName assemblyRef, _di__Assembly &__Load_result) = 0 ;
	virtual HRESULT __safecall Load_2(const System::WideString assemblyString, _di__Assembly &__Load_2_result) = 0 ;
	virtual HRESULT __safecall Load_3(Activex::PSafeArray rawAssembly, _di__Assembly &__Load_3_result) = 0 ;
	virtual HRESULT __safecall Load_4(Activex::PSafeArray rawAssembly, Activex::PSafeArray rawSymbolStore, _di__Assembly &__Load_4_result) = 0 ;
	virtual HRESULT __safecall Load_5(Activex::PSafeArray rawAssembly, Activex::PSafeArray rawSymbolStore, const _di__Evidence securityEvidence, _di__Assembly &__Load_5_result) = 0 ;
	virtual HRESULT __safecall Load_6(const _di__AssemblyName assemblyRef, const _di__Evidence assemblySecurity, _di__Assembly &__Load_6_result) = 0 ;
	virtual HRESULT __safecall Load_7(const System::WideString assemblyString, const _di__Evidence assemblySecurity, _di__Assembly &__Load_7_result) = 0 ;
	virtual HRESULT __safecall ExecuteAssembly(const System::WideString assemblyFile, const _di__Evidence assemblySecurity, int &__ExecuteAssembly_result) = 0 ;
	virtual HRESULT __safecall ExecuteAssembly_2(const System::WideString assemblyFile, int &__ExecuteAssembly_2_result) = 0 ;
	virtual HRESULT __safecall ExecuteAssembly_3(const System::WideString assemblyFile, const _di__Evidence assemblySecurity, Activex::PSafeArray args, int &__ExecuteAssembly_3_result) = 0 ;
	virtual HRESULT __safecall Get_FriendlyName(System::WideString &__Get_FriendlyName_result) = 0 ;
	virtual HRESULT __safecall Get_BaseDirectory(System::WideString &__Get_BaseDirectory_result) = 0 ;
	virtual HRESULT __safecall Get_RelativeSearchPath(System::WideString &__Get_RelativeSearchPath_result) = 0 ;
	virtual HRESULT __safecall Get_ShadowCopyFiles(System::WordBool &__Get_ShadowCopyFiles_result) = 0 ;
	virtual HRESULT __safecall GetAssemblies(Activex::PSafeArray &__GetAssemblies_result) = 0 ;
	virtual HRESULT __safecall AppendPrivatePath(const System::WideString Path) = 0 ;
	virtual HRESULT __safecall ClearPrivatePath(void) = 0 ;
	virtual HRESULT __safecall SetShadowCopyPath(const System::WideString s) = 0 ;
	virtual HRESULT __safecall ClearShadowCopyPath(void) = 0 ;
	virtual HRESULT __safecall SetCachePath(const System::WideString s) = 0 ;
	virtual HRESULT __safecall SetData(const System::WideString name, const System::OleVariant data) = 0 ;
	virtual HRESULT __safecall GetData(const System::WideString name, System::OleVariant &__GetData_result) = 0 ;
	virtual HRESULT __safecall SetAppDomainPolicy(const _di__PolicyLevel domainPolicy) = 0 ;
	virtual HRESULT __safecall SetThreadPrincipal(const _di_IPrincipal principal) = 0 ;
	virtual HRESULT __safecall SetPrincipalPolicy(Activex::TOleEnum policy) = 0 ;
	virtual HRESULT __safecall DoCallBack(const _di__CrossAppDomainDelegate theDelegate) = 0 ;
	virtual HRESULT __safecall Get_DynamicDirectory(System::WideString &__Get_DynamicDirectory_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Evidence _scw_Get_Evidence() { _di__Evidence __r; HRESULT __hr = Get_Evidence(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Evidence Evidence = {read=_scw_Get_Evidence};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_FriendlyName() { System::WideString __r; HRESULT __hr = Get_FriendlyName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString FriendlyName = {read=_scw_Get_FriendlyName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_BaseDirectory() { System::WideString __r; HRESULT __hr = Get_BaseDirectory(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString BaseDirectory = {read=_scw_Get_BaseDirectory};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_RelativeSearchPath() { System::WideString __r; HRESULT __hr = Get_RelativeSearchPath(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString RelativeSearchPath = {read=_scw_Get_RelativeSearchPath};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_ShadowCopyFiles() { System::WordBool __r; HRESULT __hr = Get_ShadowCopyFiles(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool ShadowCopyFiles = {read=_scw_Get_ShadowCopyFiles};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_DynamicDirectory() { System::WideString __r; HRESULT __hr = Get_DynamicDirectory(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString DynamicDirectory = {read=_scw_Get_DynamicDirectory};
};

__interface IEvidenceFactory;
typedef System::DelphiInterface<IEvidenceFactory> _di_IEvidenceFactory;
__interface  INTERFACE_UUID("{35A8F3AC-FE28-360F-A0C0-9A4D50C4682A}") IEvidenceFactory  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Evidence(_di__Evidence &__Get_Evidence_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Evidence _scw_Get_Evidence() { _di__Evidence __r; HRESULT __hr = Get_Evidence(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Evidence Evidence = {read=_scw_Get_Evidence};
};

__interface  INTERFACE_UUID("{AF93163F-C2F4-3FAB-9FF1-728A7AAAD1CB}") _CrossAppDomainDelegate  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{27FFF232-A7A8-40DD-8D4A-734AD59FCD41}") IAppDomainSetup  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Get_ApplicationBase(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_ApplicationBase(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_ApplicationName(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_ApplicationName(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_CachePath(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_CachePath(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_ConfigurationFile(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_ConfigurationFile(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_DynamicBase(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_DynamicBase(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_LicenseFile(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_LicenseFile(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_PrivateBinPath(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_PrivateBinPath(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_PrivateBinPathProbe(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_PrivateBinPathProbe(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_ShadowCopyDirectories(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_ShadowCopyDirectories(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __stdcall Get_ShadowCopyFiles(/* out */ System::WideString &pRetVal) = 0 ;
	virtual HRESULT __stdcall Set_ShadowCopyFiles(const System::WideString pRetVal) = 0 ;
};

__interface  INTERFACE_UUID("{917B14D0-2D9E-38B8-92A9-381ACF52F7C0}") _Attribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CE59D7AD-05CA-33B4-A1DD-06028D46E9D2}") _LoaderOptimizationAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6E96AA70-9FFB-399D-96BF-A68436095C54}") _AppDomainUnloadedException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4DB2C2B7-CBC2-3185-B966-875D4625B1A8}") _ArgumentException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C991949B-E623-3F24-885C-BBB01FF43564}") _ArgumentNullException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{77DA3028-BC45-3E82-BF76-2C123EE2C021}") _ArgumentOutOfRangeException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9B012CF1-ACF6-3389-A336-C023040C62A2}") _ArithmeticException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DD7488A6-1B3F-3823-9556-C2772B15150F}") _ArrayTypeMismatchException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3612706E-0239-35FD-B900-0819D16D442D}") _AsyncCallback  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A902A192-49BA-3EC8-B444-AF5F7743F61A}") _AttributeUsageAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F98BCE04-4A4B-398C-A512-FD8348D51E3B}") _BadImageFormatException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5CD861E8-CA91-301B-9E24-141E3D85BD5D}") _BitConverter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F036BCA4-F8DF-3682-8290-75285CE7456C}") _Buffer  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6D4B6ADB-B9FA-3809-B5EA-FA57B56C546F}") _CannotUnloadAppDomainException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1DD627FC-89E3-384F-BB9D-58CB4EFB9456}") _CharEnumerator  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BF1AF177-94CA-3E6D-9D91-55CF9E859D22}") _CLSCompliantAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C2A10F3A-356A-3C77-AAB9-8991D73A2561}") _TypeUnloadedException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{88592805-9549-3E00-8308-03CFA6B93882}") _Console  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7386F4D7-7C11-389F-BB75-895714B12BB5}") _ContextMarshalException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9E1348D4-3FAC-3704-840D-20D91E4AD542}") _Convert  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3EB1D909-E8BF-3C6B-ADA5-0E86E31E186E}") _ContextBoundObject  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{160D517F-F175-3B61-8264-6D2305B8246C}") _ContextStaticAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3025F666-7891-33D7-AACD-23D169EF354E}") _TimeZone  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0D9F1B65-6D27-3E9F-BAF3-0597837E0F33}") _DBNull  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3169AB11-7109-3808-9A61-EF4BA0534FD9}") _Binder  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall BindToMethod(Activex::TOleEnum bindingAttr, Activex::PSafeArray match, Activex::PSafeArray &args, Activex::PSafeArray modifiers, const _di__CultureInfo culture, Activex::PSafeArray names, /* out */ System::OleVariant &state, _di__MethodBase &__BindToMethod_result) = 0 ;
	virtual HRESULT __safecall BindToField(Activex::TOleEnum bindingAttr, Activex::PSafeArray match, const System::OleVariant value, const _di__CultureInfo culture, _di__FieldInfo &__BindToField_result) = 0 ;
	virtual HRESULT __safecall SelectMethod(Activex::TOleEnum bindingAttr, Activex::PSafeArray match, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__MethodBase &__SelectMethod_result) = 0 ;
	virtual HRESULT __safecall SelectProperty(Activex::TOleEnum bindingAttr, Activex::PSafeArray match, const _di__Type returnType, Activex::PSafeArray indexes, Activex::PSafeArray modifiers, _di__PropertyInfo &__SelectProperty_result) = 0 ;
	virtual HRESULT __safecall ChangeType(const System::OleVariant value, const _di__Type Type_, const _di__CultureInfo culture, System::OleVariant &__ChangeType_result) = 0 ;
	virtual HRESULT __safecall ReorderArgumentArray(Activex::PSafeArray &args, const System::OleVariant state) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
};

__interface IObjectReference;
typedef System::DelphiInterface<IObjectReference> _di_IObjectReference;
__interface  INTERFACE_UUID("{6E70ED5F-0439-38CE-83BB-860F1421F29F}") IObjectReference  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetRealObject(const StreamingContext Context, System::OleVariant &__GetRealObject_result) = 0 ;
};

__interface  INTERFACE_UUID("{BDEEA460-8241-3B41-9ED3-6E3E9977AC7F}") _DivideByZeroException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D345A42B-CFE0-3EEE-861C-F3322812B388}") _DuplicateWaitObjectException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{82D6B3BF-A633-3B3B-A09E-2363E4B24A41}") _TypeLoadException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{67388F3F-B600-3BCF-84AA-BB2B88DD9EE2}") _EntryPointNotFoundException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{24AE6464-2834-32CD-83D6-FA06953DE62A}") _DllNotFoundException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{29DC56CF-B981-3432-97C8-3680AB6D862D}") _Environment  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7CEFC46E-16E0-3E65-9C38-55B4342BA7F0}") _EventHandler  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8D5F5811-FFA1-3306-93E3-8AFC572B9B82}") _FieldAccessException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EBE3746D-DDEC-3D23-8E8D-9361BA87BAC6}") _FlagsAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{07F92156-398A-3548-90B7-2E58026353D0}") _FormatException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{679ED106-5DC1-38FE-8B5C-2ADCA3552298}") _GC  : public IDispatch 
{
	
};

__interface IAsyncResult;
typedef System::DelphiInterface<IAsyncResult> _di_IAsyncResult;
__interface  INTERFACE_UUID("{11AB34E7-0176-3C9E-9EFE-197858400A3D}") IAsyncResult  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_IsCompleted(System::WordBool &__Get_IsCompleted_result) = 0 ;
	virtual HRESULT __safecall Get_AsyncWaitHandle(_di__WaitHandle &__Get_AsyncWaitHandle_result) = 0 ;
	virtual HRESULT __safecall Get_AsyncState(System::OleVariant &__Get_AsyncState_result) = 0 ;
	virtual HRESULT __safecall Get_CompletedSynchronously(System::WordBool &__Get_CompletedSynchronously_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsCompleted() { System::WordBool __r; HRESULT __hr = Get_IsCompleted(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsCompleted = {read=_scw_Get_IsCompleted};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__WaitHandle _scw_Get_AsyncWaitHandle() { _di__WaitHandle __r; HRESULT __hr = Get_AsyncWaitHandle(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__WaitHandle AsyncWaitHandle = {read=_scw_Get_AsyncWaitHandle};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_AsyncState() { System::OleVariant __r; HRESULT __hr = Get_AsyncState(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant AsyncState = {read=_scw_Get_AsyncState};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_CompletedSynchronously() { System::WordBool __r; HRESULT __hr = Get_CompletedSynchronously(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool CompletedSynchronously = {read=_scw_Get_CompletedSynchronously};
};

__interface ICustomFormatter;
typedef System::DelphiInterface<ICustomFormatter> _di_ICustomFormatter;
__interface  INTERFACE_UUID("{2B130940-CA5E-3406-8385-E259E68AB039}") ICustomFormatter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall format(const System::WideString format, const System::OleVariant arg, const _di_IFormatProvider formatProvider, System::WideString &__format_result) = 0 ;
};

__interface IDisposable;
typedef System::DelphiInterface<IDisposable> _di_IDisposable;
__interface  INTERFACE_UUID("{805D7A98-D4AF-3F0F-967F-E5CF45312D2C}") IDisposable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Dispose(void) = 0 ;
};

__interface  INTERFACE_UUID("{C8CB1DED-2814-396A-9CC0-473CA49779CC}") IFormatProvider  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetFormat(const _di__Type formatType, System::OleVariant &__GetFormat_result) = 0 ;
};

__interface  INTERFACE_UUID("{E5A5F1E4-82C1-391F-A1C6-F39EAE9DC72F}") _IndexOutOfRangeException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FA047CBD-9BA5-3A13-9B1F-6694D622CD76}") _InvalidCastException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8D520D10-0B8A-3553-8874-D30A4AD2FF4C}") _InvalidOperationException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3410E0FB-636F-3CD1-8045-3993CA113F25}") _InvalidProgramException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DC77F976-318D-3A1A-9B60-ABB9DD9406D6}") _LocalDataStoreSlot  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A19F91C8-7D23-3DFB-A988-CEE05B039121}") _Math  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FF0BF77D-8F81-3D31-A3BB-6F54440FA7E5}") _MethodAccessException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8897D14B-7FB3-3D8B-9EE4-221C3DBAD6FE}") _MissingMemberException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9717176D-1179-3487-8849-CF5F63DE356E}") _MissingFieldException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E5C659F6-92C8-3887-A07E-74D0D9C6267A}") _MissingMethodException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D2BA71CC-1B3D-3966-A0D7-C61E957AD325}") _MulticastNotSupportedException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{665C9669-B9C6-3ADD-9213-099F0127C893}") _NonSerializedAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8E21CE22-4F17-347B-B3B5-6A6DF3E0E58A}") _NotFiniteNumberException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1E4D31A2-63EA-397A-A77E-B20AD87A9614}") _NotImplementedException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{40E5451F-B237-33F8-945B-0230DB700BBB}") _NotSupportedException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{ECBE2313-CF41-34B4-9FD0-B6CD602B023F}") _NullReferenceException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{17B730BA-45EF-3DDF-9F8D-A490BAC731F4}") _ObjectDisposedException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E84307BE-3036-307A-ACC2-5D5DE8A006A8}") _ObsoleteAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9E230640-A5D0-30E1-B217-9D2B6CC0FC40}") _OperatingSystem  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{37C69A5D-7619-3A0F-A96B-9C9578AE00EF}") _OverflowException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D54500AE-8CF4-3092-9054-90DC91AC65C9}") _ParamArrayAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1EB8340B-8190-3D9D-92F8-51244B9804C5}") _PlatformNotSupportedException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0F240708-629A-31AB-94A5-2BB476FE1783}") _Random  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{871DDC46-B68E-3FEE-A09A-C808B0F827E6}") _RankException  : public IDispatch 
{
	
};

__interface ICustomAttributeProvider;
typedef System::DelphiInterface<ICustomAttributeProvider> _di_ICustomAttributeProvider;
__interface  INTERFACE_UUID("{B9B91146-D6C2-3A62-8159-C2D1794CDEB0}") ICustomAttributeProvider  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
};

__interface  INTERFACE_UUID("{F7102FA9-CABB-3A74-A6DA-B4567EF1B079}") _MemberInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_MemberType(Activex::TOleEnum &__Get_MemberType_result) = 0 ;
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_DeclaringType(_di__Type &__Get_DeclaringType_result) = 0 ;
	virtual HRESULT __safecall Get_ReflectedType(_di__Type &__Get_ReflectedType_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_MemberType() { Activex::TOleEnum __r; HRESULT __hr = Get_MemberType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum MemberType = {read=_scw_Get_MemberType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_DeclaringType() { _di__Type __r; HRESULT __hr = Get_DeclaringType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type DeclaringType = {read=_scw_Get_DeclaringType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ReflectedType() { _di__Type __r; HRESULT __hr = Get_ReflectedType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ReflectedType = {read=_scw_Get_ReflectedType};
};

__interface IReflect;
typedef System::DelphiInterface<IReflect> _di_IReflect;
__interface  INTERFACE_UUID("{AFBF15E5-C37C-11D2-B88E-00A0C9B471B8}") IReflect  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetMethod(const System::WideString name, Activex::TOleEnum bindingAttr, const _di__Binder Binder, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__MethodInfo &__GetMethod_result) = 0 ;
	virtual HRESULT __safecall GetMethod_2(const System::WideString name, Activex::TOleEnum bindingAttr, _di__MethodInfo &__GetMethod_2_result) = 0 ;
	virtual HRESULT __safecall GetMethods(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetMethods_result) = 0 ;
	virtual HRESULT __safecall GetField(const System::WideString name, Activex::TOleEnum bindingAttr, _di__FieldInfo &__GetField_result) = 0 ;
	virtual HRESULT __safecall GetFields(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetFields_result) = 0 ;
	virtual HRESULT __safecall GetProperty(const System::WideString name, Activex::TOleEnum bindingAttr, _di__PropertyInfo &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall GetProperty_2(const System::WideString name, Activex::TOleEnum bindingAttr, const _di__Binder Binder, const _di__Type returnType, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__PropertyInfo &__GetProperty_2_result) = 0 ;
	virtual HRESULT __safecall GetProperties(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetProperties_result) = 0 ;
	virtual HRESULT __safecall GetMember(const System::WideString name, Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetMember_result) = 0 ;
	virtual HRESULT __safecall GetMembers(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetMembers_result) = 0 ;
	virtual HRESULT __safecall InvokeMember(const System::WideString name, Activex::TOleEnum invokeAttr, const _di__Binder Binder, const System::OleVariant Target, Activex::PSafeArray args, Activex::PSafeArray modifiers, const _di__CultureInfo culture, Activex::PSafeArray namedParameters, System::OleVariant &__InvokeMember_result) = 0 ;
	virtual HRESULT __safecall Get_UnderlyingSystemType(_di__Type &__Get_UnderlyingSystemType_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_UnderlyingSystemType() { _di__Type __r; HRESULT __hr = Get_UnderlyingSystemType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type UnderlyingSystemType = {read=_scw_Get_UnderlyingSystemType};
};

__interface  INTERFACE_UUID("{BCA8B44D-AAD6-3A86-8AB7-03349F4F2DA2}") _Type  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant o, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_MemberType(Activex::TOleEnum &__Get_MemberType_result) = 0 ;
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_DeclaringType(_di__Type &__Get_DeclaringType_result) = 0 ;
	virtual HRESULT __safecall Get_ReflectedType(_di__Type &__Get_ReflectedType_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	virtual HRESULT __safecall Get_Guid(GUID &__Get_Guid_result) = 0 ;
	virtual HRESULT __safecall Get_Module(_di__Module &__Get_Module_result) = 0 ;
	virtual HRESULT __safecall Get_Assembly(_di__Assembly &__Get_Assembly_result) = 0 ;
	virtual HRESULT __safecall Get_TypeHandle(RuntimeTypeHandle &__Get_TypeHandle_result) = 0 ;
	virtual HRESULT __safecall Get_FullName(System::WideString &__Get_FullName_result) = 0 ;
	virtual HRESULT __safecall Get_Namespace(System::WideString &__Get_Namespace_result) = 0 ;
	virtual HRESULT __safecall Get_AssemblyQualifiedName(System::WideString &__Get_AssemblyQualifiedName_result) = 0 ;
	virtual HRESULT __safecall GetArrayRank(int &__GetArrayRank_result) = 0 ;
	virtual HRESULT __safecall Get_BaseType(_di__Type &__Get_BaseType_result) = 0 ;
	virtual HRESULT __safecall GetConstructors(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetConstructors_result) = 0 ;
	virtual HRESULT __safecall GetInterface(const System::WideString name, System::WordBool ignoreCase, _di__Type &__GetInterface_result) = 0 ;
	virtual HRESULT __safecall GetInterfaces(Activex::PSafeArray &__GetInterfaces_result) = 0 ;
	virtual HRESULT __safecall FindInterfaces(const _di__TypeFilter filter, const System::OleVariant filterCriteria, Activex::PSafeArray &__FindInterfaces_result) = 0 ;
	virtual HRESULT __safecall GetEvent(const System::WideString name, Activex::TOleEnum bindingAttr, _di__EventInfo &__GetEvent_result) = 0 ;
	virtual HRESULT __safecall GetEvents(Activex::PSafeArray &__GetEvents_result) = 0 ;
	virtual HRESULT __safecall GetEvents_2(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetEvents_2_result) = 0 ;
	virtual HRESULT __safecall GetNestedTypes(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetNestedTypes_result) = 0 ;
	virtual HRESULT __safecall GetNestedType(const System::WideString name, Activex::TOleEnum bindingAttr, _di__Type &__GetNestedType_result) = 0 ;
	virtual HRESULT __safecall GetMember(const System::WideString name, Activex::TOleEnum Type_, Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetMember_result) = 0 ;
	virtual HRESULT __safecall GetDefaultMembers(Activex::PSafeArray &__GetDefaultMembers_result) = 0 ;
	virtual HRESULT __safecall FindMembers(Activex::TOleEnum MemberType, Activex::TOleEnum bindingAttr, const _di__MemberFilter filter, const System::OleVariant filterCriteria, Activex::PSafeArray &__FindMembers_result) = 0 ;
	virtual HRESULT __safecall GetElementType(_di__Type &__GetElementType_result) = 0 ;
	virtual HRESULT __safecall IsSubclassOf(const _di__Type c, System::WordBool &__IsSubclassOf_result) = 0 ;
	virtual HRESULT __safecall IsInstanceOfType(const System::OleVariant o, System::WordBool &__IsInstanceOfType_result) = 0 ;
	virtual HRESULT __safecall IsAssignableFrom(const _di__Type c, System::WordBool &__IsAssignableFrom_result) = 0 ;
	virtual HRESULT __safecall GetInterfaceMap(const _di__Type interfaceType, InterfaceMapping &__GetInterfaceMap_result) = 0 ;
	virtual HRESULT __safecall GetMethod(const System::WideString name, Activex::TOleEnum bindingAttr, const _di__Binder Binder, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__MethodInfo &__GetMethod_result) = 0 ;
	virtual HRESULT __safecall GetMethod_2(const System::WideString name, Activex::TOleEnum bindingAttr, _di__MethodInfo &__GetMethod_2_result) = 0 ;
	virtual HRESULT __safecall GetMethods(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetMethods_result) = 0 ;
	virtual HRESULT __safecall GetField(const System::WideString name, Activex::TOleEnum bindingAttr, _di__FieldInfo &__GetField_result) = 0 ;
	virtual HRESULT __safecall GetFields(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetFields_result) = 0 ;
	virtual HRESULT __safecall GetProperty(const System::WideString name, Activex::TOleEnum bindingAttr, _di__PropertyInfo &__GetProperty_result) = 0 ;
	virtual HRESULT __safecall GetProperty_2(const System::WideString name, Activex::TOleEnum bindingAttr, const _di__Binder Binder, const _di__Type returnType, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__PropertyInfo &__GetProperty_2_result) = 0 ;
	virtual HRESULT __safecall GetProperties(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetProperties_result) = 0 ;
	virtual HRESULT __safecall GetMember_2(const System::WideString name, Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetMember_2_result) = 0 ;
	virtual HRESULT __safecall GetMembers(Activex::TOleEnum bindingAttr, Activex::PSafeArray &__GetMembers_result) = 0 ;
	virtual HRESULT __safecall InvokeMember(const System::WideString name, Activex::TOleEnum invokeAttr, const _di__Binder Binder, const System::OleVariant Target, Activex::PSafeArray args, Activex::PSafeArray modifiers, const _di__CultureInfo culture, Activex::PSafeArray namedParameters, System::OleVariant &__InvokeMember_result) = 0 ;
	virtual HRESULT __safecall Get_UnderlyingSystemType(_di__Type &__Get_UnderlyingSystemType_result) = 0 ;
	virtual HRESULT __safecall InvokeMember_2(const System::WideString name, Activex::TOleEnum invokeAttr, const _di__Binder Binder, const System::OleVariant Target, Activex::PSafeArray args, const _di__CultureInfo culture, System::OleVariant &__InvokeMember_2_result) = 0 ;
	virtual HRESULT __safecall InvokeMember_3(const System::WideString name, Activex::TOleEnum invokeAttr, const _di__Binder Binder, const System::OleVariant Target, Activex::PSafeArray args, System::OleVariant &__InvokeMember_3_result) = 0 ;
	virtual HRESULT __safecall GetConstructor(Activex::TOleEnum bindingAttr, const _di__Binder Binder, Activex::TOleEnum callConvention, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__ConstructorInfo &__GetConstructor_result) = 0 ;
	virtual HRESULT __safecall GetConstructor_2(Activex::TOleEnum bindingAttr, const _di__Binder Binder, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__ConstructorInfo &__GetConstructor_2_result) = 0 ;
	virtual HRESULT __safecall GetConstructor_3(Activex::PSafeArray types, _di__ConstructorInfo &__GetConstructor_3_result) = 0 ;
	virtual HRESULT __safecall GetConstructors_2(Activex::PSafeArray &__GetConstructors_2_result) = 0 ;
	virtual HRESULT __safecall Get_TypeInitializer(_di__ConstructorInfo &__Get_TypeInitializer_result) = 0 ;
	virtual HRESULT __safecall GetMethod_3(const System::WideString name, Activex::TOleEnum bindingAttr, const _di__Binder Binder, Activex::TOleEnum callConvention, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__MethodInfo &__GetMethod_3_result) = 0 ;
	virtual HRESULT __safecall GetMethod_4(const System::WideString name, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__MethodInfo &__GetMethod_4_result) = 0 ;
	virtual HRESULT __safecall GetMethod_5(const System::WideString name, Activex::PSafeArray types, _di__MethodInfo &__GetMethod_5_result) = 0 ;
	virtual HRESULT __safecall GetMethod_6(const System::WideString name, _di__MethodInfo &__GetMethod_6_result) = 0 ;
	virtual HRESULT __safecall GetMethods_2(Activex::PSafeArray &__GetMethods_2_result) = 0 ;
	virtual HRESULT __safecall GetField_2(const System::WideString name, _di__FieldInfo &__GetField_2_result) = 0 ;
	virtual HRESULT __safecall GetFields_2(Activex::PSafeArray &__GetFields_2_result) = 0 ;
	virtual HRESULT __safecall GetInterface_2(const System::WideString name, _di__Type &__GetInterface_2_result) = 0 ;
	virtual HRESULT __safecall GetEvent_2(const System::WideString name, _di__EventInfo &__GetEvent_2_result) = 0 ;
	virtual HRESULT __safecall GetProperty_3(const System::WideString name, const _di__Type returnType, Activex::PSafeArray types, Activex::PSafeArray modifiers, _di__PropertyInfo &__GetProperty_3_result) = 0 ;
	virtual HRESULT __safecall GetProperty_4(const System::WideString name, const _di__Type returnType, Activex::PSafeArray types, _di__PropertyInfo &__GetProperty_4_result) = 0 ;
	virtual HRESULT __safecall GetProperty_5(const System::WideString name, Activex::PSafeArray types, _di__PropertyInfo &__GetProperty_5_result) = 0 ;
	virtual HRESULT __safecall GetProperty_6(const System::WideString name, const _di__Type returnType, _di__PropertyInfo &__GetProperty_6_result) = 0 ;
	virtual HRESULT __safecall GetProperty_7(const System::WideString name, _di__PropertyInfo &__GetProperty_7_result) = 0 ;
	virtual HRESULT __safecall GetProperties_2(Activex::PSafeArray &__GetProperties_2_result) = 0 ;
	virtual HRESULT __safecall GetNestedTypes_2(Activex::PSafeArray &__GetNestedTypes_2_result) = 0 ;
	virtual HRESULT __safecall GetNestedType_2(const System::WideString name, _di__Type &__GetNestedType_2_result) = 0 ;
	virtual HRESULT __safecall GetMember_3(const System::WideString name, Activex::PSafeArray &__GetMember_3_result) = 0 ;
	virtual HRESULT __safecall GetMembers_2(Activex::PSafeArray &__GetMembers_2_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(Activex::TOleEnum &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall Get_IsNotPublic(System::WordBool &__Get_IsNotPublic_result) = 0 ;
	virtual HRESULT __safecall Get_IsPublic(System::WordBool &__Get_IsPublic_result) = 0 ;
	virtual HRESULT __safecall Get_IsNestedPublic(System::WordBool &__Get_IsNestedPublic_result) = 0 ;
	virtual HRESULT __safecall Get_IsNestedPrivate(System::WordBool &__Get_IsNestedPrivate_result) = 0 ;
	virtual HRESULT __safecall Get_IsNestedFamily(System::WordBool &__Get_IsNestedFamily_result) = 0 ;
	virtual HRESULT __safecall Get_IsNestedAssembly(System::WordBool &__Get_IsNestedAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsNestedFamANDAssem(System::WordBool &__Get_IsNestedFamANDAssem_result) = 0 ;
	virtual HRESULT __safecall Get_IsNestedFamORAssem(System::WordBool &__Get_IsNestedFamORAssem_result) = 0 ;
	virtual HRESULT __safecall Get_IsAutoLayout(System::WordBool &__Get_IsAutoLayout_result) = 0 ;
	virtual HRESULT __safecall Get_IsLayoutSequential(System::WordBool &__Get_IsLayoutSequential_result) = 0 ;
	virtual HRESULT __safecall Get_IsExplicitLayout(System::WordBool &__Get_IsExplicitLayout_result) = 0 ;
	virtual HRESULT __safecall Get_IsClass(System::WordBool &__Get_IsClass_result) = 0 ;
	virtual HRESULT __safecall Get_IsInterface(System::WordBool &__Get_IsInterface_result) = 0 ;
	virtual HRESULT __safecall Get_IsValueType(System::WordBool &__Get_IsValueType_result) = 0 ;
	virtual HRESULT __safecall Get_IsAbstract(System::WordBool &__Get_IsAbstract_result) = 0 ;
	virtual HRESULT __safecall Get_IsSealed(System::WordBool &__Get_IsSealed_result) = 0 ;
	virtual HRESULT __safecall Get_IsEnum(System::WordBool &__Get_IsEnum_result) = 0 ;
	virtual HRESULT __safecall Get_IsSpecialName(System::WordBool &__Get_IsSpecialName_result) = 0 ;
	virtual HRESULT __safecall Get_IsImport(System::WordBool &__Get_IsImport_result) = 0 ;
	virtual HRESULT __safecall Get_IsSerializable(System::WordBool &__Get_IsSerializable_result) = 0 ;
	virtual HRESULT __safecall Get_IsAnsiClass(System::WordBool &__Get_IsAnsiClass_result) = 0 ;
	virtual HRESULT __safecall Get_IsUnicodeClass(System::WordBool &__Get_IsUnicodeClass_result) = 0 ;
	virtual HRESULT __safecall Get_IsAutoClass(System::WordBool &__Get_IsAutoClass_result) = 0 ;
	virtual HRESULT __safecall Get_IsArray(System::WordBool &__Get_IsArray_result) = 0 ;
	virtual HRESULT __safecall Get_IsByRef(System::WordBool &__Get_IsByRef_result) = 0 ;
	virtual HRESULT __safecall Get_IsPointer(System::WordBool &__Get_IsPointer_result) = 0 ;
	virtual HRESULT __safecall Get_IsPrimitive(System::WordBool &__Get_IsPrimitive_result) = 0 ;
	virtual HRESULT __safecall Get_IsCOMObject(System::WordBool &__Get_IsCOMObject_result) = 0 ;
	virtual HRESULT __safecall Get_HasElementType(System::WordBool &__Get_HasElementType_result) = 0 ;
	virtual HRESULT __safecall Get_IsContextful(System::WordBool &__Get_IsContextful_result) = 0 ;
	virtual HRESULT __safecall Get_IsMarshalByRef(System::WordBool &__Get_IsMarshalByRef_result) = 0 ;
	virtual HRESULT __safecall Equals_2(const _di__Type o, System::WordBool &__Equals_2_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_MemberType() { Activex::TOleEnum __r; HRESULT __hr = Get_MemberType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum MemberType = {read=_scw_Get_MemberType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_DeclaringType() { _di__Type __r; HRESULT __hr = Get_DeclaringType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type DeclaringType = {read=_scw_Get_DeclaringType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ReflectedType() { _di__Type __r; HRESULT __hr = Get_ReflectedType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ReflectedType = {read=_scw_Get_ReflectedType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline GUID _scw_Get_Guid() { GUID __r; HRESULT __hr = Get_Guid(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property GUID Guid = {read=_scw_Get_Guid};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Module _scw_Get_Module() { _di__Module __r; HRESULT __hr = Get_Module(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Module Module = {read=_scw_Get_Module};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Assembly _scw_Get_Assembly() { _di__Assembly __r; HRESULT __hr = Get_Assembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Assembly Assembly = {read=_scw_Get_Assembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline RuntimeTypeHandle _scw_Get_TypeHandle() { RuntimeTypeHandle __r; HRESULT __hr = Get_TypeHandle(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property RuntimeTypeHandle TypeHandle = {read=_scw_Get_TypeHandle};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_FullName() { System::WideString __r; HRESULT __hr = Get_FullName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString FullName = {read=_scw_Get_FullName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Namespace() { System::WideString __r; HRESULT __hr = Get_Namespace(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Namespace = {read=_scw_Get_Namespace};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_AssemblyQualifiedName() { System::WideString __r; HRESULT __hr = Get_AssemblyQualifiedName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString AssemblyQualifiedName = {read=_scw_Get_AssemblyQualifiedName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_BaseType() { _di__Type __r; HRESULT __hr = Get_BaseType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type BaseType = {read=_scw_Get_BaseType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_UnderlyingSystemType() { _di__Type __r; HRESULT __hr = Get_UnderlyingSystemType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type UnderlyingSystemType = {read=_scw_Get_UnderlyingSystemType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__ConstructorInfo _scw_Get_TypeInitializer() { _di__ConstructorInfo __r; HRESULT __hr = Get_TypeInitializer(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__ConstructorInfo TypeInitializer = {read=_scw_Get_TypeInitializer};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_Attributes() { Activex::TOleEnum __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum Attributes = {read=_scw_Get_Attributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsNotPublic() { System::WordBool __r; HRESULT __hr = Get_IsNotPublic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsNotPublic = {read=_scw_Get_IsNotPublic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPublic() { System::WordBool __r; HRESULT __hr = Get_IsPublic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPublic = {read=_scw_Get_IsPublic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsNestedPublic() { System::WordBool __r; HRESULT __hr = Get_IsNestedPublic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsNestedPublic = {read=_scw_Get_IsNestedPublic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsNestedPrivate() { System::WordBool __r; HRESULT __hr = Get_IsNestedPrivate(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsNestedPrivate = {read=_scw_Get_IsNestedPrivate};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsNestedFamily() { System::WordBool __r; HRESULT __hr = Get_IsNestedFamily(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsNestedFamily = {read=_scw_Get_IsNestedFamily};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsNestedAssembly() { System::WordBool __r; HRESULT __hr = Get_IsNestedAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsNestedAssembly = {read=_scw_Get_IsNestedAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsNestedFamANDAssem() { System::WordBool __r; HRESULT __hr = Get_IsNestedFamANDAssem(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsNestedFamANDAssem = {read=_scw_Get_IsNestedFamANDAssem};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsNestedFamORAssem() { System::WordBool __r; HRESULT __hr = Get_IsNestedFamORAssem(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsNestedFamORAssem = {read=_scw_Get_IsNestedFamORAssem};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAutoLayout() { System::WordBool __r; HRESULT __hr = Get_IsAutoLayout(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAutoLayout = {read=_scw_Get_IsAutoLayout};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsLayoutSequential() { System::WordBool __r; HRESULT __hr = Get_IsLayoutSequential(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsLayoutSequential = {read=_scw_Get_IsLayoutSequential};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsExplicitLayout() { System::WordBool __r; HRESULT __hr = Get_IsExplicitLayout(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsExplicitLayout = {read=_scw_Get_IsExplicitLayout};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsClass() { System::WordBool __r; HRESULT __hr = Get_IsClass(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsClass = {read=_scw_Get_IsClass};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsInterface() { System::WordBool __r; HRESULT __hr = Get_IsInterface(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsInterface = {read=_scw_Get_IsInterface};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsValueType() { System::WordBool __r; HRESULT __hr = Get_IsValueType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsValueType = {read=_scw_Get_IsValueType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAbstract() { System::WordBool __r; HRESULT __hr = Get_IsAbstract(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAbstract = {read=_scw_Get_IsAbstract};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSealed() { System::WordBool __r; HRESULT __hr = Get_IsSealed(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSealed = {read=_scw_Get_IsSealed};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsEnum() { System::WordBool __r; HRESULT __hr = Get_IsEnum(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsEnum = {read=_scw_Get_IsEnum};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSpecialName() { System::WordBool __r; HRESULT __hr = Get_IsSpecialName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSpecialName = {read=_scw_Get_IsSpecialName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsImport() { System::WordBool __r; HRESULT __hr = Get_IsImport(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsImport = {read=_scw_Get_IsImport};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSerializable() { System::WordBool __r; HRESULT __hr = Get_IsSerializable(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSerializable = {read=_scw_Get_IsSerializable};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAnsiClass() { System::WordBool __r; HRESULT __hr = Get_IsAnsiClass(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAnsiClass = {read=_scw_Get_IsAnsiClass};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsUnicodeClass() { System::WordBool __r; HRESULT __hr = Get_IsUnicodeClass(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsUnicodeClass = {read=_scw_Get_IsUnicodeClass};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAutoClass() { System::WordBool __r; HRESULT __hr = Get_IsAutoClass(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAutoClass = {read=_scw_Get_IsAutoClass};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsArray() { System::WordBool __r; HRESULT __hr = Get_IsArray(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsArray = {read=_scw_Get_IsArray};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsByRef() { System::WordBool __r; HRESULT __hr = Get_IsByRef(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsByRef = {read=_scw_Get_IsByRef};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPointer() { System::WordBool __r; HRESULT __hr = Get_IsPointer(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPointer = {read=_scw_Get_IsPointer};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPrimitive() { System::WordBool __r; HRESULT __hr = Get_IsPrimitive(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPrimitive = {read=_scw_Get_IsPrimitive};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsCOMObject() { System::WordBool __r; HRESULT __hr = Get_IsCOMObject(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsCOMObject = {read=_scw_Get_IsCOMObject};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_HasElementType() { System::WordBool __r; HRESULT __hr = Get_HasElementType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool HasElementType = {read=_scw_Get_HasElementType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsContextful() { System::WordBool __r; HRESULT __hr = Get_IsContextful(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsContextful = {read=_scw_Get_IsContextful};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsMarshalByRef() { System::WordBool __r; HRESULT __hr = Get_IsMarshalByRef(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsMarshalByRef = {read=_scw_Get_IsMarshalByRef};
};

__interface  INTERFACE_UUID("{1B96E53C-4028-38BC-9DC3-8D7A9555C311}") _SerializableAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FEB0323D-8CE4-36A4-A41E-0BA0C32E1A6A}") _TypeInitializationException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6193C5F6-6807-3561-A7F3-B64C80B5F00F}") _UnauthorizedAccessException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A218E20A-0905-3741-B0B3-9E3193162E50}") _UnhandledExceptionEventArgs  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{84199E64-439C-3011-B249-3C9065735ADB}") _UnhandledExceptionEventHandler  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{011A90C5-4910-3C29-BBB7-50D05CCBAA4A}") _Version  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C5DF3568-C251-3C58-AFB4-32E79E8261F0}") _WeakReference  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{40DFC50A-E93A-3C08-B9EF-E2B4F28B5676}") _WaitHandle  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3F243EBD-612F-3DB8-9E03-BD92343A8371}") _AutoResetEvent  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4BCBC4D6-98EB-381A-A8A6-08B2378738ED}") _CompressedStack  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DF20F518-8ED1-35E3-950E-020214FDB9B2}") _Interlocked  : public IDispatch 
{
	
};

__interface IObjectHandle;
typedef System::DelphiInterface<IObjectHandle> _di_IObjectHandle;
__interface  INTERFACE_UUID("{C460E2B4-E199-412A-8456-84DC3E4838C3}") IObjectHandle  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall Unwrap(/* out */ System::OleVariant &pRetVal) = 0 ;
};

__interface  INTERFACE_UUID("{C0BB9361-268F-3E72-BF6F-4120175A1500}") _ManualResetEvent  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EE22485E-4C45-3C9D-9027-A8D61C5F53F2}") _Monitor  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{36CB559B-87C6-3AD2-9225-62A7ED499B37}") _Mutex  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DD846FCC-8D04-3665-81B6-AACBE99C19C3}") _Overlapped  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AD89B568-4FD4-3F8D-8327-B396B20A460E}") _ReaderWriterLock  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{87F55344-17E0-30FD-8EB9-38EAF6A19B3F}") _SynchronizationLockException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C281C7F1-4AA9-3517-961A-463CFED57E75}") _Thread  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{95B525DB-6B81-3CDC-8FE7-713F7FC793C0}") _ThreadAbortException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{85D72F83-BE91-3CB1-B4F0-76B56FF04033}") _STAThreadAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C02468D1-8713-3225-BDA3-49B2FE37DDBB}") _MTAThreadAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B9E07599-7C44-33BE-A70E-EFA16F51F54A}") _ThreadInterruptedException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{64409425-F8C9-370E-809E-3241CE804541}") _RegisteredWaitHandle  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CE949142-4D4C-358D-89A9-E69A531AA363}") _WaitCallback  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F078F795-F452-3D2D-8CC8-16D66AE46C67}") _WaitOrTimerCallback  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BBAE942D-BFF4-36E2-A3BC-508BB3801F4F}") _IOCompletionCallback  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F5E02ADE-E724-3001-B498-3305B2A93D72}") _ThreadPool  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B45BBD7E-A977-3F56-A626-7A693E5DBBC5}") _ThreadStart  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A13A41CF-E066-3B90-82F4-73109104E348}") _ThreadStateException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A6B94B6D-854E-3172-A4EC-A17EDD16F85E}") _ThreadStaticAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{81456E86-22AF-31D1-A91A-9C370C0E2530}") _Timeout  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3741BC6F-101B-36D7-A9D5-03FCC0ECDA35}") _TimerCallback  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B49A029B-406B-3B1E-88E4-F86690D20364}") _Timer  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{401F89CB-C127-3041-82FD-B67035395C56}") _ArrayList  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F145C46A-D170-3170-B52F-4678DFCA0300}") _BitArray  : public IDispatch 
{
	
};

__interface IComparer;
typedef System::DelphiInterface<IComparer> _di_IComparer;
__interface  INTERFACE_UUID("{C20FD3EB-7022-3D14-8477-760FAB54E50D}") IComparer  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Compare(const System::OleVariant x, const System::OleVariant y, int &__Compare_result) = 0 ;
};

__interface  INTERFACE_UUID("{EA6795AC-97D6-3377-BE64-829ABD67607B}") _CaseInsensitiveComparer  : public IDispatch 
{
	
};

__interface IHashCodeProvider;
typedef System::DelphiInterface<IHashCodeProvider> _di_IHashCodeProvider;
__interface  INTERFACE_UUID("{5D573036-3435-3C5A-AEFF-2B8191082C71}") IHashCodeProvider  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetHashCode(const System::OleVariant obj, int &__GetHashCode_result) = 0 ;
};

__interface  INTERFACE_UUID("{0422B845-B636-3688-8F61-9B6D93096336}") _CaseInsensitiveHashCodeProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B7D29E26-7798-3FA4-90F4-E6A22D2099F9}") _CollectionBase  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8064A157-B5C8-3A4A-AD3D-02DC1A39C417}") _Comparer  : public IDispatch 
{
	
};

__interface IDictionary;
typedef System::DelphiInterface<IDictionary> _di_IDictionary;
__interface IDictionaryEnumerator;
typedef System::DelphiInterface<IDictionaryEnumerator> _di_IDictionaryEnumerator;
__interface  INTERFACE_UUID("{6A6841DF-3287-3D87-8060-CE0B4C77D2A1}") IDictionary  : public IDispatch 
{
	
public:
	System::OleVariant operator[](System::OleVariant key) { return Item[key]; }
	
public:
	virtual HRESULT __safecall Get_Item(const System::OleVariant key, System::OleVariant &__Get_Item_result) = 0 ;
	virtual HRESULT __safecall _Set_Item(const System::OleVariant key, const System::OleVariant pRetVal) = 0 ;
	virtual HRESULT __safecall Get_Keys(_di_ICollection &__Get_Keys_result) = 0 ;
	virtual HRESULT __safecall Get_Values(_di_ICollection &__Get_Values_result) = 0 ;
	virtual HRESULT __safecall Contains(const System::OleVariant key, System::WordBool &__Contains_result) = 0 ;
	virtual HRESULT __safecall Add(const System::OleVariant key, const System::OleVariant value) = 0 ;
	virtual HRESULT __safecall Clear(void) = 0 ;
	virtual HRESULT __safecall Get_IsReadOnly(System::WordBool &__Get_IsReadOnly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFixedSize(System::WordBool &__Get_IsFixedSize_result) = 0 ;
	virtual HRESULT __safecall GetEnumerator(_di_IDictionaryEnumerator &__GetEnumerator_result) = 0 ;
	virtual HRESULT __safecall Remove(const System::OleVariant key) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_Item(const System::OleVariant key) { System::OleVariant __r; HRESULT __hr = Get_Item(key, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant Item[System::OleVariant key] = {read=_scw_Get_Item, write=_Set_Item/*, default*/};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_ICollection _scw_Get_Keys() { _di_ICollection __r; HRESULT __hr = Get_Keys(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_ICollection Keys = {read=_scw_Get_Keys};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_ICollection _scw_Get_Values() { _di_ICollection __r; HRESULT __hr = Get_Values(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_ICollection Values = {read=_scw_Get_Values};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsReadOnly() { System::WordBool __r; HRESULT __hr = Get_IsReadOnly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsReadOnly = {read=_scw_Get_IsReadOnly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFixedSize() { System::WordBool __r; HRESULT __hr = Get_IsFixedSize(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFixedSize = {read=_scw_Get_IsFixedSize};
};

__interface  INTERFACE_UUID("{DDD44DA2-BC6B-3620-9317-C0372968C741}") _DictionaryBase  : public IDispatch 
{
	
};

__interface IDeserializationCallback;
typedef System::DelphiInterface<IDeserializationCallback> _di_IDeserializationCallback;
__interface  INTERFACE_UUID("{AB3F47E4-C227-3B05-BF9F-94649BEF9888}") IDeserializationCallback  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall OnDeserialization(const System::OleVariant sender) = 0 ;
};

__interface  INTERFACE_UUID("{D25A197E-3E69-3271-A989-23D85E97F920}") _Hashtable  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{35D574BF-7A4F-3588-8C19-12212A0FE4DC}") IDictionaryEnumerator  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_key(System::OleVariant &__Get_key_result) = 0 ;
	virtual HRESULT __safecall Get_value(System::OleVariant &__Get_value_result) = 0 ;
	virtual HRESULT __safecall Get_Entry(DictionaryEntry &__Get_Entry_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_key() { System::OleVariant __r; HRESULT __hr = Get_key(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant key = {read=_scw_Get_key};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_value() { System::OleVariant __r; HRESULT __hr = Get_value(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant value = {read=_scw_Get_value};
	#pragma option push -w-inl
	/* safecall wrapper */ inline DictionaryEntry _scw_Get_Entry() { DictionaryEntry __r; HRESULT __hr = Get_Entry(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property DictionaryEntry Entry = {read=_scw_Get_Entry};
};

__interface  INTERFACE_UUID("{3A7D3CA4-B7D1-3A2A-800C-8FC2ACFCBDA4}") _Queue  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BD32D878-A59B-3E5C-BFE0-A96B1A1E9D6F}") _ReadOnlyCollectionBase  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{56421139-A143-3AE9-9852-1DBDFE3D6BFA}") _SortedList  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AB538809-3C2F-35D9-80E6-7BAD540484A1}") _Stack  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E40A025C-645B-3C8E-A1AC-9C5CCA279625}") _ConditionalAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A9B4786C-08E3-344F-A651-2F9926DEAC5E}") _Debugger  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3344E8B4-A5C3-3882-8D30-63792485ECCF}") _DebuggerStepThroughAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{55B6903B-55FE-35E0-804F-E42A096D2EB0}") _DebuggerHiddenAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{428E3627-2B1F-302C-A7E6-6388CD535E75}") _DebuggableAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9A2669EC-FF84-3726-89A0-663A3EF3B5CD}") _StackTrace  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0E9B8E47-CA67-38B6-B9DB-2C42EE757B08}") _StackFrame  : public IDispatch 
{
	
};

__interface ISymbolBinder;
typedef System::DelphiInterface<ISymbolBinder> _di_ISymbolBinder;
__interface ISymbolReader;
typedef System::DelphiInterface<ISymbolReader> _di_ISymbolReader;
__interface  INTERFACE_UUID("{20808ADC-CC01-3F3A-8F09-ED12940FC212}") ISymbolBinder  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetReader(int importer, const System::WideString filename, const System::WideString searchPath, _di_ISymbolReader &__GetReader_result) = 0 ;
};

__interface ISymbolDocument;
typedef System::DelphiInterface<ISymbolDocument> _di_ISymbolDocument;
__interface  INTERFACE_UUID("{1C32F012-2684-3EFE-8D50-9C2973ACC00B}") ISymbolDocument  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Url(System::WideString &__Get_Url_result) = 0 ;
	virtual HRESULT __safecall Get_DocumentType(GUID &__Get_DocumentType_result) = 0 ;
	virtual HRESULT __safecall Get_Language(GUID &__Get_Language_result) = 0 ;
	virtual HRESULT __safecall Get_LanguageVendor(GUID &__Get_LanguageVendor_result) = 0 ;
	virtual HRESULT __safecall Get_CheckSumAlgorithmId(GUID &__Get_CheckSumAlgorithmId_result) = 0 ;
	virtual HRESULT __safecall GetCheckSum(Activex::PSafeArray &__GetCheckSum_result) = 0 ;
	virtual HRESULT __safecall FindClosestLine(int line, int &__FindClosestLine_result) = 0 ;
	virtual HRESULT __safecall Get_HasEmbeddedSource(System::WordBool &__Get_HasEmbeddedSource_result) = 0 ;
	virtual HRESULT __safecall Get_SourceLength(int &__Get_SourceLength_result) = 0 ;
	virtual HRESULT __safecall GetSourceRange(int startLine, int startColumn, int endLine, int endColumn, Activex::PSafeArray &__GetSourceRange_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Url() { System::WideString __r; HRESULT __hr = Get_Url(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Url = {read=_scw_Get_Url};
	#pragma option push -w-inl
	/* safecall wrapper */ inline GUID _scw_Get_DocumentType() { GUID __r; HRESULT __hr = Get_DocumentType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property GUID DocumentType = {read=_scw_Get_DocumentType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline GUID _scw_Get_Language() { GUID __r; HRESULT __hr = Get_Language(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property GUID Language = {read=_scw_Get_Language};
	#pragma option push -w-inl
	/* safecall wrapper */ inline GUID _scw_Get_LanguageVendor() { GUID __r; HRESULT __hr = Get_LanguageVendor(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property GUID LanguageVendor = {read=_scw_Get_LanguageVendor};
	#pragma option push -w-inl
	/* safecall wrapper */ inline GUID _scw_Get_CheckSumAlgorithmId() { GUID __r; HRESULT __hr = Get_CheckSumAlgorithmId(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property GUID CheckSumAlgorithmId = {read=_scw_Get_CheckSumAlgorithmId};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_HasEmbeddedSource() { System::WordBool __r; HRESULT __hr = Get_HasEmbeddedSource(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool HasEmbeddedSource = {read=_scw_Get_HasEmbeddedSource};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_SourceLength() { int __r; HRESULT __hr = Get_SourceLength(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int SourceLength = {read=_scw_Get_SourceLength};
};

__interface ISymbolDocumentWriter;
typedef System::DelphiInterface<ISymbolDocumentWriter> _di_ISymbolDocumentWriter;
__interface  INTERFACE_UUID("{FA682F24-3A3C-390D-B8A2-96F1106F4B37}") ISymbolDocumentWriter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall SetSource(Activex::PSafeArray Source) = 0 ;
	virtual HRESULT __safecall SetCheckSum(const GUID algorithmId, Activex::PSafeArray checkSum) = 0 ;
};

__interface ISymbolMethod;
typedef System::DelphiInterface<ISymbolMethod> _di_ISymbolMethod;
__interface ISymbolScope;
typedef System::DelphiInterface<ISymbolScope> _di_ISymbolScope;
__interface ISymbolNamespace;
typedef System::DelphiInterface<ISymbolNamespace> _di_ISymbolNamespace;
__interface  INTERFACE_UUID("{25C72EB0-E437-3F17-946D-3B72A3ACFF37}") ISymbolMethod  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Token(SymbolToken &__Get_Token_result) = 0 ;
	virtual HRESULT __safecall Get_SequencePointCount(int &__Get_SequencePointCount_result) = 0 ;
	virtual HRESULT __safecall GetSequencePoints(Activex::PSafeArray offsets, Activex::PSafeArray documents, Activex::PSafeArray lines, Activex::PSafeArray columns, Activex::PSafeArray endLines, Activex::PSafeArray endColumns) = 0 ;
	virtual HRESULT __safecall Get_RootScope(_di_ISymbolScope &__Get_RootScope_result) = 0 ;
	virtual HRESULT __safecall GetScope(int offset, _di_ISymbolScope &__GetScope_result) = 0 ;
	virtual HRESULT __safecall GetOffset(const _di_ISymbolDocument document, int line, int column, int &__GetOffset_result) = 0 ;
	virtual HRESULT __safecall GetRanges(const _di_ISymbolDocument document, int line, int column, Activex::PSafeArray &__GetRanges_result) = 0 ;
	virtual HRESULT __safecall GetParameters(Activex::PSafeArray &__GetParameters_result) = 0 ;
	virtual HRESULT __safecall GetNamespace(_di_ISymbolNamespace &__GetNamespace_result) = 0 ;
	virtual HRESULT __safecall GetSourceStartEnd(Activex::PSafeArray docs, Activex::PSafeArray lines, Activex::PSafeArray columns, System::WordBool &__GetSourceStartEnd_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline SymbolToken _scw_Get_Token() { SymbolToken __r; HRESULT __hr = Get_Token(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property SymbolToken Token = {read=_scw_Get_Token};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_SequencePointCount() { int __r; HRESULT __hr = Get_SequencePointCount(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int SequencePointCount = {read=_scw_Get_SequencePointCount};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_ISymbolScope _scw_Get_RootScope() { _di_ISymbolScope __r; HRESULT __hr = Get_RootScope(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_ISymbolScope RootScope = {read=_scw_Get_RootScope};
};

__interface  INTERFACE_UUID("{23ED2454-6899-3C28-BAB7-6EC86683964A}") ISymbolNamespace  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall GetNamespaces(Activex::PSafeArray &__GetNamespaces_result) = 0 ;
	virtual HRESULT __safecall GetVariables(Activex::PSafeArray &__GetVariables_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
};

__interface  INTERFACE_UUID("{E809A5F1-D3D7-3144-9BEF-FE8AC0364699}") ISymbolReader  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetDocument(const System::WideString Url, const GUID Language, const GUID LanguageVendor, const GUID DocumentType, _di_ISymbolDocument &__GetDocument_result) = 0 ;
	virtual HRESULT __safecall GetDocuments(Activex::PSafeArray &__GetDocuments_result) = 0 ;
	virtual HRESULT __safecall Get_UserEntryPoint(SymbolToken &__Get_UserEntryPoint_result) = 0 ;
	virtual HRESULT __safecall GetMethod(SymbolToken Method, _di_ISymbolMethod &__GetMethod_result) = 0 ;
	virtual HRESULT __safecall GetMethod_2(SymbolToken Method, int Version, _di_ISymbolMethod &__GetMethod_2_result) = 0 ;
	virtual HRESULT __safecall GetVariables(SymbolToken parent, Activex::PSafeArray &__GetVariables_result) = 0 ;
	virtual HRESULT __safecall GetGlobalVariables(Activex::PSafeArray &__GetGlobalVariables_result) = 0 ;
	virtual HRESULT __safecall GetMethodFromDocumentPosition(const _di_ISymbolDocument document, int line, int column, _di_ISymbolMethod &__GetMethodFromDocumentPosition_result) = 0 ;
	virtual HRESULT __safecall GetSymAttribute(SymbolToken parent, const System::WideString name, Activex::PSafeArray &__GetSymAttribute_result) = 0 ;
	virtual HRESULT __safecall GetNamespaces(Activex::PSafeArray &__GetNamespaces_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline SymbolToken _scw_Get_UserEntryPoint() { SymbolToken __r; HRESULT __hr = Get_UserEntryPoint(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property SymbolToken UserEntryPoint = {read=_scw_Get_UserEntryPoint};
};

__interface  INTERFACE_UUID("{1CEE3A11-01AE-3244-A939-4972FC9703EF}") ISymbolScope  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Method(_di_ISymbolMethod &__Get_Method_result) = 0 ;
	virtual HRESULT __safecall Get_parent(_di_ISymbolScope &__Get_parent_result) = 0 ;
	virtual HRESULT __safecall GetChildren(Activex::PSafeArray &__GetChildren_result) = 0 ;
	virtual HRESULT __safecall Get_StartOffset(int &__Get_StartOffset_result) = 0 ;
	virtual HRESULT __safecall Get_EndOffset(int &__Get_EndOffset_result) = 0 ;
	virtual HRESULT __safecall GetLocals(Activex::PSafeArray &__GetLocals_result) = 0 ;
	virtual HRESULT __safecall GetNamespaces(Activex::PSafeArray &__GetNamespaces_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_ISymbolMethod _scw_Get_Method() { _di_ISymbolMethod __r; HRESULT __hr = Get_Method(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_ISymbolMethod Method = {read=_scw_Get_Method};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_ISymbolScope _scw_Get_parent() { _di_ISymbolScope __r; HRESULT __hr = Get_parent(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_ISymbolScope parent = {read=_scw_Get_parent};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_StartOffset() { int __r; HRESULT __hr = Get_StartOffset(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int StartOffset = {read=_scw_Get_StartOffset};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_EndOffset() { int __r; HRESULT __hr = Get_EndOffset(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int EndOffset = {read=_scw_Get_EndOffset};
};

__interface ISymbolVariable;
typedef System::DelphiInterface<ISymbolVariable> _di_ISymbolVariable;
__interface  INTERFACE_UUID("{4042BD4D-B5AB-30E8-919B-14910687BAAE}") ISymbolVariable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(System::OleVariant &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall GetSignature(Activex::PSafeArray &__GetSignature_result) = 0 ;
	virtual HRESULT __safecall Get_AddressKind(Activex::TOleEnum &__Get_AddressKind_result) = 0 ;
	virtual HRESULT __safecall Get_AddressField1(int &__Get_AddressField1_result) = 0 ;
	virtual HRESULT __safecall Get_AddressField2(int &__Get_AddressField2_result) = 0 ;
	virtual HRESULT __safecall Get_AddressField3(int &__Get_AddressField3_result) = 0 ;
	virtual HRESULT __safecall Get_StartOffset(int &__Get_StartOffset_result) = 0 ;
	virtual HRESULT __safecall Get_EndOffset(int &__Get_EndOffset_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_Attributes() { System::OleVariant __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant Attributes = {read=_scw_Get_Attributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_AddressKind() { Activex::TOleEnum __r; HRESULT __hr = Get_AddressKind(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum AddressKind = {read=_scw_Get_AddressKind};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_AddressField1() { int __r; HRESULT __hr = Get_AddressField1(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int AddressField1 = {read=_scw_Get_AddressField1};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_AddressField2() { int __r; HRESULT __hr = Get_AddressField2(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int AddressField2 = {read=_scw_Get_AddressField2};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_AddressField3() { int __r; HRESULT __hr = Get_AddressField3(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int AddressField3 = {read=_scw_Get_AddressField3};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_StartOffset() { int __r; HRESULT __hr = Get_StartOffset(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int StartOffset = {read=_scw_Get_StartOffset};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_EndOffset() { int __r; HRESULT __hr = Get_EndOffset(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int EndOffset = {read=_scw_Get_EndOffset};
};

__interface ISymbolWriter;
typedef System::DelphiInterface<ISymbolWriter> _di_ISymbolWriter;
__interface  INTERFACE_UUID("{DA295A1B-C5BD-3B34-8ACD-1D7D334FFB7F}") ISymbolWriter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Initialize(int emitter, const System::WideString filename, System::WordBool fFullBuild) = 0 ;
	virtual HRESULT __safecall DefineDocument(const System::WideString Url, const GUID Language, const GUID LanguageVendor, const GUID DocumentType, _di_ISymbolDocumentWriter &__DefineDocument_result) = 0 ;
	virtual HRESULT __safecall SetUserEntryPoint(SymbolToken entryMethod) = 0 ;
	virtual HRESULT __safecall OpenMethod(SymbolToken Method) = 0 ;
	virtual HRESULT __safecall CloseMethod(void) = 0 ;
	virtual HRESULT __safecall DefineSequencePoints(const _di_ISymbolDocumentWriter document, Activex::PSafeArray offsets, Activex::PSafeArray lines, Activex::PSafeArray columns, Activex::PSafeArray endLines, Activex::PSafeArray endColumns) = 0 ;
	virtual HRESULT __safecall OpenScope(int StartOffset, int &__OpenScope_result) = 0 ;
	virtual HRESULT __safecall CloseScope(int EndOffset) = 0 ;
	virtual HRESULT __safecall SetScopeRange(int scopeID, int StartOffset, int EndOffset) = 0 ;
	virtual HRESULT __safecall DefineLocalVariable(const System::WideString name, Activex::TOleEnum Attributes, Activex::PSafeArray signature, Activex::TOleEnum addrKind, int addr1, int addr2, int addr3, int StartOffset, int EndOffset) = 0 ;
	virtual HRESULT __safecall DefineParameter(const System::WideString name, Activex::TOleEnum Attributes, int sequence, Activex::TOleEnum addrKind, int addr1, int addr2, int addr3) = 0 ;
	virtual HRESULT __safecall DefineField(SymbolToken parent, const System::WideString name, Activex::TOleEnum Attributes, Activex::PSafeArray signature, Activex::TOleEnum addrKind, int addr1, int addr2, int addr3) = 0 ;
	virtual HRESULT __safecall DefineGlobalVariable(const System::WideString name, Activex::TOleEnum Attributes, Activex::PSafeArray signature, Activex::TOleEnum addrKind, int addr1, int addr2, int addr3) = 0 ;
	virtual HRESULT __safecall Close(void) = 0 ;
	virtual HRESULT __safecall SetSymAttribute(SymbolToken parent, const System::WideString name, Activex::PSafeArray data) = 0 ;
	virtual HRESULT __safecall OpenNamespace(const System::WideString name) = 0 ;
	virtual HRESULT __safecall CloseNamespace(void) = 0 ;
	virtual HRESULT __safecall UsingNamespace(const System::WideString FullName) = 0 ;
	virtual HRESULT __safecall SetMethodSourceRange(const _di_ISymbolDocumentWriter startDoc, int startLine, int startColumn, const _di_ISymbolDocumentWriter endDoc, int endLine, int endColumn) = 0 ;
	virtual HRESULT __safecall SetUnderlyingWriter(int underlyingWriter) = 0 ;
};

__interface  INTERFACE_UUID("{5141D79C-7B01-37DA-B7E9-53E5A271BAF8}") _SymDocumentType  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{22BB8891-FD21-313D-92E4-8A892DC0B39C}") _SymLanguageType  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{01364E7B-C983-3651-B7D8-FD1B64FC0E00}") _SymLanguageVendor  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{81AA0D59-C3B1-36A3-B2E7-054928FBFC1A}") _AmbiguousMatchException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{05532E88-E0F2-3263-9B57-805AC6B6BB72}") _ModuleResolveEventHandler  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{17156360-2F1A-384A-BC52-FDE93C215C5B}") _Assembly  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_CodeBase(System::WideString &__Get_CodeBase_result) = 0 ;
	virtual HRESULT __safecall Get_EscapedCodeBase(System::WideString &__Get_EscapedCodeBase_result) = 0 ;
	virtual HRESULT __safecall GetName(_di__AssemblyName &__GetName_result) = 0 ;
	virtual HRESULT __safecall GetName_2(System::WordBool copiedName, _di__AssemblyName &__GetName_2_result) = 0 ;
	virtual HRESULT __safecall Get_FullName(System::WideString &__Get_FullName_result) = 0 ;
	virtual HRESULT __safecall Get_EntryPoint(_di__MethodInfo &__Get_EntryPoint_result) = 0 ;
	virtual HRESULT __safecall GetType_2(const System::WideString name, _di__Type &__GetType_2_result) = 0 ;
	virtual HRESULT __safecall GetType_3(const System::WideString name, System::WordBool throwOnError, _di__Type &__GetType_3_result) = 0 ;
	virtual HRESULT __safecall GetExportedTypes(Activex::PSafeArray &__GetExportedTypes_result) = 0 ;
	virtual HRESULT __safecall GetTypes(Activex::PSafeArray &__GetTypes_result) = 0 ;
	virtual HRESULT __safecall GetManifestResourceStream(const _di__Type Type_, const System::WideString name, _di__Stream &__GetManifestResourceStream_result) = 0 ;
	virtual HRESULT __safecall GetManifestResourceStream_2(const System::WideString name, _di__Stream &__GetManifestResourceStream_2_result) = 0 ;
	virtual HRESULT __safecall GetFile(const System::WideString name, _di__FileStream &__GetFile_result) = 0 ;
	virtual HRESULT __safecall GetFiles(Activex::PSafeArray &__GetFiles_result) = 0 ;
	virtual HRESULT __safecall GetFiles_2(System::WordBool getResourceModules, Activex::PSafeArray &__GetFiles_2_result) = 0 ;
	virtual HRESULT __safecall GetManifestResourceNames(Activex::PSafeArray &__GetManifestResourceNames_result) = 0 ;
	virtual HRESULT __safecall GetManifestResourceInfo(const System::WideString resourceName, _di__ManifestResourceInfo &__GetManifestResourceInfo_result) = 0 ;
	virtual HRESULT __safecall Get_Location(System::WideString &__Get_Location_result) = 0 ;
	virtual HRESULT __safecall Get_Evidence(_di__Evidence &__Get_Evidence_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	virtual HRESULT __safecall GetObjectData(const _di__SerializationInfo info, const StreamingContext Context) = 0 ;
	virtual HRESULT __safecall add_ModuleResolve(const _di__ModuleResolveEventHandler value) = 0 ;
	virtual HRESULT __safecall remove_ModuleResolve(const _di__ModuleResolveEventHandler value) = 0 ;
	virtual HRESULT __safecall GetType_4(const System::WideString name, System::WordBool throwOnError, System::WordBool ignoreCase, _di__Type &__GetType_4_result) = 0 ;
	virtual HRESULT __safecall GetSatelliteAssembly(const _di__CultureInfo culture, _di__Assembly &__GetSatelliteAssembly_result) = 0 ;
	virtual HRESULT __safecall GetSatelliteAssembly_2(const _di__CultureInfo culture, const _di__Version Version, _di__Assembly &__GetSatelliteAssembly_2_result) = 0 ;
	virtual HRESULT __safecall LoadModule(const System::WideString moduleName, Activex::PSafeArray rawModule, _di__Module &__LoadModule_result) = 0 ;
	virtual HRESULT __safecall LoadModule_2(const System::WideString moduleName, Activex::PSafeArray rawModule, Activex::PSafeArray rawSymbolStore, _di__Module &__LoadModule_2_result) = 0 ;
	virtual HRESULT __safecall CreateInstance(const System::WideString typeName, System::OleVariant &__CreateInstance_result) = 0 ;
	virtual HRESULT __safecall CreateInstance_2(const System::WideString typeName, System::WordBool ignoreCase, System::OleVariant &__CreateInstance_2_result) = 0 ;
	virtual HRESULT __safecall CreateInstance_3(const System::WideString typeName, System::WordBool ignoreCase, Activex::TOleEnum bindingAttr, const _di__Binder Binder, Activex::PSafeArray args, const _di__CultureInfo culture, Activex::PSafeArray activationAttributes, System::OleVariant &__CreateInstance_3_result) = 0 ;
	virtual HRESULT __safecall GetLoadedModules(Activex::PSafeArray &__GetLoadedModules_result) = 0 ;
	virtual HRESULT __safecall GetLoadedModules_2(System::WordBool getResourceModules, Activex::PSafeArray &__GetLoadedModules_2_result) = 0 ;
	virtual HRESULT __safecall GetModules(Activex::PSafeArray &__GetModules_result) = 0 ;
	virtual HRESULT __safecall GetModules_2(System::WordBool getResourceModules, Activex::PSafeArray &__GetModules_2_result) = 0 ;
	virtual HRESULT __safecall GetModule(const System::WideString name, _di__Module &__GetModule_result) = 0 ;
	virtual HRESULT __safecall GetReferencedAssemblies(Activex::PSafeArray &__GetReferencedAssemblies_result) = 0 ;
	virtual HRESULT __safecall Get_GlobalAssemblyCache(System::WordBool &__Get_GlobalAssemblyCache_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_CodeBase() { System::WideString __r; HRESULT __hr = Get_CodeBase(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString CodeBase = {read=_scw_Get_CodeBase};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_EscapedCodeBase() { System::WideString __r; HRESULT __hr = Get_EscapedCodeBase(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString EscapedCodeBase = {read=_scw_Get_EscapedCodeBase};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_FullName() { System::WideString __r; HRESULT __hr = Get_FullName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString FullName = {read=_scw_Get_FullName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__MethodInfo _scw_Get_EntryPoint() { _di__MethodInfo __r; HRESULT __hr = Get_EntryPoint(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__MethodInfo EntryPoint = {read=_scw_Get_EntryPoint};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Location() { System::WideString __r; HRESULT __hr = Get_Location(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Location = {read=_scw_Get_Location};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Evidence _scw_Get_Evidence() { _di__Evidence __r; HRESULT __hr = Get_Evidence(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Evidence Evidence = {read=_scw_Get_Evidence};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_GlobalAssemblyCache() { System::WordBool __r; HRESULT __hr = Get_GlobalAssemblyCache(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool GlobalAssemblyCache = {read=_scw_Get_GlobalAssemblyCache};
};

__interface  INTERFACE_UUID("{177C4E63-9E0B-354D-838B-B52AA8683EF6}") _AssemblyCultureAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A1693C5C-101F-3557-94DB-C480CEB4C16B}") _AssemblyVersionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A9FCDA18-C237-3C6F-A6EF-749BE22BA2BF}") _AssemblyKeyFileAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{322A304D-11AC-3814-A905-A019F6E3DAE9}") _AssemblyKeyNameAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6CF1C077-C974-38E1-90A4-976E4835E165}") _AssemblyDelaySignAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{57B849AA-D8EF-3EA6-9538-C5B4D498C2F7}") _AssemblyAlgorithmIdAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0ECD8635-F5EB-3E4A-8989-4D684D67C48A}") _AssemblyFlagsAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B101FE3C-4479-311A-A945-1225EE1731E8}") _AssemblyFileVersionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B42B6AAC-317E-34D5-9FA9-093BB4160C50}") _AssemblyName  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FE52F19A-8AA8-309C-BF99-9D0A566FB76A}") _AssemblyNameProxy  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6163F792-3CD6-38F1-B5F7-000B96A5082B}") _AssemblyCopyrightAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{64C26BF9-C9E5-3F66-AD74-BEBAADE36214}") _AssemblyTrademarkAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DE10D587-A188-3DCB-8000-92DFDB9B8021}") _AssemblyProductAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C6802233-EF82-3C91-AD72-B3A5D7230ED5}") _AssemblyCompanyAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6B2C0BC4-DDB7-38EA-8A86-F0B59E192816}") _AssemblyDescriptionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DF44CAD3-CEF2-36A9-B013-383CC03177D7}") _AssemblyTitleAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{746D1D1E-EE37-393B-B6FA-E387D37553AA}") _AssemblyConfigurationAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{04311D35-75EC-347B-BEDF-969487CE4014}") _AssemblyDefaultAliasAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C6F5946C-143A-3747-A7C0-ABFADA6BDEB7}") _AssemblyInformationalVersionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1660EB67-EE41-363E-BEB0-C2DE09214ABF}") _CustomAttributeFormatException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6240837A-707F-3181-8E98-A36AE086766B}") _MethodBase  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_MemberType(Activex::TOleEnum &__Get_MemberType_result) = 0 ;
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_DeclaringType(_di__Type &__Get_DeclaringType_result) = 0 ;
	virtual HRESULT __safecall Get_ReflectedType(_di__Type &__Get_ReflectedType_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	virtual HRESULT __safecall GetParameters(Activex::PSafeArray &__GetParameters_result) = 0 ;
	virtual HRESULT __safecall GetMethodImplementationFlags(Activex::TOleEnum &__GetMethodImplementationFlags_result) = 0 ;
	virtual HRESULT __safecall Get_MethodHandle(RuntimeMethodHandle &__Get_MethodHandle_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(Activex::TOleEnum &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall Get_CallingConvention(Activex::TOleEnum &__Get_CallingConvention_result) = 0 ;
	virtual HRESULT __safecall Invoke_2(const System::OleVariant obj, Activex::TOleEnum invokeAttr, const _di__Binder Binder, Activex::PSafeArray parameters, const _di__CultureInfo culture, System::OleVariant &__Invoke_2_result) = 0 ;
	virtual HRESULT __safecall Get_IsPublic(System::WordBool &__Get_IsPublic_result) = 0 ;
	virtual HRESULT __safecall Get_IsPrivate(System::WordBool &__Get_IsPrivate_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamily(System::WordBool &__Get_IsFamily_result) = 0 ;
	virtual HRESULT __safecall Get_IsAssembly(System::WordBool &__Get_IsAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamilyAndAssembly(System::WordBool &__Get_IsFamilyAndAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamilyOrAssembly(System::WordBool &__Get_IsFamilyOrAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsStatic(System::WordBool &__Get_IsStatic_result) = 0 ;
	virtual HRESULT __safecall Get_IsFinal(System::WordBool &__Get_IsFinal_result) = 0 ;
	virtual HRESULT __safecall Get_IsVirtual(System::WordBool &__Get_IsVirtual_result) = 0 ;
	virtual HRESULT __safecall Get_IsHideBySig(System::WordBool &__Get_IsHideBySig_result) = 0 ;
	virtual HRESULT __safecall Get_IsAbstract(System::WordBool &__Get_IsAbstract_result) = 0 ;
	virtual HRESULT __safecall Get_IsSpecialName(System::WordBool &__Get_IsSpecialName_result) = 0 ;
	virtual HRESULT __safecall Get_IsConstructor(System::WordBool &__Get_IsConstructor_result) = 0 ;
	virtual HRESULT __safecall Invoke_3(const System::OleVariant obj, Activex::PSafeArray parameters, System::OleVariant &__Invoke_3_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_MemberType() { Activex::TOleEnum __r; HRESULT __hr = Get_MemberType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum MemberType = {read=_scw_Get_MemberType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_DeclaringType() { _di__Type __r; HRESULT __hr = Get_DeclaringType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type DeclaringType = {read=_scw_Get_DeclaringType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ReflectedType() { _di__Type __r; HRESULT __hr = Get_ReflectedType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ReflectedType = {read=_scw_Get_ReflectedType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline RuntimeMethodHandle _scw_Get_MethodHandle() { RuntimeMethodHandle __r; HRESULT __hr = Get_MethodHandle(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property RuntimeMethodHandle MethodHandle = {read=_scw_Get_MethodHandle};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_Attributes() { Activex::TOleEnum __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum Attributes = {read=_scw_Get_Attributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_CallingConvention() { Activex::TOleEnum __r; HRESULT __hr = Get_CallingConvention(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum CallingConvention = {read=_scw_Get_CallingConvention};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPublic() { System::WordBool __r; HRESULT __hr = Get_IsPublic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPublic = {read=_scw_Get_IsPublic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPrivate() { System::WordBool __r; HRESULT __hr = Get_IsPrivate(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPrivate = {read=_scw_Get_IsPrivate};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamily() { System::WordBool __r; HRESULT __hr = Get_IsFamily(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamily = {read=_scw_Get_IsFamily};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAssembly() { System::WordBool __r; HRESULT __hr = Get_IsAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAssembly = {read=_scw_Get_IsAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamilyAndAssembly() { System::WordBool __r; HRESULT __hr = Get_IsFamilyAndAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamilyAndAssembly = {read=_scw_Get_IsFamilyAndAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamilyOrAssembly() { System::WordBool __r; HRESULT __hr = Get_IsFamilyOrAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamilyOrAssembly = {read=_scw_Get_IsFamilyOrAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsStatic() { System::WordBool __r; HRESULT __hr = Get_IsStatic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsStatic = {read=_scw_Get_IsStatic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFinal() { System::WordBool __r; HRESULT __hr = Get_IsFinal(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFinal = {read=_scw_Get_IsFinal};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsVirtual() { System::WordBool __r; HRESULT __hr = Get_IsVirtual(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsVirtual = {read=_scw_Get_IsVirtual};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsHideBySig() { System::WordBool __r; HRESULT __hr = Get_IsHideBySig(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsHideBySig = {read=_scw_Get_IsHideBySig};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAbstract() { System::WordBool __r; HRESULT __hr = Get_IsAbstract(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAbstract = {read=_scw_Get_IsAbstract};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSpecialName() { System::WordBool __r; HRESULT __hr = Get_IsSpecialName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSpecialName = {read=_scw_Get_IsSpecialName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsConstructor() { System::WordBool __r; HRESULT __hr = Get_IsConstructor(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsConstructor = {read=_scw_Get_IsConstructor};
};

__interface  INTERFACE_UUID("{E9A19478-9646-3679-9B10-8411AE1FD57D}") _ConstructorInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_MemberType(Activex::TOleEnum &__Get_MemberType_result) = 0 ;
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_DeclaringType(_di__Type &__Get_DeclaringType_result) = 0 ;
	virtual HRESULT __safecall Get_ReflectedType(_di__Type &__Get_ReflectedType_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	virtual HRESULT __safecall GetParameters(Activex::PSafeArray &__GetParameters_result) = 0 ;
	virtual HRESULT __safecall GetMethodImplementationFlags(Activex::TOleEnum &__GetMethodImplementationFlags_result) = 0 ;
	virtual HRESULT __safecall Get_MethodHandle(RuntimeMethodHandle &__Get_MethodHandle_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(Activex::TOleEnum &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall Get_CallingConvention(Activex::TOleEnum &__Get_CallingConvention_result) = 0 ;
	virtual HRESULT __safecall Invoke_2(const System::OleVariant obj, Activex::TOleEnum invokeAttr, const _di__Binder Binder, Activex::PSafeArray parameters, const _di__CultureInfo culture, System::OleVariant &__Invoke_2_result) = 0 ;
	virtual HRESULT __safecall Get_IsPublic(System::WordBool &__Get_IsPublic_result) = 0 ;
	virtual HRESULT __safecall Get_IsPrivate(System::WordBool &__Get_IsPrivate_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamily(System::WordBool &__Get_IsFamily_result) = 0 ;
	virtual HRESULT __safecall Get_IsAssembly(System::WordBool &__Get_IsAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamilyAndAssembly(System::WordBool &__Get_IsFamilyAndAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamilyOrAssembly(System::WordBool &__Get_IsFamilyOrAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsStatic(System::WordBool &__Get_IsStatic_result) = 0 ;
	virtual HRESULT __safecall Get_IsFinal(System::WordBool &__Get_IsFinal_result) = 0 ;
	virtual HRESULT __safecall Get_IsVirtual(System::WordBool &__Get_IsVirtual_result) = 0 ;
	virtual HRESULT __safecall Get_IsHideBySig(System::WordBool &__Get_IsHideBySig_result) = 0 ;
	virtual HRESULT __safecall Get_IsAbstract(System::WordBool &__Get_IsAbstract_result) = 0 ;
	virtual HRESULT __safecall Get_IsSpecialName(System::WordBool &__Get_IsSpecialName_result) = 0 ;
	virtual HRESULT __safecall Get_IsConstructor(System::WordBool &__Get_IsConstructor_result) = 0 ;
	virtual HRESULT __safecall Invoke_3(const System::OleVariant obj, Activex::PSafeArray parameters, System::OleVariant &__Invoke_3_result) = 0 ;
	virtual HRESULT __safecall Invoke_4(Activex::TOleEnum invokeAttr, const _di__Binder Binder, Activex::PSafeArray parameters, const _di__CultureInfo culture, System::OleVariant &__Invoke_4_result) = 0 ;
	virtual HRESULT __safecall Invoke_5(Activex::PSafeArray parameters, System::OleVariant &__Invoke_5_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_MemberType() { Activex::TOleEnum __r; HRESULT __hr = Get_MemberType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum MemberType = {read=_scw_Get_MemberType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_DeclaringType() { _di__Type __r; HRESULT __hr = Get_DeclaringType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type DeclaringType = {read=_scw_Get_DeclaringType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ReflectedType() { _di__Type __r; HRESULT __hr = Get_ReflectedType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ReflectedType = {read=_scw_Get_ReflectedType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline RuntimeMethodHandle _scw_Get_MethodHandle() { RuntimeMethodHandle __r; HRESULT __hr = Get_MethodHandle(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property RuntimeMethodHandle MethodHandle = {read=_scw_Get_MethodHandle};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_Attributes() { Activex::TOleEnum __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum Attributes = {read=_scw_Get_Attributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_CallingConvention() { Activex::TOleEnum __r; HRESULT __hr = Get_CallingConvention(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum CallingConvention = {read=_scw_Get_CallingConvention};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPublic() { System::WordBool __r; HRESULT __hr = Get_IsPublic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPublic = {read=_scw_Get_IsPublic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPrivate() { System::WordBool __r; HRESULT __hr = Get_IsPrivate(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPrivate = {read=_scw_Get_IsPrivate};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamily() { System::WordBool __r; HRESULT __hr = Get_IsFamily(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamily = {read=_scw_Get_IsFamily};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAssembly() { System::WordBool __r; HRESULT __hr = Get_IsAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAssembly = {read=_scw_Get_IsAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamilyAndAssembly() { System::WordBool __r; HRESULT __hr = Get_IsFamilyAndAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamilyAndAssembly = {read=_scw_Get_IsFamilyAndAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamilyOrAssembly() { System::WordBool __r; HRESULT __hr = Get_IsFamilyOrAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamilyOrAssembly = {read=_scw_Get_IsFamilyOrAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsStatic() { System::WordBool __r; HRESULT __hr = Get_IsStatic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsStatic = {read=_scw_Get_IsStatic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFinal() { System::WordBool __r; HRESULT __hr = Get_IsFinal(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFinal = {read=_scw_Get_IsFinal};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsVirtual() { System::WordBool __r; HRESULT __hr = Get_IsVirtual(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsVirtual = {read=_scw_Get_IsVirtual};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsHideBySig() { System::WordBool __r; HRESULT __hr = Get_IsHideBySig(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsHideBySig = {read=_scw_Get_IsHideBySig};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAbstract() { System::WordBool __r; HRESULT __hr = Get_IsAbstract(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAbstract = {read=_scw_Get_IsAbstract};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSpecialName() { System::WordBool __r; HRESULT __hr = Get_IsSpecialName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSpecialName = {read=_scw_Get_IsSpecialName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsConstructor() { System::WordBool __r; HRESULT __hr = Get_IsConstructor(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsConstructor = {read=_scw_Get_IsConstructor};
};

__interface  INTERFACE_UUID("{C462B072-FE6E-3BDC-9FAB-4CDBFCBCD124}") _DefaultMemberAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9DE59C64-D889-35A1-B897-587D74469E5B}") _EventInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_MemberType(Activex::TOleEnum &__Get_MemberType_result) = 0 ;
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_DeclaringType(_di__Type &__Get_DeclaringType_result) = 0 ;
	virtual HRESULT __safecall Get_ReflectedType(_di__Type &__Get_ReflectedType_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	virtual HRESULT __safecall GetAddMethod(System::WordBool nonPublic, _di__MethodInfo &__GetAddMethod_result) = 0 ;
	virtual HRESULT __safecall GetRemoveMethod(System::WordBool nonPublic, _di__MethodInfo &__GetRemoveMethod_result) = 0 ;
	virtual HRESULT __safecall GetRaiseMethod(System::WordBool nonPublic, _di__MethodInfo &__GetRaiseMethod_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(Activex::TOleEnum &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall GetAddMethod_2(_di__MethodInfo &__GetAddMethod_2_result) = 0 ;
	virtual HRESULT __safecall GetRemoveMethod_2(_di__MethodInfo &__GetRemoveMethod_2_result) = 0 ;
	virtual HRESULT __safecall GetRaiseMethod_2(_di__MethodInfo &__GetRaiseMethod_2_result) = 0 ;
	virtual HRESULT __safecall AddEventHandler(const System::OleVariant Target, const _di__Delegate handler) = 0 ;
	virtual HRESULT __safecall RemoveEventHandler(const System::OleVariant Target, const _di__Delegate handler) = 0 ;
	virtual HRESULT __safecall Get_EventHandlerType(_di__Type &__Get_EventHandlerType_result) = 0 ;
	virtual HRESULT __safecall Get_IsSpecialName(System::WordBool &__Get_IsSpecialName_result) = 0 ;
	virtual HRESULT __safecall Get_IsMulticast(System::WordBool &__Get_IsMulticast_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_MemberType() { Activex::TOleEnum __r; HRESULT __hr = Get_MemberType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum MemberType = {read=_scw_Get_MemberType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_DeclaringType() { _di__Type __r; HRESULT __hr = Get_DeclaringType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type DeclaringType = {read=_scw_Get_DeclaringType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ReflectedType() { _di__Type __r; HRESULT __hr = Get_ReflectedType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ReflectedType = {read=_scw_Get_ReflectedType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_Attributes() { Activex::TOleEnum __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum Attributes = {read=_scw_Get_Attributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_EventHandlerType() { _di__Type __r; HRESULT __hr = Get_EventHandlerType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type EventHandlerType = {read=_scw_Get_EventHandlerType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSpecialName() { System::WordBool __r; HRESULT __hr = Get_IsSpecialName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSpecialName = {read=_scw_Get_IsSpecialName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsMulticast() { System::WordBool __r; HRESULT __hr = Get_IsMulticast(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsMulticast = {read=_scw_Get_IsMulticast};
};

__interface  INTERFACE_UUID("{8A7C1442-A9FB-366B-80D8-4939FFA6DBE0}") _FieldInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_MemberType(Activex::TOleEnum &__Get_MemberType_result) = 0 ;
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_DeclaringType(_di__Type &__Get_DeclaringType_result) = 0 ;
	virtual HRESULT __safecall Get_ReflectedType(_di__Type &__Get_ReflectedType_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	virtual HRESULT __safecall Get_FieldType(_di__Type &__Get_FieldType_result) = 0 ;
	virtual HRESULT __safecall GetValue(const System::OleVariant obj, System::OleVariant &__GetValue_result) = 0 ;
	virtual HRESULT __safecall GetValueDirect(const System::OleVariant obj, System::OleVariant &__GetValueDirect_result) = 0 ;
	virtual HRESULT __safecall SetValue(const System::OleVariant obj, const System::OleVariant value, Activex::TOleEnum invokeAttr, const _di__Binder Binder, const _di__CultureInfo culture) = 0 ;
	virtual HRESULT __safecall SetValueDirect(const System::OleVariant obj, const System::OleVariant value) = 0 ;
	virtual HRESULT __safecall Get_FieldHandle(RuntimeFieldHandle &__Get_FieldHandle_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(Activex::TOleEnum &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall SetValue_2(const System::OleVariant obj, const System::OleVariant value) = 0 ;
	virtual HRESULT __safecall Get_IsPublic(System::WordBool &__Get_IsPublic_result) = 0 ;
	virtual HRESULT __safecall Get_IsPrivate(System::WordBool &__Get_IsPrivate_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamily(System::WordBool &__Get_IsFamily_result) = 0 ;
	virtual HRESULT __safecall Get_IsAssembly(System::WordBool &__Get_IsAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamilyAndAssembly(System::WordBool &__Get_IsFamilyAndAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamilyOrAssembly(System::WordBool &__Get_IsFamilyOrAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsStatic(System::WordBool &__Get_IsStatic_result) = 0 ;
	virtual HRESULT __safecall Get_IsInitOnly(System::WordBool &__Get_IsInitOnly_result) = 0 ;
	virtual HRESULT __safecall Get_IsLiteral(System::WordBool &__Get_IsLiteral_result) = 0 ;
	virtual HRESULT __safecall Get_IsNotSerialized(System::WordBool &__Get_IsNotSerialized_result) = 0 ;
	virtual HRESULT __safecall Get_IsSpecialName(System::WordBool &__Get_IsSpecialName_result) = 0 ;
	virtual HRESULT __safecall Get_IsPinvokeImpl(System::WordBool &__Get_IsPinvokeImpl_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_MemberType() { Activex::TOleEnum __r; HRESULT __hr = Get_MemberType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum MemberType = {read=_scw_Get_MemberType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_DeclaringType() { _di__Type __r; HRESULT __hr = Get_DeclaringType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type DeclaringType = {read=_scw_Get_DeclaringType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ReflectedType() { _di__Type __r; HRESULT __hr = Get_ReflectedType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ReflectedType = {read=_scw_Get_ReflectedType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_FieldType() { _di__Type __r; HRESULT __hr = Get_FieldType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type FieldType = {read=_scw_Get_FieldType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline RuntimeFieldHandle _scw_Get_FieldHandle() { RuntimeFieldHandle __r; HRESULT __hr = Get_FieldHandle(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property RuntimeFieldHandle FieldHandle = {read=_scw_Get_FieldHandle};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_Attributes() { Activex::TOleEnum __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum Attributes = {read=_scw_Get_Attributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPublic() { System::WordBool __r; HRESULT __hr = Get_IsPublic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPublic = {read=_scw_Get_IsPublic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPrivate() { System::WordBool __r; HRESULT __hr = Get_IsPrivate(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPrivate = {read=_scw_Get_IsPrivate};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamily() { System::WordBool __r; HRESULT __hr = Get_IsFamily(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamily = {read=_scw_Get_IsFamily};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAssembly() { System::WordBool __r; HRESULT __hr = Get_IsAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAssembly = {read=_scw_Get_IsAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamilyAndAssembly() { System::WordBool __r; HRESULT __hr = Get_IsFamilyAndAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamilyAndAssembly = {read=_scw_Get_IsFamilyAndAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamilyOrAssembly() { System::WordBool __r; HRESULT __hr = Get_IsFamilyOrAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamilyOrAssembly = {read=_scw_Get_IsFamilyOrAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsStatic() { System::WordBool __r; HRESULT __hr = Get_IsStatic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsStatic = {read=_scw_Get_IsStatic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsInitOnly() { System::WordBool __r; HRESULT __hr = Get_IsInitOnly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsInitOnly = {read=_scw_Get_IsInitOnly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsLiteral() { System::WordBool __r; HRESULT __hr = Get_IsLiteral(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsLiteral = {read=_scw_Get_IsLiteral};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsNotSerialized() { System::WordBool __r; HRESULT __hr = Get_IsNotSerialized(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsNotSerialized = {read=_scw_Get_IsNotSerialized};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSpecialName() { System::WordBool __r; HRESULT __hr = Get_IsSpecialName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSpecialName = {read=_scw_Get_IsSpecialName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPinvokeImpl() { System::WordBool __r; HRESULT __hr = Get_IsPinvokeImpl(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPinvokeImpl = {read=_scw_Get_IsPinvokeImpl};
};

__interface  INTERFACE_UUID("{E6DF0AE7-BA15-3F80-8AFA-27773AE414FC}") _InvalidFilterCriteriaException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3188878C-DEB3-3558-80E8-84E9ED95F92C}") _ManifestResourceInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FAE5D9B7-40C1-3DE1-BE06-A91C9DA1BA9F}") _MemberFilter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FFCC1B5D-ECB8-38DD-9B01-3DC8ABC2AA5F}") _MethodInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_MemberType(Activex::TOleEnum &__Get_MemberType_result) = 0 ;
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_DeclaringType(_di__Type &__Get_DeclaringType_result) = 0 ;
	virtual HRESULT __safecall Get_ReflectedType(_di__Type &__Get_ReflectedType_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	virtual HRESULT __safecall GetParameters(Activex::PSafeArray &__GetParameters_result) = 0 ;
	virtual HRESULT __safecall GetMethodImplementationFlags(Activex::TOleEnum &__GetMethodImplementationFlags_result) = 0 ;
	virtual HRESULT __safecall Get_MethodHandle(RuntimeMethodHandle &__Get_MethodHandle_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(Activex::TOleEnum &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall Get_CallingConvention(Activex::TOleEnum &__Get_CallingConvention_result) = 0 ;
	virtual HRESULT __safecall Invoke_2(const System::OleVariant obj, Activex::TOleEnum invokeAttr, const _di__Binder Binder, Activex::PSafeArray parameters, const _di__CultureInfo culture, System::OleVariant &__Invoke_2_result) = 0 ;
	virtual HRESULT __safecall Get_IsPublic(System::WordBool &__Get_IsPublic_result) = 0 ;
	virtual HRESULT __safecall Get_IsPrivate(System::WordBool &__Get_IsPrivate_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamily(System::WordBool &__Get_IsFamily_result) = 0 ;
	virtual HRESULT __safecall Get_IsAssembly(System::WordBool &__Get_IsAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamilyAndAssembly(System::WordBool &__Get_IsFamilyAndAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsFamilyOrAssembly(System::WordBool &__Get_IsFamilyOrAssembly_result) = 0 ;
	virtual HRESULT __safecall Get_IsStatic(System::WordBool &__Get_IsStatic_result) = 0 ;
	virtual HRESULT __safecall Get_IsFinal(System::WordBool &__Get_IsFinal_result) = 0 ;
	virtual HRESULT __safecall Get_IsVirtual(System::WordBool &__Get_IsVirtual_result) = 0 ;
	virtual HRESULT __safecall Get_IsHideBySig(System::WordBool &__Get_IsHideBySig_result) = 0 ;
	virtual HRESULT __safecall Get_IsAbstract(System::WordBool &__Get_IsAbstract_result) = 0 ;
	virtual HRESULT __safecall Get_IsSpecialName(System::WordBool &__Get_IsSpecialName_result) = 0 ;
	virtual HRESULT __safecall Get_IsConstructor(System::WordBool &__Get_IsConstructor_result) = 0 ;
	virtual HRESULT __safecall Invoke_3(const System::OleVariant obj, Activex::PSafeArray parameters, System::OleVariant &__Invoke_3_result) = 0 ;
	virtual HRESULT __safecall Get_returnType(_di__Type &__Get_returnType_result) = 0 ;
	virtual HRESULT __safecall Get_ReturnTypeCustomAttributes(_di_ICustomAttributeProvider &__Get_ReturnTypeCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetBaseDefinition(_di__MethodInfo &__GetBaseDefinition_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_MemberType() { Activex::TOleEnum __r; HRESULT __hr = Get_MemberType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum MemberType = {read=_scw_Get_MemberType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_DeclaringType() { _di__Type __r; HRESULT __hr = Get_DeclaringType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type DeclaringType = {read=_scw_Get_DeclaringType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ReflectedType() { _di__Type __r; HRESULT __hr = Get_ReflectedType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ReflectedType = {read=_scw_Get_ReflectedType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline RuntimeMethodHandle _scw_Get_MethodHandle() { RuntimeMethodHandle __r; HRESULT __hr = Get_MethodHandle(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property RuntimeMethodHandle MethodHandle = {read=_scw_Get_MethodHandle};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_Attributes() { Activex::TOleEnum __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum Attributes = {read=_scw_Get_Attributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_CallingConvention() { Activex::TOleEnum __r; HRESULT __hr = Get_CallingConvention(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum CallingConvention = {read=_scw_Get_CallingConvention};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPublic() { System::WordBool __r; HRESULT __hr = Get_IsPublic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPublic = {read=_scw_Get_IsPublic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsPrivate() { System::WordBool __r; HRESULT __hr = Get_IsPrivate(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsPrivate = {read=_scw_Get_IsPrivate};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamily() { System::WordBool __r; HRESULT __hr = Get_IsFamily(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamily = {read=_scw_Get_IsFamily};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAssembly() { System::WordBool __r; HRESULT __hr = Get_IsAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAssembly = {read=_scw_Get_IsAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamilyAndAssembly() { System::WordBool __r; HRESULT __hr = Get_IsFamilyAndAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamilyAndAssembly = {read=_scw_Get_IsFamilyAndAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFamilyOrAssembly() { System::WordBool __r; HRESULT __hr = Get_IsFamilyOrAssembly(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFamilyOrAssembly = {read=_scw_Get_IsFamilyOrAssembly};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsStatic() { System::WordBool __r; HRESULT __hr = Get_IsStatic(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsStatic = {read=_scw_Get_IsStatic};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsFinal() { System::WordBool __r; HRESULT __hr = Get_IsFinal(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsFinal = {read=_scw_Get_IsFinal};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsVirtual() { System::WordBool __r; HRESULT __hr = Get_IsVirtual(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsVirtual = {read=_scw_Get_IsVirtual};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsHideBySig() { System::WordBool __r; HRESULT __hr = Get_IsHideBySig(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsHideBySig = {read=_scw_Get_IsHideBySig};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAbstract() { System::WordBool __r; HRESULT __hr = Get_IsAbstract(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAbstract = {read=_scw_Get_IsAbstract};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSpecialName() { System::WordBool __r; HRESULT __hr = Get_IsSpecialName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSpecialName = {read=_scw_Get_IsSpecialName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsConstructor() { System::WordBool __r; HRESULT __hr = Get_IsConstructor(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsConstructor = {read=_scw_Get_IsConstructor};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_returnType() { _di__Type __r; HRESULT __hr = Get_returnType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type returnType = {read=_scw_Get_returnType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_ICustomAttributeProvider _scw_Get_ReturnTypeCustomAttributes() { _di_ICustomAttributeProvider __r; HRESULT __hr = Get_ReturnTypeCustomAttributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_ICustomAttributeProvider ReturnTypeCustomAttributes = {read=_scw_Get_ReturnTypeCustomAttributes};
};

__interface  INTERFACE_UUID("{0C48F55D-5240-30C7-A8F1-AF87A640CEFE}") _Missing  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D002E9BA-D9E3-3749-B1D3-D565A08B13E7}") _Module  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{993634C4-E47A-32CC-BE08-85F567DC27D6}") _ParameterInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F0DEAFE9-5EBA-3737-9950-C1795739CDCD}") _Pointer  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F59ED4E4-E68F-3218-BD77-061AA82824BF}") _PropertyInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall Get_MemberType(Activex::TOleEnum &__Get_MemberType_result) = 0 ;
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_DeclaringType(_di__Type &__Get_DeclaringType_result) = 0 ;
	virtual HRESULT __safecall Get_ReflectedType(_di__Type &__Get_ReflectedType_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes(const _di__Type attributeType, System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_result) = 0 ;
	virtual HRESULT __safecall GetCustomAttributes_2(System::WordBool inherit, Activex::PSafeArray &__GetCustomAttributes_2_result) = 0 ;
	virtual HRESULT __safecall IsDefined(const _di__Type attributeType, System::WordBool inherit, System::WordBool &__IsDefined_result) = 0 ;
	virtual HRESULT __safecall Get_PropertyType(_di__Type &__Get_PropertyType_result) = 0 ;
	virtual HRESULT __safecall GetValue(const System::OleVariant obj, Activex::PSafeArray index, System::OleVariant &__GetValue_result) = 0 ;
	virtual HRESULT __safecall GetValue_2(const System::OleVariant obj, Activex::TOleEnum invokeAttr, const _di__Binder Binder, Activex::PSafeArray index, const _di__CultureInfo culture, System::OleVariant &__GetValue_2_result) = 0 ;
	virtual HRESULT __safecall SetValue(const System::OleVariant obj, const System::OleVariant value, Activex::PSafeArray index) = 0 ;
	virtual HRESULT __safecall SetValue_2(const System::OleVariant obj, const System::OleVariant value, Activex::TOleEnum invokeAttr, const _di__Binder Binder, Activex::PSafeArray index, const _di__CultureInfo culture) = 0 ;
	virtual HRESULT __safecall GetAccessors(System::WordBool nonPublic, Activex::PSafeArray &__GetAccessors_result) = 0 ;
	virtual HRESULT __safecall GetGetMethod(System::WordBool nonPublic, _di__MethodInfo &__GetGetMethod_result) = 0 ;
	virtual HRESULT __safecall GetSetMethod(System::WordBool nonPublic, _di__MethodInfo &__GetSetMethod_result) = 0 ;
	virtual HRESULT __safecall GetIndexParameters(Activex::PSafeArray &__GetIndexParameters_result) = 0 ;
	virtual HRESULT __safecall Get_Attributes(Activex::TOleEnum &__Get_Attributes_result) = 0 ;
	virtual HRESULT __safecall Get_CanRead(System::WordBool &__Get_CanRead_result) = 0 ;
	virtual HRESULT __safecall Get_CanWrite(System::WordBool &__Get_CanWrite_result) = 0 ;
	virtual HRESULT __safecall GetAccessors_2(Activex::PSafeArray &__GetAccessors_2_result) = 0 ;
	virtual HRESULT __safecall GetGetMethod_2(_di__MethodInfo &__GetGetMethod_2_result) = 0 ;
	virtual HRESULT __safecall GetSetMethod_2(_di__MethodInfo &__GetSetMethod_2_result) = 0 ;
	virtual HRESULT __safecall Get_IsSpecialName(System::WordBool &__Get_IsSpecialName_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_MemberType() { Activex::TOleEnum __r; HRESULT __hr = Get_MemberType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum MemberType = {read=_scw_Get_MemberType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_DeclaringType() { _di__Type __r; HRESULT __hr = Get_DeclaringType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type DeclaringType = {read=_scw_Get_DeclaringType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ReflectedType() { _di__Type __r; HRESULT __hr = Get_ReflectedType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ReflectedType = {read=_scw_Get_ReflectedType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_PropertyType() { _di__Type __r; HRESULT __hr = Get_PropertyType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type PropertyType = {read=_scw_Get_PropertyType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_Attributes() { Activex::TOleEnum __r; HRESULT __hr = Get_Attributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum Attributes = {read=_scw_Get_Attributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_CanRead() { System::WordBool __r; HRESULT __hr = Get_CanRead(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool CanRead = {read=_scw_Get_CanRead};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_CanWrite() { System::WordBool __r; HRESULT __hr = Get_CanWrite(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool CanWrite = {read=_scw_Get_CanWrite};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsSpecialName() { System::WordBool __r; HRESULT __hr = Get_IsSpecialName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsSpecialName = {read=_scw_Get_IsSpecialName};
};

__interface  INTERFACE_UUID("{22C26A41-5FA3-34E3-A76F-BA480252D8EC}") _ReflectionTypeLoadException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FC4963CB-E52B-32D8-A418-D058FA51A1FA}") _StrongNameKeyPair  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{98B1524D-DA12-3C4B-8A69-7539A6DEC4FA}") _TargetException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A90106ED-9099-3329-8A5A-2044B3D8552B}") _TargetInvocationException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6032B3CD-9BED-351C-A145-9D500B0F636F}") _TargetParameterCountException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{34E00EF9-83E2-3BBC-B6AF-4CAE703838BD}") _TypeDelegator  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E1817846-3745-3C97-B4A6-EE20A1641B29}") _TypeFilter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FD302D86-240A-3694-A31F-9EF59E6E41BC}") _UnmanagedMarshal  : public IDispatch 
{
	
};

__interface IFormatter;
typedef System::DelphiInterface<IFormatter> _di_IFormatter;
__interface ISurrogateSelector;
typedef System::DelphiInterface<ISurrogateSelector> _di_ISurrogateSelector;
__interface  INTERFACE_UUID("{93D7A8C5-D2EB-319B-A374-A65D321F2AA9}") IFormatter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Deserialize(const _di__Stream serializationStream, System::OleVariant &__Deserialize_result) = 0 ;
	virtual HRESULT __safecall Serialize(const _di__Stream serializationStream, const System::OleVariant graph) = 0 ;
	virtual HRESULT __safecall Get_SurrogateSelector(_di_ISurrogateSelector &__Get_SurrogateSelector_result) = 0 ;
	virtual HRESULT __safecall _Set_SurrogateSelector(const _di_ISurrogateSelector pRetVal) = 0 ;
	virtual HRESULT __safecall Get_Binder(_di__SerializationBinder &__Get_Binder_result) = 0 ;
	virtual HRESULT __safecall _Set_Binder(const _di__SerializationBinder pRetVal) = 0 ;
	virtual HRESULT __safecall Get_Context(StreamingContext &__Get_Context_result) = 0 ;
	virtual HRESULT __safecall Set_Context(const StreamingContext pRetVal) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_ISurrogateSelector _scw_Get_SurrogateSelector() { _di_ISurrogateSelector __r; HRESULT __hr = Get_SurrogateSelector(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_ISurrogateSelector SurrogateSelector = {read=_scw_Get_SurrogateSelector};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__SerializationBinder _scw_Get_Binder() { _di__SerializationBinder __r; HRESULT __hr = Get_Binder(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__SerializationBinder Binder = {read=_scw_Get_Binder};
	#pragma option push -w-inl
	/* safecall wrapper */ inline StreamingContext _scw_Get_Context() { StreamingContext __r; HRESULT __hr = Get_Context(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property StreamingContext Context = {read=_scw_Get_Context};
};

__interface  INTERFACE_UUID("{D9BD3C8D-9395-3657-B6EE-D1B509C38B70}") _Formatter  : public IDispatch 
{
	
};

__interface IFormatterConverter;
typedef System::DelphiInterface<IFormatterConverter> _di_IFormatterConverter;
__interface  INTERFACE_UUID("{F4F5C303-FAD3-3D0C-A4DF-BB82B5EE308F}") IFormatterConverter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Convert(const System::OleVariant value, const _di__Type Type_, System::OleVariant &__Convert_result) = 0 ;
	virtual HRESULT __safecall Convert_2(const System::OleVariant value, Activex::TOleEnum TypeCode, System::OleVariant &__Convert_2_result) = 0 ;
	virtual HRESULT __safecall ToBoolean(const System::OleVariant value, System::WordBool &__ToBoolean_result) = 0 ;
	virtual HRESULT __safecall ToChar(const System::OleVariant value, System::Word &__ToChar_result) = 0 ;
	virtual HRESULT __safecall ToSByte(const System::OleVariant value, System::ShortInt &__ToSByte_result) = 0 ;
	virtual HRESULT __safecall ToByte(const System::OleVariant value, System::Byte &__ToByte_result) = 0 ;
	virtual HRESULT __safecall ToInt16(const System::OleVariant value, short &__ToInt16_result) = 0 ;
	virtual HRESULT __safecall ToUInt16(const System::OleVariant value, System::Word &__ToUInt16_result) = 0 ;
	virtual HRESULT __safecall ToInt32(const System::OleVariant value, int &__ToInt32_result) = 0 ;
	virtual HRESULT __safecall ToUInt32(const System::OleVariant value, unsigned &__ToUInt32_result) = 0 ;
	virtual HRESULT __safecall ToInt64(const System::OleVariant value, __int64 &__ToInt64_result) = 0 ;
	virtual HRESULT __safecall ToUInt64(const System::OleVariant value, unsigned __int64 &__ToUInt64_result) = 0 ;
	virtual HRESULT __safecall ToSingle(const System::OleVariant value, float &__ToSingle_result) = 0 ;
	virtual HRESULT __safecall ToDouble(const System::OleVariant value, double &__ToDouble_result) = 0 ;
	virtual HRESULT __safecall ToDecimal(const System::OleVariant value, tagDEC &__ToDecimal_result) = 0 ;
	virtual HRESULT __safecall ToDateTime(const System::OleVariant value, System::TDateTime &__ToDateTime_result) = 0 ;
	virtual HRESULT __safecall Get_ToString(const System::OleVariant value, System::WideString &__Get_ToString_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString(const System::OleVariant value) { System::WideString __r; HRESULT __hr = Get_ToString(value, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString[System::OleVariant value] = {read=_scw_Get_ToString};
};

__interface  INTERFACE_UUID("{3FAA35EE-C867-3E2E-BF48-2DA271F88303}") _FormatterConverter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F859954A-78CF-3D00-86AB-EF661E6A4B8D}") _FormatterServices  : public IDispatch 
{
	
};

__interface ISerializationSurrogate;
typedef System::DelphiInterface<ISerializationSurrogate> _di_ISerializationSurrogate;
__interface  INTERFACE_UUID("{62339172-DBFA-337B-8AC8-053B241E06AB}") ISerializationSurrogate  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetObjectData(const System::OleVariant obj, const _di__SerializationInfo info, const StreamingContext Context) = 0 ;
	virtual HRESULT __safecall SetObjectData(const System::OleVariant obj, const _di__SerializationInfo info, const StreamingContext Context, const _di_ISurrogateSelector selector, System::OleVariant &__SetObjectData_result) = 0 ;
};

__interface  INTERFACE_UUID("{7C66FF18-A1A5-3E19-857B-0E7B6A9E3F38}") ISurrogateSelector  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall ChainSelector(const _di_ISurrogateSelector selector) = 0 ;
	virtual HRESULT __safecall GetSurrogate(const _di__Type Type_, const StreamingContext Context, /* out */ _di_ISurrogateSelector &selector, _di_ISerializationSurrogate &__GetSurrogate_result) = 0 ;
	virtual HRESULT __safecall GetNextSelector(_di_ISurrogateSelector &__GetNextSelector_result) = 0 ;
};

__interface  INTERFACE_UUID("{A30646CC-F710-3BFA-A356-B4C858D4ED8E}") _ObjectIDGenerator  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F28E7D04-3319-3968-8201-C6E55BECD3D4}") _ObjectManager  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{450222D0-87CA-3699-A7B4-D8A0FDB72357}") _SerializationBinder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B58D62CF-B03A-3A14-B0B6-B1E5AD4E4AD5}") _SerializationInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{607056C6-1BCA-36C8-AB87-33B202EBF0D8}") _SerializationInfoEnumerator  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{245FE7FD-E020-3053-B5F6-7467FD2C6883}") _SerializationException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6DE1230E-1F52-3779-9619-F5184103466C}") _SurrogateSelector  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4CCA29E4-584B-3CD0-AD25-855DC5799C16}") _Calendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{505DEFE5-AEFA-3E23-82B0-D5EB085BB840}") _CompareInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{152722C2-F0B1-3D19-ADA8-F40CA5CAECB8}") _CultureInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{015E9F67-337C-398A-A0C1-DA4AF1905571}") _DateTimeFormatInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EFEA8FEB-EE7F-3E48-8A36-6206A6ACBF73}") _DaylightTime  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{677AD8B5-8A0E-3C39-92FB-72FB817CF694}") _GregorianCalendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{96A62D6C-72A9-387A-81FA-E6DD5998CAEE}") _HebrewCalendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{28DDC187-56B2-34CF-A078-48BD1E113D1E}") _HijriCalendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D662AE3F-CEF9-38B4-BB8E-5D8DD1DBF806}") _JapaneseCalendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{36E2DE92-1FB3-3D7D-BA26-9CAD5B98DD52}") _JulianCalendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{48BEA6C4-752E-3974-8CA8-CFB6274E2379}") _KoreanCalendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F9E97E04-4E1E-368F-B6C6-5E96CE4362D6}") _RegionInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F4C70E15-2CA6-3E90-96ED-92E28491F538}") _SortKey  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0A25141F-51B3-3121-AA30-0AF4556A52D9}") _StringInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0C08ED74-0ACF-32A9-99DF-09A9DC4786DD}") _TaiwanCalendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8C248251-3E6C-3151-9F8E-A255FB8D2B12}") _TextElementEnumerator  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DB8DE23F-F264-39AC-B61C-CC1E7EB4A5E6}") _TextInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C70C8AE8-925B-37CE-8944-34F15FF94307}") _ThaiBuddhistCalendar  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{25E47D71-20DD-31BE-B261-7AE76497D6B9}") _NumberFormatInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DDEDB94D-4F3F-35C1-97C9-3F1D87628D9E}") _Encoding  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2ADB0D4A-5976-38E4-852B-C131797430F5}") _System_Text_Decoder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8FD56502-8724-3DF0-A1B5-9D0E8D4E4F78}") _System_Text_Encoder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0CBE0204-12A1-3D40-9D9E-195DE6AAA534}") _ASCIIEncoding  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F7DD3B7F-2B05-3894-8EDA-59CDF9395B6A}") _UnicodeEncoding  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{89B9F00B-AA2A-3A49-91B4-E8D1F1C00E58}") _UTF7Encoding  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{010FC1D0-3EF9-3F3B-AA0A-B78A1FF83A37}") _UTF8Encoding  : public IDispatch 
{
	
};

__interface IResourceReader;
typedef System::DelphiInterface<IResourceReader> _di_IResourceReader;
__interface  INTERFACE_UUID("{8965A22F-FBA8-36AD-8132-70BBD0DA457D}") IResourceReader  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Close(void) = 0 ;
	virtual HRESULT __safecall GetEnumerator(_di_IDictionaryEnumerator &__GetEnumerator_result) = 0 ;
};

__interface IResourceWriter;
typedef System::DelphiInterface<IResourceWriter> _di_IResourceWriter;
__interface  INTERFACE_UUID("{E97AA6E5-595E-31C3-82F0-688FB91954C6}") IResourceWriter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall AddResource(const System::WideString name, const System::WideString value) = 0 ;
	virtual HRESULT __safecall AddResource_2(const System::WideString name, const System::OleVariant value) = 0 ;
	virtual HRESULT __safecall AddResource_3(const System::WideString name, Activex::PSafeArray value) = 0 ;
	virtual HRESULT __safecall Close(void) = 0 ;
	virtual HRESULT __safecall Generate(void) = 0 ;
};

__interface  INTERFACE_UUID("{1A4E1878-FE8C-3F59-B6A9-21AB82BE57E9}") _MissingManifestResourceException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F48DF808-8B7D-3F4E-9159-1DFD60F298D6}") _NeutralResourcesLanguageAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4DE671B7-7C85-37E9-AFF8-1222ABE4883E}") _ResourceManager  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7FBCFDC7-5CEC-3945-8095-DAED61BE5FB1}") _ResourceReader  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{44D5F81A-727C-35AE-8DF8-9FF6722F1C6C}") _ResourceSet  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AF170258-AAC6-3A86-BD34-303E62CED10E}") _ResourceWriter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5CBB1F47-FBA5-33B9-9D4A-57D6E3D133D2}") _SatelliteContractVersionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{23BAE0C0-3A36-32F0-9DAD-0E95ADD67D23}") _Registry  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2EAC6733-8D92-31D9-BE04-DC467EFC3EB1}") _RegistryKey  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{68FD6F14-A7B2-36C8-A724-D01F90D73477}") _X509Certificate  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{09343AC0-D19A-3E62-BC16-0F600F10180A}") _AsymmetricAlgorithm  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B6685CCA-7A49-37D1-A805-3DE829CB8DEB}") _AsymmetricKeyExchangeDeformatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1365B84B-6477-3C40-BE6A-089DC01ECED9}") _AsymmetricKeyExchangeFormatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7CA5FE57-D1AC-3064-BB0B-F450BE40F194}") _AsymmetricSignatureDeformatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5363D066-6295-3618-BE33-3F0B070B7976}") _AsymmetricSignatureFormatter  : public IDispatch 
{
	
};

__interface ICryptoTransform;
typedef System::DelphiInterface<ICryptoTransform> _di_ICryptoTransform;
__interface  INTERFACE_UUID("{8ABAD867-F515-3CF6-BB62-5F0C88B3BB11}") ICryptoTransform  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_InputBlockSize(int &__Get_InputBlockSize_result) = 0 ;
	virtual HRESULT __safecall Get_OutputBlockSize(int &__Get_OutputBlockSize_result) = 0 ;
	virtual HRESULT __safecall Get_CanTransformMultipleBlocks(System::WordBool &__Get_CanTransformMultipleBlocks_result) = 0 ;
	virtual HRESULT __safecall Get_CanReuseTransform(System::WordBool &__Get_CanReuseTransform_result) = 0 ;
	virtual HRESULT __safecall TransformBlock(Activex::PSafeArray inputBuffer, int inputOffset, int inputCount, Activex::PSafeArray outputBuffer, int outputOffset, int &__TransformBlock_result) = 0 ;
	virtual HRESULT __safecall TransformFinalBlock(Activex::PSafeArray inputBuffer, int inputOffset, int inputCount, Activex::PSafeArray &__TransformFinalBlock_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_InputBlockSize() { int __r; HRESULT __hr = Get_InputBlockSize(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int InputBlockSize = {read=_scw_Get_InputBlockSize};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_OutputBlockSize() { int __r; HRESULT __hr = Get_OutputBlockSize(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int OutputBlockSize = {read=_scw_Get_OutputBlockSize};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_CanTransformMultipleBlocks() { System::WordBool __r; HRESULT __hr = Get_CanTransformMultipleBlocks(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool CanTransformMultipleBlocks = {read=_scw_Get_CanTransformMultipleBlocks};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_CanReuseTransform() { System::WordBool __r; HRESULT __hr = Get_CanReuseTransform(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool CanReuseTransform = {read=_scw_Get_CanReuseTransform};
};

__interface  INTERFACE_UUID("{23DED1E1-7D5F-3936-AA4E-18BBCC39B155}") _ToBase64Transform  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FC0717A6-2E86-372F-81F4-B35ED4BDF0DE}") _FromBase64Transform  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8978B0BE-A89E-3FF9-9834-77862CEBFF3D}") _KeySizes  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4311E8F5-B249-3F81-8FF4-CF853D85306D}") _CryptographicException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7FB08423-038F-3ACC-B600-E6D072BAE160}") _CryptographicUnexpectedOperationException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{983B8639-2ED7-364C-9899-682ABB2CE850}") _CryptoAPITransform  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D5331D95-FFF2-358F-AFD5-588F469FF2E4}") _CspParameters  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AB00F3F8-7DDE-3FF5-B805-6C5DBB200549}") _CryptoConfig  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2752364A-924F-3603-8F6F-6586DF98B292}") _Stream  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4134F762-D0EC-3210-93C0-DE4F443D5669}") _CryptoStream  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{05BC0E38-7136-3825-9E34-26C1CF2142C9}") _SymmetricAlgorithm  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C7EF0214-B91C-3799-98DD-C994AABFC741}") _DES  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{65E8495E-5207-3248-9250-0FC849B4F096}") _DESCryptoServiceProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{140EE78F-067F-3765-9258-C3BC72FE976B}") _DeriveBytes  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0EB5B5E0-1BE6-3A5F-87B3-E3323342F44E}") _DSA  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1F38AAFE-7502-332F-971F-C2FC700A1D55}") _DSACryptoServiceProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0E774498-ADE6-3820-B1D5-426B06397BE7}") _DSASignatureDeformatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4B5FC561-5983-31E4-903B-1404231B2C89}") _DSASignatureFormatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{69D3BABA-1C3D-354C-ACFE-F19109EC3896}") _HashAlgorithm  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D182CF91-628C-3FF6-87F0-41BA51CC7433}") _KeyedHashAlgorithm  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{63AC7C37-C51A-3D82-8FDD-2A567039E46D}") _HMACSHA1  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1CAC0BDA-AC58-31BC-B624-63F77D0C3D2F}") _MACTripleDES  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9AA8765E-69A0-30E3-9CDE-EBC70662AE37}") _MD5  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D3F5C812-5867-33C9-8CEE-CB170E8D844A}") _MD5CryptoServiceProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{85601FEE-A79D-3710-AF21-099089EDC0BF}") _MaskGenerationMethod  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3CD62D67-586F-309E-A6D8-1F4BAAC5AC28}") _PasswordDeriveBytes  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{425BFF0D-59E4-36A8-B1FF-1F5D39D698F4}") _PKCS1MaskGenerationMethod  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F7C0C4CC-0D49-31EE-A3D3-B8B551E4928C}") _RC2  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{875715C5-CB64-3920-8156-0EE9CB0E07EA}") _RC2CryptoServiceProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7AE4B03C-414A-36E0-BA68-F9603004C925}") _RandomNumberGenerator  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2C65D4C0-584C-3E4E-8E6D-1AFB112BFF69}") _RNGCryptoServiceProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0B3FB710-A25C-3310-8774-1CF117F95BD4}") _RSA  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BD9DF856-2300-3254-BCF0-679BA03C7A13}") _RSACryptoServiceProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{37625095-7BAA-377D-A0DC-7F465C0167AA}") _RSAOAEPKeyExchangeDeformatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{77A416E7-2AC6-3D0E-98FF-3BA0F586F56F}") _RSAOAEPKeyExchangeFormatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8034AAF4-3666-3B6F-85CF-463F9BFD31A9}") _RSAPKCS1KeyExchangeDeformatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9FF67F8E-A7AA-3BA6-90EE-9D44AF6E2F8C}") _RSAPKCS1KeyExchangeFormatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FC38507E-06A4-3300-8652-8D7B54341F65}") _RSAPKCS1SignatureDeformatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FB7A5FF4-CFA8-3F24-AD5F-D5EB39359707}") _RSAPKCS1SignatureFormatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{21B52A91-856F-373C-AD42-4CF3F1021F5A}") _Rijndael  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{427EA9D3-11D8-3E38-9E05-A4F7FA684183}") _RijndaelManaged  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{48600DD2-0099-337F-92D6-961D1E5010D4}") _SHA1  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A16537BC-1EDF-3516-B75E-CC65CAF873AB}") _SHA1CryptoServiceProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C27990BB-3CFD-3D29-8DC0-BBE5FBADEAFD}") _SHA1Managed  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3B274703-DFAE-3F9C-A1B5-9990DF9D7FA3}") _SHA256  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3D077954-7BCC-325B-9DDA-3B17A03378E0}") _SHA256Managed  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B60AD5D7-2C2E-35B7-8D77-7946156CFE8E}") _SHA384  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DE541460-F838-3698-B2DA-510B09070118}") _SHA384Managed  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{49DD9E4B-84F3-3D6D-91FB-3FEDCEF634C7}") _SHA512  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DC8CE439-7954-36ED-803C-674F72F27249}") _SHA512Managed  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8017B414-4886-33DA-80A3-7865C1350D43}") _SignatureDescription  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C040B889-5278-3132-AFF9-AFA61707A81D}") _TripleDES  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EC69D083-3CD0-3C0C-998C-3B738DB535D5}") _TripleDESCryptoServiceProvider  : public IDispatch 
{
	
};

__interface ISecurityEncodable;
typedef System::DelphiInterface<ISecurityEncodable> _di_ISecurityEncodable;
__interface  INTERFACE_UUID("{FD46BDE5-ACDF-3CA5-B189-F0678387077F}") ISecurityEncodable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall ToXml(_di__SecurityElement &__ToXml_result) = 0 ;
	virtual HRESULT __safecall FromXml(const _di__SecurityElement e) = 0 ;
};

__interface ISecurityPolicyEncodable;
typedef System::DelphiInterface<ISecurityPolicyEncodable> _di_ISecurityPolicyEncodable;
__interface  INTERFACE_UUID("{E6C21BA7-21BB-34E9-8E57-DB66D8CE4A70}") ISecurityPolicyEncodable  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall ToXml(const _di__PolicyLevel level, _di__SecurityElement &__ToXml_result) = 0 ;
	virtual HRESULT __safecall FromXml(const _di__SecurityElement e, const _di__PolicyLevel level) = 0 ;
};

__interface IMembershipCondition;
typedef System::DelphiInterface<IMembershipCondition> _di_IMembershipCondition;
__interface  INTERFACE_UUID("{6844EFF4-4F86-3CA1-A1EA-AAF583A6395E}") IMembershipCondition  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Check(const _di__Evidence Evidence, System::WordBool &__Check_result) = 0 ;
	virtual HRESULT __safecall Copy(_di_IMembershipCondition &__Copy_result) = 0 ;
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
};

__interface  INTERFACE_UUID("{99F01720-3CC2-366D-9AB9-50E36647617F}") _AllMembershipCondition  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9CCC831B-1BA7-34BE-A966-56D5A6DB5AAD}") _ApplicationDirectory  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A02A2B22-1DBA-3F92-9F84-5563182851BB}") _ApplicationDirectoryMembershipCondition  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D7093F61-ED6B-343F-B1E9-02472FCC710E}") _CodeGroup  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A505EDBC-380E-3B23-9E1A-0974D4EF02EF}") _Evidence  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DFAD74DC-8390-32F6-9612-1BD293B233F4}") _FileCodeGroup  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{54B0AFB1-E7D3-3770-BB0E-75A95E8D2656}") _FirstMatchCodeGroup  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7574E121-74A6-3626-B578-0783BADB19D2}") _Hash  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6BA6EA7A-C9FC-3E73-82EC-18F29D83EEFD}") _HashMembershipCondition  : public IDispatch 
{
	
};

__interface IIdentityPermissionFactory;
typedef System::DelphiInterface<IIdentityPermissionFactory> _di_IIdentityPermissionFactory;
__interface IPermission;
typedef System::DelphiInterface<IPermission> _di_IPermission;
__interface  INTERFACE_UUID("{4E95244E-C6FC-3A86-8DB7-1712454DE3B6}") IIdentityPermissionFactory  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall CreateIdentityPermission(const _di__Evidence Evidence, _di_IPermission &__CreateIdentityPermission_result) = 0 ;
};

__interface  INTERFACE_UUID("{A8F69ECA-8C48-3B5E-92A1-654925058059}") _NetCodeGroup  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{34B0417E-E71D-304C-9FAC-689350A1B41C}") _PermissionRequestEvidence  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A9C9F3D9-E153-39B8-A533-B8DF4664407B}") _PolicyException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{44494E35-C370-3014-BC78-0F2ECBF83F53}") _PolicyLevel  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3EEFD1FC-4D8D-3177-99F6-6C19D9E088D3}") _PolicyStatement  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{77CCA693-ABF6-3773-BF58-C0B02701A744}") _Publisher  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3515CF63-9863-3044-B3E1-210E98EFC702}") _PublisherMembershipCondition  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{90C40B4C-B0D0-30F5-B520-FDBA97BC31A0}") _Site  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0A7C3542-8031-3593-872C-78D85D7CC273}") _SiteMembershipCondition  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2A75C1FD-06B0-3CBB-B467-2545D4D6C865}") _StrongName  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{579E93BC-FFAB-3B8D-9181-CE9C22B51915}") _StrongNameMembershipCondition  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D9D822DE-44E5-33CE-A43F-173E475CECB1}") _UnionCodeGroup  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D94ED9BF-C065-3703-81A2-2F76EA8E312F}") _Url  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BB7A158D-DBD9-3E13-B137-8E61E87E1128}") _UrlMembershipCondition  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{742E0C26-0E23-3D20-968C-D221094909AA}") _Zone  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{ADBC3463-0101-3429-A06C-DB2F1DD6B724}") _ZoneMembershipCondition  : public IDispatch 
{
	
};

__interface IIdentity;
typedef System::DelphiInterface<IIdentity> _di_IIdentity;
__interface  INTERFACE_UUID("{F4205A87-4D46-303D-B1D9-5A99F7C90D30}") IIdentity  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall Get_AuthenticationType(System::WideString &__Get_AuthenticationType_result) = 0 ;
	virtual HRESULT __safecall Get_IsAuthenticated(System::WordBool &__Get_IsAuthenticated_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_AuthenticationType() { System::WideString __r; HRESULT __hr = Get_AuthenticationType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString AuthenticationType = {read=_scw_Get_AuthenticationType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_IsAuthenticated() { System::WordBool __r; HRESULT __hr = Get_IsAuthenticated(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool IsAuthenticated = {read=_scw_Get_IsAuthenticated};
};

__interface  INTERFACE_UUID("{9A37D8B2-2256-3FE3-8BF0-4FC421A1244F}") _GenericIdentity  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4283CA6C-D291-3481-83C9-9554481FE888}") IPrincipal  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Identity(_di_IIdentity &__Get_Identity_result) = 0 ;
	virtual HRESULT __safecall IsInRole(const System::WideString role, System::WordBool &__IsInRole_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IIdentity _scw_Get_Identity() { _di_IIdentity __r; HRESULT __hr = Get_Identity(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IIdentity Identity = {read=_scw_Get_Identity};
};

__interface  INTERFACE_UUID("{B4701C26-1509-3726-B2E1-409A636C9B4F}") _GenericPrincipal  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D8CF3F23-1A66-3344-8230-07EB53970B85}") _WindowsIdentity  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{60ECFDDA-650A-324C-B4B3-F4D75B563BB1}") _WindowsImpersonationContext  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6C42BAF9-1893-34FC-B3AF-06931E9B34A3}") _WindowsPrincipal  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BBE41AC5-8692-3427-9AE1-C1058A38D492}") _DispIdAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A2145F38-CAC1-33DD-A318-21948AF6825D}") _InterfaceTypeAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6B6391EE-842F-3E9A-8EEE-F13325E10996}") _ClassInterfaceAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1E7FFFE2-AAD9-34EE-8A9F-3C016B880FF0}") _ComVisibleAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4AB67927-3C86-328A-8186-F85357DD5527}") _LCIDConversionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{51BA926F-AAB5-3945-B8A6-C8F0F4A7D12B}") _ComRegisterFunctionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9F164188-34EB-3F86-9F74-0BBE4155E65E}") _ComUnregisterFunctionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2B9F01DF-5A12-3688-98D6-C34BF5ED1865}") _ProgIdAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3F3311CE-6BAF-3FB0-B855-489AFF740B6E}") _ImportedFromTypeLibAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5778E7C7-2040-330E-B47A-92974DFFCFD4}") _IDispatchImplAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E1984175-55F5-3065-82D8-A683FDFCF0AC}") _ComSourceInterfacesAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FD5B6AAC-FF8C-3472-B894-CD6DFADB6939}") _ComConversionLossAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B5A1729E-B721-3121-A838-FDE43AF13468}") _TypeLibTypeAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3D18A8E2-EEDE-3139-B29D-8CAC057955DF}") _TypeLibFuncAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7B89862A-02A4-3279-8B42-4095FA3A778E}") _TypeLibVarAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D858399F-E19E-3423-A720-AC12ABE2E5E8}") _MarshalAsAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1B093056-5454-386F-8971-BBCBC4E9A8F3}") _ComImportAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{74435DAD-EC55-354B-8F5B-FA70D13B6293}") _GuidAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FDF2A2EE-C882-3198-A48B-E37F0E574DFA}") _PreserveSigAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8474B65C-C39A-3D05-893D-577B9A314615}") _InAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0697FC8C-9B04-3783-95C7-45ECCAC1CA27}") _OutAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0D6BD9AD-198E-3904-AD99-F6F82A2787C4}") _OptionalAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A1A26181-D55E-3EE2-96E6-70B354EF9371}") _DllImportAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{23753322-C7B3-3F9A-AC96-52672C1B1CA9}") _StructLayoutAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C14342B8-BAFD-322A-BB71-62C672DA284E}") _FieldOffsetAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E78785C4-3A73-3C15-9390-618BF3A14719}") _ComAliasNameAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{57B908A8-C082-3581-8A47-6B41B86E8FDC}") _AutomationProxyAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C69E96B2-6161-3621-B165-5805198C6B8D}") _PrimaryInteropAssemblyAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{15D54C00-7C95-38D7-B859-E19346677DCD}") _CoClassAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{76CC0491-9A10-35C0-8A66-7931EC345B7F}") _ComEventInterfaceAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A03B61A4-CA61-3460-8232-2F4EC96AA88F}") _TypeLibVersionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AD419379-2AC8-3588-AB1E-0115413277C4}") _ComCompatibleVersionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{ED47ABE7-C84B-39F9-BE1B-828CFB925AFE}") _BestFitMappingAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A83F04E9-FD28-384A-9DFF-410688AC23AB}") _ExternalException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A28C19DF-B488-34AE-BECC-7DE744D17F7B}") _COMException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7DF6F279-DA62-3C9F-8944-4DD3C0F08170}") _CurrencyWrapper  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{72103C67-D511-329C-B19A-DD5EC3F1206C}") _DispatchWrapper  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F79DB336-06BE-3959-A5AB-58B2AB6C5FD1}") _ErrorWrapper  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{519EB857-7A2D-3A95-A2A3-8BB8ED63D41B}") _ExtensibleClassFactory  : public IDispatch 
{
	
};

__interface ICustomAdapter;
typedef System::DelphiInterface<ICustomAdapter> _di_ICustomAdapter;
__interface  INTERFACE_UUID("{3CC86595-FEB5-3CE9-BA14-D05C8DC3321C}") ICustomAdapter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetUnderlyingObject(System::_di_IInterface &__GetUnderlyingObject_result) = 0 ;
};

__interface ICustomMarshaler;
typedef System::DelphiInterface<ICustomMarshaler> _di_ICustomMarshaler;
__interface  INTERFACE_UUID("{601CD486-04BF-3213-9EA9-06EBE4351D74}") ICustomMarshaler  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall MarshalNativeToManaged(int pNativeData, System::OleVariant &__MarshalNativeToManaged_result) = 0 ;
	virtual HRESULT __safecall MarshalManagedToNative(const System::OleVariant ManagedObj, int &__MarshalManagedToNative_result) = 0 ;
	virtual HRESULT __safecall CleanUpNativeData(int pNativeData) = 0 ;
	virtual HRESULT __safecall CleanUpManagedData(const System::OleVariant ManagedObj) = 0 ;
	virtual HRESULT __safecall GetNativeDataSize(int &__GetNativeDataSize_result) = 0 ;
};

__interface ICustomFactory;
typedef System::DelphiInterface<ICustomFactory> _di_ICustomFactory;
__interface  INTERFACE_UUID("{0CA9008E-EE90-356E-9F6D-B59E6006B9A4}") ICustomFactory  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall CreateInstance(const _di__Type serverType, _di__MarshalByRefObject &__CreateInstance_result) = 0 ;
};

__interface  INTERFACE_UUID("{DE9156B5-5E7A-3041-BF45-A29A6C2CF48A}") _InvalidComObjectException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{76E5DBD6-F960-3C65-8EA6-FC8AD6A67022}") _InvalidOleVariantTypeException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CCBD682C-73A5-4568-B8B0-C7007E11ABA2}") IRegistrationServices  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall RegisterAssembly(const _di__Assembly Assembly, Activex::TOleEnum flags, System::WordBool &__RegisterAssembly_result) = 0 ;
	virtual HRESULT __safecall UnregisterAssembly(const _di__Assembly Assembly, System::WordBool &__UnregisterAssembly_result) = 0 ;
	virtual HRESULT __safecall GetRegistrableTypesInAssembly(const _di__Assembly Assembly, Activex::PSafeArray &__GetRegistrableTypesInAssembly_result) = 0 ;
	virtual HRESULT __safecall GetProgIdForType(const _di__Type Type_, System::WideString &__GetProgIdForType_result) = 0 ;
	virtual HRESULT __safecall RegisterTypeForComClients(const _di__Type Type_, GUID &G) = 0 ;
	virtual HRESULT __safecall GetManagedCategoryGuid(GUID &__GetManagedCategoryGuid_result) = 0 ;
	virtual HRESULT __safecall TypeRequiresRegistration(const _di__Type Type_, System::WordBool &__TypeRequiresRegistration_result) = 0 ;
	virtual HRESULT __safecall TypeRepresentsComType(const _di__Type Type_, System::WordBool &__TypeRepresentsComType_result) = 0 ;
};

__interface ITypeLibImporterNotifySink;
typedef System::DelphiInterface<ITypeLibImporterNotifySink> _di_ITypeLibImporterNotifySink;
__interface  INTERFACE_UUID("{F1C3BF76-C3E4-11D3-88E7-00902754C43A}") ITypeLibImporterNotifySink  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall ReportEvent(Activex::TOleEnum eventKind, int eventCode, const System::WideString eventMsg) = 0 ;
	virtual HRESULT __stdcall ResolveRef(const System::_di_IInterface typeLib, /* out */ _di__Assembly &pRetVal) = 0 ;
};

__interface ITypeLibExporterNotifySink;
typedef System::DelphiInterface<ITypeLibExporterNotifySink> _di_ITypeLibExporterNotifySink;
__interface  INTERFACE_UUID("{F1C3BF77-C3E4-11D3-88E7-00902754C43A}") ITypeLibExporterNotifySink  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall ReportEvent(Activex::TOleEnum eventKind, int eventCode, const System::WideString eventMsg) = 0 ;
	virtual HRESULT __stdcall ResolveRef(const _di__Assembly Assembly, /* out */ System::_di_IInterface &pRetVal) = 0 ;
};

__interface  INTERFACE_UUID("{F1C3BF78-C3E4-11D3-88E7-00902754C43A}") ITypeLibConverter  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall ConvertTypeLibToAssembly(const System::_di_IInterface typeLib, const System::WideString asmFileName, Activex::TOleEnum flags, const _di_ITypeLibImporterNotifySink notifySink, Activex::PSafeArray publicKey, const _di__StrongNameKeyPair keyPair, const System::WideString asmNamespace, const _di__Version asmVersion, /* out */ _di__AssemblyBuilder &pRetVal) = 0 ;
	virtual HRESULT __stdcall ConvertAssemblyToTypeLib(const _di__Assembly Assembly, const System::WideString typeLibName, Activex::TOleEnum flags, const _di_ITypeLibExporterNotifySink notifySink, /* out */ System::_di_IInterface &pRetVal) = 0 ;
	virtual HRESULT __stdcall GetPrimaryInteropAssembly(const GUID G, int major, int minor, int lcid, /* out */ System::WideString &asmName, /* out */ System::WideString &asmCodeBase, /* out */ System::WordBool &pRetVal) = 0 ;
	virtual HRESULT __stdcall ConvertTypeLibToAssembly_2(const System::_di_IInterface typeLib, const System::WideString asmFileName, int flags, const _di_ITypeLibImporterNotifySink notifySink, Activex::PSafeArray publicKey, const _di__StrongNameKeyPair keyPair, System::WordBool unsafeInterfaces, /* out */ _di__AssemblyBuilder &pRetVal) = 0 ;
};

__interface ITypeLibExporterNameProvider;
typedef System::DelphiInterface<ITypeLibExporterNameProvider> _di_ITypeLibExporterNameProvider;
__interface  INTERFACE_UUID("{FA1F3615-ACB9-486D-9EAC-1BEF87E36B09}") ITypeLibExporterNameProvider  : public System::IInterface 
{
	
public:
	virtual HRESULT __stdcall GetNames(/* out */ Activex::PSafeArray &pRetVal) = 0 ;
};

__interface  INTERFACE_UUID("{5F06D2F8-F3D4-3585-814C-2E886C465F25}") _Marshal  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{523F42A5-1FD2-355D-82BF-0D67C4A0A0E7}") _MarshalDirectiveException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E4A369D3-6CF0-3B05-9C0C-1A91E331641A}") _ObjectCreationDelegate  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EDCEE21A-3E3A-331E-A86D-274028BE6716}") _RuntimeEnvironment  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8608FE7B-2FDC-318A-B711-6F7B2FEDED06}") _SafeArrayRankMismatchException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E093FB32-E43B-3B3F-A163-742C920C2AF3}") _SafeArrayTypeMismatchException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3E72E067-4C5E-36C8-BBEF-1E2978C7780D}") _SEHException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1C8D8B14-4589-3DCA-8E0F-A30E80FBD1A8}") _UnknownWrapper  : public IDispatch 
{
	
};

__interface IExpando;
typedef System::DelphiInterface<IExpando> _di_IExpando;
__interface  INTERFACE_UUID("{AFBF15E6-C37C-11D2-B88E-00A0C9B471B8}") IExpando  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall AddField(const System::WideString name, _di__FieldInfo &__AddField_result) = 0 ;
	virtual HRESULT __safecall AddProperty(const System::WideString name, _di__PropertyInfo &__AddProperty_result) = 0 ;
	virtual HRESULT __safecall AddMethod(const System::WideString name, const _di__Delegate Method, _di__MethodInfo &__AddMethod_result) = 0 ;
	virtual HRESULT __safecall RemoveMember(const _di__MemberInfo m) = 0 ;
};

__interface  INTERFACE_UUID("{442E3C03-A205-3F21-AA4D-31768BB8EA28}") _BinaryReader  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4CA8147E-BAA3-3A7F-92CE-A4FD7F17D8DA}") _BinaryWriter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4B7571C3-1275-3457-8FEE-9976FD3937E3}") _BufferedStream  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8CE58FF5-F26D-38A4-9195-0E2ECB3B56B9}") _Directory  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A5D29A57-36A8-3E36-A099-7458B1FABAA2}") _FileSystemInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{487E52F1-2BB9-3BD0-A0CA-6728B3A1D051}") _DirectoryInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C5BFC9BF-27A7-3A59-A986-44C85F3521BF}") _IOException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C8A200E4-9735-30E4-B168-ED861A3020F2}") _DirectoryNotFoundException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D625AFD0-8FD9-3113-A900-43912A54C421}") _EndOfStreamException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5D59051F-E19D-329A-9962-FD00D552E13D}") _File  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C3C429F9-8590-3A01-B2B2-434837F3D16D}") _FileInfo  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{51D2C393-9B70-3551-84B5-FF5409FB3ADA}") _FileLoadException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A15A976B-81E3-3EF4-8FF1-D75DDBE20AEF}") _FileNotFoundException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{74265195-4A46-3D6F-A9DD-69C367EA39C8}") _FileStream  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2DBC46FE-B3DD-3858-AFC2-D3A2D492A588}") _MemoryStream  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6DF93530-D276-31D9-8573-346778C650AF}") _Path  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{468B8EB4-89AC-381B-8F86-5E47EC0648B4}") _PathTooLongException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{897471F2-9450-3F03-A41F-D2E1F1397854}") _TextReader  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E645B470-DC3F-3CE0-8104-5837FEDA04B3}") _StreamReader  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{556137EA-8825-30BC-9D49-E47A9DB034EE}") _TextWriter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1F124E1C-D05D-3643-A59F-C3DE6051994F}") _StreamWriter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{59733B03-0EA5-358C-95B5-659FCD9AA0B4}") _StringReader  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CB9F94C0-D691-3B62-B0B2-3CE5309CFA62}") _StringWriter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{998DCF16-F603-355D-8C89-3B675947997F}") _AccessedThroughPropertyAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A6C2239B-08E6-3822-9769-E3D4B0431B82}") _CallConvCdecl  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8E17A5CD-1160-32DC-8548-407E7C3827C9}") _CallConvStdcall  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FA73DD3D-A472-35ED-B8BE-F99A13581F72}") _CallConvThiscall  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3B452D17-3C5E-36C4-A12D-5E9276036CF8}") _CallConvFastcall  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{028A39F4-2061-3C98-897C-2F6B29370B9B}") _RuntimeHelpers  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{62CAF4A2-6A78-3FC7-AF81-A6BBF930761F}") _CustomConstantAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EF387020-B664-3ACD-A1D2-806345845953}") _DateTimeConstantAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3C3A8C69-7417-32FA-AA20-762D85E1B594}") _DiscardableAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7E133967-CCEC-3E89-8BD2-6CFCA649ECBF}") _DecimalConstantAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C5C4F625-2329-3382-8994-AAF561E5DFE9}") _CompilationRelaxationsAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1EED213E-656A-3A73-A4B9-0D3B26FD942B}") _CompilerGlobalScopeAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{97D0B28A-6932-3D74-B67F-6BCD3C921E7D}") _IDispatchConstantAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{243368F5-67C9-3510-9424-335A8A67772F}") _IndexerNameAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0278C819-0C06-3756-B053-601A3E566D9B}") _IsVolatile  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{54542649-CE64-3F96-BCE5-FDE3BB22F242}") _IUnknownConstantAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{98966503-5D80-3242-83EF-79E136F6B954}") _MethodImplAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{DB2C11D9-3870-35E7-A10C-A3DDC3DC79B1}") _RequiredAttributeAttribute  : public IDispatch 
{
	
};

__interface IStackWalk;
typedef System::DelphiInterface<IStackWalk> _di_IStackWalk;
__interface  INTERFACE_UUID("{60FC57B0-4A46-32A0-A5B4-B05B0DE8E781}") IStackWalk  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall _Assert(void) = 0 ;
	virtual HRESULT __safecall Demand(void) = 0 ;
	virtual HRESULT __safecall Deny(void) = 0 ;
	virtual HRESULT __safecall PermitOnly(void) = 0 ;
};

__interface  INTERFACE_UUID("{C2AF4970-4FB6-319C-A8AA-0614D27F2B2C}") _PermissionSet  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BA3E053F-ADE3-3233-874A-16E624C9A49B}") _NamedPermissionSet  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8D597C42-2CFD-32B6-B6D6-86C9E2CFF00A}") _SecurityElement  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D9FCAD88-D869-3788-A802-1B1E007C7A22}") _XmlSyntaxException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A19B3FC6-D680-3DD4-A17A-F58A7D481494}") IPermission  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Copy(_di_IPermission &__Copy_result) = 0 ;
	virtual HRESULT __safecall Intersect(const _di_IPermission Target, _di_IPermission &__Intersect_result) = 0 ;
	virtual HRESULT __safecall Union(const _di_IPermission Target, _di_IPermission &__Union_result) = 0 ;
	virtual HRESULT __safecall IsSubsetOf(const _di_IPermission Target, System::WordBool &__IsSubsetOf_result) = 0 ;
	virtual HRESULT __safecall Demand(void) = 0 ;
};

__interface  INTERFACE_UUID("{4803CE39-2F30-31FC-B84B-5A0141385269}") _CodeAccessPermission  : public IDispatch 
{
	
};

__interface IUnrestrictedPermission;
typedef System::DelphiInterface<IUnrestrictedPermission> _di_IUnrestrictedPermission;
__interface  INTERFACE_UUID("{0F1284E6-4399-3963-8DDD-A6A4904F66C8}") IUnrestrictedPermission  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall IsUnrestricted(System::WordBool &__IsUnrestricted_result) = 0 ;
};

__interface  INTERFACE_UUID("{0720590D-5218-352A-A337-5449E6BD19DA}") _EnvironmentPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A8B7138C-8932-3D78-A585-A91569C743AC}") _FileDialogPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A2ED7EFC-8E59-3CCC-AE92-EA2377F4D5EF}") _FileIOPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7FEE7903-F97C-3350-AD42-196B00AD2564}") _IsolatedStoragePermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0D0C83E8-BDE1-3BA5-B1EF-A8FC686D8BC9}") _IsolatedStorageFilePermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{48815668-6C27-3312-803E-2757F55CE96A}") _SecurityAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9C5149CB-D3C6-32FD-A0D5-95350DE7B813}") _CodeAccessSecurityAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4164071A-ED12-3BDD-AF40-FDABCAA77D5F}") _EnvironmentPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0CCCA629-440F-313E-96CD-BA1B4B4997F7}") _FileDialogPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0DCA817D-F21A-3943-B54C-5E800CE5BC50}") _FileIOPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{68AB69E4-5D68-3B51-B74D-1BEAB9F37F2B}") _PrincipalPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D31EED10-A5F0-308F-A951-E557961EC568}") _ReflectionPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{38B6068C-1E94-3119-8841-1ECA35ED8578}") _RegistryPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3A5B876C-CDE4-32D2-9C7E-020A14ACA332}") _SecurityPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1D5C0F70-AF29-38A3-9436-3070A310C73B}") _UIPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2E3BE3ED-2F22-3B20-9F92-BD29B79D6F42}") _ZoneIdentityPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C9A740F4-26E9-39A8-8885-8CA26BD79B21}") _StrongNameIdentityPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6FE6894A-2A53-3FB6-A06E-348F9BDAD23B}") _SiteIdentityPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CA4A2073-48C5-3E61-8349-11701A90DD9B}") _UrlIdentityPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6722C730-1239-3784-AC94-C285AE5B901A}") _PublisherIdentityPermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5C4C522F-DE4E-3595-9AA9-9319C86A5283}") _IsolatedStoragePermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6F1F8AAE-D667-39CC-98FA-722BEBBBEAC3}") _IsolatedStorageFilePermissionAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{947A1995-BC16-3E7C-B65A-99E71F39C091}") _PermissionSetAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E86CC74A-1233-3DF3-B13F-8B27EEAAC1F6}") _PublisherIdentityPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AEB3727F-5C3A-34C4-BF18-A38F088AC8C7}") _ReflectionPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C3FB5510-3454-3B31-B64F-DE6AAD6BE820}") _RegistryPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7C6B06D1-63AD-35EF-A938-149B4AD9A71F}") _PrincipalPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{33C54A2D-02BD-3848-80B6-742D537085E5}") _SecurityPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{790B3EE9-7E06-3CD0-8243-5848486D6A78}") _SiteIdentityPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5F1562FB-0160-3655-BAEA-B15BEF609161}") _StrongNameIdentityPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AF53D21A-D6AF-3406-B399-7DF9D2AAD48A}") _StrongNamePublicKeyBlob  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{47698389-F182-3A67-87DF-AED490E14DC6}") _UIPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EC7CAC31-08A2-393B-BDF2-D052EB53AF2C}") _UrlIdentityPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{38B2F8D7-8CF4-323B-9C17-9C55EE287A63}") _ZoneIdentityPermission  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8000E51A-541C-3B20-A8EC-C8A8B41116C4}") _SuppressUnmanagedCodeSecurityAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{41F41C1B-7B8D-39A3-A28F-AAE20787F469}") _UnverifiableCodeAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F1C930C4-2233-3924-9840-231D008259B4}") _AllowPartiallyTrustedCallersAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F174290F-E4CF-3976-88AA-4F8E32EB03DB}") _SecurityException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{ABC04B16-5539-3C7E-92EC-0905A4A24464}") _SecurityManager  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F65070DF-57AF-3AE3-B951-D2AD7D513347}") _VerificationException  : public IDispatch 
{
	
};

__interface IContextAttribute;
typedef System::DelphiInterface<IContextAttribute> _di_IContextAttribute;
__interface IConstructionCallMessage;
typedef System::DelphiInterface<IConstructionCallMessage> _di_IConstructionCallMessage;
__interface  INTERFACE_UUID("{4A68BAA3-27AA-314A-BDBB-6AE9BDFC0420}") IContextAttribute  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall IsContextOK(const _di__Context ctx, const _di_IConstructionCallMessage msg, System::WordBool &__IsContextOK_result) = 0 ;
	virtual HRESULT __safecall GetPropertiesForNewContext(const _di_IConstructionCallMessage msg) = 0 ;
};

__interface IContextProperty;
typedef System::DelphiInterface<IContextProperty> _di_IContextProperty;
__interface  INTERFACE_UUID("{F01D896D-8D5F-3235-BE59-20E1E10DC22A}") IContextProperty  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	virtual HRESULT __safecall IsNewContextOK(const _di__Context newCtx, System::WordBool &__IsNewContextOK_result) = 0 ;
	virtual HRESULT __safecall Freeze(const _di__Context newContext) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
};

__interface  INTERFACE_UUID("{F042505B-7AAC-313B-A8C7-3F1AC949C311}") _ContextAttribute  : public IDispatch 
{
	
};

__interface IActivator;
typedef System::DelphiInterface<IActivator> _di_IActivator;
__interface IConstructionReturnMessage;
typedef System::DelphiInterface<IConstructionReturnMessage> _di_IConstructionReturnMessage;
__interface  INTERFACE_UUID("{C02BBB79-5AA8-390D-927F-717B7BFF06A1}") IActivator  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_NextActivator(_di_IActivator &__Get_NextActivator_result) = 0 ;
	virtual HRESULT __safecall _Set_NextActivator(const _di_IActivator pRetVal) = 0 ;
	virtual HRESULT __safecall Activate(const _di_IConstructionCallMessage msg, _di_IConstructionReturnMessage &__Activate_result) = 0 ;
	virtual HRESULT __safecall Get_level(Activex::TOleEnum &__Get_level_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IActivator _scw_Get_NextActivator() { _di_IActivator __r; HRESULT __hr = Get_NextActivator(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IActivator NextActivator = {read=_scw_Get_NextActivator};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_level() { Activex::TOleEnum __r; HRESULT __hr = Get_level(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum level = {read=_scw_Get_level};
};

__interface IMessageSink;
typedef System::DelphiInterface<IMessageSink> _di_IMessageSink;
__interface IMessage;
typedef System::DelphiInterface<IMessage> _di_IMessage;
__interface IMessageCtrl;
typedef System::DelphiInterface<IMessageCtrl> _di_IMessageCtrl;
__interface  INTERFACE_UUID("{941F8AAA-A353-3B1D-A019-12E44377F1CD}") IMessageSink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall SyncProcessMessage(const _di_IMessage msg, _di_IMessage &__SyncProcessMessage_result) = 0 ;
	virtual HRESULT __safecall AsyncProcessMessage(const _di_IMessage msg, const _di_IMessageSink replySink, _di_IMessageCtrl &__AsyncProcessMessage_result) = 0 ;
	virtual HRESULT __safecall Get_NextSink(_di_IMessageSink &__Get_NextSink_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IMessageSink _scw_Get_NextSink() { _di_IMessageSink __r; HRESULT __hr = Get_NextSink(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IMessageSink NextSink = {read=_scw_Get_NextSink};
};

__interface  INTERFACE_UUID("{3936ABE1-B29E-3593-83F1-793D1A7F3898}") _AsyncResult  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{53BCE4D4-6209-396D-BD4A-0B0A0A177DF9}") _CallContext  : public IDispatch 
{
	
};

__interface ILogicalThreadAffinative;
typedef System::DelphiInterface<ILogicalThreadAffinative> _di_ILogicalThreadAffinative;
__interface  INTERFACE_UUID("{4D125449-BA27-3927-8589-3E1B34B622E5}") ILogicalThreadAffinative  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9AFF21F5-1C9C-35E7-AEA4-C3AA0BEB3B77}") _LogicalCallContext  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FFB2E16E-E5C7-367C-B326-965ABF510F24}") _ChannelServices  : public IDispatch 
{
	
};

__interface IClientResponseChannelSinkStack;
typedef System::DelphiInterface<IClientResponseChannelSinkStack> _di_IClientResponseChannelSinkStack;
__interface ITransportHeaders;
typedef System::DelphiInterface<ITransportHeaders> _di_ITransportHeaders;
__interface  INTERFACE_UUID("{3AFAB213-F5A2-3241-93BA-329EA4BA8016}") IClientResponseChannelSinkStack  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall AsyncProcessResponse(const _di_ITransportHeaders headers, const _di__Stream Stream) = 0 ;
	virtual HRESULT __safecall DispatchReplyMessage(const _di_IMessage msg) = 0 ;
	virtual HRESULT __safecall DispatchException(const _di__Exception e) = 0 ;
};

__interface IClientChannelSinkStack;
typedef System::DelphiInterface<IClientChannelSinkStack> _di_IClientChannelSinkStack;
__interface IClientChannelSink;
typedef System::DelphiInterface<IClientChannelSink> _di_IClientChannelSink;
__interface  INTERFACE_UUID("{3A5FDE6B-DB46-34E8-BACD-16EA5A440540}") IClientChannelSinkStack  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Push(const _di_IClientChannelSink sink, const System::OleVariant state) = 0 ;
	virtual HRESULT __safecall Pop(const _di_IClientChannelSink sink, System::OleVariant &__Pop_result) = 0 ;
};

__interface  INTERFACE_UUID("{E1796120-C324-30D8-86F4-20086711463B}") _ClientChannelSinkStack  : public IDispatch 
{
	
};

__interface IServerResponseChannelSinkStack;
typedef System::DelphiInterface<IServerResponseChannelSinkStack> _di_IServerResponseChannelSinkStack;
__interface  INTERFACE_UUID("{9BE679A6-61FD-38FC-A7B2-89982D33338B}") IServerResponseChannelSinkStack  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall AsyncProcessResponse(const _di_IMessage msg, const _di_ITransportHeaders headers, const _di__Stream Stream) = 0 ;
	virtual HRESULT __safecall GetResponseStream(const _di_IMessage msg, const _di_ITransportHeaders headers, _di__Stream &__GetResponseStream_result) = 0 ;
};

__interface IServerChannelSinkStack;
typedef System::DelphiInterface<IServerChannelSinkStack> _di_IServerChannelSinkStack;
__interface IServerChannelSink;
typedef System::DelphiInterface<IServerChannelSink> _di_IServerChannelSink;
__interface  INTERFACE_UUID("{E694A733-768D-314D-B317-DCEAD136B11D}") IServerChannelSinkStack  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Push(const _di_IServerChannelSink sink, const System::OleVariant state) = 0 ;
	virtual HRESULT __safecall Pop(const _di_IServerChannelSink sink, System::OleVariant &__Pop_result) = 0 ;
	virtual HRESULT __safecall Store(const _di_IServerChannelSink sink, const System::OleVariant state) = 0 ;
	virtual HRESULT __safecall StoreAndDispatch(const _di_IServerChannelSink sink, const System::OleVariant state) = 0 ;
	virtual HRESULT __safecall ServerCallback(const _di_IAsyncResult ar) = 0 ;
};

__interface  INTERFACE_UUID("{52DA9F90-89B3-35AB-907B-3562642967DE}") _ServerChannelSinkStack  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EF926E1F-3EE7-32BC-8B01-C6E98C24BC19}") _InternalMessageWrapper  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1A8B0DE6-B825-38C5-B744-8F93075FD6FA}") IMessage  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Properties(_di_IDictionary &__Get_Properties_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IDictionary _scw_Get_Properties() { _di_IDictionary __r; HRESULT __hr = Get_Properties(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IDictionary Properties = {read=_scw_Get_Properties};
};

__interface IMethodMessage;
typedef System::DelphiInterface<IMethodMessage> _di_IMethodMessage;
__interface  INTERFACE_UUID("{8E5E0B95-750E-310D-892C-8CA7231CF75B}") IMethodMessage  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Uri(System::WideString &__Get_Uri_result) = 0 ;
	virtual HRESULT __safecall Get_MethodName(System::WideString &__Get_MethodName_result) = 0 ;
	virtual HRESULT __safecall Get_typeName(System::WideString &__Get_typeName_result) = 0 ;
	virtual HRESULT __safecall Get_MethodSignature(System::OleVariant &__Get_MethodSignature_result) = 0 ;
	virtual HRESULT __safecall Get_ArgCount(int &__Get_ArgCount_result) = 0 ;
	virtual HRESULT __safecall GetArgName(int index, System::WideString &__GetArgName_result) = 0 ;
	virtual HRESULT __safecall GetArg(int argNum, System::OleVariant &__GetArg_result) = 0 ;
	virtual HRESULT __safecall Get_args(Activex::PSafeArray &__Get_args_result) = 0 ;
	virtual HRESULT __safecall Get_HasVarArgs(System::WordBool &__Get_HasVarArgs_result) = 0 ;
	virtual HRESULT __safecall Get_LogicalCallContext(_di__LogicalCallContext &__Get_LogicalCallContext_result) = 0 ;
	virtual HRESULT __safecall Get_MethodBase(_di__MethodBase &__Get_MethodBase_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_Uri() { System::WideString __r; HRESULT __hr = Get_Uri(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString Uri = {read=_scw_Get_Uri};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_MethodName() { System::WideString __r; HRESULT __hr = Get_MethodName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString MethodName = {read=_scw_Get_MethodName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_typeName() { System::WideString __r; HRESULT __hr = Get_typeName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString typeName = {read=_scw_Get_typeName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_MethodSignature() { System::OleVariant __r; HRESULT __hr = Get_MethodSignature(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant MethodSignature = {read=_scw_Get_MethodSignature};
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_ArgCount() { int __r; HRESULT __hr = Get_ArgCount(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int ArgCount = {read=_scw_Get_ArgCount};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_args() { Activex::PSafeArray __r; HRESULT __hr = Get_args(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray args = {read=_scw_Get_args};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_HasVarArgs() { System::WordBool __r; HRESULT __hr = Get_HasVarArgs(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool HasVarArgs = {read=_scw_Get_HasVarArgs};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__LogicalCallContext _scw_Get_LogicalCallContext() { _di__LogicalCallContext __r; HRESULT __hr = Get_LogicalCallContext(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__LogicalCallContext LogicalCallContext = {read=_scw_Get_LogicalCallContext};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__MethodBase _scw_Get_MethodBase() { _di__MethodBase __r; HRESULT __hr = Get_MethodBase(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__MethodBase MethodBase = {read=_scw_Get_MethodBase};
};

__interface IMethodCallMessage;
typedef System::DelphiInterface<IMethodCallMessage> _di_IMethodCallMessage;
__interface  INTERFACE_UUID("{B90EFAA6-25E4-33D2-ACA3-94BF74DC4AB9}") IMethodCallMessage  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_InArgCount(int &__Get_InArgCount_result) = 0 ;
	virtual HRESULT __safecall GetInArgName(int index, System::WideString &__GetInArgName_result) = 0 ;
	virtual HRESULT __safecall GetInArg(int argNum, System::OleVariant &__GetInArg_result) = 0 ;
	virtual HRESULT __safecall Get_InArgs(Activex::PSafeArray &__Get_InArgs_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_InArgCount() { int __r; HRESULT __hr = Get_InArgCount(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int InArgCount = {read=_scw_Get_InArgCount};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_InArgs() { Activex::PSafeArray __r; HRESULT __hr = Get_InArgs(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray InArgs = {read=_scw_Get_InArgs};
};

__interface  INTERFACE_UUID("{C9614D78-10EA-3310-87EA-821B70632898}") _MethodCallMessageWrapper  : public IDispatch 
{
	
};

__interface ISponsor;
typedef System::DelphiInterface<ISponsor> _di_ISponsor;
__interface ILease;
typedef System::DelphiInterface<ILease> _di_ILease;
__interface  INTERFACE_UUID("{675591AF-0508-3131-A7CC-287D265CA7D6}") ISponsor  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Renewal(const _di_ILease lease, TimeSpan &__Renewal_result) = 0 ;
};

__interface  INTERFACE_UUID("{FF19D114-3BDA-30AC-8E89-36CA64A87120}") _ClientSponsor  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EE949B7B-439F-363E-B9FC-34DB1FB781D7}") _CrossContextDelegate  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{11A2EA7A-D600-307B-A606-511A6C7950D1}") _Context  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4ACB3495-05DB-381B-890A-D12F5340DCA3}") _ContextProperty  : public IDispatch 
{
	
};

__interface IContextPropertyActivator;
typedef System::DelphiInterface<IContextPropertyActivator> _di_IContextPropertyActivator;
__interface  INTERFACE_UUID("{7197B56B-5FA1-31EF-B38B-62FEE737277F}") IContextPropertyActivator  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall IsOKToActivate(const _di_IConstructionCallMessage msg, System::WordBool &__IsOKToActivate_result) = 0 ;
	virtual HRESULT __safecall CollectFromClientContext(const _di_IConstructionCallMessage msg) = 0 ;
	virtual HRESULT __safecall DeliverClientContextToServerContext(const _di_IConstructionCallMessage msg, System::WordBool &__DeliverClientContextToServerContext_result) = 0 ;
	virtual HRESULT __safecall CollectFromServerContext(const _di_IConstructionReturnMessage msg) = 0 ;
	virtual HRESULT __safecall DeliverServerContextToClientContext(const _di_IConstructionReturnMessage msg, System::WordBool &__DeliverServerContextToClientContext_result) = 0 ;
};

__interface IChannel;
typedef System::DelphiInterface<IChannel> _di_IChannel;
__interface  INTERFACE_UUID("{563581E8-C86D-39E2-B2E8-6C23F7987A4B}") IChannel  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ChannelPriority(int &__Get_ChannelPriority_result) = 0 ;
	virtual HRESULT __safecall Get_ChannelName(System::WideString &__Get_ChannelName_result) = 0 ;
	virtual HRESULT __safecall Parse(const System::WideString Url, /* out */ System::WideString &objectURI, System::WideString &__Parse_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_ChannelPriority() { int __r; HRESULT __hr = Get_ChannelPriority(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int ChannelPriority = {read=_scw_Get_ChannelPriority};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ChannelName() { System::WideString __r; HRESULT __hr = Get_ChannelName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ChannelName = {read=_scw_Get_ChannelName};
};

__interface IChannelSender;
typedef System::DelphiInterface<IChannelSender> _di_IChannelSender;
__interface  INTERFACE_UUID("{10F1D605-E201-3145-B7AE-3AD746701986}") IChannelSender  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall CreateMessageSink(const System::WideString Url, const System::OleVariant remoteChannelData, /* out */ System::WideString &objectURI, _di_IMessageSink &__CreateMessageSink_result) = 0 ;
};

__interface IChannelReceiver;
typedef System::DelphiInterface<IChannelReceiver> _di_IChannelReceiver;
__interface  INTERFACE_UUID("{48AD41DA-0872-31DA-9887-F81F213527E6}") IChannelReceiver  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ChannelData(System::OleVariant &__Get_ChannelData_result) = 0 ;
	virtual HRESULT __safecall GetUrlsForUri(const System::WideString objectURI, Activex::PSafeArray &__GetUrlsForUri_result) = 0 ;
	virtual HRESULT __safecall StartListening(const System::OleVariant data) = 0 ;
	virtual HRESULT __safecall StopListening(const System::OleVariant data) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_ChannelData() { System::OleVariant __r; HRESULT __hr = Get_ChannelData(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant ChannelData = {read=_scw_Get_ChannelData};
};

__interface IServerChannelSinkProvider;
typedef System::DelphiInterface<IServerChannelSinkProvider> _di_IServerChannelSinkProvider;
__interface IChannelDataStore;
typedef System::DelphiInterface<IChannelDataStore> _di_IChannelDataStore;
__interface  INTERFACE_UUID("{7DD6E975-24EA-323C-A98C-0FDE96F9C4E6}") IServerChannelSinkProvider  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetChannelData(const _di_IChannelDataStore ChannelData) = 0 ;
	virtual HRESULT __safecall CreateSink(const _di_IChannelReceiver channel, _di_IServerChannelSink &__CreateSink_result) = 0 ;
	virtual HRESULT __safecall Get_Next(_di_IServerChannelSinkProvider &__Get_Next_result) = 0 ;
	virtual HRESULT __safecall _Set_Next(const _di_IServerChannelSinkProvider pRetVal) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IServerChannelSinkProvider _scw_Get_Next() { _di_IServerChannelSinkProvider __r; HRESULT __hr = Get_Next(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IServerChannelSinkProvider Next = {read=_scw_Get_Next};
};

__interface IChannelSinkBase;
typedef System::DelphiInterface<IChannelSinkBase> _di_IChannelSinkBase;
__interface  INTERFACE_UUID("{308DE042-ACC8-32F8-B632-7CB9799D9AA6}") IChannelSinkBase  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Properties(_di_IDictionary &__Get_Properties_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IDictionary _scw_Get_Properties() { _di_IDictionary __r; HRESULT __hr = Get_Properties(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IDictionary Properties = {read=_scw_Get_Properties};
};

__interface  INTERFACE_UUID("{21B5F37B-BEF3-354C-8F84-0F9F0863F5C5}") IServerChannelSink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall ProcessMessage(const _di_IServerChannelSinkStack sinkStack, const _di_IMessage requestMsg, const _di_ITransportHeaders requestHeaders, const _di__Stream requestStream, /* out */ _di_IMessage &responseMsg, /* out */ _di_ITransportHeaders &responseHeaders, /* out */ _di__Stream &responseStream, Activex::TOleEnum &__ProcessMessage_result) = 0 ;
	virtual HRESULT __safecall AsyncProcessResponse(const _di_IServerResponseChannelSinkStack sinkStack, const System::OleVariant state, const _di_IMessage msg, const _di_ITransportHeaders headers, const _di__Stream Stream) = 0 ;
	virtual HRESULT __safecall GetResponseStream(const _di_IServerResponseChannelSinkStack sinkStack, const System::OleVariant state, const _di_IMessage msg, const _di_ITransportHeaders headers, _di__Stream &__GetResponseStream_result) = 0 ;
	virtual HRESULT __safecall Get_NextChannelSink(_di_IServerChannelSink &__Get_NextChannelSink_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IServerChannelSink _scw_Get_NextChannelSink() { _di_IServerChannelSink __r; HRESULT __hr = Get_NextChannelSink(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IServerChannelSink NextChannelSink = {read=_scw_Get_NextChannelSink};
};

__interface  INTERFACE_UUID("{77C9BCEB-9958-33C0-A858-599F66697DA7}") _EnterpriseServicesHelper  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0D296515-AD19-3602-B415-D8EC77066081}") _Header  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5DBBAF39-A3DF-30B7-AAEA-9FD11394123F}") _HeaderHandler  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FA28E3AF-7D09-31D5-BEEB-7F2626497CDE}") IConstructionCallMessage  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_Activator(_di_IActivator &__Get_Activator_result) = 0 ;
	virtual HRESULT __safecall _Set_Activator(const _di_IActivator pRetVal) = 0 ;
	virtual HRESULT __safecall Get_CallSiteActivationAttributes(Activex::PSafeArray &__Get_CallSiteActivationAttributes_result) = 0 ;
	virtual HRESULT __safecall Get_ActivationTypeName(System::WideString &__Get_ActivationTypeName_result) = 0 ;
	virtual HRESULT __safecall Get_ActivationType(_di__Type &__Get_ActivationType_result) = 0 ;
	virtual HRESULT __safecall Get_ContextProperties(_di_IList &__Get_ContextProperties_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IActivator _scw_Get_Activator() { _di_IActivator __r; HRESULT __hr = Get_Activator(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IActivator Activator = {read=_scw_Get_Activator};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_CallSiteActivationAttributes() { Activex::PSafeArray __r; HRESULT __hr = Get_CallSiteActivationAttributes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray CallSiteActivationAttributes = {read=_scw_Get_CallSiteActivationAttributes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ActivationTypeName() { System::WideString __r; HRESULT __hr = Get_ActivationTypeName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ActivationTypeName = {read=_scw_Get_ActivationTypeName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Type _scw_Get_ActivationType() { _di__Type __r; HRESULT __hr = Get_ActivationType(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Type ActivationType = {read=_scw_Get_ActivationType};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IList _scw_Get_ContextProperties() { _di_IList __r; HRESULT __hr = Get_ContextProperties(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IList ContextProperties = {read=_scw_Get_ContextProperties};
};

__interface IMethodReturnMessage;
typedef System::DelphiInterface<IMethodReturnMessage> _di_IMethodReturnMessage;
__interface  INTERFACE_UUID("{F617690A-55F4-36AF-9149-D199831F8594}") IMethodReturnMessage  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_OutArgCount(int &__Get_OutArgCount_result) = 0 ;
	virtual HRESULT __safecall GetOutArgName(int index, System::WideString &__GetOutArgName_result) = 0 ;
	virtual HRESULT __safecall GetOutArg(int argNum, System::OleVariant &__GetOutArg_result) = 0 ;
	virtual HRESULT __safecall Get_OutArgs(Activex::PSafeArray &__Get_OutArgs_result) = 0 ;
	virtual HRESULT __safecall Get_Exception(_di__Exception &__Get_Exception_result) = 0 ;
	virtual HRESULT __safecall Get_ReturnValue(System::OleVariant &__Get_ReturnValue_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline int _scw_Get_OutArgCount() { int __r; HRESULT __hr = Get_OutArgCount(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property int OutArgCount = {read=_scw_Get_OutArgCount};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_OutArgs() { Activex::PSafeArray __r; HRESULT __hr = Get_OutArgs(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray OutArgs = {read=_scw_Get_OutArgs};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di__Exception _scw_Get_Exception() { _di__Exception __r; HRESULT __hr = Get_Exception(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di__Exception Exception = {read=_scw_Get_Exception};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_ReturnValue() { System::OleVariant __r; HRESULT __hr = Get_ReturnValue(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant ReturnValue = {read=_scw_Get_ReturnValue};
};

__interface  INTERFACE_UUID("{CA0AB564-F5E9-3A7F-A80B-EB0AEEFA44E9}") IConstructionReturnMessage  : public IDispatch 
{
	
};

__interface IChannelReceiverHook;
typedef System::DelphiInterface<IChannelReceiverHook> _di_IChannelReceiverHook;
__interface  INTERFACE_UUID("{3A02D3F7-3F40-3022-853D-CFDA765182FE}") IChannelReceiverHook  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ChannelScheme(System::WideString &__Get_ChannelScheme_result) = 0 ;
	virtual HRESULT __safecall Get_WantsToListen(System::WordBool &__Get_WantsToListen_result) = 0 ;
	virtual HRESULT __safecall Get_ChannelSinkChain(_di_IServerChannelSink &__Get_ChannelSinkChain_result) = 0 ;
	virtual HRESULT __safecall AddHookChannelUri(const System::WideString channelUri) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ChannelScheme() { System::WideString __r; HRESULT __hr = Get_ChannelScheme(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ChannelScheme = {read=_scw_Get_ChannelScheme};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WordBool _scw_Get_WantsToListen() { System::WordBool __r; HRESULT __hr = Get_WantsToListen(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WordBool WantsToListen = {read=_scw_Get_WantsToListen};
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IServerChannelSink _scw_Get_ChannelSinkChain() { _di_IServerChannelSink __r; HRESULT __hr = Get_ChannelSinkChain(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IServerChannelSink ChannelSinkChain = {read=_scw_Get_ChannelSinkChain};
};

__interface IClientChannelSinkProvider;
typedef System::DelphiInterface<IClientChannelSinkProvider> _di_IClientChannelSinkProvider;
__interface  INTERFACE_UUID("{3F8742C2-AC57-3440-A283-FE5FF4C75025}") IClientChannelSinkProvider  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall CreateSink(const _di_IChannelSender channel, const System::WideString Url, const System::OleVariant remoteChannelData, _di_IClientChannelSink &__CreateSink_result) = 0 ;
	virtual HRESULT __safecall Get_Next(_di_IClientChannelSinkProvider &__Get_Next_result) = 0 ;
	virtual HRESULT __safecall _Set_Next(const _di_IClientChannelSinkProvider pRetVal) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IClientChannelSinkProvider _scw_Get_Next() { _di_IClientChannelSinkProvider __r; HRESULT __hr = Get_Next(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IClientChannelSinkProvider Next = {read=_scw_Get_Next};
};

__interface IClientFormatterSinkProvider;
typedef System::DelphiInterface<IClientFormatterSinkProvider> _di_IClientFormatterSinkProvider;
__interface  INTERFACE_UUID("{6D94B6F3-DA91-3C2F-B876-083769667468}") IClientFormatterSinkProvider  : public IDispatch 
{
	
};

__interface IServerFormatterSinkProvider;
typedef System::DelphiInterface<IServerFormatterSinkProvider> _di_IServerFormatterSinkProvider;
__interface  INTERFACE_UUID("{042B5200-4317-3E4D-B653-7E9A08F1A5F2}") IServerFormatterSinkProvider  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{FF726320-6B92-3E6C-AAAC-F97063D0B142}") IClientChannelSink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall ProcessMessage(const _di_IMessage msg, const _di_ITransportHeaders requestHeaders, const _di__Stream requestStream, /* out */ _di_ITransportHeaders &responseHeaders, /* out */ _di__Stream &responseStream) = 0 ;
	virtual HRESULT __safecall AsyncProcessRequest(const _di_IClientChannelSinkStack sinkStack, const _di_IMessage msg, const _di_ITransportHeaders headers, const _di__Stream Stream) = 0 ;
	virtual HRESULT __safecall AsyncProcessResponse(const _di_IClientResponseChannelSinkStack sinkStack, const System::OleVariant state, const _di_ITransportHeaders headers, const _di__Stream Stream) = 0 ;
	virtual HRESULT __safecall GetRequestStream(const _di_IMessage msg, const _di_ITransportHeaders headers, _di__Stream &__GetRequestStream_result) = 0 ;
	virtual HRESULT __safecall Get_NextChannelSink(_di_IClientChannelSink &__Get_NextChannelSink_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IClientChannelSink _scw_Get_NextChannelSink() { _di_IClientChannelSink __r; HRESULT __hr = Get_NextChannelSink(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IClientChannelSink NextChannelSink = {read=_scw_Get_NextChannelSink};
};

__interface IClientFormatterSink;
typedef System::DelphiInterface<IClientFormatterSink> _di_IClientFormatterSink;
__interface  INTERFACE_UUID("{46527C03-B144-3CF0-86B3-B8776148A6E9}") IClientFormatterSink  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1E250CCD-DC30-3217-A7E4-148F375A0088}") IChannelDataStore  : public IDispatch 
{
	
public:
	System::OleVariant operator[](System::OleVariant key) { return Item[key]; }
	
public:
	virtual HRESULT __safecall Get_ChannelUris(Activex::PSafeArray &__Get_ChannelUris_result) = 0 ;
	virtual HRESULT __safecall Get_Item(const System::OleVariant key, System::OleVariant &__Get_Item_result) = 0 ;
	virtual HRESULT __safecall _Set_Item(const System::OleVariant key, const System::OleVariant pRetVal) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_ChannelUris() { Activex::PSafeArray __r; HRESULT __hr = Get_ChannelUris(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray ChannelUris = {read=_scw_Get_ChannelUris};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_Item(const System::OleVariant key) { System::OleVariant __r; HRESULT __hr = Get_Item(key, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant Item[System::OleVariant key] = {read=_scw_Get_Item, write=_Set_Item/*, default*/};
};

__interface  INTERFACE_UUID("{AA6DA581-F972-36DE-A53B-7585428A68AB}") _ChannelDataStore  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1AC82FBE-4FF0-383C-BBFD-FE40ECB3628D}") ITransportHeaders  : public IDispatch 
{
	
public:
	System::OleVariant operator[](System::OleVariant key) { return Item[key]; }
	
public:
	virtual HRESULT __safecall Get_Item(const System::OleVariant key, System::OleVariant &__Get_Item_result) = 0 ;
	virtual HRESULT __safecall _Set_Item(const System::OleVariant key, const System::OleVariant pRetVal) = 0 ;
	virtual HRESULT __safecall GetEnumerator(_di_IEnumVARIANT &__GetEnumerator_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::OleVariant _scw_Get_Item(const System::OleVariant key) { System::OleVariant __r; HRESULT __hr = Get_Item(key, __r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::OleVariant Item[System::OleVariant key] = {read=_scw_Get_Item, write=_Set_Item/*, default*/};
};

__interface  INTERFACE_UUID("{65887F70-C646-3A66-8697-8A3F7D8FE94D}") _TransportHeaders  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A18545B7-E5EE-31EE-9B9B-41199B11C995}") _SinkProviderData  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A1329EC9-E567-369F-8258-18366D89EAF8}") _BaseChannelObjectWithProperties  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8AF3451E-154D-3D86-80D8-F8478B9733ED}") _BaseChannelSinkWithProperties  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{94BB98ED-18BB-3843-A7FE-642824AB4E01}") _BaseChannelWithProperties  : public IDispatch 
{
	
};

__interface IContributeClientContextSink;
typedef System::DelphiInterface<IContributeClientContextSink> _di_IContributeClientContextSink;
__interface  INTERFACE_UUID("{4DB956B7-69D0-312A-AA75-44FB55FD5D4B}") IContributeClientContextSink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetClientContextSink(const _di_IMessageSink NextSink, _di_IMessageSink &__GetClientContextSink_result) = 0 ;
};

__interface IContributeDynamicSink;
typedef System::DelphiInterface<IContributeDynamicSink> _di_IContributeDynamicSink;
__interface IDynamicMessageSink;
typedef System::DelphiInterface<IDynamicMessageSink> _di_IDynamicMessageSink;
__interface  INTERFACE_UUID("{A0FE9B86-0C06-32CE-85FA-2FF1B58697FB}") IContributeDynamicSink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetDynamicSink(_di_IDynamicMessageSink &__GetDynamicSink_result) = 0 ;
};

__interface IContributeEnvoySink;
typedef System::DelphiInterface<IContributeEnvoySink> _di_IContributeEnvoySink;
__interface  INTERFACE_UUID("{124777B6-0308-3569-97E5-E6FE88EAE4EB}") IContributeEnvoySink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetEnvoySink(const _di__MarshalByRefObject obj, const _di_IMessageSink NextSink, _di_IMessageSink &__GetEnvoySink_result) = 0 ;
};

__interface IContributeObjectSink;
typedef System::DelphiInterface<IContributeObjectSink> _di_IContributeObjectSink;
__interface  INTERFACE_UUID("{6A5D38BC-2789-3546-81A1-F10C0FB59366}") IContributeObjectSink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetObjectSink(const _di__MarshalByRefObject obj, const _di_IMessageSink NextSink, _di_IMessageSink &__GetObjectSink_result) = 0 ;
};

__interface IContributeServerContextSink;
typedef System::DelphiInterface<IContributeServerContextSink> _di_IContributeServerContextSink;
__interface  INTERFACE_UUID("{0CAA23EC-F78C-39C9-8D25-B7A9CE4097A7}") IContributeServerContextSink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetServerContextSink(const _di_IMessageSink NextSink, _di_IMessageSink &__GetServerContextSink_result) = 0 ;
};

__interface IDynamicProperty;
typedef System::DelphiInterface<IDynamicProperty> _di_IDynamicProperty;
__interface  INTERFACE_UUID("{00A358D4-4D58-3B9D-8FB6-FB7F6BC1713B}") IDynamicProperty  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_name(System::WideString &__Get_name_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_name() { System::WideString __r; HRESULT __hr = Get_name(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString name = {read=_scw_Get_name};
};

__interface  INTERFACE_UUID("{C74076BB-8A2D-3C20-A542-625329E9AF04}") IDynamicMessageSink  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall ProcessMessageStart(const _di_IMessage reqMsg, System::WordBool bCliSide, System::WordBool bAsync) = 0 ;
	virtual HRESULT __safecall ProcessMessageFinish(const _di_IMessage replyMsg, System::WordBool bCliSide, System::WordBool bAsync) = 0 ;
};

__interface  INTERFACE_UUID("{53A561F2-CBBF-3748-BFFE-2180002DB3DF}") ILease  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Register(const _di_ISponsor obj, const TimeSpan renewalTime) = 0 ;
	virtual HRESULT __safecall Register_2(const _di_ISponsor obj) = 0 ;
	virtual HRESULT __safecall Unregister(const _di_ISponsor obj) = 0 ;
	virtual HRESULT __safecall Renew(const TimeSpan renewalTime, TimeSpan &__Renew_result) = 0 ;
	virtual HRESULT __safecall Get_RenewOnCallTime(TimeSpan &__Get_RenewOnCallTime_result) = 0 ;
	virtual HRESULT __safecall Set_RenewOnCallTime(const TimeSpan pRetVal) = 0 ;
	virtual HRESULT __safecall Get_SponsorshipTimeout(TimeSpan &__Get_SponsorshipTimeout_result) = 0 ;
	virtual HRESULT __safecall Set_SponsorshipTimeout(const TimeSpan pRetVal) = 0 ;
	virtual HRESULT __safecall Get_InitialLeaseTime(TimeSpan &__Get_InitialLeaseTime_result) = 0 ;
	virtual HRESULT __safecall Set_InitialLeaseTime(const TimeSpan pRetVal) = 0 ;
	virtual HRESULT __safecall Get_CurrentLeaseTime(TimeSpan &__Get_CurrentLeaseTime_result) = 0 ;
	virtual HRESULT __safecall Get_CurrentState(Activex::TOleEnum &__Get_CurrentState_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline TimeSpan _scw_Get_RenewOnCallTime() { TimeSpan __r; HRESULT __hr = Get_RenewOnCallTime(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property TimeSpan RenewOnCallTime = {read=_scw_Get_RenewOnCallTime};
	#pragma option push -w-inl
	/* safecall wrapper */ inline TimeSpan _scw_Get_SponsorshipTimeout() { TimeSpan __r; HRESULT __hr = Get_SponsorshipTimeout(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property TimeSpan SponsorshipTimeout = {read=_scw_Get_SponsorshipTimeout};
	#pragma option push -w-inl
	/* safecall wrapper */ inline TimeSpan _scw_Get_InitialLeaseTime() { TimeSpan __r; HRESULT __hr = Get_InitialLeaseTime(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property TimeSpan InitialLeaseTime = {read=_scw_Get_InitialLeaseTime};
	#pragma option push -w-inl
	/* safecall wrapper */ inline TimeSpan _scw_Get_CurrentLeaseTime() { TimeSpan __r; HRESULT __hr = Get_CurrentLeaseTime(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property TimeSpan CurrentLeaseTime = {read=_scw_Get_CurrentLeaseTime};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::TOleEnum _scw_Get_CurrentState() { Activex::TOleEnum __r; HRESULT __hr = Get_CurrentState(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::TOleEnum CurrentState = {read=_scw_Get_CurrentState};
};

__interface  INTERFACE_UUID("{3677CBB0-784D-3C15-BBC8-75CD7DC3901E}") IMessageCtrl  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Cancel(int msToCancel) = 0 ;
};

__interface IRemotingFormatter;
typedef System::DelphiInterface<IRemotingFormatter> _di_IRemotingFormatter;
__interface  INTERFACE_UUID("{AE1850FD-3596-3727-A242-2FC31C5A0312}") IRemotingFormatter  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Deserialize(const _di__Stream serializationStream, const _di__HeaderHandler handler, System::OleVariant &__Deserialize_result) = 0 ;
	virtual HRESULT __safecall Serialize(const _di__Stream serializationStream, const System::OleVariant graph, Activex::PSafeArray headers) = 0 ;
};

__interface  INTERFACE_UUID("{B0AD9A21-5439-3D88-8975-4018B828D74C}") _LifetimeServices  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{0EEFF4C2-84BF-3E4E-BF22-B7BDBB5DF899}") _ReturnMessage  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{95E01216-5467-371B-8597-4074402CCB06}") _MethodCall  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A2246AE7-EB81-3A20-8E70-C9FA341C7E10}") _ConstructionCall  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{9E9EA93A-D000-3AB9-BFCA-DDEB398A55B9}") _MethodResponse  : public IDispatch 
{
	
};

__interface IFieldInfo;
typedef System::DelphiInterface<IFieldInfo> _di_IFieldInfo;
__interface  INTERFACE_UUID("{CC18FD4D-AA2D-3AB4-9848-584BBAE4AB44}") IFieldInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_FieldNames(Activex::PSafeArray &__Get_FieldNames_result) = 0 ;
	virtual HRESULT __safecall Set_FieldNames(Activex::PSafeArray pRetVal) = 0 ;
	virtual HRESULT __safecall Get_FieldTypes(Activex::PSafeArray &__Get_FieldTypes_result) = 0 ;
	virtual HRESULT __safecall Set_FieldTypes(Activex::PSafeArray pRetVal) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_FieldNames() { Activex::PSafeArray __r; HRESULT __hr = Get_FieldNames(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray FieldNames = {read=_scw_Get_FieldNames};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_FieldTypes() { Activex::PSafeArray __r; HRESULT __hr = Get_FieldTypes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray FieldTypes = {read=_scw_Get_FieldTypes};
};

__interface  INTERFACE_UUID("{BE457280-6FFA-3E76-9822-83DE63C0C4E0}") _ConstructionResponse  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{89304439-A24F-30F6-9A8F-89CE472D85DA}") _MethodReturnMessageWrapper  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EA675B47-64E0-3B5F-9BE7-F7DC2990730D}") _ObjectHandle  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ToString(System::WideString &__Get_ToString_result) = 0 ;
	virtual HRESULT __safecall Equals(const System::OleVariant obj, System::WordBool &__Equals_result) = 0 ;
	virtual HRESULT __safecall GetHashCode(int &__GetHashCode_result) = 0 ;
	virtual HRESULT __safecall GetType(_di__Type &__GetType_result) = 0 ;
	virtual HRESULT __safecall GetLifetimeService(System::OleVariant &__GetLifetimeService_result) = 0 ;
	virtual HRESULT __safecall InitializeLifetimeService(System::OleVariant &__InitializeLifetimeService_result) = 0 ;
	virtual HRESULT __safecall CreateObjRef(const _di__Type requestedType, _di__ObjRef &__CreateObjRef_result) = 0 ;
	virtual HRESULT __safecall Unwrap(System::OleVariant &__Unwrap_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_ToString() { System::WideString __r; HRESULT __hr = Get_ToString(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString ToString = {read=_scw_Get_ToString};
};

__interface IRemotingTypeInfo;
typedef System::DelphiInterface<IRemotingTypeInfo> _di_IRemotingTypeInfo;
__interface  INTERFACE_UUID("{C09EFFA9-1FFE-3A52-A733-6236CBC45E7B}") IRemotingTypeInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_typeName(System::WideString &__Get_typeName_result) = 0 ;
	virtual HRESULT __safecall Set_typeName(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __safecall CanCastTo(const _di__Type fromType, const System::OleVariant o, System::WordBool &__CanCastTo_result) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_typeName() { System::WideString __r; HRESULT __hr = Get_typeName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString typeName = {read=_scw_Get_typeName};
};

__interface IChannelInfo;
typedef System::DelphiInterface<IChannelInfo> _di_IChannelInfo;
__interface  INTERFACE_UUID("{855E6566-014A-3FE8-AA70-1EAC771E3A88}") IChannelInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ChannelData(Activex::PSafeArray &__Get_ChannelData_result) = 0 ;
	virtual HRESULT __safecall Set_ChannelData(Activex::PSafeArray pRetVal) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_ChannelData() { Activex::PSafeArray __r; HRESULT __hr = Get_ChannelData(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray ChannelData = {read=_scw_Get_ChannelData};
};

__interface IEnvoyInfo;
typedef System::DelphiInterface<IEnvoyInfo> _di_IEnvoyInfo;
__interface  INTERFACE_UUID("{2A6E91B9-A874-38E4-99C2-C5D83D78140D}") IEnvoyInfo  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_EnvoySinks(_di_IMessageSink &__Get_EnvoySinks_result) = 0 ;
	virtual HRESULT __safecall _Set_EnvoySinks(const _di_IMessageSink pRetVal) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline _di_IMessageSink _scw_Get_EnvoySinks() { _di_IMessageSink __r; HRESULT __hr = Get_EnvoySinks(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property _di_IMessageSink EnvoySinks = {read=_scw_Get_EnvoySinks};
};

__interface  INTERFACE_UUID("{1DD3CF3D-DF8E-32FF-91EC-E19AA10B63FB}") _ObjRef  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8FFEDC68-5233-3FA8-813D-405AABB33ECB}") _OneWayAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D80FF312-2930-3680-A5E9-B48296C7415F}") _ProxyAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E0CF3F77-C7C3-33DA-BEB4-46147FC905DE}") _RealProxy  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{725692A5-9E12-37F6-911C-E3DA77E5FACA}") _SoapAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{EBCDCD84-8C74-39FD-821C-F5EB3A2704D7}") _SoapTypeAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C58145B5-BD5A-3896-95D9-B358F54FBC44}") _SoapMethodAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{46A3F9FF-F73C-33C7-BCC3-1BEF4B25E4AE}") _SoapFieldAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C32ABFC9-3917-30BF-A7BC-44250BDFC5D8}") _SoapParameterAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4B10971E-D61D-373F-BC8D-2CCF31126215}") _RemotingConfiguration  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8359F3AB-643F-3BCF-91E8-16E779EDEBE1}") _System_Runtime_Remoting_TypeEntry  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BAC12781-6865-3558-A8D1-F1CADD2806DD}") _ActivatedClientTypeEntry  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{94855A3B-5CA2-32CF-B1AB-48FD3915822C}") _ActivatedServiceTypeEntry  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4D0BC339-E3F9-3E9E-8F68-92168E6F6981}") _WellKnownClientTypeEntry  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{60B8B604-0AED-3093-AC05-EB98FB29FC47}") _WellKnownServiceTypeEntry  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7264843F-F60C-39A9-99E1-029126AA0815}") _RemotingException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{19373C44-55B4-3487-9AD8-4C621AAE85EA}") _ServerException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{44DB8E15-ACB1-34EE-81F9-56ED7AE37A5C}") _RemotingTimeoutException  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7B91368D-A50A-3D36-BE8E-5B8836A419AD}") _RemotingServices  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F4EFB305-CDC4-31C5-8102-33C9B91774F3}") _InternalRemotingServices  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{04A35D22-0B08-34E7-A573-88EF2374375E}") _MessageSurrogateFilter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{551F7A57-8651-37DB-A94A-6A3CA09C0ED7}") _RemotingSurrogateSelector  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7416B6EE-82E8-3A16-966B-018A40E7B1AA}") _SoapServices  : public IDispatch 
{
	
};

__interface ISoapXsd;
typedef System::DelphiInterface<ISoapXsd> _di_ISoapXsd;
__interface  INTERFACE_UUID("{80031D2A-AD59-3FB4-97F3-B864D71DA86B}") ISoapXsd  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall GetXsdType(System::WideString &__GetXsdType_result) = 0 ;
};

__interface  INTERFACE_UUID("{1738ADBC-156E-3897-844F-C3147C528DEA}") _SoapDateTime  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7EF50DDB-32A5-30A1-B412-47FAB911404A}") _SoapDuration  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A3BF0BCD-EC32-38E6-92F2-5F37BAD8030D}") _SoapTime  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CFA6E9D2-B3DE-39A6-94D1-CC691DE193F8}") _SoapDate  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{103C7EF9-A9EE-35FB-84C5-3086C9725A20}") _SoapYearMonth  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C20769F3-858D-316A-BE6D-C347A47948AD}") _SoapYear  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F9EAD0AA-4156-368F-AE05-FD59D70F758D}") _SoapMonthDay  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D9E8314D-5053-3497-8A33-97D3DCFE33E2}") _SoapDay  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{B4E32423-E473-3562-AA12-62FDE5A7D4A2}") _SoapMonth  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{63B9DA95-FB91-358A-B7B7-90C34AA34AB7}") _SoapHexBinary  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{8ED115A1-5E7B-34DC-AB85-90316F28015D}") _SoapBase64Binary  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{30C65C40-4E54-3051-9D8F-4709B6AB214C}") _SoapInteger  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4979EC29-C2B7-3AD6-986D-5AAF7344CC4E}") _SoapPositiveInteger  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AAF5401E-F71C-3FE3-8A73-A25074B20D3A}") _SoapNonPositiveInteger  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BC261FC6-7132-3FB5-9AAC-224845D3AA99}") _SoapNonNegativeInteger  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E384AA10-A70C-3943-97CF-0F7C282C3BDC}") _SoapNegativeInteger  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{818EC118-BE7E-3CDE-92C8-44B99160920E}") _SoapAnyUri  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3AC646B6-6B84-382F-9AED-22C2433244E6}") _SoapQName  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{974F01F4-6086-3137-9448-6A31FC9BEF08}") _SoapNotation  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{F4926B50-3F23-37E0-9AFA-AA91FF89A7BD}") _SoapNormalizedString  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AB4E97B9-651D-36F4-AABA-28ACF5746624}") _SoapToken  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{14AED851-A168-3462-B877-8F9A01126653}") _SoapLanguage  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{5EB06BEF-4ADF-3CC1-A6F2-62F76886B13A}") _SoapName  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7947A829-ADB5-34D0-9CC8-6C172742C803}") _SoapIdrefs  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{ACA96DA3-96ED-397E-8A72-EE1BE1025F5E}") _SoapEntities  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{E941FA15-E6C8-3DD4-B060-C0DDFBC0240A}") _SoapNmtoken  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A5E385AE-27FB-3708-BAF7-0BF1F3955747}") _SoapNmtokens  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{725CDAF7-B739-35C1-8463-E2A923E1F618}") _SoapNcName  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6A46B6A2-2D2C-3C67-AF67-AAE0175F17AE}") _SoapId  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7DB7FD83-DE89-38E1-9645-D4CABDE694C0}") _SoapIdref  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{37171746-B784-3586-A7D5-692A7604A66B}") _SoapEntity  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{2D985674-231C-33D4-B14D-F3A6BD2EBE19}") _SynchronizationAttribute  : public IDispatch 
{
	
};

__interface ITrackingHandler;
typedef System::DelphiInterface<ITrackingHandler> _di_ITrackingHandler;
__interface  INTERFACE_UUID("{03EC7D10-17A5-3585-9A2E-0596FCAC3870}") ITrackingHandler  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall MarshaledObject(const System::OleVariant obj, const _di__ObjRef or_) = 0 ;
	virtual HRESULT __safecall UnmarshaledObject(const System::OleVariant obj, const _di__ObjRef or_) = 0 ;
	virtual HRESULT __safecall DisconnectedObject(const System::OleVariant obj) = 0 ;
};

__interface  INTERFACE_UUID("{F51728F2-2DEF-308C-874A-CBB1BAA9CF9E}") _TrackingServices  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{717105A3-739B-3BC3-A2B7-AD215903FAD2}") _UrlAttribute  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{34EC3BD7-F2F6-3C20-A639-804BFF89DF65}") _IsolatedStorage  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{6BBB7DEE-186F-3D51-9486-BE0A71E915CE}") _IsolatedStorageFile  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{68D5592B-47C8-381A-8D51-3925C16CF025}") _IsolatedStorageFileStream  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AEC2B0DE-9898-3607-B845-63E2E307CB5F}") _IsolatedStorageException  : public IDispatch 
{
	
};

__interface INormalizeForIsolatedStorage;
typedef System::DelphiInterface<INormalizeForIsolatedStorage> _di_INormalizeForIsolatedStorage;
__interface  INTERFACE_UUID("{F5006531-D4D7-319E-9EDA-9B4B65AD8D4F}") INormalizeForIsolatedStorage  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Normalize(System::OleVariant &__Normalize_result) = 0 ;
};

__interface ISoapMessage;
typedef System::DelphiInterface<ISoapMessage> _di_ISoapMessage;
__interface  INTERFACE_UUID("{E699146C-7793-3455-9BEF-964C90D8F995}") ISoapMessage  : public IDispatch 
{
	
public:
	virtual HRESULT __safecall Get_ParamNames(Activex::PSafeArray &__Get_ParamNames_result) = 0 ;
	virtual HRESULT __safecall Set_ParamNames(Activex::PSafeArray pRetVal) = 0 ;
	virtual HRESULT __safecall Get_ParamValues(Activex::PSafeArray &__Get_ParamValues_result) = 0 ;
	virtual HRESULT __safecall Set_ParamValues(Activex::PSafeArray pRetVal) = 0 ;
	virtual HRESULT __safecall Get_ParamTypes(Activex::PSafeArray &__Get_ParamTypes_result) = 0 ;
	virtual HRESULT __safecall Set_ParamTypes(Activex::PSafeArray pRetVal) = 0 ;
	virtual HRESULT __safecall Get_MethodName(System::WideString &__Get_MethodName_result) = 0 ;
	virtual HRESULT __safecall Set_MethodName(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __safecall Get_XmlNameSpace(System::WideString &__Get_XmlNameSpace_result) = 0 ;
	virtual HRESULT __safecall Set_XmlNameSpace(const System::WideString pRetVal) = 0 ;
	virtual HRESULT __safecall Get_headers(Activex::PSafeArray &__Get_headers_result) = 0 ;
	virtual HRESULT __safecall Set_headers(Activex::PSafeArray pRetVal) = 0 ;
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_ParamNames() { Activex::PSafeArray __r; HRESULT __hr = Get_ParamNames(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray ParamNames = {read=_scw_Get_ParamNames};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_ParamValues() { Activex::PSafeArray __r; HRESULT __hr = Get_ParamValues(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray ParamValues = {read=_scw_Get_ParamValues};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_ParamTypes() { Activex::PSafeArray __r; HRESULT __hr = Get_ParamTypes(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray ParamTypes = {read=_scw_Get_ParamTypes};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_MethodName() { System::WideString __r; HRESULT __hr = Get_MethodName(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString MethodName = {read=_scw_Get_MethodName};
	#pragma option push -w-inl
	/* safecall wrapper */ inline System::WideString _scw_Get_XmlNameSpace() { System::WideString __r; HRESULT __hr = Get_XmlNameSpace(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property System::WideString XmlNameSpace = {read=_scw_Get_XmlNameSpace};
	#pragma option push -w-inl
	/* safecall wrapper */ inline Activex::PSafeArray _scw_Get_headers() { Activex::PSafeArray __r; HRESULT __hr = Get_headers(__r); System::CheckSafecallResult(__hr); return __r; }
	#pragma option pop
	__property Activex::PSafeArray headers = {read=_scw_Get_headers};
};

__interface  INTERFACE_UUID("{361A5049-1BC8-35A9-946A-53A877902F25}") _InternalRM  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A864FB13-F945-3DC0-A01C-B903F944FC97}") _InternalST  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BC0847B2-BD5C-37B3-BA67-7D2D54B17238}") _SoapMessage  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A1C392FC-314C-39D5-8DE6-1F8EBCA0A1E2}") _SoapFault  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{02D1BD78-3BB6-37AD-A9F8-F7D5DA273E4E}") _ServerFault  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{3BCF0CB2-A849-375E-8189-1BA5F1F4A9B0}") _BinaryFormatter  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BEBB2505-8B54-3443-AEAD-142A16DD9CC7}") _AssemblyBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{ED3E4384-D7E2-3FA7-8FFD-8940D330519A}") _ConstructorBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{AADABA99-895D-3D65-9760-B1F12621FAE8}") _EventBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{CE1A3BF5-975E-30CC-97C9-1EF70F8F3993}") _FieldBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{A4924B27-6E3B-37F7-9B83-A4501955E6A7}") _ILGenerator  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{4E6350D1-A08B-3DEC-9A3E-C465F9AEEC0C}") _LocalBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{007D8A14-FDF3-363E-9A0B-FEC0618260A2}") _MethodBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{BE9ACCE8-AAFF-3B91-81AE-8211663F5CAD}") _CustomAttributeBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C2323C25-F57F-3880-8A4D-12EBEA7A5852}") _MethodRental  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{D05FFA9A-04AF-3519-8EE1-8D93AD73430B}") _ModuleBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{1DB1CC2A-DA73-389E-828B-5C616F4FAC49}") _OpCodes  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{36329EBA-F97A-3565-BC07-0ED5C6EF19FC}") _ParameterBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{15F9A479-9397-3A63-ACBD-F51977FB0F02}") _PropertyBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7D13DD37-5A04-393C-BBCA-A5FEA802893D}") _SignatureHelper  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{7E5678EE-48B3-3F83-B076-C58543498A58}") _TypeBuilder  : public IDispatch 
{
	
};

__interface  INTERFACE_UUID("{C7BD73DE-9F85-3290-88EE-090B8BDFE2DF}") _EnumBuilder  : public IDispatch 
{
	
};

class DELPHICLASS CoAppDomain;
class PASCALIMPLEMENTATION CoAppDomain : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AppDomain __fastcall Create();
	__classmethod _di__AppDomain __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAppDomain(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAppDomain(void) { }
	
};


class DELPHICLASS CoRegistrationServices;
class PASCALIMPLEMENTATION CoRegistrationServices : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di_IRegistrationServices __fastcall Create();
	__classmethod _di_IRegistrationServices __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRegistrationServices(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRegistrationServices(void) { }
	
};


class DELPHICLASS CoTypeLibConverter;
class PASCALIMPLEMENTATION CoTypeLibConverter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di_ITypeLibConverter __fastcall Create();
	__classmethod _di_ITypeLibConverter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeLibConverter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeLibConverter(void) { }
	
};


class DELPHICLASS CoAppDomainSetup;
class PASCALIMPLEMENTATION CoAppDomainSetup : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di_IAppDomainSetup __fastcall Create();
	__classmethod _di_IAppDomainSetup __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAppDomainSetup(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAppDomainSetup(void) { }
	
};


class DELPHICLASS CoObject_;
class PASCALIMPLEMENTATION CoObject_ : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Object __fastcall Create();
	__classmethod _di__Object __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoObject_(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoObject_(void) { }
	
};


class DELPHICLASS CoArray_;
class PASCALIMPLEMENTATION CoArray_ : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Array __fastcall Create();
	__classmethod _di__Array __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoArray_(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoArray_(void) { }
	
};


class DELPHICLASS CoString_;
class PASCALIMPLEMENTATION CoString_ : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__String __fastcall Create();
	__classmethod _di__String __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoString_(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoString_(void) { }
	
};


class DELPHICLASS CoStringBuilder;
class PASCALIMPLEMENTATION CoStringBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StringBuilder __fastcall Create();
	__classmethod _di__StringBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStringBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStringBuilder(void) { }
	
};


class DELPHICLASS CoException;
class PASCALIMPLEMENTATION CoException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Exception __fastcall Create();
	__classmethod _di__Exception __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoException(void) { }
	
};


class DELPHICLASS CoValueType;
class PASCALIMPLEMENTATION CoValueType : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ValueType __fastcall Create();
	__classmethod _di__ValueType __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoValueType(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoValueType(void) { }
	
};


class DELPHICLASS CoSystemException;
class PASCALIMPLEMENTATION CoSystemException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SystemException __fastcall Create();
	__classmethod _di__SystemException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSystemException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSystemException(void) { }
	
};


class DELPHICLASS CoOutOfMemoryException;
class PASCALIMPLEMENTATION CoOutOfMemoryException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__OutOfMemoryException __fastcall Create();
	__classmethod _di__OutOfMemoryException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoOutOfMemoryException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoOutOfMemoryException(void) { }
	
};


class DELPHICLASS CoStackOverflowException;
class PASCALIMPLEMENTATION CoStackOverflowException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StackOverflowException __fastcall Create();
	__classmethod _di__StackOverflowException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStackOverflowException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStackOverflowException(void) { }
	
};


class DELPHICLASS CoExecutionEngineException;
class PASCALIMPLEMENTATION CoExecutionEngineException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ExecutionEngineException __fastcall Create();
	__classmethod _di__ExecutionEngineException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoExecutionEngineException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoExecutionEngineException(void) { }
	
};


class DELPHICLASS CoDelegate;
class PASCALIMPLEMENTATION CoDelegate : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Delegate __fastcall Create();
	__classmethod _di__Delegate __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDelegate(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDelegate(void) { }
	
};


class DELPHICLASS CoMulticastDelegate;
class PASCALIMPLEMENTATION CoMulticastDelegate : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MulticastDelegate __fastcall Create();
	__classmethod _di__MulticastDelegate __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMulticastDelegate(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMulticastDelegate(void) { }
	
};


class DELPHICLASS CoEnum;
class PASCALIMPLEMENTATION CoEnum : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Enum __fastcall Create();
	__classmethod _di__Enum __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEnum(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEnum(void) { }
	
};


class DELPHICLASS CoMemberAccessException;
class PASCALIMPLEMENTATION CoMemberAccessException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MemberAccessException __fastcall Create();
	__classmethod _di__MemberAccessException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMemberAccessException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMemberAccessException(void) { }
	
};


class DELPHICLASS CoActivator;
class PASCALIMPLEMENTATION CoActivator : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Activator __fastcall Create();
	__classmethod _di__Activator __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoActivator(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoActivator(void) { }
	
};


class DELPHICLASS CoApplicationException;
class PASCALIMPLEMENTATION CoApplicationException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ApplicationException __fastcall Create();
	__classmethod _di__ApplicationException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoApplicationException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoApplicationException(void) { }
	
};


class DELPHICLASS CoEventArgs;
class PASCALIMPLEMENTATION CoEventArgs : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EventArgs __fastcall Create();
	__classmethod _di__EventArgs __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEventArgs(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEventArgs(void) { }
	
};


class DELPHICLASS CoResolveEventArgs;
class PASCALIMPLEMENTATION CoResolveEventArgs : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ResolveEventArgs __fastcall Create();
	__classmethod _di__ResolveEventArgs __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoResolveEventArgs(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoResolveEventArgs(void) { }
	
};


class DELPHICLASS CoAssemblyLoadEventArgs;
class PASCALIMPLEMENTATION CoAssemblyLoadEventArgs : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyLoadEventArgs __fastcall Create();
	__classmethod _di__AssemblyLoadEventArgs __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyLoadEventArgs(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyLoadEventArgs(void) { }
	
};


class DELPHICLASS CoResolveEventHandler;
class PASCALIMPLEMENTATION CoResolveEventHandler : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ResolveEventHandler __fastcall Create();
	__classmethod _di__ResolveEventHandler __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoResolveEventHandler(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoResolveEventHandler(void) { }
	
};


class DELPHICLASS CoAssemblyLoadEventHandler;
class PASCALIMPLEMENTATION CoAssemblyLoadEventHandler : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyLoadEventHandler __fastcall Create();
	__classmethod _di__AssemblyLoadEventHandler __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyLoadEventHandler(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyLoadEventHandler(void) { }
	
};


class DELPHICLASS CoMarshalByRefObject;
class PASCALIMPLEMENTATION CoMarshalByRefObject : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MarshalByRefObject __fastcall Create();
	__classmethod _di__MarshalByRefObject __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMarshalByRefObject(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMarshalByRefObject(void) { }
	
};


class DELPHICLASS CoCrossAppDomainDelegate;
class PASCALIMPLEMENTATION CoCrossAppDomainDelegate : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CrossAppDomainDelegate __fastcall Create();
	__classmethod _di__CrossAppDomainDelegate __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCrossAppDomainDelegate(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCrossAppDomainDelegate(void) { }
	
};


class DELPHICLASS CoAttribute;
class PASCALIMPLEMENTATION CoAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Attribute __fastcall Create();
	__classmethod _di__Attribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAttribute(void) { }
	
};


class DELPHICLASS CoLoaderOptimizationAttribute;
class PASCALIMPLEMENTATION CoLoaderOptimizationAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__LoaderOptimizationAttribute __fastcall Create();
	__classmethod _di__LoaderOptimizationAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoLoaderOptimizationAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoLoaderOptimizationAttribute(void) { }
	
};


class DELPHICLASS CoAppDomainUnloadedException;
class PASCALIMPLEMENTATION CoAppDomainUnloadedException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AppDomainUnloadedException __fastcall Create();
	__classmethod _di__AppDomainUnloadedException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAppDomainUnloadedException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAppDomainUnloadedException(void) { }
	
};


class DELPHICLASS CoArgumentException;
class PASCALIMPLEMENTATION CoArgumentException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ArgumentException __fastcall Create();
	__classmethod _di__ArgumentException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoArgumentException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoArgumentException(void) { }
	
};


class DELPHICLASS CoArgumentNullException;
class PASCALIMPLEMENTATION CoArgumentNullException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ArgumentNullException __fastcall Create();
	__classmethod _di__ArgumentNullException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoArgumentNullException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoArgumentNullException(void) { }
	
};


class DELPHICLASS CoArgumentOutOfRangeException;
class PASCALIMPLEMENTATION CoArgumentOutOfRangeException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ArgumentOutOfRangeException __fastcall Create();
	__classmethod _di__ArgumentOutOfRangeException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoArgumentOutOfRangeException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoArgumentOutOfRangeException(void) { }
	
};


class DELPHICLASS CoArithmeticException;
class PASCALIMPLEMENTATION CoArithmeticException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ArithmeticException __fastcall Create();
	__classmethod _di__ArithmeticException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoArithmeticException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoArithmeticException(void) { }
	
};


class DELPHICLASS CoArrayTypeMismatchException;
class PASCALIMPLEMENTATION CoArrayTypeMismatchException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ArrayTypeMismatchException __fastcall Create();
	__classmethod _di__ArrayTypeMismatchException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoArrayTypeMismatchException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoArrayTypeMismatchException(void) { }
	
};


class DELPHICLASS CoAsyncCallback;
class PASCALIMPLEMENTATION CoAsyncCallback : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AsyncCallback __fastcall Create();
	__classmethod _di__AsyncCallback __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAsyncCallback(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAsyncCallback(void) { }
	
};


class DELPHICLASS CoAttributeUsageAttribute;
class PASCALIMPLEMENTATION CoAttributeUsageAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AttributeUsageAttribute __fastcall Create();
	__classmethod _di__AttributeUsageAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAttributeUsageAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAttributeUsageAttribute(void) { }
	
};


class DELPHICLASS CoBadImageFormatException;
class PASCALIMPLEMENTATION CoBadImageFormatException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BadImageFormatException __fastcall Create();
	__classmethod _di__BadImageFormatException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBadImageFormatException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBadImageFormatException(void) { }
	
};


class DELPHICLASS CoBitConverter;
class PASCALIMPLEMENTATION CoBitConverter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BitConverter __fastcall Create();
	__classmethod _di__BitConverter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBitConverter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBitConverter(void) { }
	
};


class DELPHICLASS CoBuffer;
class PASCALIMPLEMENTATION CoBuffer : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Buffer __fastcall Create();
	__classmethod _di__Buffer __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBuffer(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBuffer(void) { }
	
};


class DELPHICLASS CoCannotUnloadAppDomainException;
class PASCALIMPLEMENTATION CoCannotUnloadAppDomainException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CannotUnloadAppDomainException __fastcall Create();
	__classmethod _di__CannotUnloadAppDomainException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCannotUnloadAppDomainException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCannotUnloadAppDomainException(void) { }
	
};


class DELPHICLASS CoCharEnumerator;
class PASCALIMPLEMENTATION CoCharEnumerator : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CharEnumerator __fastcall Create();
	__classmethod _di__CharEnumerator __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCharEnumerator(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCharEnumerator(void) { }
	
};


class DELPHICLASS CoCLSCompliantAttribute;
class PASCALIMPLEMENTATION CoCLSCompliantAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CLSCompliantAttribute __fastcall Create();
	__classmethod _di__CLSCompliantAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCLSCompliantAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCLSCompliantAttribute(void) { }
	
};


class DELPHICLASS CoTypeUnloadedException;
class PASCALIMPLEMENTATION CoTypeUnloadedException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeUnloadedException __fastcall Create();
	__classmethod _di__TypeUnloadedException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeUnloadedException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeUnloadedException(void) { }
	
};


class DELPHICLASS CoConsole;
class PASCALIMPLEMENTATION CoConsole : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Console __fastcall Create();
	__classmethod _di__Console __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoConsole(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoConsole(void) { }
	
};


class DELPHICLASS CoContextMarshalException;
class PASCALIMPLEMENTATION CoContextMarshalException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ContextMarshalException __fastcall Create();
	__classmethod _di__ContextMarshalException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoContextMarshalException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoContextMarshalException(void) { }
	
};


class DELPHICLASS CoConvert;
class PASCALIMPLEMENTATION CoConvert : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Convert __fastcall Create();
	__classmethod _di__Convert __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoConvert(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoConvert(void) { }
	
};


class DELPHICLASS CoContextBoundObject;
class PASCALIMPLEMENTATION CoContextBoundObject : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ContextBoundObject __fastcall Create();
	__classmethod _di__ContextBoundObject __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoContextBoundObject(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoContextBoundObject(void) { }
	
};


class DELPHICLASS CoContextStaticAttribute;
class PASCALIMPLEMENTATION CoContextStaticAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ContextStaticAttribute __fastcall Create();
	__classmethod _di__ContextStaticAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoContextStaticAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoContextStaticAttribute(void) { }
	
};


class DELPHICLASS CoTimeZone;
class PASCALIMPLEMENTATION CoTimeZone : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TimeZone __fastcall Create();
	__classmethod _di__TimeZone __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTimeZone(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTimeZone(void) { }
	
};


class DELPHICLASS CoDBNull;
class PASCALIMPLEMENTATION CoDBNull : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DBNull __fastcall Create();
	__classmethod _di__DBNull __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDBNull(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDBNull(void) { }
	
};


class DELPHICLASS CoBinder;
class PASCALIMPLEMENTATION CoBinder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Binder __fastcall Create();
	__classmethod _di__Binder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBinder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBinder(void) { }
	
};


class DELPHICLASS CoDivideByZeroException;
class PASCALIMPLEMENTATION CoDivideByZeroException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DivideByZeroException __fastcall Create();
	__classmethod _di__DivideByZeroException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDivideByZeroException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDivideByZeroException(void) { }
	
};


class DELPHICLASS CoDuplicateWaitObjectException;
class PASCALIMPLEMENTATION CoDuplicateWaitObjectException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DuplicateWaitObjectException __fastcall Create();
	__classmethod _di__DuplicateWaitObjectException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDuplicateWaitObjectException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDuplicateWaitObjectException(void) { }
	
};


class DELPHICLASS CoTypeLoadException;
class PASCALIMPLEMENTATION CoTypeLoadException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeLoadException __fastcall Create();
	__classmethod _di__TypeLoadException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeLoadException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeLoadException(void) { }
	
};


class DELPHICLASS CoEntryPointNotFoundException;
class PASCALIMPLEMENTATION CoEntryPointNotFoundException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EntryPointNotFoundException __fastcall Create();
	__classmethod _di__EntryPointNotFoundException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEntryPointNotFoundException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEntryPointNotFoundException(void) { }
	
};


class DELPHICLASS CoDllNotFoundException;
class PASCALIMPLEMENTATION CoDllNotFoundException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DllNotFoundException __fastcall Create();
	__classmethod _di__DllNotFoundException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDllNotFoundException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDllNotFoundException(void) { }
	
};


class DELPHICLASS CoEnvironment;
class PASCALIMPLEMENTATION CoEnvironment : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Environment __fastcall Create();
	__classmethod _di__Environment __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEnvironment(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEnvironment(void) { }
	
};


class DELPHICLASS CoEventHandler;
class PASCALIMPLEMENTATION CoEventHandler : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EventHandler __fastcall Create();
	__classmethod _di__EventHandler __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEventHandler(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEventHandler(void) { }
	
};


class DELPHICLASS CoFieldAccessException;
class PASCALIMPLEMENTATION CoFieldAccessException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FieldAccessException __fastcall Create();
	__classmethod _di__FieldAccessException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFieldAccessException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFieldAccessException(void) { }
	
};


class DELPHICLASS CoFlagsAttribute;
class PASCALIMPLEMENTATION CoFlagsAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FlagsAttribute __fastcall Create();
	__classmethod _di__FlagsAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFlagsAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFlagsAttribute(void) { }
	
};


class DELPHICLASS CoFormatException;
class PASCALIMPLEMENTATION CoFormatException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FormatException __fastcall Create();
	__classmethod _di__FormatException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFormatException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFormatException(void) { }
	
};


class DELPHICLASS CoGC;
class PASCALIMPLEMENTATION CoGC : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__GC __fastcall Create();
	__classmethod _di__GC __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoGC(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoGC(void) { }
	
};


class DELPHICLASS CoIndexOutOfRangeException;
class PASCALIMPLEMENTATION CoIndexOutOfRangeException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IndexOutOfRangeException __fastcall Create();
	__classmethod _di__IndexOutOfRangeException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIndexOutOfRangeException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIndexOutOfRangeException(void) { }
	
};


class DELPHICLASS CoInvalidCastException;
class PASCALIMPLEMENTATION CoInvalidCastException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InvalidCastException __fastcall Create();
	__classmethod _di__InvalidCastException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInvalidCastException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInvalidCastException(void) { }
	
};


class DELPHICLASS CoInvalidOperationException;
class PASCALIMPLEMENTATION CoInvalidOperationException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InvalidOperationException __fastcall Create();
	__classmethod _di__InvalidOperationException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInvalidOperationException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInvalidOperationException(void) { }
	
};


class DELPHICLASS CoInvalidProgramException;
class PASCALIMPLEMENTATION CoInvalidProgramException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InvalidProgramException __fastcall Create();
	__classmethod _di__InvalidProgramException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInvalidProgramException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInvalidProgramException(void) { }
	
};


class DELPHICLASS CoLocalDataStoreSlot;
class PASCALIMPLEMENTATION CoLocalDataStoreSlot : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__LocalDataStoreSlot __fastcall Create();
	__classmethod _di__LocalDataStoreSlot __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoLocalDataStoreSlot(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoLocalDataStoreSlot(void) { }
	
};


class DELPHICLASS CoMath;
class PASCALIMPLEMENTATION CoMath : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Math __fastcall Create();
	__classmethod _di__Math __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMath(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMath(void) { }
	
};


class DELPHICLASS CoMethodAccessException;
class PASCALIMPLEMENTATION CoMethodAccessException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodAccessException __fastcall Create();
	__classmethod _di__MethodAccessException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodAccessException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodAccessException(void) { }
	
};


class DELPHICLASS CoMissingMemberException;
class PASCALIMPLEMENTATION CoMissingMemberException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MissingMemberException __fastcall Create();
	__classmethod _di__MissingMemberException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMissingMemberException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMissingMemberException(void) { }
	
};


class DELPHICLASS CoMissingFieldException;
class PASCALIMPLEMENTATION CoMissingFieldException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MissingFieldException __fastcall Create();
	__classmethod _di__MissingFieldException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMissingFieldException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMissingFieldException(void) { }
	
};


class DELPHICLASS CoMissingMethodException;
class PASCALIMPLEMENTATION CoMissingMethodException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MissingMethodException __fastcall Create();
	__classmethod _di__MissingMethodException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMissingMethodException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMissingMethodException(void) { }
	
};


class DELPHICLASS CoMulticastNotSupportedException;
class PASCALIMPLEMENTATION CoMulticastNotSupportedException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MulticastNotSupportedException __fastcall Create();
	__classmethod _di__MulticastNotSupportedException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMulticastNotSupportedException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMulticastNotSupportedException(void) { }
	
};


class DELPHICLASS CoNonSerializedAttribute;
class PASCALIMPLEMENTATION CoNonSerializedAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NonSerializedAttribute __fastcall Create();
	__classmethod _di__NonSerializedAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNonSerializedAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNonSerializedAttribute(void) { }
	
};


class DELPHICLASS CoNotFiniteNumberException;
class PASCALIMPLEMENTATION CoNotFiniteNumberException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NotFiniteNumberException __fastcall Create();
	__classmethod _di__NotFiniteNumberException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNotFiniteNumberException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNotFiniteNumberException(void) { }
	
};


class DELPHICLASS CoNotImplementedException;
class PASCALIMPLEMENTATION CoNotImplementedException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NotImplementedException __fastcall Create();
	__classmethod _di__NotImplementedException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNotImplementedException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNotImplementedException(void) { }
	
};


class DELPHICLASS CoNotSupportedException;
class PASCALIMPLEMENTATION CoNotSupportedException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NotSupportedException __fastcall Create();
	__classmethod _di__NotSupportedException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNotSupportedException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNotSupportedException(void) { }
	
};


class DELPHICLASS CoNullReferenceException;
class PASCALIMPLEMENTATION CoNullReferenceException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NullReferenceException __fastcall Create();
	__classmethod _di__NullReferenceException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNullReferenceException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNullReferenceException(void) { }
	
};


class DELPHICLASS CoObjectDisposedException;
class PASCALIMPLEMENTATION CoObjectDisposedException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ObjectDisposedException __fastcall Create();
	__classmethod _di__ObjectDisposedException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoObjectDisposedException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoObjectDisposedException(void) { }
	
};


class DELPHICLASS CoObsoleteAttribute;
class PASCALIMPLEMENTATION CoObsoleteAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ObsoleteAttribute __fastcall Create();
	__classmethod _di__ObsoleteAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoObsoleteAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoObsoleteAttribute(void) { }
	
};


class DELPHICLASS CoOperatingSystem;
class PASCALIMPLEMENTATION CoOperatingSystem : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__OperatingSystem __fastcall Create();
	__classmethod _di__OperatingSystem __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoOperatingSystem(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoOperatingSystem(void) { }
	
};


class DELPHICLASS CoOverflowException;
class PASCALIMPLEMENTATION CoOverflowException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__OverflowException __fastcall Create();
	__classmethod _di__OverflowException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoOverflowException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoOverflowException(void) { }
	
};


class DELPHICLASS CoParamArrayAttribute;
class PASCALIMPLEMENTATION CoParamArrayAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ParamArrayAttribute __fastcall Create();
	__classmethod _di__ParamArrayAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoParamArrayAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoParamArrayAttribute(void) { }
	
};


class DELPHICLASS CoPlatformNotSupportedException;
class PASCALIMPLEMENTATION CoPlatformNotSupportedException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PlatformNotSupportedException __fastcall Create();
	__classmethod _di__PlatformNotSupportedException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPlatformNotSupportedException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPlatformNotSupportedException(void) { }
	
};


class DELPHICLASS CoRandom;
class PASCALIMPLEMENTATION CoRandom : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Random __fastcall Create();
	__classmethod _di__Random __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRandom(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRandom(void) { }
	
};


class DELPHICLASS CoRankException;
class PASCALIMPLEMENTATION CoRankException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RankException __fastcall Create();
	__classmethod _di__RankException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRankException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRankException(void) { }
	
};


class DELPHICLASS CoMemberInfo;
class PASCALIMPLEMENTATION CoMemberInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MemberInfo __fastcall Create();
	__classmethod _di__MemberInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMemberInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMemberInfo(void) { }
	
};


class DELPHICLASS CoType_;
class PASCALIMPLEMENTATION CoType_ : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Type __fastcall Create();
	__classmethod _di__Type __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoType_(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoType_(void) { }
	
};


class DELPHICLASS CoSerializableAttribute;
class PASCALIMPLEMENTATION CoSerializableAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SerializableAttribute __fastcall Create();
	__classmethod _di__SerializableAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSerializableAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSerializableAttribute(void) { }
	
};


class DELPHICLASS CoTypeInitializationException;
class PASCALIMPLEMENTATION CoTypeInitializationException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeInitializationException __fastcall Create();
	__classmethod _di__TypeInitializationException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeInitializationException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeInitializationException(void) { }
	
};


class DELPHICLASS CoUnauthorizedAccessException;
class PASCALIMPLEMENTATION CoUnauthorizedAccessException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UnauthorizedAccessException __fastcall Create();
	__classmethod _di__UnauthorizedAccessException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUnauthorizedAccessException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUnauthorizedAccessException(void) { }
	
};


class DELPHICLASS CoUnhandledExceptionEventArgs;
class PASCALIMPLEMENTATION CoUnhandledExceptionEventArgs : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UnhandledExceptionEventArgs __fastcall Create();
	__classmethod _di__UnhandledExceptionEventArgs __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUnhandledExceptionEventArgs(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUnhandledExceptionEventArgs(void) { }
	
};


class DELPHICLASS CoUnhandledExceptionEventHandler;
class PASCALIMPLEMENTATION CoUnhandledExceptionEventHandler : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UnhandledExceptionEventHandler __fastcall Create();
	__classmethod _di__UnhandledExceptionEventHandler __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUnhandledExceptionEventHandler(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUnhandledExceptionEventHandler(void) { }
	
};


class DELPHICLASS CoVersion;
class PASCALIMPLEMENTATION CoVersion : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Version __fastcall Create();
	__classmethod _di__Version __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoVersion(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoVersion(void) { }
	
};


class DELPHICLASS CoWeakReference;
class PASCALIMPLEMENTATION CoWeakReference : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WeakReference __fastcall Create();
	__classmethod _di__WeakReference __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWeakReference(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWeakReference(void) { }
	
};


class DELPHICLASS CoWaitHandle;
class PASCALIMPLEMENTATION CoWaitHandle : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WaitHandle __fastcall Create();
	__classmethod _di__WaitHandle __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWaitHandle(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWaitHandle(void) { }
	
};


class DELPHICLASS CoAutoResetEvent;
class PASCALIMPLEMENTATION CoAutoResetEvent : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AutoResetEvent __fastcall Create();
	__classmethod _di__AutoResetEvent __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAutoResetEvent(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAutoResetEvent(void) { }
	
};


class DELPHICLASS CoCompressedStack;
class PASCALIMPLEMENTATION CoCompressedStack : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CompressedStack __fastcall Create();
	__classmethod _di__CompressedStack __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCompressedStack(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCompressedStack(void) { }
	
};


class DELPHICLASS CoInterlocked;
class PASCALIMPLEMENTATION CoInterlocked : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Interlocked __fastcall Create();
	__classmethod _di__Interlocked __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInterlocked(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInterlocked(void) { }
	
};


class DELPHICLASS CoManualResetEvent;
class PASCALIMPLEMENTATION CoManualResetEvent : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ManualResetEvent __fastcall Create();
	__classmethod _di__ManualResetEvent __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoManualResetEvent(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoManualResetEvent(void) { }
	
};


class DELPHICLASS CoMonitor;
class PASCALIMPLEMENTATION CoMonitor : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Monitor __fastcall Create();
	__classmethod _di__Monitor __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMonitor(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMonitor(void) { }
	
};


class DELPHICLASS CoMutex;
class PASCALIMPLEMENTATION CoMutex : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Mutex __fastcall Create();
	__classmethod _di__Mutex __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMutex(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMutex(void) { }
	
};


class DELPHICLASS CoOverlapped;
class PASCALIMPLEMENTATION CoOverlapped : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Overlapped __fastcall Create();
	__classmethod _di__Overlapped __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoOverlapped(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoOverlapped(void) { }
	
};


class DELPHICLASS CoReaderWriterLock;
class PASCALIMPLEMENTATION CoReaderWriterLock : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ReaderWriterLock __fastcall Create();
	__classmethod _di__ReaderWriterLock __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoReaderWriterLock(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoReaderWriterLock(void) { }
	
};


class DELPHICLASS CoSynchronizationLockException;
class PASCALIMPLEMENTATION CoSynchronizationLockException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SynchronizationLockException __fastcall Create();
	__classmethod _di__SynchronizationLockException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSynchronizationLockException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSynchronizationLockException(void) { }
	
};


class DELPHICLASS CoThread;
class PASCALIMPLEMENTATION CoThread : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Thread __fastcall Create();
	__classmethod _di__Thread __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoThread(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoThread(void) { }
	
};


class DELPHICLASS CoThreadAbortException;
class PASCALIMPLEMENTATION CoThreadAbortException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ThreadAbortException __fastcall Create();
	__classmethod _di__ThreadAbortException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoThreadAbortException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoThreadAbortException(void) { }
	
};


class DELPHICLASS CoSTAThreadAttribute;
class PASCALIMPLEMENTATION CoSTAThreadAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__STAThreadAttribute __fastcall Create();
	__classmethod _di__STAThreadAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSTAThreadAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSTAThreadAttribute(void) { }
	
};


class DELPHICLASS CoMTAThreadAttribute;
class PASCALIMPLEMENTATION CoMTAThreadAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MTAThreadAttribute __fastcall Create();
	__classmethod _di__MTAThreadAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMTAThreadAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMTAThreadAttribute(void) { }
	
};


class DELPHICLASS CoThreadInterruptedException;
class PASCALIMPLEMENTATION CoThreadInterruptedException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ThreadInterruptedException __fastcall Create();
	__classmethod _di__ThreadInterruptedException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoThreadInterruptedException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoThreadInterruptedException(void) { }
	
};


class DELPHICLASS CoRegisteredWaitHandle;
class PASCALIMPLEMENTATION CoRegisteredWaitHandle : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RegisteredWaitHandle __fastcall Create();
	__classmethod _di__RegisteredWaitHandle __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRegisteredWaitHandle(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRegisteredWaitHandle(void) { }
	
};


class DELPHICLASS CoWaitCallback;
class PASCALIMPLEMENTATION CoWaitCallback : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WaitCallback __fastcall Create();
	__classmethod _di__WaitCallback __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWaitCallback(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWaitCallback(void) { }
	
};


class DELPHICLASS CoWaitOrTimerCallback;
class PASCALIMPLEMENTATION CoWaitOrTimerCallback : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WaitOrTimerCallback __fastcall Create();
	__classmethod _di__WaitOrTimerCallback __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWaitOrTimerCallback(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWaitOrTimerCallback(void) { }
	
};


class DELPHICLASS CoIOCompletionCallback;
class PASCALIMPLEMENTATION CoIOCompletionCallback : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IOCompletionCallback __fastcall Create();
	__classmethod _di__IOCompletionCallback __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIOCompletionCallback(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIOCompletionCallback(void) { }
	
};


class DELPHICLASS CoThreadPool;
class PASCALIMPLEMENTATION CoThreadPool : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ThreadPool __fastcall Create();
	__classmethod _di__ThreadPool __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoThreadPool(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoThreadPool(void) { }
	
};


class DELPHICLASS CoThreadStart;
class PASCALIMPLEMENTATION CoThreadStart : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ThreadStart __fastcall Create();
	__classmethod _di__ThreadStart __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoThreadStart(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoThreadStart(void) { }
	
};


class DELPHICLASS CoThreadStateException;
class PASCALIMPLEMENTATION CoThreadStateException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ThreadStateException __fastcall Create();
	__classmethod _di__ThreadStateException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoThreadStateException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoThreadStateException(void) { }
	
};


class DELPHICLASS CoThreadStaticAttribute;
class PASCALIMPLEMENTATION CoThreadStaticAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ThreadStaticAttribute __fastcall Create();
	__classmethod _di__ThreadStaticAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoThreadStaticAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoThreadStaticAttribute(void) { }
	
};


class DELPHICLASS CoTimeout;
class PASCALIMPLEMENTATION CoTimeout : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Timeout __fastcall Create();
	__classmethod _di__Timeout __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTimeout(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTimeout(void) { }
	
};


class DELPHICLASS CoTimerCallback;
class PASCALIMPLEMENTATION CoTimerCallback : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TimerCallback __fastcall Create();
	__classmethod _di__TimerCallback __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTimerCallback(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTimerCallback(void) { }
	
};


class DELPHICLASS CoTimer;
class PASCALIMPLEMENTATION CoTimer : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Timer __fastcall Create();
	__classmethod _di__Timer __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTimer(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTimer(void) { }
	
};


class DELPHICLASS CoArrayList;
class PASCALIMPLEMENTATION CoArrayList : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ArrayList __fastcall Create();
	__classmethod _di__ArrayList __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoArrayList(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoArrayList(void) { }
	
};


class DELPHICLASS CoBitArray;
class PASCALIMPLEMENTATION CoBitArray : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BitArray __fastcall Create();
	__classmethod _di__BitArray __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBitArray(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBitArray(void) { }
	
};


class DELPHICLASS CoCaseInsensitiveComparer;
class PASCALIMPLEMENTATION CoCaseInsensitiveComparer : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CaseInsensitiveComparer __fastcall Create();
	__classmethod _di__CaseInsensitiveComparer __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCaseInsensitiveComparer(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCaseInsensitiveComparer(void) { }
	
};


class DELPHICLASS CoCaseInsensitiveHashCodeProvider;
class PASCALIMPLEMENTATION CoCaseInsensitiveHashCodeProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CaseInsensitiveHashCodeProvider __fastcall Create();
	__classmethod _di__CaseInsensitiveHashCodeProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCaseInsensitiveHashCodeProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCaseInsensitiveHashCodeProvider(void) { }
	
};


class DELPHICLASS CoCollectionBase;
class PASCALIMPLEMENTATION CoCollectionBase : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CollectionBase __fastcall Create();
	__classmethod _di__CollectionBase __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCollectionBase(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCollectionBase(void) { }
	
};


class DELPHICLASS CoComparer;
class PASCALIMPLEMENTATION CoComparer : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Comparer __fastcall Create();
	__classmethod _di__Comparer __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComparer(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComparer(void) { }
	
};


class DELPHICLASS CoDictionaryBase;
class PASCALIMPLEMENTATION CoDictionaryBase : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DictionaryBase __fastcall Create();
	__classmethod _di__DictionaryBase __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDictionaryBase(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDictionaryBase(void) { }
	
};


class DELPHICLASS CoHashtable;
class PASCALIMPLEMENTATION CoHashtable : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Hashtable __fastcall Create();
	__classmethod _di__Hashtable __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHashtable(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHashtable(void) { }
	
};


class DELPHICLASS CoQueue;
class PASCALIMPLEMENTATION CoQueue : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Queue __fastcall Create();
	__classmethod _di__Queue __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoQueue(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoQueue(void) { }
	
};


class DELPHICLASS CoReadOnlyCollectionBase;
class PASCALIMPLEMENTATION CoReadOnlyCollectionBase : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ReadOnlyCollectionBase __fastcall Create();
	__classmethod _di__ReadOnlyCollectionBase __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoReadOnlyCollectionBase(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoReadOnlyCollectionBase(void) { }
	
};


class DELPHICLASS CoSortedList;
class PASCALIMPLEMENTATION CoSortedList : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SortedList __fastcall Create();
	__classmethod _di__SortedList __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSortedList(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSortedList(void) { }
	
};


class DELPHICLASS CoStack;
class PASCALIMPLEMENTATION CoStack : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Stack __fastcall Create();
	__classmethod _di__Stack __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStack(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStack(void) { }
	
};


class DELPHICLASS CoConditionalAttribute;
class PASCALIMPLEMENTATION CoConditionalAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ConditionalAttribute __fastcall Create();
	__classmethod _di__ConditionalAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoConditionalAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoConditionalAttribute(void) { }
	
};


class DELPHICLASS CoDebugger;
class PASCALIMPLEMENTATION CoDebugger : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Debugger __fastcall Create();
	__classmethod _di__Debugger __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDebugger(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDebugger(void) { }
	
};


class DELPHICLASS CoDebuggerStepThroughAttribute;
class PASCALIMPLEMENTATION CoDebuggerStepThroughAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DebuggerStepThroughAttribute __fastcall Create();
	__classmethod _di__DebuggerStepThroughAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDebuggerStepThroughAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDebuggerStepThroughAttribute(void) { }
	
};


class DELPHICLASS CoDebuggerHiddenAttribute;
class PASCALIMPLEMENTATION CoDebuggerHiddenAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DebuggerHiddenAttribute __fastcall Create();
	__classmethod _di__DebuggerHiddenAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDebuggerHiddenAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDebuggerHiddenAttribute(void) { }
	
};


class DELPHICLASS CoDebuggableAttribute;
class PASCALIMPLEMENTATION CoDebuggableAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DebuggableAttribute __fastcall Create();
	__classmethod _di__DebuggableAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDebuggableAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDebuggableAttribute(void) { }
	
};


class DELPHICLASS CoStackTrace;
class PASCALIMPLEMENTATION CoStackTrace : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StackTrace __fastcall Create();
	__classmethod _di__StackTrace __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStackTrace(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStackTrace(void) { }
	
};


class DELPHICLASS CoStackFrame;
class PASCALIMPLEMENTATION CoStackFrame : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StackFrame __fastcall Create();
	__classmethod _di__StackFrame __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStackFrame(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStackFrame(void) { }
	
};


class DELPHICLASS CoSymDocumentType;
class PASCALIMPLEMENTATION CoSymDocumentType : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SymDocumentType __fastcall Create();
	__classmethod _di__SymDocumentType __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSymDocumentType(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSymDocumentType(void) { }
	
};


class DELPHICLASS CoSymLanguageType;
class PASCALIMPLEMENTATION CoSymLanguageType : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SymLanguageType __fastcall Create();
	__classmethod _di__SymLanguageType __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSymLanguageType(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSymLanguageType(void) { }
	
};


class DELPHICLASS CoSymLanguageVendor;
class PASCALIMPLEMENTATION CoSymLanguageVendor : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SymLanguageVendor __fastcall Create();
	__classmethod _di__SymLanguageVendor __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSymLanguageVendor(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSymLanguageVendor(void) { }
	
};


class DELPHICLASS CoAmbiguousMatchException;
class PASCALIMPLEMENTATION CoAmbiguousMatchException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AmbiguousMatchException __fastcall Create();
	__classmethod _di__AmbiguousMatchException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAmbiguousMatchException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAmbiguousMatchException(void) { }
	
};


class DELPHICLASS CoModuleResolveEventHandler;
class PASCALIMPLEMENTATION CoModuleResolveEventHandler : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ModuleResolveEventHandler __fastcall Create();
	__classmethod _di__ModuleResolveEventHandler __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoModuleResolveEventHandler(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoModuleResolveEventHandler(void) { }
	
};


class DELPHICLASS CoAssembly;
class PASCALIMPLEMENTATION CoAssembly : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Assembly __fastcall Create();
	__classmethod _di__Assembly __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssembly(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssembly(void) { }
	
};


class DELPHICLASS CoAssemblyCultureAttribute;
class PASCALIMPLEMENTATION CoAssemblyCultureAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyCultureAttribute __fastcall Create();
	__classmethod _di__AssemblyCultureAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyCultureAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyCultureAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyVersionAttribute;
class PASCALIMPLEMENTATION CoAssemblyVersionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyVersionAttribute __fastcall Create();
	__classmethod _di__AssemblyVersionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyVersionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyVersionAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyKeyFileAttribute;
class PASCALIMPLEMENTATION CoAssemblyKeyFileAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyKeyFileAttribute __fastcall Create();
	__classmethod _di__AssemblyKeyFileAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyKeyFileAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyKeyFileAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyKeyNameAttribute;
class PASCALIMPLEMENTATION CoAssemblyKeyNameAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyKeyNameAttribute __fastcall Create();
	__classmethod _di__AssemblyKeyNameAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyKeyNameAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyKeyNameAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyDelaySignAttribute;
class PASCALIMPLEMENTATION CoAssemblyDelaySignAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyDelaySignAttribute __fastcall Create();
	__classmethod _di__AssemblyDelaySignAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyDelaySignAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyDelaySignAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyAlgorithmIdAttribute;
class PASCALIMPLEMENTATION CoAssemblyAlgorithmIdAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyAlgorithmIdAttribute __fastcall Create();
	__classmethod _di__AssemblyAlgorithmIdAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyAlgorithmIdAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyAlgorithmIdAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyFlagsAttribute;
class PASCALIMPLEMENTATION CoAssemblyFlagsAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyFlagsAttribute __fastcall Create();
	__classmethod _di__AssemblyFlagsAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyFlagsAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyFlagsAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyFileVersionAttribute;
class PASCALIMPLEMENTATION CoAssemblyFileVersionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyFileVersionAttribute __fastcall Create();
	__classmethod _di__AssemblyFileVersionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyFileVersionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyFileVersionAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyName;
class PASCALIMPLEMENTATION CoAssemblyName : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyName __fastcall Create();
	__classmethod _di__AssemblyName __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyName(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyName(void) { }
	
};


class DELPHICLASS CoAssemblyNameProxy;
class PASCALIMPLEMENTATION CoAssemblyNameProxy : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyNameProxy __fastcall Create();
	__classmethod _di__AssemblyNameProxy __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyNameProxy(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyNameProxy(void) { }
	
};


class DELPHICLASS CoAssemblyCopyrightAttribute;
class PASCALIMPLEMENTATION CoAssemblyCopyrightAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyCopyrightAttribute __fastcall Create();
	__classmethod _di__AssemblyCopyrightAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyCopyrightAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyCopyrightAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyTrademarkAttribute;
class PASCALIMPLEMENTATION CoAssemblyTrademarkAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyTrademarkAttribute __fastcall Create();
	__classmethod _di__AssemblyTrademarkAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyTrademarkAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyTrademarkAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyProductAttribute;
class PASCALIMPLEMENTATION CoAssemblyProductAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyProductAttribute __fastcall Create();
	__classmethod _di__AssemblyProductAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyProductAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyProductAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyCompanyAttribute;
class PASCALIMPLEMENTATION CoAssemblyCompanyAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyCompanyAttribute __fastcall Create();
	__classmethod _di__AssemblyCompanyAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyCompanyAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyCompanyAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyDescriptionAttribute;
class PASCALIMPLEMENTATION CoAssemblyDescriptionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyDescriptionAttribute __fastcall Create();
	__classmethod _di__AssemblyDescriptionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyDescriptionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyDescriptionAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyTitleAttribute;
class PASCALIMPLEMENTATION CoAssemblyTitleAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyTitleAttribute __fastcall Create();
	__classmethod _di__AssemblyTitleAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyTitleAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyTitleAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyConfigurationAttribute;
class PASCALIMPLEMENTATION CoAssemblyConfigurationAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyConfigurationAttribute __fastcall Create();
	__classmethod _di__AssemblyConfigurationAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyConfigurationAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyConfigurationAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyDefaultAliasAttribute;
class PASCALIMPLEMENTATION CoAssemblyDefaultAliasAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyDefaultAliasAttribute __fastcall Create();
	__classmethod _di__AssemblyDefaultAliasAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyDefaultAliasAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyDefaultAliasAttribute(void) { }
	
};


class DELPHICLASS CoAssemblyInformationalVersionAttribute;
class PASCALIMPLEMENTATION CoAssemblyInformationalVersionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyInformationalVersionAttribute __fastcall Create();
	__classmethod _di__AssemblyInformationalVersionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyInformationalVersionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyInformationalVersionAttribute(void) { }
	
};


class DELPHICLASS CoCustomAttributeFormatException;
class PASCALIMPLEMENTATION CoCustomAttributeFormatException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CustomAttributeFormatException __fastcall Create();
	__classmethod _di__CustomAttributeFormatException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCustomAttributeFormatException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCustomAttributeFormatException(void) { }
	
};


class DELPHICLASS CoMethodBase;
class PASCALIMPLEMENTATION CoMethodBase : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodBase __fastcall Create();
	__classmethod _di__MethodBase __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodBase(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodBase(void) { }
	
};


class DELPHICLASS CoConstructorInfo;
class PASCALIMPLEMENTATION CoConstructorInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ConstructorInfo __fastcall Create();
	__classmethod _di__ConstructorInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoConstructorInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoConstructorInfo(void) { }
	
};


class DELPHICLASS CoDefaultMemberAttribute;
class PASCALIMPLEMENTATION CoDefaultMemberAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DefaultMemberAttribute __fastcall Create();
	__classmethod _di__DefaultMemberAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDefaultMemberAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDefaultMemberAttribute(void) { }
	
};


class DELPHICLASS CoEventInfo;
class PASCALIMPLEMENTATION CoEventInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EventInfo __fastcall Create();
	__classmethod _di__EventInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEventInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEventInfo(void) { }
	
};


class DELPHICLASS CoFieldInfo;
class PASCALIMPLEMENTATION CoFieldInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FieldInfo __fastcall Create();
	__classmethod _di__FieldInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFieldInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFieldInfo(void) { }
	
};


class DELPHICLASS CoInvalidFilterCriteriaException;
class PASCALIMPLEMENTATION CoInvalidFilterCriteriaException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InvalidFilterCriteriaException __fastcall Create();
	__classmethod _di__InvalidFilterCriteriaException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInvalidFilterCriteriaException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInvalidFilterCriteriaException(void) { }
	
};


class DELPHICLASS CoManifestResourceInfo;
class PASCALIMPLEMENTATION CoManifestResourceInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ManifestResourceInfo __fastcall Create();
	__classmethod _di__ManifestResourceInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoManifestResourceInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoManifestResourceInfo(void) { }
	
};


class DELPHICLASS CoMemberFilter;
class PASCALIMPLEMENTATION CoMemberFilter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MemberFilter __fastcall Create();
	__classmethod _di__MemberFilter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMemberFilter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMemberFilter(void) { }
	
};


class DELPHICLASS CoMethodInfo;
class PASCALIMPLEMENTATION CoMethodInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodInfo __fastcall Create();
	__classmethod _di__MethodInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodInfo(void) { }
	
};


class DELPHICLASS CoMissing;
class PASCALIMPLEMENTATION CoMissing : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Missing __fastcall Create();
	__classmethod _di__Missing __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMissing(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMissing(void) { }
	
};


class DELPHICLASS CoModule;
class PASCALIMPLEMENTATION CoModule : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Module __fastcall Create();
	__classmethod _di__Module __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoModule(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoModule(void) { }
	
};


class DELPHICLASS CoParameterInfo;
class PASCALIMPLEMENTATION CoParameterInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ParameterInfo __fastcall Create();
	__classmethod _di__ParameterInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoParameterInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoParameterInfo(void) { }
	
};


class DELPHICLASS CoPointer;
class PASCALIMPLEMENTATION CoPointer : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Pointer __fastcall Create();
	__classmethod _di__Pointer __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPointer(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPointer(void) { }
	
};


class DELPHICLASS CoPropertyInfo;
class PASCALIMPLEMENTATION CoPropertyInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PropertyInfo __fastcall Create();
	__classmethod _di__PropertyInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPropertyInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPropertyInfo(void) { }
	
};


class DELPHICLASS CoReflectionTypeLoadException;
class PASCALIMPLEMENTATION CoReflectionTypeLoadException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ReflectionTypeLoadException __fastcall Create();
	__classmethod _di__ReflectionTypeLoadException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoReflectionTypeLoadException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoReflectionTypeLoadException(void) { }
	
};


class DELPHICLASS CoStrongNameKeyPair;
class PASCALIMPLEMENTATION CoStrongNameKeyPair : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StrongNameKeyPair __fastcall Create();
	__classmethod _di__StrongNameKeyPair __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStrongNameKeyPair(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStrongNameKeyPair(void) { }
	
};


class DELPHICLASS CoTargetException;
class PASCALIMPLEMENTATION CoTargetException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TargetException __fastcall Create();
	__classmethod _di__TargetException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTargetException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTargetException(void) { }
	
};


class DELPHICLASS CoTargetInvocationException;
class PASCALIMPLEMENTATION CoTargetInvocationException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TargetInvocationException __fastcall Create();
	__classmethod _di__TargetInvocationException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTargetInvocationException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTargetInvocationException(void) { }
	
};


class DELPHICLASS CoTargetParameterCountException;
class PASCALIMPLEMENTATION CoTargetParameterCountException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TargetParameterCountException __fastcall Create();
	__classmethod _di__TargetParameterCountException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTargetParameterCountException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTargetParameterCountException(void) { }
	
};


class DELPHICLASS CoTypeDelegator;
class PASCALIMPLEMENTATION CoTypeDelegator : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeDelegator __fastcall Create();
	__classmethod _di__TypeDelegator __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeDelegator(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeDelegator(void) { }
	
};


class DELPHICLASS CoTypeFilter;
class PASCALIMPLEMENTATION CoTypeFilter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeFilter __fastcall Create();
	__classmethod _di__TypeFilter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeFilter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeFilter(void) { }
	
};


class DELPHICLASS CoUnmanagedMarshal;
class PASCALIMPLEMENTATION CoUnmanagedMarshal : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UnmanagedMarshal __fastcall Create();
	__classmethod _di__UnmanagedMarshal __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUnmanagedMarshal(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUnmanagedMarshal(void) { }
	
};


class DELPHICLASS CoFormatter;
class PASCALIMPLEMENTATION CoFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Formatter __fastcall Create();
	__classmethod _di__Formatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFormatter(void) { }
	
};


class DELPHICLASS CoFormatterConverter;
class PASCALIMPLEMENTATION CoFormatterConverter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FormatterConverter __fastcall Create();
	__classmethod _di__FormatterConverter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFormatterConverter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFormatterConverter(void) { }
	
};


class DELPHICLASS CoFormatterServices;
class PASCALIMPLEMENTATION CoFormatterServices : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FormatterServices __fastcall Create();
	__classmethod _di__FormatterServices __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFormatterServices(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFormatterServices(void) { }
	
};


class DELPHICLASS CoObjectIDGenerator;
class PASCALIMPLEMENTATION CoObjectIDGenerator : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ObjectIDGenerator __fastcall Create();
	__classmethod _di__ObjectIDGenerator __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoObjectIDGenerator(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoObjectIDGenerator(void) { }
	
};


class DELPHICLASS CoObjectManager;
class PASCALIMPLEMENTATION CoObjectManager : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ObjectManager __fastcall Create();
	__classmethod _di__ObjectManager __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoObjectManager(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoObjectManager(void) { }
	
};


class DELPHICLASS CoSerializationBinder;
class PASCALIMPLEMENTATION CoSerializationBinder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SerializationBinder __fastcall Create();
	__classmethod _di__SerializationBinder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSerializationBinder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSerializationBinder(void) { }
	
};


class DELPHICLASS CoSerializationInfo;
class PASCALIMPLEMENTATION CoSerializationInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SerializationInfo __fastcall Create();
	__classmethod _di__SerializationInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSerializationInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSerializationInfo(void) { }
	
};


class DELPHICLASS CoSerializationInfoEnumerator;
class PASCALIMPLEMENTATION CoSerializationInfoEnumerator : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SerializationInfoEnumerator __fastcall Create();
	__classmethod _di__SerializationInfoEnumerator __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSerializationInfoEnumerator(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSerializationInfoEnumerator(void) { }
	
};


class DELPHICLASS CoSerializationException;
class PASCALIMPLEMENTATION CoSerializationException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SerializationException __fastcall Create();
	__classmethod _di__SerializationException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSerializationException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSerializationException(void) { }
	
};


class DELPHICLASS CoSurrogateSelector;
class PASCALIMPLEMENTATION CoSurrogateSelector : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SurrogateSelector __fastcall Create();
	__classmethod _di__SurrogateSelector __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSurrogateSelector(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSurrogateSelector(void) { }
	
};


class DELPHICLASS CoCalendar;
class PASCALIMPLEMENTATION CoCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Calendar __fastcall Create();
	__classmethod _di__Calendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCalendar(void) { }
	
};


class DELPHICLASS CoCompareInfo;
class PASCALIMPLEMENTATION CoCompareInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CompareInfo __fastcall Create();
	__classmethod _di__CompareInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCompareInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCompareInfo(void) { }
	
};


class DELPHICLASS CoCultureInfo;
class PASCALIMPLEMENTATION CoCultureInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CultureInfo __fastcall Create();
	__classmethod _di__CultureInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCultureInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCultureInfo(void) { }
	
};


class DELPHICLASS CoDateTimeFormatInfo;
class PASCALIMPLEMENTATION CoDateTimeFormatInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DateTimeFormatInfo __fastcall Create();
	__classmethod _di__DateTimeFormatInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDateTimeFormatInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDateTimeFormatInfo(void) { }
	
};


class DELPHICLASS CoDaylightTime;
class PASCALIMPLEMENTATION CoDaylightTime : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DaylightTime __fastcall Create();
	__classmethod _di__DaylightTime __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDaylightTime(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDaylightTime(void) { }
	
};


class DELPHICLASS CoGregorianCalendar;
class PASCALIMPLEMENTATION CoGregorianCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__GregorianCalendar __fastcall Create();
	__classmethod _di__GregorianCalendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoGregorianCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoGregorianCalendar(void) { }
	
};


class DELPHICLASS CoHebrewCalendar;
class PASCALIMPLEMENTATION CoHebrewCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__HebrewCalendar __fastcall Create();
	__classmethod _di__HebrewCalendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHebrewCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHebrewCalendar(void) { }
	
};


class DELPHICLASS CoHijriCalendar;
class PASCALIMPLEMENTATION CoHijriCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__HijriCalendar __fastcall Create();
	__classmethod _di__HijriCalendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHijriCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHijriCalendar(void) { }
	
};


class DELPHICLASS CoJapaneseCalendar;
class PASCALIMPLEMENTATION CoJapaneseCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__JapaneseCalendar __fastcall Create();
	__classmethod _di__JapaneseCalendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoJapaneseCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoJapaneseCalendar(void) { }
	
};


class DELPHICLASS CoJulianCalendar;
class PASCALIMPLEMENTATION CoJulianCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__JulianCalendar __fastcall Create();
	__classmethod _di__JulianCalendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoJulianCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoJulianCalendar(void) { }
	
};


class DELPHICLASS CoKoreanCalendar;
class PASCALIMPLEMENTATION CoKoreanCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__KoreanCalendar __fastcall Create();
	__classmethod _di__KoreanCalendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoKoreanCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoKoreanCalendar(void) { }
	
};


class DELPHICLASS CoRegionInfo;
class PASCALIMPLEMENTATION CoRegionInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RegionInfo __fastcall Create();
	__classmethod _di__RegionInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRegionInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRegionInfo(void) { }
	
};


class DELPHICLASS CoSortKey;
class PASCALIMPLEMENTATION CoSortKey : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SortKey __fastcall Create();
	__classmethod _di__SortKey __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSortKey(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSortKey(void) { }
	
};


class DELPHICLASS CoStringInfo;
class PASCALIMPLEMENTATION CoStringInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StringInfo __fastcall Create();
	__classmethod _di__StringInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStringInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStringInfo(void) { }
	
};


class DELPHICLASS CoTaiwanCalendar;
class PASCALIMPLEMENTATION CoTaiwanCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TaiwanCalendar __fastcall Create();
	__classmethod _di__TaiwanCalendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTaiwanCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTaiwanCalendar(void) { }
	
};


class DELPHICLASS CoTextElementEnumerator;
class PASCALIMPLEMENTATION CoTextElementEnumerator : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TextElementEnumerator __fastcall Create();
	__classmethod _di__TextElementEnumerator __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTextElementEnumerator(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTextElementEnumerator(void) { }
	
};


class DELPHICLASS CoTextInfo;
class PASCALIMPLEMENTATION CoTextInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TextInfo __fastcall Create();
	__classmethod _di__TextInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTextInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTextInfo(void) { }
	
};


class DELPHICLASS CoThaiBuddhistCalendar;
class PASCALIMPLEMENTATION CoThaiBuddhistCalendar : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ThaiBuddhistCalendar __fastcall Create();
	__classmethod _di__ThaiBuddhistCalendar __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoThaiBuddhistCalendar(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoThaiBuddhistCalendar(void) { }
	
};


class DELPHICLASS CoNumberFormatInfo;
class PASCALIMPLEMENTATION CoNumberFormatInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NumberFormatInfo __fastcall Create();
	__classmethod _di__NumberFormatInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNumberFormatInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNumberFormatInfo(void) { }
	
};


class DELPHICLASS CoEncoding;
class PASCALIMPLEMENTATION CoEncoding : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Encoding __fastcall Create();
	__classmethod _di__Encoding __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEncoding(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEncoding(void) { }
	
};


class DELPHICLASS CoSystem_Text_Decoder;
class PASCALIMPLEMENTATION CoSystem_Text_Decoder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__System_Text_Decoder __fastcall Create();
	__classmethod _di__System_Text_Decoder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSystem_Text_Decoder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSystem_Text_Decoder(void) { }
	
};


class DELPHICLASS CoSystem_Text_Encoder;
class PASCALIMPLEMENTATION CoSystem_Text_Encoder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__System_Text_Encoder __fastcall Create();
	__classmethod _di__System_Text_Encoder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSystem_Text_Encoder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSystem_Text_Encoder(void) { }
	
};


class DELPHICLASS CoASCIIEncoding;
class PASCALIMPLEMENTATION CoASCIIEncoding : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ASCIIEncoding __fastcall Create();
	__classmethod _di__ASCIIEncoding __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoASCIIEncoding(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoASCIIEncoding(void) { }
	
};


class DELPHICLASS CoUnicodeEncoding;
class PASCALIMPLEMENTATION CoUnicodeEncoding : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UnicodeEncoding __fastcall Create();
	__classmethod _di__UnicodeEncoding __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUnicodeEncoding(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUnicodeEncoding(void) { }
	
};


class DELPHICLASS CoUTF7Encoding;
class PASCALIMPLEMENTATION CoUTF7Encoding : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UTF7Encoding __fastcall Create();
	__classmethod _di__UTF7Encoding __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUTF7Encoding(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUTF7Encoding(void) { }
	
};


class DELPHICLASS CoUTF8Encoding;
class PASCALIMPLEMENTATION CoUTF8Encoding : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UTF8Encoding __fastcall Create();
	__classmethod _di__UTF8Encoding __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUTF8Encoding(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUTF8Encoding(void) { }
	
};


class DELPHICLASS CoMissingManifestResourceException;
class PASCALIMPLEMENTATION CoMissingManifestResourceException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MissingManifestResourceException __fastcall Create();
	__classmethod _di__MissingManifestResourceException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMissingManifestResourceException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMissingManifestResourceException(void) { }
	
};


class DELPHICLASS CoNeutralResourcesLanguageAttribute;
class PASCALIMPLEMENTATION CoNeutralResourcesLanguageAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NeutralResourcesLanguageAttribute __fastcall Create();
	__classmethod _di__NeutralResourcesLanguageAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNeutralResourcesLanguageAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNeutralResourcesLanguageAttribute(void) { }
	
};


class DELPHICLASS CoResourceManager;
class PASCALIMPLEMENTATION CoResourceManager : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ResourceManager __fastcall Create();
	__classmethod _di__ResourceManager __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoResourceManager(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoResourceManager(void) { }
	
};


class DELPHICLASS CoResourceReader;
class PASCALIMPLEMENTATION CoResourceReader : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ResourceReader __fastcall Create();
	__classmethod _di__ResourceReader __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoResourceReader(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoResourceReader(void) { }
	
};


class DELPHICLASS CoResourceSet;
class PASCALIMPLEMENTATION CoResourceSet : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ResourceSet __fastcall Create();
	__classmethod _di__ResourceSet __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoResourceSet(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoResourceSet(void) { }
	
};


class DELPHICLASS CoResourceWriter;
class PASCALIMPLEMENTATION CoResourceWriter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ResourceWriter __fastcall Create();
	__classmethod _di__ResourceWriter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoResourceWriter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoResourceWriter(void) { }
	
};


class DELPHICLASS CoSatelliteContractVersionAttribute;
class PASCALIMPLEMENTATION CoSatelliteContractVersionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SatelliteContractVersionAttribute __fastcall Create();
	__classmethod _di__SatelliteContractVersionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSatelliteContractVersionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSatelliteContractVersionAttribute(void) { }
	
};


class DELPHICLASS CoRegistry;
class PASCALIMPLEMENTATION CoRegistry : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Registry __fastcall Create();
	__classmethod _di__Registry __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRegistry(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRegistry(void) { }
	
};


class DELPHICLASS CoRegistryKey;
class PASCALIMPLEMENTATION CoRegistryKey : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RegistryKey __fastcall Create();
	__classmethod _di__RegistryKey __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRegistryKey(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRegistryKey(void) { }
	
};


class DELPHICLASS CoX509Certificate;
class PASCALIMPLEMENTATION CoX509Certificate : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__X509Certificate __fastcall Create();
	__classmethod _di__X509Certificate __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoX509Certificate(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoX509Certificate(void) { }
	
};


class DELPHICLASS CoAsymmetricAlgorithm;
class PASCALIMPLEMENTATION CoAsymmetricAlgorithm : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AsymmetricAlgorithm __fastcall Create();
	__classmethod _di__AsymmetricAlgorithm __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAsymmetricAlgorithm(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAsymmetricAlgorithm(void) { }
	
};


class DELPHICLASS CoAsymmetricKeyExchangeDeformatter;
class PASCALIMPLEMENTATION CoAsymmetricKeyExchangeDeformatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AsymmetricKeyExchangeDeformatter __fastcall Create();
	__classmethod _di__AsymmetricKeyExchangeDeformatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAsymmetricKeyExchangeDeformatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAsymmetricKeyExchangeDeformatter(void) { }
	
};


class DELPHICLASS CoAsymmetricKeyExchangeFormatter;
class PASCALIMPLEMENTATION CoAsymmetricKeyExchangeFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AsymmetricKeyExchangeFormatter __fastcall Create();
	__classmethod _di__AsymmetricKeyExchangeFormatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAsymmetricKeyExchangeFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAsymmetricKeyExchangeFormatter(void) { }
	
};


class DELPHICLASS CoAsymmetricSignatureDeformatter;
class PASCALIMPLEMENTATION CoAsymmetricSignatureDeformatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AsymmetricSignatureDeformatter __fastcall Create();
	__classmethod _di__AsymmetricSignatureDeformatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAsymmetricSignatureDeformatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAsymmetricSignatureDeformatter(void) { }
	
};


class DELPHICLASS CoAsymmetricSignatureFormatter;
class PASCALIMPLEMENTATION CoAsymmetricSignatureFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AsymmetricSignatureFormatter __fastcall Create();
	__classmethod _di__AsymmetricSignatureFormatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAsymmetricSignatureFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAsymmetricSignatureFormatter(void) { }
	
};


class DELPHICLASS CoToBase64Transform;
class PASCALIMPLEMENTATION CoToBase64Transform : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ToBase64Transform __fastcall Create();
	__classmethod _di__ToBase64Transform __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoToBase64Transform(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoToBase64Transform(void) { }
	
};


class DELPHICLASS CoFromBase64Transform;
class PASCALIMPLEMENTATION CoFromBase64Transform : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FromBase64Transform __fastcall Create();
	__classmethod _di__FromBase64Transform __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFromBase64Transform(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFromBase64Transform(void) { }
	
};


class DELPHICLASS CoKeySizes;
class PASCALIMPLEMENTATION CoKeySizes : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__KeySizes __fastcall Create();
	__classmethod _di__KeySizes __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoKeySizes(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoKeySizes(void) { }
	
};


class DELPHICLASS CoCryptographicException;
class PASCALIMPLEMENTATION CoCryptographicException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CryptographicException __fastcall Create();
	__classmethod _di__CryptographicException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCryptographicException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCryptographicException(void) { }
	
};


class DELPHICLASS CoCryptographicUnexpectedOperationException;
class PASCALIMPLEMENTATION CoCryptographicUnexpectedOperationException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CryptographicUnexpectedOperationException __fastcall Create();
	__classmethod _di__CryptographicUnexpectedOperationException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCryptographicUnexpectedOperationException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCryptographicUnexpectedOperationException(void) { }
	
};


class DELPHICLASS CoCryptoAPITransform;
class PASCALIMPLEMENTATION CoCryptoAPITransform : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CryptoAPITransform __fastcall Create();
	__classmethod _di__CryptoAPITransform __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCryptoAPITransform(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCryptoAPITransform(void) { }
	
};


class DELPHICLASS CoCspParameters;
class PASCALIMPLEMENTATION CoCspParameters : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CspParameters __fastcall Create();
	__classmethod _di__CspParameters __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCspParameters(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCspParameters(void) { }
	
};


class DELPHICLASS CoCryptoConfig;
class PASCALIMPLEMENTATION CoCryptoConfig : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CryptoConfig __fastcall Create();
	__classmethod _di__CryptoConfig __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCryptoConfig(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCryptoConfig(void) { }
	
};


class DELPHICLASS CoStream;
class PASCALIMPLEMENTATION CoStream : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Stream __fastcall Create();
	__classmethod _di__Stream __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStream(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStream(void) { }
	
};


class DELPHICLASS CoCryptoStream;
class PASCALIMPLEMENTATION CoCryptoStream : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CryptoStream __fastcall Create();
	__classmethod _di__CryptoStream __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCryptoStream(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCryptoStream(void) { }
	
};


class DELPHICLASS CoSymmetricAlgorithm;
class PASCALIMPLEMENTATION CoSymmetricAlgorithm : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SymmetricAlgorithm __fastcall Create();
	__classmethod _di__SymmetricAlgorithm __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSymmetricAlgorithm(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSymmetricAlgorithm(void) { }
	
};


class DELPHICLASS CoDES;
class PASCALIMPLEMENTATION CoDES : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DES __fastcall Create();
	__classmethod _di__DES __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDES(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDES(void) { }
	
};


class DELPHICLASS CoDESCryptoServiceProvider;
class PASCALIMPLEMENTATION CoDESCryptoServiceProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DESCryptoServiceProvider __fastcall Create();
	__classmethod _di__DESCryptoServiceProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDESCryptoServiceProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDESCryptoServiceProvider(void) { }
	
};


class DELPHICLASS CoDeriveBytes;
class PASCALIMPLEMENTATION CoDeriveBytes : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DeriveBytes __fastcall Create();
	__classmethod _di__DeriveBytes __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDeriveBytes(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDeriveBytes(void) { }
	
};


class DELPHICLASS CoDSA;
class PASCALIMPLEMENTATION CoDSA : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DSA __fastcall Create();
	__classmethod _di__DSA __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDSA(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDSA(void) { }
	
};


class DELPHICLASS CoDSACryptoServiceProvider;
class PASCALIMPLEMENTATION CoDSACryptoServiceProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DSACryptoServiceProvider __fastcall Create();
	__classmethod _di__DSACryptoServiceProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDSACryptoServiceProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDSACryptoServiceProvider(void) { }
	
};


class DELPHICLASS CoDSASignatureDeformatter;
class PASCALIMPLEMENTATION CoDSASignatureDeformatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DSASignatureDeformatter __fastcall Create();
	__classmethod _di__DSASignatureDeformatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDSASignatureDeformatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDSASignatureDeformatter(void) { }
	
};


class DELPHICLASS CoDSASignatureFormatter;
class PASCALIMPLEMENTATION CoDSASignatureFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DSASignatureFormatter __fastcall Create();
	__classmethod _di__DSASignatureFormatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDSASignatureFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDSASignatureFormatter(void) { }
	
};


class DELPHICLASS CoHashAlgorithm;
class PASCALIMPLEMENTATION CoHashAlgorithm : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__HashAlgorithm __fastcall Create();
	__classmethod _di__HashAlgorithm __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHashAlgorithm(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHashAlgorithm(void) { }
	
};


class DELPHICLASS CoKeyedHashAlgorithm;
class PASCALIMPLEMENTATION CoKeyedHashAlgorithm : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__KeyedHashAlgorithm __fastcall Create();
	__classmethod _di__KeyedHashAlgorithm __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoKeyedHashAlgorithm(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoKeyedHashAlgorithm(void) { }
	
};


class DELPHICLASS CoHMACSHA1;
class PASCALIMPLEMENTATION CoHMACSHA1 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__HMACSHA1 __fastcall Create();
	__classmethod _di__HMACSHA1 __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHMACSHA1(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHMACSHA1(void) { }
	
};


class DELPHICLASS CoMACTripleDES;
class PASCALIMPLEMENTATION CoMACTripleDES : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MACTripleDES __fastcall Create();
	__classmethod _di__MACTripleDES __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMACTripleDES(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMACTripleDES(void) { }
	
};


class DELPHICLASS CoMD5;
class PASCALIMPLEMENTATION CoMD5 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MD5 __fastcall Create();
	__classmethod _di__MD5 __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMD5(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMD5(void) { }
	
};


class DELPHICLASS CoMD5CryptoServiceProvider;
class PASCALIMPLEMENTATION CoMD5CryptoServiceProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MD5CryptoServiceProvider __fastcall Create();
	__classmethod _di__MD5CryptoServiceProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMD5CryptoServiceProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMD5CryptoServiceProvider(void) { }
	
};


class DELPHICLASS CoMaskGenerationMethod;
class PASCALIMPLEMENTATION CoMaskGenerationMethod : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MaskGenerationMethod __fastcall Create();
	__classmethod _di__MaskGenerationMethod __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMaskGenerationMethod(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMaskGenerationMethod(void) { }
	
};


class DELPHICLASS CoPasswordDeriveBytes;
class PASCALIMPLEMENTATION CoPasswordDeriveBytes : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PasswordDeriveBytes __fastcall Create();
	__classmethod _di__PasswordDeriveBytes __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPasswordDeriveBytes(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPasswordDeriveBytes(void) { }
	
};


class DELPHICLASS CoPKCS1MaskGenerationMethod;
class PASCALIMPLEMENTATION CoPKCS1MaskGenerationMethod : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PKCS1MaskGenerationMethod __fastcall Create();
	__classmethod _di__PKCS1MaskGenerationMethod __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPKCS1MaskGenerationMethod(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPKCS1MaskGenerationMethod(void) { }
	
};


class DELPHICLASS CoRC2;
class PASCALIMPLEMENTATION CoRC2 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RC2 __fastcall Create();
	__classmethod _di__RC2 __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRC2(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRC2(void) { }
	
};


class DELPHICLASS CoRC2CryptoServiceProvider;
class PASCALIMPLEMENTATION CoRC2CryptoServiceProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RC2CryptoServiceProvider __fastcall Create();
	__classmethod _di__RC2CryptoServiceProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRC2CryptoServiceProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRC2CryptoServiceProvider(void) { }
	
};


class DELPHICLASS CoRandomNumberGenerator;
class PASCALIMPLEMENTATION CoRandomNumberGenerator : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RandomNumberGenerator __fastcall Create();
	__classmethod _di__RandomNumberGenerator __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRandomNumberGenerator(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRandomNumberGenerator(void) { }
	
};


class DELPHICLASS CoRNGCryptoServiceProvider;
class PASCALIMPLEMENTATION CoRNGCryptoServiceProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RNGCryptoServiceProvider __fastcall Create();
	__classmethod _di__RNGCryptoServiceProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRNGCryptoServiceProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRNGCryptoServiceProvider(void) { }
	
};


class DELPHICLASS CoRSA;
class PASCALIMPLEMENTATION CoRSA : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RSA __fastcall Create();
	__classmethod _di__RSA __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRSA(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRSA(void) { }
	
};


class DELPHICLASS CoRSACryptoServiceProvider;
class PASCALIMPLEMENTATION CoRSACryptoServiceProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RSACryptoServiceProvider __fastcall Create();
	__classmethod _di__RSACryptoServiceProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRSACryptoServiceProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRSACryptoServiceProvider(void) { }
	
};


class DELPHICLASS CoRSAOAEPKeyExchangeDeformatter;
class PASCALIMPLEMENTATION CoRSAOAEPKeyExchangeDeformatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RSAOAEPKeyExchangeDeformatter __fastcall Create();
	__classmethod _di__RSAOAEPKeyExchangeDeformatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRSAOAEPKeyExchangeDeformatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRSAOAEPKeyExchangeDeformatter(void) { }
	
};


class DELPHICLASS CoRSAOAEPKeyExchangeFormatter;
class PASCALIMPLEMENTATION CoRSAOAEPKeyExchangeFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RSAOAEPKeyExchangeFormatter __fastcall Create();
	__classmethod _di__RSAOAEPKeyExchangeFormatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRSAOAEPKeyExchangeFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRSAOAEPKeyExchangeFormatter(void) { }
	
};


class DELPHICLASS CoRSAPKCS1KeyExchangeDeformatter;
class PASCALIMPLEMENTATION CoRSAPKCS1KeyExchangeDeformatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RSAPKCS1KeyExchangeDeformatter __fastcall Create();
	__classmethod _di__RSAPKCS1KeyExchangeDeformatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRSAPKCS1KeyExchangeDeformatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRSAPKCS1KeyExchangeDeformatter(void) { }
	
};


class DELPHICLASS CoRSAPKCS1KeyExchangeFormatter;
class PASCALIMPLEMENTATION CoRSAPKCS1KeyExchangeFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RSAPKCS1KeyExchangeFormatter __fastcall Create();
	__classmethod _di__RSAPKCS1KeyExchangeFormatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRSAPKCS1KeyExchangeFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRSAPKCS1KeyExchangeFormatter(void) { }
	
};


class DELPHICLASS CoRSAPKCS1SignatureDeformatter;
class PASCALIMPLEMENTATION CoRSAPKCS1SignatureDeformatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RSAPKCS1SignatureDeformatter __fastcall Create();
	__classmethod _di__RSAPKCS1SignatureDeformatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRSAPKCS1SignatureDeformatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRSAPKCS1SignatureDeformatter(void) { }
	
};


class DELPHICLASS CoRSAPKCS1SignatureFormatter;
class PASCALIMPLEMENTATION CoRSAPKCS1SignatureFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RSAPKCS1SignatureFormatter __fastcall Create();
	__classmethod _di__RSAPKCS1SignatureFormatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRSAPKCS1SignatureFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRSAPKCS1SignatureFormatter(void) { }
	
};


class DELPHICLASS CoRijndael;
class PASCALIMPLEMENTATION CoRijndael : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Rijndael __fastcall Create();
	__classmethod _di__Rijndael __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRijndael(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRijndael(void) { }
	
};


class DELPHICLASS CoRijndaelManaged;
class PASCALIMPLEMENTATION CoRijndaelManaged : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RijndaelManaged __fastcall Create();
	__classmethod _di__RijndaelManaged __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRijndaelManaged(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRijndaelManaged(void) { }
	
};


class DELPHICLASS CoSHA1;
class PASCALIMPLEMENTATION CoSHA1 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA1 __fastcall Create();
	__classmethod _di__SHA1 __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA1(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA1(void) { }
	
};


class DELPHICLASS CoSHA1CryptoServiceProvider;
class PASCALIMPLEMENTATION CoSHA1CryptoServiceProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA1CryptoServiceProvider __fastcall Create();
	__classmethod _di__SHA1CryptoServiceProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA1CryptoServiceProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA1CryptoServiceProvider(void) { }
	
};


class DELPHICLASS CoSHA1Managed;
class PASCALIMPLEMENTATION CoSHA1Managed : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA1Managed __fastcall Create();
	__classmethod _di__SHA1Managed __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA1Managed(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA1Managed(void) { }
	
};


class DELPHICLASS CoSHA256;
class PASCALIMPLEMENTATION CoSHA256 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA256 __fastcall Create();
	__classmethod _di__SHA256 __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA256(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA256(void) { }
	
};


class DELPHICLASS CoSHA256Managed;
class PASCALIMPLEMENTATION CoSHA256Managed : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA256Managed __fastcall Create();
	__classmethod _di__SHA256Managed __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA256Managed(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA256Managed(void) { }
	
};


class DELPHICLASS CoSHA384;
class PASCALIMPLEMENTATION CoSHA384 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA384 __fastcall Create();
	__classmethod _di__SHA384 __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA384(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA384(void) { }
	
};


class DELPHICLASS CoSHA384Managed;
class PASCALIMPLEMENTATION CoSHA384Managed : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA384Managed __fastcall Create();
	__classmethod _di__SHA384Managed __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA384Managed(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA384Managed(void) { }
	
};


class DELPHICLASS CoSHA512;
class PASCALIMPLEMENTATION CoSHA512 : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA512 __fastcall Create();
	__classmethod _di__SHA512 __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA512(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA512(void) { }
	
};


class DELPHICLASS CoSHA512Managed;
class PASCALIMPLEMENTATION CoSHA512Managed : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SHA512Managed __fastcall Create();
	__classmethod _di__SHA512Managed __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSHA512Managed(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSHA512Managed(void) { }
	
};


class DELPHICLASS CoSignatureDescription;
class PASCALIMPLEMENTATION CoSignatureDescription : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SignatureDescription __fastcall Create();
	__classmethod _di__SignatureDescription __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSignatureDescription(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSignatureDescription(void) { }
	
};


class DELPHICLASS CoTripleDES;
class PASCALIMPLEMENTATION CoTripleDES : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TripleDES __fastcall Create();
	__classmethod _di__TripleDES __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTripleDES(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTripleDES(void) { }
	
};


class DELPHICLASS CoTripleDESCryptoServiceProvider;
class PASCALIMPLEMENTATION CoTripleDESCryptoServiceProvider : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TripleDESCryptoServiceProvider __fastcall Create();
	__classmethod _di__TripleDESCryptoServiceProvider __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTripleDESCryptoServiceProvider(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTripleDESCryptoServiceProvider(void) { }
	
};


class DELPHICLASS CoAllMembershipCondition;
class PASCALIMPLEMENTATION CoAllMembershipCondition : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AllMembershipCondition __fastcall Create();
	__classmethod _di__AllMembershipCondition __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAllMembershipCondition(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAllMembershipCondition(void) { }
	
};


class DELPHICLASS CoApplicationDirectory;
class PASCALIMPLEMENTATION CoApplicationDirectory : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ApplicationDirectory __fastcall Create();
	__classmethod _di__ApplicationDirectory __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoApplicationDirectory(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoApplicationDirectory(void) { }
	
};


class DELPHICLASS CoApplicationDirectoryMembershipCondition;
class PASCALIMPLEMENTATION CoApplicationDirectoryMembershipCondition : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ApplicationDirectoryMembershipCondition __fastcall Create();
	__classmethod _di__ApplicationDirectoryMembershipCondition __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoApplicationDirectoryMembershipCondition(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoApplicationDirectoryMembershipCondition(void) { }
	
};


class DELPHICLASS CoCodeGroup;
class PASCALIMPLEMENTATION CoCodeGroup : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CodeGroup __fastcall Create();
	__classmethod _di__CodeGroup __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCodeGroup(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCodeGroup(void) { }
	
};


class DELPHICLASS CoEvidence;
class PASCALIMPLEMENTATION CoEvidence : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Evidence __fastcall Create();
	__classmethod _di__Evidence __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEvidence(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEvidence(void) { }
	
};


class DELPHICLASS CoFileCodeGroup;
class PASCALIMPLEMENTATION CoFileCodeGroup : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileCodeGroup __fastcall Create();
	__classmethod _di__FileCodeGroup __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileCodeGroup(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileCodeGroup(void) { }
	
};


class DELPHICLASS CoFirstMatchCodeGroup;
class PASCALIMPLEMENTATION CoFirstMatchCodeGroup : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FirstMatchCodeGroup __fastcall Create();
	__classmethod _di__FirstMatchCodeGroup __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFirstMatchCodeGroup(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFirstMatchCodeGroup(void) { }
	
};


class DELPHICLASS CoHash;
class PASCALIMPLEMENTATION CoHash : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Hash __fastcall Create();
	__classmethod _di__Hash __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHash(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHash(void) { }
	
};


class DELPHICLASS CoHashMembershipCondition;
class PASCALIMPLEMENTATION CoHashMembershipCondition : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__HashMembershipCondition __fastcall Create();
	__classmethod _di__HashMembershipCondition __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHashMembershipCondition(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHashMembershipCondition(void) { }
	
};


class DELPHICLASS CoNetCodeGroup;
class PASCALIMPLEMENTATION CoNetCodeGroup : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NetCodeGroup __fastcall Create();
	__classmethod _di__NetCodeGroup __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNetCodeGroup(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNetCodeGroup(void) { }
	
};


class DELPHICLASS CoPermissionRequestEvidence;
class PASCALIMPLEMENTATION CoPermissionRequestEvidence : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PermissionRequestEvidence __fastcall Create();
	__classmethod _di__PermissionRequestEvidence __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPermissionRequestEvidence(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPermissionRequestEvidence(void) { }
	
};


class DELPHICLASS CoPolicyException;
class PASCALIMPLEMENTATION CoPolicyException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PolicyException __fastcall Create();
	__classmethod _di__PolicyException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPolicyException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPolicyException(void) { }
	
};


class DELPHICLASS CoPolicyLevel;
class PASCALIMPLEMENTATION CoPolicyLevel : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PolicyLevel __fastcall Create();
	__classmethod _di__PolicyLevel __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPolicyLevel(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPolicyLevel(void) { }
	
};


class DELPHICLASS CoPolicyStatement;
class PASCALIMPLEMENTATION CoPolicyStatement : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PolicyStatement __fastcall Create();
	__classmethod _di__PolicyStatement __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPolicyStatement(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPolicyStatement(void) { }
	
};


class DELPHICLASS CoPublisher;
class PASCALIMPLEMENTATION CoPublisher : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Publisher __fastcall Create();
	__classmethod _di__Publisher __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPublisher(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPublisher(void) { }
	
};


class DELPHICLASS CoPublisherMembershipCondition;
class PASCALIMPLEMENTATION CoPublisherMembershipCondition : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PublisherMembershipCondition __fastcall Create();
	__classmethod _di__PublisherMembershipCondition __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPublisherMembershipCondition(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPublisherMembershipCondition(void) { }
	
};


class DELPHICLASS CoSite;
class PASCALIMPLEMENTATION CoSite : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Site __fastcall Create();
	__classmethod _di__Site __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSite(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSite(void) { }
	
};


class DELPHICLASS CoSiteMembershipCondition;
class PASCALIMPLEMENTATION CoSiteMembershipCondition : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SiteMembershipCondition __fastcall Create();
	__classmethod _di__SiteMembershipCondition __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSiteMembershipCondition(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSiteMembershipCondition(void) { }
	
};


class DELPHICLASS CoStrongName;
class PASCALIMPLEMENTATION CoStrongName : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StrongName __fastcall Create();
	__classmethod _di__StrongName __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStrongName(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStrongName(void) { }
	
};


class DELPHICLASS CoStrongNameMembershipCondition;
class PASCALIMPLEMENTATION CoStrongNameMembershipCondition : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StrongNameMembershipCondition __fastcall Create();
	__classmethod _di__StrongNameMembershipCondition __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStrongNameMembershipCondition(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStrongNameMembershipCondition(void) { }
	
};


class DELPHICLASS CoUnionCodeGroup;
class PASCALIMPLEMENTATION CoUnionCodeGroup : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UnionCodeGroup __fastcall Create();
	__classmethod _di__UnionCodeGroup __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUnionCodeGroup(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUnionCodeGroup(void) { }
	
};


class DELPHICLASS CoUrl;
class PASCALIMPLEMENTATION CoUrl : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Url __fastcall Create();
	__classmethod _di__Url __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUrl(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUrl(void) { }
	
};


class DELPHICLASS CoUrlMembershipCondition;
class PASCALIMPLEMENTATION CoUrlMembershipCondition : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UrlMembershipCondition __fastcall Create();
	__classmethod _di__UrlMembershipCondition __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUrlMembershipCondition(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUrlMembershipCondition(void) { }
	
};


class DELPHICLASS CoZone;
class PASCALIMPLEMENTATION CoZone : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Zone __fastcall Create();
	__classmethod _di__Zone __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoZone(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoZone(void) { }
	
};


class DELPHICLASS CoZoneMembershipCondition;
class PASCALIMPLEMENTATION CoZoneMembershipCondition : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ZoneMembershipCondition __fastcall Create();
	__classmethod _di__ZoneMembershipCondition __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoZoneMembershipCondition(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoZoneMembershipCondition(void) { }
	
};


class DELPHICLASS CoGenericIdentity;
class PASCALIMPLEMENTATION CoGenericIdentity : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__GenericIdentity __fastcall Create();
	__classmethod _di__GenericIdentity __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoGenericIdentity(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoGenericIdentity(void) { }
	
};


class DELPHICLASS CoGenericPrincipal;
class PASCALIMPLEMENTATION CoGenericPrincipal : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__GenericPrincipal __fastcall Create();
	__classmethod _di__GenericPrincipal __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoGenericPrincipal(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoGenericPrincipal(void) { }
	
};


class DELPHICLASS CoWindowsIdentity;
class PASCALIMPLEMENTATION CoWindowsIdentity : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WindowsIdentity __fastcall Create();
	__classmethod _di__WindowsIdentity __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWindowsIdentity(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWindowsIdentity(void) { }
	
};


class DELPHICLASS CoWindowsImpersonationContext;
class PASCALIMPLEMENTATION CoWindowsImpersonationContext : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WindowsImpersonationContext __fastcall Create();
	__classmethod _di__WindowsImpersonationContext __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWindowsImpersonationContext(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWindowsImpersonationContext(void) { }
	
};


class DELPHICLASS CoWindowsPrincipal;
class PASCALIMPLEMENTATION CoWindowsPrincipal : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WindowsPrincipal __fastcall Create();
	__classmethod _di__WindowsPrincipal __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWindowsPrincipal(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWindowsPrincipal(void) { }
	
};


class DELPHICLASS CoDispIdAttribute;
class PASCALIMPLEMENTATION CoDispIdAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DispIdAttribute __fastcall Create();
	__classmethod _di__DispIdAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDispIdAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDispIdAttribute(void) { }
	
};


class DELPHICLASS CoInterfaceTypeAttribute;
class PASCALIMPLEMENTATION CoInterfaceTypeAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InterfaceTypeAttribute __fastcall Create();
	__classmethod _di__InterfaceTypeAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInterfaceTypeAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInterfaceTypeAttribute(void) { }
	
};


class DELPHICLASS CoClassInterfaceAttribute;
class PASCALIMPLEMENTATION CoClassInterfaceAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ClassInterfaceAttribute __fastcall Create();
	__classmethod _di__ClassInterfaceAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoClassInterfaceAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoClassInterfaceAttribute(void) { }
	
};


class DELPHICLASS CoComVisibleAttribute;
class PASCALIMPLEMENTATION CoComVisibleAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComVisibleAttribute __fastcall Create();
	__classmethod _di__ComVisibleAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComVisibleAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComVisibleAttribute(void) { }
	
};


class DELPHICLASS CoLCIDConversionAttribute;
class PASCALIMPLEMENTATION CoLCIDConversionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__LCIDConversionAttribute __fastcall Create();
	__classmethod _di__LCIDConversionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoLCIDConversionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoLCIDConversionAttribute(void) { }
	
};


class DELPHICLASS CoComRegisterFunctionAttribute;
class PASCALIMPLEMENTATION CoComRegisterFunctionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComRegisterFunctionAttribute __fastcall Create();
	__classmethod _di__ComRegisterFunctionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComRegisterFunctionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComRegisterFunctionAttribute(void) { }
	
};


class DELPHICLASS CoComUnregisterFunctionAttribute;
class PASCALIMPLEMENTATION CoComUnregisterFunctionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComUnregisterFunctionAttribute __fastcall Create();
	__classmethod _di__ComUnregisterFunctionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComUnregisterFunctionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComUnregisterFunctionAttribute(void) { }
	
};


class DELPHICLASS CoProgIdAttribute;
class PASCALIMPLEMENTATION CoProgIdAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ProgIdAttribute __fastcall Create();
	__classmethod _di__ProgIdAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoProgIdAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoProgIdAttribute(void) { }
	
};


class DELPHICLASS CoImportedFromTypeLibAttribute;
class PASCALIMPLEMENTATION CoImportedFromTypeLibAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ImportedFromTypeLibAttribute __fastcall Create();
	__classmethod _di__ImportedFromTypeLibAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoImportedFromTypeLibAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoImportedFromTypeLibAttribute(void) { }
	
};


class DELPHICLASS CoIDispatchImplAttribute;
class PASCALIMPLEMENTATION CoIDispatchImplAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IDispatchImplAttribute __fastcall Create();
	__classmethod _di__IDispatchImplAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIDispatchImplAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIDispatchImplAttribute(void) { }
	
};


class DELPHICLASS CoComSourceInterfacesAttribute;
class PASCALIMPLEMENTATION CoComSourceInterfacesAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComSourceInterfacesAttribute __fastcall Create();
	__classmethod _di__ComSourceInterfacesAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComSourceInterfacesAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComSourceInterfacesAttribute(void) { }
	
};


class DELPHICLASS CoComConversionLossAttribute;
class PASCALIMPLEMENTATION CoComConversionLossAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComConversionLossAttribute __fastcall Create();
	__classmethod _di__ComConversionLossAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComConversionLossAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComConversionLossAttribute(void) { }
	
};


class DELPHICLASS CoTypeLibTypeAttribute;
class PASCALIMPLEMENTATION CoTypeLibTypeAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeLibTypeAttribute __fastcall Create();
	__classmethod _di__TypeLibTypeAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeLibTypeAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeLibTypeAttribute(void) { }
	
};


class DELPHICLASS CoTypeLibFuncAttribute;
class PASCALIMPLEMENTATION CoTypeLibFuncAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeLibFuncAttribute __fastcall Create();
	__classmethod _di__TypeLibFuncAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeLibFuncAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeLibFuncAttribute(void) { }
	
};


class DELPHICLASS CoTypeLibVarAttribute;
class PASCALIMPLEMENTATION CoTypeLibVarAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeLibVarAttribute __fastcall Create();
	__classmethod _di__TypeLibVarAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeLibVarAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeLibVarAttribute(void) { }
	
};


class DELPHICLASS CoMarshalAsAttribute;
class PASCALIMPLEMENTATION CoMarshalAsAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MarshalAsAttribute __fastcall Create();
	__classmethod _di__MarshalAsAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMarshalAsAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMarshalAsAttribute(void) { }
	
};


class DELPHICLASS CoComImportAttribute;
class PASCALIMPLEMENTATION CoComImportAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComImportAttribute __fastcall Create();
	__classmethod _di__ComImportAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComImportAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComImportAttribute(void) { }
	
};


class DELPHICLASS CoGuidAttribute;
class PASCALIMPLEMENTATION CoGuidAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__GuidAttribute __fastcall Create();
	__classmethod _di__GuidAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoGuidAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoGuidAttribute(void) { }
	
};


class DELPHICLASS CoPreserveSigAttribute;
class PASCALIMPLEMENTATION CoPreserveSigAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PreserveSigAttribute __fastcall Create();
	__classmethod _di__PreserveSigAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPreserveSigAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPreserveSigAttribute(void) { }
	
};


class DELPHICLASS CoInAttribute;
class PASCALIMPLEMENTATION CoInAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InAttribute __fastcall Create();
	__classmethod _di__InAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInAttribute(void) { }
	
};


class DELPHICLASS CoOutAttribute;
class PASCALIMPLEMENTATION CoOutAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__OutAttribute __fastcall Create();
	__classmethod _di__OutAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoOutAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoOutAttribute(void) { }
	
};


class DELPHICLASS CoOptionalAttribute;
class PASCALIMPLEMENTATION CoOptionalAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__OptionalAttribute __fastcall Create();
	__classmethod _di__OptionalAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoOptionalAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoOptionalAttribute(void) { }
	
};


class DELPHICLASS CoDllImportAttribute;
class PASCALIMPLEMENTATION CoDllImportAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DllImportAttribute __fastcall Create();
	__classmethod _di__DllImportAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDllImportAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDllImportAttribute(void) { }
	
};


class DELPHICLASS CoStructLayoutAttribute;
class PASCALIMPLEMENTATION CoStructLayoutAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StructLayoutAttribute __fastcall Create();
	__classmethod _di__StructLayoutAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStructLayoutAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStructLayoutAttribute(void) { }
	
};


class DELPHICLASS CoFieldOffsetAttribute;
class PASCALIMPLEMENTATION CoFieldOffsetAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FieldOffsetAttribute __fastcall Create();
	__classmethod _di__FieldOffsetAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFieldOffsetAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFieldOffsetAttribute(void) { }
	
};


class DELPHICLASS CoComAliasNameAttribute;
class PASCALIMPLEMENTATION CoComAliasNameAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComAliasNameAttribute __fastcall Create();
	__classmethod _di__ComAliasNameAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComAliasNameAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComAliasNameAttribute(void) { }
	
};


class DELPHICLASS CoAutomationProxyAttribute;
class PASCALIMPLEMENTATION CoAutomationProxyAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AutomationProxyAttribute __fastcall Create();
	__classmethod _di__AutomationProxyAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAutomationProxyAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAutomationProxyAttribute(void) { }
	
};


class DELPHICLASS CoPrimaryInteropAssemblyAttribute;
class PASCALIMPLEMENTATION CoPrimaryInteropAssemblyAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PrimaryInteropAssemblyAttribute __fastcall Create();
	__classmethod _di__PrimaryInteropAssemblyAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPrimaryInteropAssemblyAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPrimaryInteropAssemblyAttribute(void) { }
	
};


class DELPHICLASS CoCoClassAttribute;
class PASCALIMPLEMENTATION CoCoClassAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CoClassAttribute __fastcall Create();
	__classmethod _di__CoClassAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCoClassAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCoClassAttribute(void) { }
	
};


class DELPHICLASS CoComEventInterfaceAttribute;
class PASCALIMPLEMENTATION CoComEventInterfaceAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComEventInterfaceAttribute __fastcall Create();
	__classmethod _di__ComEventInterfaceAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComEventInterfaceAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComEventInterfaceAttribute(void) { }
	
};


class DELPHICLASS CoTypeLibVersionAttribute;
class PASCALIMPLEMENTATION CoTypeLibVersionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeLibVersionAttribute __fastcall Create();
	__classmethod _di__TypeLibVersionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeLibVersionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeLibVersionAttribute(void) { }
	
};


class DELPHICLASS CoComCompatibleVersionAttribute;
class PASCALIMPLEMENTATION CoComCompatibleVersionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ComCompatibleVersionAttribute __fastcall Create();
	__classmethod _di__ComCompatibleVersionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoComCompatibleVersionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoComCompatibleVersionAttribute(void) { }
	
};


class DELPHICLASS CoBestFitMappingAttribute;
class PASCALIMPLEMENTATION CoBestFitMappingAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BestFitMappingAttribute __fastcall Create();
	__classmethod _di__BestFitMappingAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBestFitMappingAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBestFitMappingAttribute(void) { }
	
};


class DELPHICLASS CoExternalException;
class PASCALIMPLEMENTATION CoExternalException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ExternalException __fastcall Create();
	__classmethod _di__ExternalException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoExternalException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoExternalException(void) { }
	
};


class DELPHICLASS CoCOMException;
class PASCALIMPLEMENTATION CoCOMException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__COMException __fastcall Create();
	__classmethod _di__COMException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCOMException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCOMException(void) { }
	
};


class DELPHICLASS CoCurrencyWrapper;
class PASCALIMPLEMENTATION CoCurrencyWrapper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CurrencyWrapper __fastcall Create();
	__classmethod _di__CurrencyWrapper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCurrencyWrapper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCurrencyWrapper(void) { }
	
};


class DELPHICLASS CoDispatchWrapper;
class PASCALIMPLEMENTATION CoDispatchWrapper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DispatchWrapper __fastcall Create();
	__classmethod _di__DispatchWrapper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDispatchWrapper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDispatchWrapper(void) { }
	
};


class DELPHICLASS CoErrorWrapper;
class PASCALIMPLEMENTATION CoErrorWrapper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ErrorWrapper __fastcall Create();
	__classmethod _di__ErrorWrapper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoErrorWrapper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoErrorWrapper(void) { }
	
};


class DELPHICLASS CoExtensibleClassFactory;
class PASCALIMPLEMENTATION CoExtensibleClassFactory : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ExtensibleClassFactory __fastcall Create();
	__classmethod _di__ExtensibleClassFactory __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoExtensibleClassFactory(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoExtensibleClassFactory(void) { }
	
};


class DELPHICLASS CoInvalidComObjectException;
class PASCALIMPLEMENTATION CoInvalidComObjectException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InvalidComObjectException __fastcall Create();
	__classmethod _di__InvalidComObjectException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInvalidComObjectException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInvalidComObjectException(void) { }
	
};


class DELPHICLASS CoInvalidOleVariantTypeException;
class PASCALIMPLEMENTATION CoInvalidOleVariantTypeException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InvalidOleVariantTypeException __fastcall Create();
	__classmethod _di__InvalidOleVariantTypeException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInvalidOleVariantTypeException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInvalidOleVariantTypeException(void) { }
	
};


class DELPHICLASS CoMarshal;
class PASCALIMPLEMENTATION CoMarshal : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Marshal __fastcall Create();
	__classmethod _di__Marshal __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMarshal(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMarshal(void) { }
	
};


class DELPHICLASS CoMarshalDirectiveException;
class PASCALIMPLEMENTATION CoMarshalDirectiveException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MarshalDirectiveException __fastcall Create();
	__classmethod _di__MarshalDirectiveException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMarshalDirectiveException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMarshalDirectiveException(void) { }
	
};


class DELPHICLASS CoObjectCreationDelegate;
class PASCALIMPLEMENTATION CoObjectCreationDelegate : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ObjectCreationDelegate __fastcall Create();
	__classmethod _di__ObjectCreationDelegate __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoObjectCreationDelegate(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoObjectCreationDelegate(void) { }
	
};


class DELPHICLASS CoRuntimeEnvironment;
class PASCALIMPLEMENTATION CoRuntimeEnvironment : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RuntimeEnvironment __fastcall Create();
	__classmethod _di__RuntimeEnvironment __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRuntimeEnvironment(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRuntimeEnvironment(void) { }
	
};


class DELPHICLASS CoSafeArrayRankMismatchException;
class PASCALIMPLEMENTATION CoSafeArrayRankMismatchException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SafeArrayRankMismatchException __fastcall Create();
	__classmethod _di__SafeArrayRankMismatchException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSafeArrayRankMismatchException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSafeArrayRankMismatchException(void) { }
	
};


class DELPHICLASS CoSafeArrayTypeMismatchException;
class PASCALIMPLEMENTATION CoSafeArrayTypeMismatchException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SafeArrayTypeMismatchException __fastcall Create();
	__classmethod _di__SafeArrayTypeMismatchException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSafeArrayTypeMismatchException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSafeArrayTypeMismatchException(void) { }
	
};


class DELPHICLASS CoSEHException;
class PASCALIMPLEMENTATION CoSEHException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SEHException __fastcall Create();
	__classmethod _di__SEHException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSEHException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSEHException(void) { }
	
};


class DELPHICLASS CoUnknownWrapper;
class PASCALIMPLEMENTATION CoUnknownWrapper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UnknownWrapper __fastcall Create();
	__classmethod _di__UnknownWrapper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUnknownWrapper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUnknownWrapper(void) { }
	
};


class DELPHICLASS CoBinaryReader;
class PASCALIMPLEMENTATION CoBinaryReader : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BinaryReader __fastcall Create();
	__classmethod _di__BinaryReader __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBinaryReader(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBinaryReader(void) { }
	
};


class DELPHICLASS CoBinaryWriter;
class PASCALIMPLEMENTATION CoBinaryWriter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BinaryWriter __fastcall Create();
	__classmethod _di__BinaryWriter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBinaryWriter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBinaryWriter(void) { }
	
};


class DELPHICLASS CoBufferedStream;
class PASCALIMPLEMENTATION CoBufferedStream : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BufferedStream __fastcall Create();
	__classmethod _di__BufferedStream __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBufferedStream(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBufferedStream(void) { }
	
};


class DELPHICLASS CoDirectory;
class PASCALIMPLEMENTATION CoDirectory : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Directory __fastcall Create();
	__classmethod _di__Directory __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDirectory(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDirectory(void) { }
	
};


class DELPHICLASS CoFileSystemInfo;
class PASCALIMPLEMENTATION CoFileSystemInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileSystemInfo __fastcall Create();
	__classmethod _di__FileSystemInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileSystemInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileSystemInfo(void) { }
	
};


class DELPHICLASS CoDirectoryInfo;
class PASCALIMPLEMENTATION CoDirectoryInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DirectoryInfo __fastcall Create();
	__classmethod _di__DirectoryInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDirectoryInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDirectoryInfo(void) { }
	
};


class DELPHICLASS CoIOException;
class PASCALIMPLEMENTATION CoIOException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IOException __fastcall Create();
	__classmethod _di__IOException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIOException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIOException(void) { }
	
};


class DELPHICLASS CoDirectoryNotFoundException;
class PASCALIMPLEMENTATION CoDirectoryNotFoundException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DirectoryNotFoundException __fastcall Create();
	__classmethod _di__DirectoryNotFoundException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDirectoryNotFoundException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDirectoryNotFoundException(void) { }
	
};


class DELPHICLASS CoEndOfStreamException;
class PASCALIMPLEMENTATION CoEndOfStreamException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EndOfStreamException __fastcall Create();
	__classmethod _di__EndOfStreamException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEndOfStreamException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEndOfStreamException(void) { }
	
};


class DELPHICLASS CoFile_;
class PASCALIMPLEMENTATION CoFile_ : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__File __fastcall Create();
	__classmethod _di__File __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFile_(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFile_(void) { }
	
};


class DELPHICLASS CoFileInfo;
class PASCALIMPLEMENTATION CoFileInfo : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileInfo __fastcall Create();
	__classmethod _di__FileInfo __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileInfo(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileInfo(void) { }
	
};


class DELPHICLASS CoFileLoadException;
class PASCALIMPLEMENTATION CoFileLoadException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileLoadException __fastcall Create();
	__classmethod _di__FileLoadException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileLoadException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileLoadException(void) { }
	
};


class DELPHICLASS CoFileNotFoundException;
class PASCALIMPLEMENTATION CoFileNotFoundException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileNotFoundException __fastcall Create();
	__classmethod _di__FileNotFoundException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileNotFoundException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileNotFoundException(void) { }
	
};


class DELPHICLASS CoFileStream;
class PASCALIMPLEMENTATION CoFileStream : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileStream __fastcall Create();
	__classmethod _di__FileStream __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileStream(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileStream(void) { }
	
};


class DELPHICLASS CoMemoryStream;
class PASCALIMPLEMENTATION CoMemoryStream : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MemoryStream __fastcall Create();
	__classmethod _di__MemoryStream __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMemoryStream(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMemoryStream(void) { }
	
};


class DELPHICLASS CoPath;
class PASCALIMPLEMENTATION CoPath : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Path __fastcall Create();
	__classmethod _di__Path __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPath(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPath(void) { }
	
};


class DELPHICLASS CoPathTooLongException;
class PASCALIMPLEMENTATION CoPathTooLongException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PathTooLongException __fastcall Create();
	__classmethod _di__PathTooLongException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPathTooLongException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPathTooLongException(void) { }
	
};


class DELPHICLASS CoTextReader;
class PASCALIMPLEMENTATION CoTextReader : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TextReader __fastcall Create();
	__classmethod _di__TextReader __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTextReader(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTextReader(void) { }
	
};


class DELPHICLASS CoStreamReader;
class PASCALIMPLEMENTATION CoStreamReader : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StreamReader __fastcall Create();
	__classmethod _di__StreamReader __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStreamReader(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStreamReader(void) { }
	
};


class DELPHICLASS CoTextWriter;
class PASCALIMPLEMENTATION CoTextWriter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TextWriter __fastcall Create();
	__classmethod _di__TextWriter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTextWriter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTextWriter(void) { }
	
};


class DELPHICLASS CoStreamWriter;
class PASCALIMPLEMENTATION CoStreamWriter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StreamWriter __fastcall Create();
	__classmethod _di__StreamWriter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStreamWriter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStreamWriter(void) { }
	
};


class DELPHICLASS CoStringReader;
class PASCALIMPLEMENTATION CoStringReader : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StringReader __fastcall Create();
	__classmethod _di__StringReader __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStringReader(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStringReader(void) { }
	
};


class DELPHICLASS CoStringWriter;
class PASCALIMPLEMENTATION CoStringWriter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StringWriter __fastcall Create();
	__classmethod _di__StringWriter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStringWriter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStringWriter(void) { }
	
};


class DELPHICLASS CoAccessedThroughPropertyAttribute;
class PASCALIMPLEMENTATION CoAccessedThroughPropertyAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AccessedThroughPropertyAttribute __fastcall Create();
	__classmethod _di__AccessedThroughPropertyAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAccessedThroughPropertyAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAccessedThroughPropertyAttribute(void) { }
	
};


class DELPHICLASS CoCallConvCdecl;
class PASCALIMPLEMENTATION CoCallConvCdecl : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CallConvCdecl __fastcall Create();
	__classmethod _di__CallConvCdecl __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCallConvCdecl(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCallConvCdecl(void) { }
	
};


class DELPHICLASS CoCallConvStdcall;
class PASCALIMPLEMENTATION CoCallConvStdcall : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CallConvStdcall __fastcall Create();
	__classmethod _di__CallConvStdcall __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCallConvStdcall(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCallConvStdcall(void) { }
	
};


class DELPHICLASS CoCallConvThiscall;
class PASCALIMPLEMENTATION CoCallConvThiscall : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CallConvThiscall __fastcall Create();
	__classmethod _di__CallConvThiscall __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCallConvThiscall(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCallConvThiscall(void) { }
	
};


class DELPHICLASS CoCallConvFastcall;
class PASCALIMPLEMENTATION CoCallConvFastcall : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CallConvFastcall __fastcall Create();
	__classmethod _di__CallConvFastcall __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCallConvFastcall(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCallConvFastcall(void) { }
	
};


class DELPHICLASS CoRuntimeHelpers;
class PASCALIMPLEMENTATION CoRuntimeHelpers : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RuntimeHelpers __fastcall Create();
	__classmethod _di__RuntimeHelpers __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRuntimeHelpers(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRuntimeHelpers(void) { }
	
};


class DELPHICLASS CoCustomConstantAttribute;
class PASCALIMPLEMENTATION CoCustomConstantAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CustomConstantAttribute __fastcall Create();
	__classmethod _di__CustomConstantAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCustomConstantAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCustomConstantAttribute(void) { }
	
};


class DELPHICLASS CoDateTimeConstantAttribute;
class PASCALIMPLEMENTATION CoDateTimeConstantAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DateTimeConstantAttribute __fastcall Create();
	__classmethod _di__DateTimeConstantAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDateTimeConstantAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDateTimeConstantAttribute(void) { }
	
};


class DELPHICLASS CoDiscardableAttribute;
class PASCALIMPLEMENTATION CoDiscardableAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DiscardableAttribute __fastcall Create();
	__classmethod _di__DiscardableAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDiscardableAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDiscardableAttribute(void) { }
	
};


class DELPHICLASS CoDecimalConstantAttribute;
class PASCALIMPLEMENTATION CoDecimalConstantAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__DecimalConstantAttribute __fastcall Create();
	__classmethod _di__DecimalConstantAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoDecimalConstantAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoDecimalConstantAttribute(void) { }
	
};


class DELPHICLASS CoCompilationRelaxationsAttribute;
class PASCALIMPLEMENTATION CoCompilationRelaxationsAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CompilationRelaxationsAttribute __fastcall Create();
	__classmethod _di__CompilationRelaxationsAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCompilationRelaxationsAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCompilationRelaxationsAttribute(void) { }
	
};


class DELPHICLASS CoCompilerGlobalScopeAttribute;
class PASCALIMPLEMENTATION CoCompilerGlobalScopeAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CompilerGlobalScopeAttribute __fastcall Create();
	__classmethod _di__CompilerGlobalScopeAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCompilerGlobalScopeAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCompilerGlobalScopeAttribute(void) { }
	
};


class DELPHICLASS CoIDispatchConstantAttribute;
class PASCALIMPLEMENTATION CoIDispatchConstantAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IDispatchConstantAttribute __fastcall Create();
	__classmethod _di__IDispatchConstantAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIDispatchConstantAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIDispatchConstantAttribute(void) { }
	
};


class DELPHICLASS CoIndexerNameAttribute;
class PASCALIMPLEMENTATION CoIndexerNameAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IndexerNameAttribute __fastcall Create();
	__classmethod _di__IndexerNameAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIndexerNameAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIndexerNameAttribute(void) { }
	
};


class DELPHICLASS CoIsVolatile;
class PASCALIMPLEMENTATION CoIsVolatile : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsVolatile __fastcall Create();
	__classmethod _di__IsVolatile __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsVolatile(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsVolatile(void) { }
	
};


class DELPHICLASS CoIUnknownConstantAttribute;
class PASCALIMPLEMENTATION CoIUnknownConstantAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IUnknownConstantAttribute __fastcall Create();
	__classmethod _di__IUnknownConstantAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIUnknownConstantAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIUnknownConstantAttribute(void) { }
	
};


class DELPHICLASS CoMethodImplAttribute;
class PASCALIMPLEMENTATION CoMethodImplAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodImplAttribute __fastcall Create();
	__classmethod _di__MethodImplAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodImplAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodImplAttribute(void) { }
	
};


class DELPHICLASS CoRequiredAttributeAttribute;
class PASCALIMPLEMENTATION CoRequiredAttributeAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RequiredAttributeAttribute __fastcall Create();
	__classmethod _di__RequiredAttributeAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRequiredAttributeAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRequiredAttributeAttribute(void) { }
	
};


class DELPHICLASS CoPermissionSet;
class PASCALIMPLEMENTATION CoPermissionSet : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PermissionSet __fastcall Create();
	__classmethod _di__PermissionSet __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPermissionSet(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPermissionSet(void) { }
	
};


class DELPHICLASS CoNamedPermissionSet;
class PASCALIMPLEMENTATION CoNamedPermissionSet : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__NamedPermissionSet __fastcall Create();
	__classmethod _di__NamedPermissionSet __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoNamedPermissionSet(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoNamedPermissionSet(void) { }
	
};


class DELPHICLASS CoSecurityElement;
class PASCALIMPLEMENTATION CoSecurityElement : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SecurityElement __fastcall Create();
	__classmethod _di__SecurityElement __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSecurityElement(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSecurityElement(void) { }
	
};


class DELPHICLASS CoXmlSyntaxException;
class PASCALIMPLEMENTATION CoXmlSyntaxException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__XmlSyntaxException __fastcall Create();
	__classmethod _di__XmlSyntaxException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoXmlSyntaxException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoXmlSyntaxException(void) { }
	
};


class DELPHICLASS CoCodeAccessPermission;
class PASCALIMPLEMENTATION CoCodeAccessPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CodeAccessPermission __fastcall Create();
	__classmethod _di__CodeAccessPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCodeAccessPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCodeAccessPermission(void) { }
	
};


class DELPHICLASS CoEnvironmentPermission;
class PASCALIMPLEMENTATION CoEnvironmentPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EnvironmentPermission __fastcall Create();
	__classmethod _di__EnvironmentPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEnvironmentPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEnvironmentPermission(void) { }
	
};


class DELPHICLASS CoFileDialogPermission;
class PASCALIMPLEMENTATION CoFileDialogPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileDialogPermission __fastcall Create();
	__classmethod _di__FileDialogPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileDialogPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileDialogPermission(void) { }
	
};


class DELPHICLASS CoFileIOPermission;
class PASCALIMPLEMENTATION CoFileIOPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileIOPermission __fastcall Create();
	__classmethod _di__FileIOPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileIOPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileIOPermission(void) { }
	
};


class DELPHICLASS CoIsolatedStoragePermission;
class PASCALIMPLEMENTATION CoIsolatedStoragePermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsolatedStoragePermission __fastcall Create();
	__classmethod _di__IsolatedStoragePermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsolatedStoragePermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsolatedStoragePermission(void) { }
	
};


class DELPHICLASS CoIsolatedStorageFilePermission;
class PASCALIMPLEMENTATION CoIsolatedStorageFilePermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsolatedStorageFilePermission __fastcall Create();
	__classmethod _di__IsolatedStorageFilePermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsolatedStorageFilePermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsolatedStorageFilePermission(void) { }
	
};


class DELPHICLASS CoSecurityAttribute;
class PASCALIMPLEMENTATION CoSecurityAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SecurityAttribute __fastcall Create();
	__classmethod _di__SecurityAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSecurityAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSecurityAttribute(void) { }
	
};


class DELPHICLASS CoCodeAccessSecurityAttribute;
class PASCALIMPLEMENTATION CoCodeAccessSecurityAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CodeAccessSecurityAttribute __fastcall Create();
	__classmethod _di__CodeAccessSecurityAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCodeAccessSecurityAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCodeAccessSecurityAttribute(void) { }
	
};


class DELPHICLASS CoEnvironmentPermissionAttribute;
class PASCALIMPLEMENTATION CoEnvironmentPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EnvironmentPermissionAttribute __fastcall Create();
	__classmethod _di__EnvironmentPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEnvironmentPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEnvironmentPermissionAttribute(void) { }
	
};


class DELPHICLASS CoFileDialogPermissionAttribute;
class PASCALIMPLEMENTATION CoFileDialogPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileDialogPermissionAttribute __fastcall Create();
	__classmethod _di__FileDialogPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileDialogPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileDialogPermissionAttribute(void) { }
	
};


class DELPHICLASS CoFileIOPermissionAttribute;
class PASCALIMPLEMENTATION CoFileIOPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FileIOPermissionAttribute __fastcall Create();
	__classmethod _di__FileIOPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFileIOPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFileIOPermissionAttribute(void) { }
	
};


class DELPHICLASS CoPrincipalPermissionAttribute;
class PASCALIMPLEMENTATION CoPrincipalPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PrincipalPermissionAttribute __fastcall Create();
	__classmethod _di__PrincipalPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPrincipalPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPrincipalPermissionAttribute(void) { }
	
};


class DELPHICLASS CoReflectionPermissionAttribute;
class PASCALIMPLEMENTATION CoReflectionPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ReflectionPermissionAttribute __fastcall Create();
	__classmethod _di__ReflectionPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoReflectionPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoReflectionPermissionAttribute(void) { }
	
};


class DELPHICLASS CoRegistryPermissionAttribute;
class PASCALIMPLEMENTATION CoRegistryPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RegistryPermissionAttribute __fastcall Create();
	__classmethod _di__RegistryPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRegistryPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRegistryPermissionAttribute(void) { }
	
};


class DELPHICLASS CoSecurityPermissionAttribute;
class PASCALIMPLEMENTATION CoSecurityPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SecurityPermissionAttribute __fastcall Create();
	__classmethod _di__SecurityPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSecurityPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSecurityPermissionAttribute(void) { }
	
};


class DELPHICLASS CoUIPermissionAttribute;
class PASCALIMPLEMENTATION CoUIPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UIPermissionAttribute __fastcall Create();
	__classmethod _di__UIPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUIPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUIPermissionAttribute(void) { }
	
};


class DELPHICLASS CoZoneIdentityPermissionAttribute;
class PASCALIMPLEMENTATION CoZoneIdentityPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ZoneIdentityPermissionAttribute __fastcall Create();
	__classmethod _di__ZoneIdentityPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoZoneIdentityPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoZoneIdentityPermissionAttribute(void) { }
	
};


class DELPHICLASS CoStrongNameIdentityPermissionAttribute;
class PASCALIMPLEMENTATION CoStrongNameIdentityPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StrongNameIdentityPermissionAttribute __fastcall Create();
	__classmethod _di__StrongNameIdentityPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStrongNameIdentityPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStrongNameIdentityPermissionAttribute(void) { }
	
};


class DELPHICLASS CoSiteIdentityPermissionAttribute;
class PASCALIMPLEMENTATION CoSiteIdentityPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SiteIdentityPermissionAttribute __fastcall Create();
	__classmethod _di__SiteIdentityPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSiteIdentityPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSiteIdentityPermissionAttribute(void) { }
	
};


class DELPHICLASS CoUrlIdentityPermissionAttribute;
class PASCALIMPLEMENTATION CoUrlIdentityPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UrlIdentityPermissionAttribute __fastcall Create();
	__classmethod _di__UrlIdentityPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUrlIdentityPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUrlIdentityPermissionAttribute(void) { }
	
};


class DELPHICLASS CoPublisherIdentityPermissionAttribute;
class PASCALIMPLEMENTATION CoPublisherIdentityPermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PublisherIdentityPermissionAttribute __fastcall Create();
	__classmethod _di__PublisherIdentityPermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPublisherIdentityPermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPublisherIdentityPermissionAttribute(void) { }
	
};


class DELPHICLASS CoIsolatedStoragePermissionAttribute;
class PASCALIMPLEMENTATION CoIsolatedStoragePermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsolatedStoragePermissionAttribute __fastcall Create();
	__classmethod _di__IsolatedStoragePermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsolatedStoragePermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsolatedStoragePermissionAttribute(void) { }
	
};


class DELPHICLASS CoIsolatedStorageFilePermissionAttribute;
class PASCALIMPLEMENTATION CoIsolatedStorageFilePermissionAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsolatedStorageFilePermissionAttribute __fastcall Create();
	__classmethod _di__IsolatedStorageFilePermissionAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsolatedStorageFilePermissionAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsolatedStorageFilePermissionAttribute(void) { }
	
};


class DELPHICLASS CoPermissionSetAttribute;
class PASCALIMPLEMENTATION CoPermissionSetAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PermissionSetAttribute __fastcall Create();
	__classmethod _di__PermissionSetAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPermissionSetAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPermissionSetAttribute(void) { }
	
};


class DELPHICLASS CoPublisherIdentityPermission;
class PASCALIMPLEMENTATION CoPublisherIdentityPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PublisherIdentityPermission __fastcall Create();
	__classmethod _di__PublisherIdentityPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPublisherIdentityPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPublisherIdentityPermission(void) { }
	
};


class DELPHICLASS CoReflectionPermission;
class PASCALIMPLEMENTATION CoReflectionPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ReflectionPermission __fastcall Create();
	__classmethod _di__ReflectionPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoReflectionPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoReflectionPermission(void) { }
	
};


class DELPHICLASS CoRegistryPermission;
class PASCALIMPLEMENTATION CoRegistryPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RegistryPermission __fastcall Create();
	__classmethod _di__RegistryPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRegistryPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRegistryPermission(void) { }
	
};


class DELPHICLASS CoPrincipalPermission;
class PASCALIMPLEMENTATION CoPrincipalPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PrincipalPermission __fastcall Create();
	__classmethod _di__PrincipalPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPrincipalPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPrincipalPermission(void) { }
	
};


class DELPHICLASS CoSecurityPermission;
class PASCALIMPLEMENTATION CoSecurityPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SecurityPermission __fastcall Create();
	__classmethod _di__SecurityPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSecurityPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSecurityPermission(void) { }
	
};


class DELPHICLASS CoSiteIdentityPermission;
class PASCALIMPLEMENTATION CoSiteIdentityPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SiteIdentityPermission __fastcall Create();
	__classmethod _di__SiteIdentityPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSiteIdentityPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSiteIdentityPermission(void) { }
	
};


class DELPHICLASS CoStrongNameIdentityPermission;
class PASCALIMPLEMENTATION CoStrongNameIdentityPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StrongNameIdentityPermission __fastcall Create();
	__classmethod _di__StrongNameIdentityPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStrongNameIdentityPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStrongNameIdentityPermission(void) { }
	
};


class DELPHICLASS CoStrongNamePublicKeyBlob;
class PASCALIMPLEMENTATION CoStrongNamePublicKeyBlob : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__StrongNamePublicKeyBlob __fastcall Create();
	__classmethod _di__StrongNamePublicKeyBlob __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoStrongNamePublicKeyBlob(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoStrongNamePublicKeyBlob(void) { }
	
};


class DELPHICLASS CoUIPermission;
class PASCALIMPLEMENTATION CoUIPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UIPermission __fastcall Create();
	__classmethod _di__UIPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUIPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUIPermission(void) { }
	
};


class DELPHICLASS CoUrlIdentityPermission;
class PASCALIMPLEMENTATION CoUrlIdentityPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UrlIdentityPermission __fastcall Create();
	__classmethod _di__UrlIdentityPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUrlIdentityPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUrlIdentityPermission(void) { }
	
};


class DELPHICLASS CoZoneIdentityPermission;
class PASCALIMPLEMENTATION CoZoneIdentityPermission : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ZoneIdentityPermission __fastcall Create();
	__classmethod _di__ZoneIdentityPermission __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoZoneIdentityPermission(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoZoneIdentityPermission(void) { }
	
};


class DELPHICLASS CoSuppressUnmanagedCodeSecurityAttribute;
class PASCALIMPLEMENTATION CoSuppressUnmanagedCodeSecurityAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SuppressUnmanagedCodeSecurityAttribute __fastcall Create();
	__classmethod _di__SuppressUnmanagedCodeSecurityAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSuppressUnmanagedCodeSecurityAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSuppressUnmanagedCodeSecurityAttribute(void) { }
	
};


class DELPHICLASS CoUnverifiableCodeAttribute;
class PASCALIMPLEMENTATION CoUnverifiableCodeAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UnverifiableCodeAttribute __fastcall Create();
	__classmethod _di__UnverifiableCodeAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUnverifiableCodeAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUnverifiableCodeAttribute(void) { }
	
};


class DELPHICLASS CoAllowPartiallyTrustedCallersAttribute;
class PASCALIMPLEMENTATION CoAllowPartiallyTrustedCallersAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AllowPartiallyTrustedCallersAttribute __fastcall Create();
	__classmethod _di__AllowPartiallyTrustedCallersAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAllowPartiallyTrustedCallersAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAllowPartiallyTrustedCallersAttribute(void) { }
	
};


class DELPHICLASS CoSecurityException;
class PASCALIMPLEMENTATION CoSecurityException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SecurityException __fastcall Create();
	__classmethod _di__SecurityException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSecurityException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSecurityException(void) { }
	
};


class DELPHICLASS CoSecurityManager;
class PASCALIMPLEMENTATION CoSecurityManager : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SecurityManager __fastcall Create();
	__classmethod _di__SecurityManager __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSecurityManager(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSecurityManager(void) { }
	
};


class DELPHICLASS CoVerificationException;
class PASCALIMPLEMENTATION CoVerificationException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__VerificationException __fastcall Create();
	__classmethod _di__VerificationException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoVerificationException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoVerificationException(void) { }
	
};


class DELPHICLASS CoContextAttribute;
class PASCALIMPLEMENTATION CoContextAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ContextAttribute __fastcall Create();
	__classmethod _di__ContextAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoContextAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoContextAttribute(void) { }
	
};


class DELPHICLASS CoAsyncResult;
class PASCALIMPLEMENTATION CoAsyncResult : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AsyncResult __fastcall Create();
	__classmethod _di__AsyncResult __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAsyncResult(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAsyncResult(void) { }
	
};


class DELPHICLASS CoCallContext;
class PASCALIMPLEMENTATION CoCallContext : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CallContext __fastcall Create();
	__classmethod _di__CallContext __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCallContext(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCallContext(void) { }
	
};


class DELPHICLASS CoLogicalCallContext;
class PASCALIMPLEMENTATION CoLogicalCallContext : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__LogicalCallContext __fastcall Create();
	__classmethod _di__LogicalCallContext __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoLogicalCallContext(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoLogicalCallContext(void) { }
	
};


class DELPHICLASS CoChannelServices;
class PASCALIMPLEMENTATION CoChannelServices : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ChannelServices __fastcall Create();
	__classmethod _di__ChannelServices __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoChannelServices(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoChannelServices(void) { }
	
};


class DELPHICLASS CoClientChannelSinkStack;
class PASCALIMPLEMENTATION CoClientChannelSinkStack : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ClientChannelSinkStack __fastcall Create();
	__classmethod _di__ClientChannelSinkStack __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoClientChannelSinkStack(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoClientChannelSinkStack(void) { }
	
};


class DELPHICLASS CoServerChannelSinkStack;
class PASCALIMPLEMENTATION CoServerChannelSinkStack : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ServerChannelSinkStack __fastcall Create();
	__classmethod _di__ServerChannelSinkStack __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoServerChannelSinkStack(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoServerChannelSinkStack(void) { }
	
};


class DELPHICLASS CoInternalMessageWrapper;
class PASCALIMPLEMENTATION CoInternalMessageWrapper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InternalMessageWrapper __fastcall Create();
	__classmethod _di__InternalMessageWrapper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInternalMessageWrapper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInternalMessageWrapper(void) { }
	
};


class DELPHICLASS CoMethodCallMessageWrapper;
class PASCALIMPLEMENTATION CoMethodCallMessageWrapper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodCallMessageWrapper __fastcall Create();
	__classmethod _di__MethodCallMessageWrapper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodCallMessageWrapper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodCallMessageWrapper(void) { }
	
};


class DELPHICLASS CoClientSponsor;
class PASCALIMPLEMENTATION CoClientSponsor : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ClientSponsor __fastcall Create();
	__classmethod _di__ClientSponsor __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoClientSponsor(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoClientSponsor(void) { }
	
};


class DELPHICLASS CoCrossContextDelegate;
class PASCALIMPLEMENTATION CoCrossContextDelegate : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CrossContextDelegate __fastcall Create();
	__classmethod _di__CrossContextDelegate __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCrossContextDelegate(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCrossContextDelegate(void) { }
	
};


class DELPHICLASS CoContext;
class PASCALIMPLEMENTATION CoContext : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Context __fastcall Create();
	__classmethod _di__Context __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoContext(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoContext(void) { }
	
};


class DELPHICLASS CoContextProperty;
class PASCALIMPLEMENTATION CoContextProperty : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ContextProperty __fastcall Create();
	__classmethod _di__ContextProperty __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoContextProperty(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoContextProperty(void) { }
	
};


class DELPHICLASS CoEnterpriseServicesHelper;
class PASCALIMPLEMENTATION CoEnterpriseServicesHelper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EnterpriseServicesHelper __fastcall Create();
	__classmethod _di__EnterpriseServicesHelper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEnterpriseServicesHelper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEnterpriseServicesHelper(void) { }
	
};


class DELPHICLASS CoHeader;
class PASCALIMPLEMENTATION CoHeader : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__Header __fastcall Create();
	__classmethod _di__Header __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHeader(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHeader(void) { }
	
};


class DELPHICLASS CoHeaderHandler;
class PASCALIMPLEMENTATION CoHeaderHandler : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__HeaderHandler __fastcall Create();
	__classmethod _di__HeaderHandler __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoHeaderHandler(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoHeaderHandler(void) { }
	
};


class DELPHICLASS CoChannelDataStore;
class PASCALIMPLEMENTATION CoChannelDataStore : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ChannelDataStore __fastcall Create();
	__classmethod _di__ChannelDataStore __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoChannelDataStore(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoChannelDataStore(void) { }
	
};


class DELPHICLASS CoTransportHeaders;
class PASCALIMPLEMENTATION CoTransportHeaders : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TransportHeaders __fastcall Create();
	__classmethod _di__TransportHeaders __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTransportHeaders(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTransportHeaders(void) { }
	
};


class DELPHICLASS CoSinkProviderData;
class PASCALIMPLEMENTATION CoSinkProviderData : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SinkProviderData __fastcall Create();
	__classmethod _di__SinkProviderData __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSinkProviderData(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSinkProviderData(void) { }
	
};


class DELPHICLASS CoBaseChannelObjectWithProperties;
class PASCALIMPLEMENTATION CoBaseChannelObjectWithProperties : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BaseChannelObjectWithProperties __fastcall Create();
	__classmethod _di__BaseChannelObjectWithProperties __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBaseChannelObjectWithProperties(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBaseChannelObjectWithProperties(void) { }
	
};


class DELPHICLASS CoBaseChannelSinkWithProperties;
class PASCALIMPLEMENTATION CoBaseChannelSinkWithProperties : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BaseChannelSinkWithProperties __fastcall Create();
	__classmethod _di__BaseChannelSinkWithProperties __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBaseChannelSinkWithProperties(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBaseChannelSinkWithProperties(void) { }
	
};


class DELPHICLASS CoBaseChannelWithProperties;
class PASCALIMPLEMENTATION CoBaseChannelWithProperties : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BaseChannelWithProperties __fastcall Create();
	__classmethod _di__BaseChannelWithProperties __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBaseChannelWithProperties(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBaseChannelWithProperties(void) { }
	
};


class DELPHICLASS CoLifetimeServices;
class PASCALIMPLEMENTATION CoLifetimeServices : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__LifetimeServices __fastcall Create();
	__classmethod _di__LifetimeServices __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoLifetimeServices(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoLifetimeServices(void) { }
	
};


class DELPHICLASS CoReturnMessage;
class PASCALIMPLEMENTATION CoReturnMessage : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ReturnMessage __fastcall Create();
	__classmethod _di__ReturnMessage __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoReturnMessage(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoReturnMessage(void) { }
	
};


class DELPHICLASS CoMethodCall;
class PASCALIMPLEMENTATION CoMethodCall : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodCall __fastcall Create();
	__classmethod _di__MethodCall __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodCall(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodCall(void) { }
	
};


class DELPHICLASS CoConstructionCall;
class PASCALIMPLEMENTATION CoConstructionCall : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ConstructionCall __fastcall Create();
	__classmethod _di__ConstructionCall __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoConstructionCall(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoConstructionCall(void) { }
	
};


class DELPHICLASS CoMethodResponse;
class PASCALIMPLEMENTATION CoMethodResponse : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodResponse __fastcall Create();
	__classmethod _di__MethodResponse __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodResponse(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodResponse(void) { }
	
};


class DELPHICLASS CoConstructionResponse;
class PASCALIMPLEMENTATION CoConstructionResponse : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ConstructionResponse __fastcall Create();
	__classmethod _di__ConstructionResponse __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoConstructionResponse(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoConstructionResponse(void) { }
	
};


class DELPHICLASS CoMethodReturnMessageWrapper;
class PASCALIMPLEMENTATION CoMethodReturnMessageWrapper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodReturnMessageWrapper __fastcall Create();
	__classmethod _di__MethodReturnMessageWrapper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodReturnMessageWrapper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodReturnMessageWrapper(void) { }
	
};


class DELPHICLASS CoObjectHandle;
class PASCALIMPLEMENTATION CoObjectHandle : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ObjectHandle __fastcall Create();
	__classmethod _di__ObjectHandle __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoObjectHandle(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoObjectHandle(void) { }
	
};


class DELPHICLASS CoObjRef;
class PASCALIMPLEMENTATION CoObjRef : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ObjRef __fastcall Create();
	__classmethod _di__ObjRef __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoObjRef(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoObjRef(void) { }
	
};


class DELPHICLASS CoOneWayAttribute;
class PASCALIMPLEMENTATION CoOneWayAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__OneWayAttribute __fastcall Create();
	__classmethod _di__OneWayAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoOneWayAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoOneWayAttribute(void) { }
	
};


class DELPHICLASS CoProxyAttribute;
class PASCALIMPLEMENTATION CoProxyAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ProxyAttribute __fastcall Create();
	__classmethod _di__ProxyAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoProxyAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoProxyAttribute(void) { }
	
};


class DELPHICLASS CoRealProxy;
class PASCALIMPLEMENTATION CoRealProxy : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RealProxy __fastcall Create();
	__classmethod _di__RealProxy __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRealProxy(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRealProxy(void) { }
	
};


class DELPHICLASS CoSoapAttribute;
class PASCALIMPLEMENTATION CoSoapAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapAttribute __fastcall Create();
	__classmethod _di__SoapAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapAttribute(void) { }
	
};


class DELPHICLASS CoSoapTypeAttribute;
class PASCALIMPLEMENTATION CoSoapTypeAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapTypeAttribute __fastcall Create();
	__classmethod _di__SoapTypeAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapTypeAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapTypeAttribute(void) { }
	
};


class DELPHICLASS CoSoapMethodAttribute;
class PASCALIMPLEMENTATION CoSoapMethodAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapMethodAttribute __fastcall Create();
	__classmethod _di__SoapMethodAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapMethodAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapMethodAttribute(void) { }
	
};


class DELPHICLASS CoSoapFieldAttribute;
class PASCALIMPLEMENTATION CoSoapFieldAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapFieldAttribute __fastcall Create();
	__classmethod _di__SoapFieldAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapFieldAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapFieldAttribute(void) { }
	
};


class DELPHICLASS CoSoapParameterAttribute;
class PASCALIMPLEMENTATION CoSoapParameterAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapParameterAttribute __fastcall Create();
	__classmethod _di__SoapParameterAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapParameterAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapParameterAttribute(void) { }
	
};


class DELPHICLASS CoRemotingConfiguration;
class PASCALIMPLEMENTATION CoRemotingConfiguration : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RemotingConfiguration __fastcall Create();
	__classmethod _di__RemotingConfiguration __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRemotingConfiguration(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRemotingConfiguration(void) { }
	
};


class DELPHICLASS CoSystem_Runtime_Remoting_TypeEntry;
class PASCALIMPLEMENTATION CoSystem_Runtime_Remoting_TypeEntry : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__System_Runtime_Remoting_TypeEntry __fastcall Create();
	__classmethod _di__System_Runtime_Remoting_TypeEntry __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSystem_Runtime_Remoting_TypeEntry(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSystem_Runtime_Remoting_TypeEntry(void) { }
	
};


class DELPHICLASS CoActivatedClientTypeEntry;
class PASCALIMPLEMENTATION CoActivatedClientTypeEntry : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ActivatedClientTypeEntry __fastcall Create();
	__classmethod _di__ActivatedClientTypeEntry __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoActivatedClientTypeEntry(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoActivatedClientTypeEntry(void) { }
	
};


class DELPHICLASS CoActivatedServiceTypeEntry;
class PASCALIMPLEMENTATION CoActivatedServiceTypeEntry : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ActivatedServiceTypeEntry __fastcall Create();
	__classmethod _di__ActivatedServiceTypeEntry __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoActivatedServiceTypeEntry(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoActivatedServiceTypeEntry(void) { }
	
};


class DELPHICLASS CoWellKnownClientTypeEntry;
class PASCALIMPLEMENTATION CoWellKnownClientTypeEntry : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WellKnownClientTypeEntry __fastcall Create();
	__classmethod _di__WellKnownClientTypeEntry __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWellKnownClientTypeEntry(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWellKnownClientTypeEntry(void) { }
	
};


class DELPHICLASS CoWellKnownServiceTypeEntry;
class PASCALIMPLEMENTATION CoWellKnownServiceTypeEntry : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__WellKnownServiceTypeEntry __fastcall Create();
	__classmethod _di__WellKnownServiceTypeEntry __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoWellKnownServiceTypeEntry(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoWellKnownServiceTypeEntry(void) { }
	
};


class DELPHICLASS CoRemotingException;
class PASCALIMPLEMENTATION CoRemotingException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RemotingException __fastcall Create();
	__classmethod _di__RemotingException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRemotingException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRemotingException(void) { }
	
};


class DELPHICLASS CoServerException;
class PASCALIMPLEMENTATION CoServerException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ServerException __fastcall Create();
	__classmethod _di__ServerException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoServerException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoServerException(void) { }
	
};


class DELPHICLASS CoRemotingTimeoutException;
class PASCALIMPLEMENTATION CoRemotingTimeoutException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RemotingTimeoutException __fastcall Create();
	__classmethod _di__RemotingTimeoutException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRemotingTimeoutException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRemotingTimeoutException(void) { }
	
};


class DELPHICLASS CoRemotingServices;
class PASCALIMPLEMENTATION CoRemotingServices : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RemotingServices __fastcall Create();
	__classmethod _di__RemotingServices __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRemotingServices(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRemotingServices(void) { }
	
};


class DELPHICLASS CoInternalRemotingServices;
class PASCALIMPLEMENTATION CoInternalRemotingServices : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InternalRemotingServices __fastcall Create();
	__classmethod _di__InternalRemotingServices __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInternalRemotingServices(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInternalRemotingServices(void) { }
	
};


class DELPHICLASS CoMessageSurrogateFilter;
class PASCALIMPLEMENTATION CoMessageSurrogateFilter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MessageSurrogateFilter __fastcall Create();
	__classmethod _di__MessageSurrogateFilter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMessageSurrogateFilter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMessageSurrogateFilter(void) { }
	
};


class DELPHICLASS CoRemotingSurrogateSelector;
class PASCALIMPLEMENTATION CoRemotingSurrogateSelector : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__RemotingSurrogateSelector __fastcall Create();
	__classmethod _di__RemotingSurrogateSelector __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoRemotingSurrogateSelector(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoRemotingSurrogateSelector(void) { }
	
};


class DELPHICLASS CoSoapServices;
class PASCALIMPLEMENTATION CoSoapServices : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapServices __fastcall Create();
	__classmethod _di__SoapServices __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapServices(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapServices(void) { }
	
};


class DELPHICLASS CoSoapDateTime;
class PASCALIMPLEMENTATION CoSoapDateTime : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapDateTime __fastcall Create();
	__classmethod _di__SoapDateTime __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapDateTime(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapDateTime(void) { }
	
};


class DELPHICLASS CoSoapDuration;
class PASCALIMPLEMENTATION CoSoapDuration : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapDuration __fastcall Create();
	__classmethod _di__SoapDuration __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapDuration(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapDuration(void) { }
	
};


class DELPHICLASS CoSoapTime;
class PASCALIMPLEMENTATION CoSoapTime : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapTime __fastcall Create();
	__classmethod _di__SoapTime __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapTime(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapTime(void) { }
	
};


class DELPHICLASS CoSoapDate;
class PASCALIMPLEMENTATION CoSoapDate : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapDate __fastcall Create();
	__classmethod _di__SoapDate __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapDate(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapDate(void) { }
	
};


class DELPHICLASS CoSoapYearMonth;
class PASCALIMPLEMENTATION CoSoapYearMonth : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapYearMonth __fastcall Create();
	__classmethod _di__SoapYearMonth __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapYearMonth(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapYearMonth(void) { }
	
};


class DELPHICLASS CoSoapYear;
class PASCALIMPLEMENTATION CoSoapYear : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapYear __fastcall Create();
	__classmethod _di__SoapYear __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapYear(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapYear(void) { }
	
};


class DELPHICLASS CoSoapMonthDay;
class PASCALIMPLEMENTATION CoSoapMonthDay : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapMonthDay __fastcall Create();
	__classmethod _di__SoapMonthDay __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapMonthDay(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapMonthDay(void) { }
	
};


class DELPHICLASS CoSoapDay;
class PASCALIMPLEMENTATION CoSoapDay : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapDay __fastcall Create();
	__classmethod _di__SoapDay __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapDay(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapDay(void) { }
	
};


class DELPHICLASS CoSoapMonth;
class PASCALIMPLEMENTATION CoSoapMonth : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapMonth __fastcall Create();
	__classmethod _di__SoapMonth __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapMonth(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapMonth(void) { }
	
};


class DELPHICLASS CoSoapHexBinary;
class PASCALIMPLEMENTATION CoSoapHexBinary : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapHexBinary __fastcall Create();
	__classmethod _di__SoapHexBinary __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapHexBinary(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapHexBinary(void) { }
	
};


class DELPHICLASS CoSoapBase64Binary;
class PASCALIMPLEMENTATION CoSoapBase64Binary : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapBase64Binary __fastcall Create();
	__classmethod _di__SoapBase64Binary __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapBase64Binary(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapBase64Binary(void) { }
	
};


class DELPHICLASS CoSoapInteger;
class PASCALIMPLEMENTATION CoSoapInteger : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapInteger __fastcall Create();
	__classmethod _di__SoapInteger __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapInteger(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapInteger(void) { }
	
};


class DELPHICLASS CoSoapPositiveInteger;
class PASCALIMPLEMENTATION CoSoapPositiveInteger : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapPositiveInteger __fastcall Create();
	__classmethod _di__SoapPositiveInteger __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapPositiveInteger(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapPositiveInteger(void) { }
	
};


class DELPHICLASS CoSoapNonPositiveInteger;
class PASCALIMPLEMENTATION CoSoapNonPositiveInteger : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapNonPositiveInteger __fastcall Create();
	__classmethod _di__SoapNonPositiveInteger __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapNonPositiveInteger(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapNonPositiveInteger(void) { }
	
};


class DELPHICLASS CoSoapNonNegativeInteger;
class PASCALIMPLEMENTATION CoSoapNonNegativeInteger : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapNonNegativeInteger __fastcall Create();
	__classmethod _di__SoapNonNegativeInteger __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapNonNegativeInteger(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapNonNegativeInteger(void) { }
	
};


class DELPHICLASS CoSoapNegativeInteger;
class PASCALIMPLEMENTATION CoSoapNegativeInteger : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapNegativeInteger __fastcall Create();
	__classmethod _di__SoapNegativeInteger __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapNegativeInteger(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapNegativeInteger(void) { }
	
};


class DELPHICLASS CoSoapAnyUri;
class PASCALIMPLEMENTATION CoSoapAnyUri : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapAnyUri __fastcall Create();
	__classmethod _di__SoapAnyUri __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapAnyUri(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapAnyUri(void) { }
	
};


class DELPHICLASS CoSoapQName;
class PASCALIMPLEMENTATION CoSoapQName : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapQName __fastcall Create();
	__classmethod _di__SoapQName __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapQName(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapQName(void) { }
	
};


class DELPHICLASS CoSoapNotation;
class PASCALIMPLEMENTATION CoSoapNotation : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapNotation __fastcall Create();
	__classmethod _di__SoapNotation __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapNotation(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapNotation(void) { }
	
};


class DELPHICLASS CoSoapNormalizedString;
class PASCALIMPLEMENTATION CoSoapNormalizedString : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapNormalizedString __fastcall Create();
	__classmethod _di__SoapNormalizedString __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapNormalizedString(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapNormalizedString(void) { }
	
};


class DELPHICLASS CoSoapToken;
class PASCALIMPLEMENTATION CoSoapToken : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapToken __fastcall Create();
	__classmethod _di__SoapToken __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapToken(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapToken(void) { }
	
};


class DELPHICLASS CoSoapLanguage;
class PASCALIMPLEMENTATION CoSoapLanguage : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapLanguage __fastcall Create();
	__classmethod _di__SoapLanguage __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapLanguage(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapLanguage(void) { }
	
};


class DELPHICLASS CoSoapName;
class PASCALIMPLEMENTATION CoSoapName : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapName __fastcall Create();
	__classmethod _di__SoapName __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapName(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapName(void) { }
	
};


class DELPHICLASS CoSoapIdrefs;
class PASCALIMPLEMENTATION CoSoapIdrefs : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapIdrefs __fastcall Create();
	__classmethod _di__SoapIdrefs __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapIdrefs(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapIdrefs(void) { }
	
};


class DELPHICLASS CoSoapEntities;
class PASCALIMPLEMENTATION CoSoapEntities : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapEntities __fastcall Create();
	__classmethod _di__SoapEntities __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapEntities(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapEntities(void) { }
	
};


class DELPHICLASS CoSoapNmtoken;
class PASCALIMPLEMENTATION CoSoapNmtoken : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapNmtoken __fastcall Create();
	__classmethod _di__SoapNmtoken __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapNmtoken(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapNmtoken(void) { }
	
};


class DELPHICLASS CoSoapNmtokens;
class PASCALIMPLEMENTATION CoSoapNmtokens : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapNmtokens __fastcall Create();
	__classmethod _di__SoapNmtokens __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapNmtokens(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapNmtokens(void) { }
	
};


class DELPHICLASS CoSoapNcName;
class PASCALIMPLEMENTATION CoSoapNcName : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapNcName __fastcall Create();
	__classmethod _di__SoapNcName __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapNcName(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapNcName(void) { }
	
};


class DELPHICLASS CoSoapId;
class PASCALIMPLEMENTATION CoSoapId : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapId __fastcall Create();
	__classmethod _di__SoapId __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapId(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapId(void) { }
	
};


class DELPHICLASS CoSoapIdref;
class PASCALIMPLEMENTATION CoSoapIdref : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapIdref __fastcall Create();
	__classmethod _di__SoapIdref __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapIdref(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapIdref(void) { }
	
};


class DELPHICLASS CoSoapEntity;
class PASCALIMPLEMENTATION CoSoapEntity : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapEntity __fastcall Create();
	__classmethod _di__SoapEntity __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapEntity(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapEntity(void) { }
	
};


class DELPHICLASS CoSynchronizationAttribute;
class PASCALIMPLEMENTATION CoSynchronizationAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SynchronizationAttribute __fastcall Create();
	__classmethod _di__SynchronizationAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSynchronizationAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSynchronizationAttribute(void) { }
	
};


class DELPHICLASS CoTrackingServices;
class PASCALIMPLEMENTATION CoTrackingServices : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TrackingServices __fastcall Create();
	__classmethod _di__TrackingServices __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTrackingServices(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTrackingServices(void) { }
	
};


class DELPHICLASS CoUrlAttribute;
class PASCALIMPLEMENTATION CoUrlAttribute : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__UrlAttribute __fastcall Create();
	__classmethod _di__UrlAttribute __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoUrlAttribute(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoUrlAttribute(void) { }
	
};


class DELPHICLASS CoIsolatedStorage;
class PASCALIMPLEMENTATION CoIsolatedStorage : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsolatedStorage __fastcall Create();
	__classmethod _di__IsolatedStorage __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsolatedStorage(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsolatedStorage(void) { }
	
};


class DELPHICLASS CoIsolatedStorageFile;
class PASCALIMPLEMENTATION CoIsolatedStorageFile : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsolatedStorageFile __fastcall Create();
	__classmethod _di__IsolatedStorageFile __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsolatedStorageFile(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsolatedStorageFile(void) { }
	
};


class DELPHICLASS CoIsolatedStorageFileStream;
class PASCALIMPLEMENTATION CoIsolatedStorageFileStream : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsolatedStorageFileStream __fastcall Create();
	__classmethod _di__IsolatedStorageFileStream __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsolatedStorageFileStream(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsolatedStorageFileStream(void) { }
	
};


class DELPHICLASS CoIsolatedStorageException;
class PASCALIMPLEMENTATION CoIsolatedStorageException : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__IsolatedStorageException __fastcall Create();
	__classmethod _di__IsolatedStorageException __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoIsolatedStorageException(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoIsolatedStorageException(void) { }
	
};


class DELPHICLASS CoInternalRM;
class PASCALIMPLEMENTATION CoInternalRM : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InternalRM __fastcall Create();
	__classmethod _di__InternalRM __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInternalRM(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInternalRM(void) { }
	
};


class DELPHICLASS CoInternalST;
class PASCALIMPLEMENTATION CoInternalST : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__InternalST __fastcall Create();
	__classmethod _di__InternalST __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoInternalST(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoInternalST(void) { }
	
};


class DELPHICLASS CoSoapMessage;
class PASCALIMPLEMENTATION CoSoapMessage : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapMessage __fastcall Create();
	__classmethod _di__SoapMessage __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapMessage(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapMessage(void) { }
	
};


class DELPHICLASS CoSoapFault;
class PASCALIMPLEMENTATION CoSoapFault : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SoapFault __fastcall Create();
	__classmethod _di__SoapFault __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSoapFault(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSoapFault(void) { }
	
};


class DELPHICLASS CoServerFault;
class PASCALIMPLEMENTATION CoServerFault : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ServerFault __fastcall Create();
	__classmethod _di__ServerFault __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoServerFault(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoServerFault(void) { }
	
};


class DELPHICLASS CoBinaryFormatter;
class PASCALIMPLEMENTATION CoBinaryFormatter : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__BinaryFormatter __fastcall Create();
	__classmethod _di__BinaryFormatter __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoBinaryFormatter(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoBinaryFormatter(void) { }
	
};


class DELPHICLASS CoAssemblyBuilder;
class PASCALIMPLEMENTATION CoAssemblyBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__AssemblyBuilder __fastcall Create();
	__classmethod _di__AssemblyBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoAssemblyBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoAssemblyBuilder(void) { }
	
};


class DELPHICLASS CoConstructorBuilder;
class PASCALIMPLEMENTATION CoConstructorBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ConstructorBuilder __fastcall Create();
	__classmethod _di__ConstructorBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoConstructorBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoConstructorBuilder(void) { }
	
};


class DELPHICLASS CoEventBuilder;
class PASCALIMPLEMENTATION CoEventBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EventBuilder __fastcall Create();
	__classmethod _di__EventBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEventBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEventBuilder(void) { }
	
};


class DELPHICLASS CoFieldBuilder;
class PASCALIMPLEMENTATION CoFieldBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__FieldBuilder __fastcall Create();
	__classmethod _di__FieldBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoFieldBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoFieldBuilder(void) { }
	
};


class DELPHICLASS CoILGenerator;
class PASCALIMPLEMENTATION CoILGenerator : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ILGenerator __fastcall Create();
	__classmethod _di__ILGenerator __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoILGenerator(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoILGenerator(void) { }
	
};


class DELPHICLASS CoLocalBuilder;
class PASCALIMPLEMENTATION CoLocalBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__LocalBuilder __fastcall Create();
	__classmethod _di__LocalBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoLocalBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoLocalBuilder(void) { }
	
};


class DELPHICLASS CoMethodBuilder;
class PASCALIMPLEMENTATION CoMethodBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodBuilder __fastcall Create();
	__classmethod _di__MethodBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodBuilder(void) { }
	
};


class DELPHICLASS CoCustomAttributeBuilder;
class PASCALIMPLEMENTATION CoCustomAttributeBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__CustomAttributeBuilder __fastcall Create();
	__classmethod _di__CustomAttributeBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoCustomAttributeBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoCustomAttributeBuilder(void) { }
	
};


class DELPHICLASS CoMethodRental;
class PASCALIMPLEMENTATION CoMethodRental : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__MethodRental __fastcall Create();
	__classmethod _di__MethodRental __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoMethodRental(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoMethodRental(void) { }
	
};


class DELPHICLASS CoModuleBuilder;
class PASCALIMPLEMENTATION CoModuleBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ModuleBuilder __fastcall Create();
	__classmethod _di__ModuleBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoModuleBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoModuleBuilder(void) { }
	
};


class DELPHICLASS CoOpCodes;
class PASCALIMPLEMENTATION CoOpCodes : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__OpCodes __fastcall Create();
	__classmethod _di__OpCodes __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoOpCodes(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoOpCodes(void) { }
	
};


class DELPHICLASS CoParameterBuilder;
class PASCALIMPLEMENTATION CoParameterBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__ParameterBuilder __fastcall Create();
	__classmethod _di__ParameterBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoParameterBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoParameterBuilder(void) { }
	
};


class DELPHICLASS CoPropertyBuilder;
class PASCALIMPLEMENTATION CoPropertyBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__PropertyBuilder __fastcall Create();
	__classmethod _di__PropertyBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoPropertyBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoPropertyBuilder(void) { }
	
};


class DELPHICLASS CoSignatureHelper;
class PASCALIMPLEMENTATION CoSignatureHelper : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__SignatureHelper __fastcall Create();
	__classmethod _di__SignatureHelper __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoSignatureHelper(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoSignatureHelper(void) { }
	
};


class DELPHICLASS CoTypeBuilder;
class PASCALIMPLEMENTATION CoTypeBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__TypeBuilder __fastcall Create();
	__classmethod _di__TypeBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoTypeBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoTypeBuilder(void) { }
	
};


class DELPHICLASS CoEnumBuilder;
class PASCALIMPLEMENTATION CoEnumBuilder : public System::TObject
{
	typedef System::TObject inherited;
	
public:
	__classmethod _di__EnumBuilder __fastcall Create();
	__classmethod _di__EnumBuilder __fastcall CreateRemote(const System::UnicodeString MachineName);
public:
	/* TObject.Create */ inline __fastcall CoEnumBuilder(void) : System::TObject() { }
	/* TObject.Destroy */ inline __fastcall virtual ~CoEnumBuilder(void) { }
	
};


//-- var, const, procedure ---------------------------------------------------
static const ShortInt mscorlibMajorVersion = 0x1;
static const ShortInt mscorlibMinorVersion = 0xa;
extern PACKAGE GUID LIBID_mscorlib;
extern PACKAGE GUID IID__Object;
extern PACKAGE GUID IID_ICloneable;
extern PACKAGE GUID IID_IEnumerable;
extern PACKAGE GUID IID_ICollection;
extern PACKAGE GUID IID_IList;
extern PACKAGE GUID IID__Array;
extern PACKAGE GUID IID_IEnumerator;
extern PACKAGE GUID IID_IComparable;
extern PACKAGE GUID IID_IConvertible;
extern PACKAGE GUID IID__String;
extern PACKAGE GUID IID__StringBuilder;
extern PACKAGE GUID IID_ISerializable;
extern PACKAGE GUID IID__Exception;
extern PACKAGE GUID IID__ValueType;
extern PACKAGE GUID IID_IFormattable;
extern PACKAGE GUID IID__SystemException;
extern PACKAGE GUID IID__OutOfMemoryException;
extern PACKAGE GUID IID__StackOverflowException;
extern PACKAGE GUID IID__ExecutionEngineException;
extern PACKAGE GUID IID__Delegate;
extern PACKAGE GUID IID__MulticastDelegate;
extern PACKAGE GUID IID__Enum;
extern PACKAGE GUID IID__MemberAccessException;
extern PACKAGE GUID IID__Activator;
extern PACKAGE GUID IID__ApplicationException;
extern PACKAGE GUID IID__EventArgs;
extern PACKAGE GUID IID__ResolveEventArgs;
extern PACKAGE GUID IID__AssemblyLoadEventArgs;
extern PACKAGE GUID IID__ResolveEventHandler;
extern PACKAGE GUID IID__AssemblyLoadEventHandler;
extern PACKAGE GUID IID__MarshalByRefObject;
extern PACKAGE GUID IID__AppDomain;
extern PACKAGE GUID IID_IEvidenceFactory;
extern PACKAGE GUID CLASS_AppDomain;
extern PACKAGE GUID IID__CrossAppDomainDelegate;
extern PACKAGE GUID IID_IAppDomainSetup;
extern PACKAGE GUID IID__Attribute;
extern PACKAGE GUID IID__LoaderOptimizationAttribute;
extern PACKAGE GUID IID__AppDomainUnloadedException;
extern PACKAGE GUID IID__ArgumentException;
extern PACKAGE GUID IID__ArgumentNullException;
extern PACKAGE GUID IID__ArgumentOutOfRangeException;
extern PACKAGE GUID IID__ArithmeticException;
extern PACKAGE GUID IID__ArrayTypeMismatchException;
extern PACKAGE GUID IID__AsyncCallback;
extern PACKAGE GUID IID__AttributeUsageAttribute;
extern PACKAGE GUID IID__BadImageFormatException;
extern PACKAGE GUID IID__BitConverter;
extern PACKAGE GUID IID__Buffer;
extern PACKAGE GUID IID__CannotUnloadAppDomainException;
extern PACKAGE GUID IID__CharEnumerator;
extern PACKAGE GUID IID__CLSCompliantAttribute;
extern PACKAGE GUID IID__TypeUnloadedException;
extern PACKAGE GUID IID__Console;
extern PACKAGE GUID IID__ContextMarshalException;
extern PACKAGE GUID IID__Convert;
extern PACKAGE GUID IID__ContextBoundObject;
extern PACKAGE GUID IID__ContextStaticAttribute;
extern PACKAGE GUID IID__TimeZone;
extern PACKAGE GUID IID__DBNull;
extern PACKAGE GUID IID__Binder;
extern PACKAGE GUID IID_IObjectReference;
extern PACKAGE GUID IID__DivideByZeroException;
extern PACKAGE GUID IID__DuplicateWaitObjectException;
extern PACKAGE GUID IID__TypeLoadException;
extern PACKAGE GUID IID__EntryPointNotFoundException;
extern PACKAGE GUID IID__DllNotFoundException;
extern PACKAGE GUID IID__Environment;
extern PACKAGE GUID IID__EventHandler;
extern PACKAGE GUID IID__FieldAccessException;
extern PACKAGE GUID IID__FlagsAttribute;
extern PACKAGE GUID IID__FormatException;
extern PACKAGE GUID IID__GC;
extern PACKAGE GUID IID_IAsyncResult;
extern PACKAGE GUID IID_ICustomFormatter;
extern PACKAGE GUID IID_IDisposable;
extern PACKAGE GUID IID_IFormatProvider;
extern PACKAGE GUID IID__IndexOutOfRangeException;
extern PACKAGE GUID IID__InvalidCastException;
extern PACKAGE GUID IID__InvalidOperationException;
extern PACKAGE GUID IID__InvalidProgramException;
extern PACKAGE GUID IID__LocalDataStoreSlot;
extern PACKAGE GUID IID__Math;
extern PACKAGE GUID IID__MethodAccessException;
extern PACKAGE GUID IID__MissingMemberException;
extern PACKAGE GUID IID__MissingFieldException;
extern PACKAGE GUID IID__MissingMethodException;
extern PACKAGE GUID IID__MulticastNotSupportedException;
extern PACKAGE GUID IID__NonSerializedAttribute;
extern PACKAGE GUID IID__NotFiniteNumberException;
extern PACKAGE GUID IID__NotImplementedException;
extern PACKAGE GUID IID__NotSupportedException;
extern PACKAGE GUID IID__NullReferenceException;
extern PACKAGE GUID IID__ObjectDisposedException;
extern PACKAGE GUID IID__ObsoleteAttribute;
extern PACKAGE GUID IID__OperatingSystem;
extern PACKAGE GUID IID__OverflowException;
extern PACKAGE GUID IID__ParamArrayAttribute;
extern PACKAGE GUID IID__PlatformNotSupportedException;
extern PACKAGE GUID IID__Random;
extern PACKAGE GUID IID__RankException;
extern PACKAGE GUID IID_ICustomAttributeProvider;
extern PACKAGE GUID IID__MemberInfo;
extern PACKAGE GUID IID_IReflect;
extern PACKAGE GUID IID__Type;
extern PACKAGE GUID IID__SerializableAttribute;
extern PACKAGE GUID IID__TypeInitializationException;
extern PACKAGE GUID IID__UnauthorizedAccessException;
extern PACKAGE GUID IID__UnhandledExceptionEventArgs;
extern PACKAGE GUID IID__UnhandledExceptionEventHandler;
extern PACKAGE GUID IID__Version;
extern PACKAGE GUID IID__WeakReference;
extern PACKAGE GUID IID__WaitHandle;
extern PACKAGE GUID IID__AutoResetEvent;
extern PACKAGE GUID IID__CompressedStack;
extern PACKAGE GUID IID__Interlocked;
extern PACKAGE GUID IID_IObjectHandle;
extern PACKAGE GUID IID__ManualResetEvent;
extern PACKAGE GUID IID__Monitor;
extern PACKAGE GUID IID__Mutex;
extern PACKAGE GUID IID__Overlapped;
extern PACKAGE GUID IID__ReaderWriterLock;
extern PACKAGE GUID IID__SynchronizationLockException;
extern PACKAGE GUID IID__Thread;
extern PACKAGE GUID IID__ThreadAbortException;
extern PACKAGE GUID IID__STAThreadAttribute;
extern PACKAGE GUID IID__MTAThreadAttribute;
extern PACKAGE GUID IID__ThreadInterruptedException;
extern PACKAGE GUID IID__RegisteredWaitHandle;
extern PACKAGE GUID IID__WaitCallback;
extern PACKAGE GUID IID__WaitOrTimerCallback;
extern PACKAGE GUID IID__IOCompletionCallback;
extern PACKAGE GUID IID__ThreadPool;
extern PACKAGE GUID IID__ThreadStart;
extern PACKAGE GUID IID__ThreadStateException;
extern PACKAGE GUID IID__ThreadStaticAttribute;
extern PACKAGE GUID IID__Timeout;
extern PACKAGE GUID IID__TimerCallback;
extern PACKAGE GUID IID__Timer;
extern PACKAGE GUID IID__ArrayList;
extern PACKAGE GUID IID__BitArray;
extern PACKAGE GUID IID_IComparer;
extern PACKAGE GUID IID__CaseInsensitiveComparer;
extern PACKAGE GUID IID_IHashCodeProvider;
extern PACKAGE GUID IID__CaseInsensitiveHashCodeProvider;
extern PACKAGE GUID IID__CollectionBase;
extern PACKAGE GUID IID__Comparer;
extern PACKAGE GUID IID_IDictionary;
extern PACKAGE GUID IID__DictionaryBase;
extern PACKAGE GUID IID_IDeserializationCallback;
extern PACKAGE GUID IID__Hashtable;
extern PACKAGE GUID IID_IDictionaryEnumerator;
extern PACKAGE GUID IID__Queue;
extern PACKAGE GUID IID__ReadOnlyCollectionBase;
extern PACKAGE GUID IID__SortedList;
extern PACKAGE GUID IID__Stack;
extern PACKAGE GUID IID__ConditionalAttribute;
extern PACKAGE GUID IID__Debugger;
extern PACKAGE GUID IID__DebuggerStepThroughAttribute;
extern PACKAGE GUID IID__DebuggerHiddenAttribute;
extern PACKAGE GUID IID__DebuggableAttribute;
extern PACKAGE GUID IID__StackTrace;
extern PACKAGE GUID IID__StackFrame;
extern PACKAGE GUID IID_ISymbolBinder;
extern PACKAGE GUID IID_ISymbolDocument;
extern PACKAGE GUID IID_ISymbolDocumentWriter;
extern PACKAGE GUID IID_ISymbolMethod;
extern PACKAGE GUID IID_ISymbolNamespace;
extern PACKAGE GUID IID_ISymbolReader;
extern PACKAGE GUID IID_ISymbolScope;
extern PACKAGE GUID IID_ISymbolVariable;
extern PACKAGE GUID IID_ISymbolWriter;
extern PACKAGE GUID IID__SymDocumentType;
extern PACKAGE GUID IID__SymLanguageType;
extern PACKAGE GUID IID__SymLanguageVendor;
extern PACKAGE GUID IID__AmbiguousMatchException;
extern PACKAGE GUID IID__ModuleResolveEventHandler;
extern PACKAGE GUID IID__Assembly;
extern PACKAGE GUID IID__AssemblyCultureAttribute;
extern PACKAGE GUID IID__AssemblyVersionAttribute;
extern PACKAGE GUID IID__AssemblyKeyFileAttribute;
extern PACKAGE GUID IID__AssemblyKeyNameAttribute;
extern PACKAGE GUID IID__AssemblyDelaySignAttribute;
extern PACKAGE GUID IID__AssemblyAlgorithmIdAttribute;
extern PACKAGE GUID IID__AssemblyFlagsAttribute;
extern PACKAGE GUID IID__AssemblyFileVersionAttribute;
extern PACKAGE GUID IID__AssemblyName;
extern PACKAGE GUID IID__AssemblyNameProxy;
extern PACKAGE GUID IID__AssemblyCopyrightAttribute;
extern PACKAGE GUID IID__AssemblyTrademarkAttribute;
extern PACKAGE GUID IID__AssemblyProductAttribute;
extern PACKAGE GUID IID__AssemblyCompanyAttribute;
extern PACKAGE GUID IID__AssemblyDescriptionAttribute;
extern PACKAGE GUID IID__AssemblyTitleAttribute;
extern PACKAGE GUID IID__AssemblyConfigurationAttribute;
extern PACKAGE GUID IID__AssemblyDefaultAliasAttribute;
extern PACKAGE GUID IID__AssemblyInformationalVersionAttribute;
extern PACKAGE GUID IID__CustomAttributeFormatException;
extern PACKAGE GUID IID__MethodBase;
extern PACKAGE GUID IID__ConstructorInfo;
extern PACKAGE GUID IID__DefaultMemberAttribute;
extern PACKAGE GUID IID__EventInfo;
extern PACKAGE GUID IID__FieldInfo;
extern PACKAGE GUID IID__InvalidFilterCriteriaException;
extern PACKAGE GUID IID__ManifestResourceInfo;
extern PACKAGE GUID IID__MemberFilter;
extern PACKAGE GUID IID__MethodInfo;
extern PACKAGE GUID IID__Missing;
extern PACKAGE GUID IID__Module;
extern PACKAGE GUID IID__ParameterInfo;
extern PACKAGE GUID IID__Pointer;
extern PACKAGE GUID IID__PropertyInfo;
extern PACKAGE GUID IID__ReflectionTypeLoadException;
extern PACKAGE GUID IID__StrongNameKeyPair;
extern PACKAGE GUID IID__TargetException;
extern PACKAGE GUID IID__TargetInvocationException;
extern PACKAGE GUID IID__TargetParameterCountException;
extern PACKAGE GUID IID__TypeDelegator;
extern PACKAGE GUID IID__TypeFilter;
extern PACKAGE GUID IID__UnmanagedMarshal;
extern PACKAGE GUID IID_IFormatter;
extern PACKAGE GUID IID__Formatter;
extern PACKAGE GUID IID_IFormatterConverter;
extern PACKAGE GUID IID__FormatterConverter;
extern PACKAGE GUID IID__FormatterServices;
extern PACKAGE GUID IID_ISerializationSurrogate;
extern PACKAGE GUID IID_ISurrogateSelector;
extern PACKAGE GUID IID__ObjectIDGenerator;
extern PACKAGE GUID IID__ObjectManager;
extern PACKAGE GUID IID__SerializationBinder;
extern PACKAGE GUID IID__SerializationInfo;
extern PACKAGE GUID IID__SerializationInfoEnumerator;
extern PACKAGE GUID IID__SerializationException;
extern PACKAGE GUID IID__SurrogateSelector;
extern PACKAGE GUID IID__Calendar;
extern PACKAGE GUID IID__CompareInfo;
extern PACKAGE GUID IID__CultureInfo;
extern PACKAGE GUID IID__DateTimeFormatInfo;
extern PACKAGE GUID IID__DaylightTime;
extern PACKAGE GUID IID__GregorianCalendar;
extern PACKAGE GUID IID__HebrewCalendar;
extern PACKAGE GUID IID__HijriCalendar;
extern PACKAGE GUID IID__JapaneseCalendar;
extern PACKAGE GUID IID__JulianCalendar;
extern PACKAGE GUID IID__KoreanCalendar;
extern PACKAGE GUID IID__RegionInfo;
extern PACKAGE GUID IID__SortKey;
extern PACKAGE GUID IID__StringInfo;
extern PACKAGE GUID IID__TaiwanCalendar;
extern PACKAGE GUID IID__TextElementEnumerator;
extern PACKAGE GUID IID__TextInfo;
extern PACKAGE GUID IID__ThaiBuddhistCalendar;
extern PACKAGE GUID IID__NumberFormatInfo;
extern PACKAGE GUID IID__Encoding;
extern PACKAGE GUID IID__System_Text_Decoder;
extern PACKAGE GUID IID__System_Text_Encoder;
extern PACKAGE GUID IID__ASCIIEncoding;
extern PACKAGE GUID IID__UnicodeEncoding;
extern PACKAGE GUID IID__UTF7Encoding;
extern PACKAGE GUID IID__UTF8Encoding;
extern PACKAGE GUID IID_IResourceReader;
extern PACKAGE GUID IID_IResourceWriter;
extern PACKAGE GUID IID__MissingManifestResourceException;
extern PACKAGE GUID IID__NeutralResourcesLanguageAttribute;
extern PACKAGE GUID IID__ResourceManager;
extern PACKAGE GUID IID__ResourceReader;
extern PACKAGE GUID IID__ResourceSet;
extern PACKAGE GUID IID__ResourceWriter;
extern PACKAGE GUID IID__SatelliteContractVersionAttribute;
extern PACKAGE GUID IID__Registry;
extern PACKAGE GUID IID__RegistryKey;
extern PACKAGE GUID IID__X509Certificate;
extern PACKAGE GUID IID__AsymmetricAlgorithm;
extern PACKAGE GUID IID__AsymmetricKeyExchangeDeformatter;
extern PACKAGE GUID IID__AsymmetricKeyExchangeFormatter;
extern PACKAGE GUID IID__AsymmetricSignatureDeformatter;
extern PACKAGE GUID IID__AsymmetricSignatureFormatter;
extern PACKAGE GUID IID_ICryptoTransform;
extern PACKAGE GUID IID__ToBase64Transform;
extern PACKAGE GUID IID__FromBase64Transform;
extern PACKAGE GUID IID__KeySizes;
extern PACKAGE GUID IID__CryptographicException;
extern PACKAGE GUID IID__CryptographicUnexpectedOperationException;
extern PACKAGE GUID IID__CryptoAPITransform;
extern PACKAGE GUID IID__CspParameters;
extern PACKAGE GUID IID__CryptoConfig;
extern PACKAGE GUID IID__Stream;
extern PACKAGE GUID IID__CryptoStream;
extern PACKAGE GUID IID__SymmetricAlgorithm;
extern PACKAGE GUID IID__DES;
extern PACKAGE GUID IID__DESCryptoServiceProvider;
extern PACKAGE GUID IID__DeriveBytes;
extern PACKAGE GUID IID__DSA;
extern PACKAGE GUID IID__DSACryptoServiceProvider;
extern PACKAGE GUID IID__DSASignatureDeformatter;
extern PACKAGE GUID IID__DSASignatureFormatter;
extern PACKAGE GUID IID__HashAlgorithm;
extern PACKAGE GUID IID__KeyedHashAlgorithm;
extern PACKAGE GUID IID__HMACSHA1;
extern PACKAGE GUID IID__MACTripleDES;
extern PACKAGE GUID IID__MD5;
extern PACKAGE GUID IID__MD5CryptoServiceProvider;
extern PACKAGE GUID IID__MaskGenerationMethod;
extern PACKAGE GUID IID__PasswordDeriveBytes;
extern PACKAGE GUID IID__PKCS1MaskGenerationMethod;
extern PACKAGE GUID IID__RC2;
extern PACKAGE GUID IID__RC2CryptoServiceProvider;
extern PACKAGE GUID IID__RandomNumberGenerator;
extern PACKAGE GUID IID__RNGCryptoServiceProvider;
extern PACKAGE GUID IID__RSA;
extern PACKAGE GUID IID__RSACryptoServiceProvider;
extern PACKAGE GUID IID__RSAOAEPKeyExchangeDeformatter;
extern PACKAGE GUID IID__RSAOAEPKeyExchangeFormatter;
extern PACKAGE GUID IID__RSAPKCS1KeyExchangeDeformatter;
extern PACKAGE GUID IID__RSAPKCS1KeyExchangeFormatter;
extern PACKAGE GUID IID__RSAPKCS1SignatureDeformatter;
extern PACKAGE GUID IID__RSAPKCS1SignatureFormatter;
extern PACKAGE GUID IID__Rijndael;
extern PACKAGE GUID IID__RijndaelManaged;
extern PACKAGE GUID IID__SHA1;
extern PACKAGE GUID IID__SHA1CryptoServiceProvider;
extern PACKAGE GUID IID__SHA1Managed;
extern PACKAGE GUID IID__SHA256;
extern PACKAGE GUID IID__SHA256Managed;
extern PACKAGE GUID IID__SHA384;
extern PACKAGE GUID IID__SHA384Managed;
extern PACKAGE GUID IID__SHA512;
extern PACKAGE GUID IID__SHA512Managed;
extern PACKAGE GUID IID__SignatureDescription;
extern PACKAGE GUID IID__TripleDES;
extern PACKAGE GUID IID__TripleDESCryptoServiceProvider;
extern PACKAGE GUID IID_ISecurityEncodable;
extern PACKAGE GUID IID_ISecurityPolicyEncodable;
extern PACKAGE GUID IID_IMembershipCondition;
extern PACKAGE GUID IID__AllMembershipCondition;
extern PACKAGE GUID IID__ApplicationDirectory;
extern PACKAGE GUID IID__ApplicationDirectoryMembershipCondition;
extern PACKAGE GUID IID__CodeGroup;
extern PACKAGE GUID IID__Evidence;
extern PACKAGE GUID IID__FileCodeGroup;
extern PACKAGE GUID IID__FirstMatchCodeGroup;
extern PACKAGE GUID IID__Hash;
extern PACKAGE GUID IID__HashMembershipCondition;
extern PACKAGE GUID IID_IIdentityPermissionFactory;
extern PACKAGE GUID IID__NetCodeGroup;
extern PACKAGE GUID IID__PermissionRequestEvidence;
extern PACKAGE GUID IID__PolicyException;
extern PACKAGE GUID IID__PolicyLevel;
extern PACKAGE GUID IID__PolicyStatement;
extern PACKAGE GUID IID__Publisher;
extern PACKAGE GUID IID__PublisherMembershipCondition;
extern PACKAGE GUID IID__Site;
extern PACKAGE GUID IID__SiteMembershipCondition;
extern PACKAGE GUID IID__StrongName;
extern PACKAGE GUID IID__StrongNameMembershipCondition;
extern PACKAGE GUID IID__UnionCodeGroup;
extern PACKAGE GUID IID__Url;
extern PACKAGE GUID IID__UrlMembershipCondition;
extern PACKAGE GUID IID__Zone;
extern PACKAGE GUID IID__ZoneMembershipCondition;
extern PACKAGE GUID IID_IIdentity;
extern PACKAGE GUID IID__GenericIdentity;
extern PACKAGE GUID IID_IPrincipal;
extern PACKAGE GUID IID__GenericPrincipal;
extern PACKAGE GUID IID__WindowsIdentity;
extern PACKAGE GUID IID__WindowsImpersonationContext;
extern PACKAGE GUID IID__WindowsPrincipal;
extern PACKAGE GUID IID__DispIdAttribute;
extern PACKAGE GUID IID__InterfaceTypeAttribute;
extern PACKAGE GUID IID__ClassInterfaceAttribute;
extern PACKAGE GUID IID__ComVisibleAttribute;
extern PACKAGE GUID IID__LCIDConversionAttribute;
extern PACKAGE GUID IID__ComRegisterFunctionAttribute;
extern PACKAGE GUID IID__ComUnregisterFunctionAttribute;
extern PACKAGE GUID IID__ProgIdAttribute;
extern PACKAGE GUID IID__ImportedFromTypeLibAttribute;
extern PACKAGE GUID IID__IDispatchImplAttribute;
extern PACKAGE GUID IID__ComSourceInterfacesAttribute;
extern PACKAGE GUID IID__ComConversionLossAttribute;
extern PACKAGE GUID IID__TypeLibTypeAttribute;
extern PACKAGE GUID IID__TypeLibFuncAttribute;
extern PACKAGE GUID IID__TypeLibVarAttribute;
extern PACKAGE GUID IID__MarshalAsAttribute;
extern PACKAGE GUID IID__ComImportAttribute;
extern PACKAGE GUID IID__GuidAttribute;
extern PACKAGE GUID IID__PreserveSigAttribute;
extern PACKAGE GUID IID__InAttribute;
extern PACKAGE GUID IID__OutAttribute;
extern PACKAGE GUID IID__OptionalAttribute;
extern PACKAGE GUID IID__DllImportAttribute;
extern PACKAGE GUID IID__StructLayoutAttribute;
extern PACKAGE GUID IID__FieldOffsetAttribute;
extern PACKAGE GUID IID__ComAliasNameAttribute;
extern PACKAGE GUID IID__AutomationProxyAttribute;
extern PACKAGE GUID IID__PrimaryInteropAssemblyAttribute;
extern PACKAGE GUID IID__CoClassAttribute;
extern PACKAGE GUID IID__ComEventInterfaceAttribute;
extern PACKAGE GUID IID__TypeLibVersionAttribute;
extern PACKAGE GUID IID__ComCompatibleVersionAttribute;
extern PACKAGE GUID IID__BestFitMappingAttribute;
extern PACKAGE GUID IID__ExternalException;
extern PACKAGE GUID IID__COMException;
extern PACKAGE GUID IID__CurrencyWrapper;
extern PACKAGE GUID IID__DispatchWrapper;
extern PACKAGE GUID IID__ErrorWrapper;
extern PACKAGE GUID IID__ExtensibleClassFactory;
extern PACKAGE GUID IID_ICustomAdapter;
extern PACKAGE GUID IID_ICustomMarshaler;
extern PACKAGE GUID IID_ICustomFactory;
extern PACKAGE GUID IID__InvalidComObjectException;
extern PACKAGE GUID IID__InvalidOleVariantTypeException;
extern PACKAGE GUID IID_IRegistrationServices;
extern PACKAGE GUID IID_ITypeLibImporterNotifySink;
extern PACKAGE GUID IID_ITypeLibExporterNotifySink;
extern PACKAGE GUID IID_ITypeLibConverter;
extern PACKAGE GUID IID_ITypeLibExporterNameProvider;
extern PACKAGE GUID IID__Marshal;
extern PACKAGE GUID IID__MarshalDirectiveException;
extern PACKAGE GUID IID__ObjectCreationDelegate;
extern PACKAGE GUID CLASS_RegistrationServices;
extern PACKAGE GUID IID__RuntimeEnvironment;
extern PACKAGE GUID IID__SafeArrayRankMismatchException;
extern PACKAGE GUID IID__SafeArrayTypeMismatchException;
extern PACKAGE GUID IID__SEHException;
extern PACKAGE GUID CLASS_TypeLibConverter;
extern PACKAGE GUID IID__UnknownWrapper;
extern PACKAGE GUID IID_IExpando;
extern PACKAGE GUID IID__BinaryReader;
extern PACKAGE GUID IID__BinaryWriter;
extern PACKAGE GUID IID__BufferedStream;
extern PACKAGE GUID IID__Directory;
extern PACKAGE GUID IID__FileSystemInfo;
extern PACKAGE GUID IID__DirectoryInfo;
extern PACKAGE GUID IID__IOException;
extern PACKAGE GUID IID__DirectoryNotFoundException;
extern PACKAGE GUID IID__EndOfStreamException;
extern PACKAGE GUID IID__File;
extern PACKAGE GUID IID__FileInfo;
extern PACKAGE GUID IID__FileLoadException;
extern PACKAGE GUID IID__FileNotFoundException;
extern PACKAGE GUID IID__FileStream;
extern PACKAGE GUID IID__MemoryStream;
extern PACKAGE GUID IID__Path;
extern PACKAGE GUID IID__PathTooLongException;
extern PACKAGE GUID IID__TextReader;
extern PACKAGE GUID IID__StreamReader;
extern PACKAGE GUID IID__TextWriter;
extern PACKAGE GUID IID__StreamWriter;
extern PACKAGE GUID IID__StringReader;
extern PACKAGE GUID IID__StringWriter;
extern PACKAGE GUID IID__AccessedThroughPropertyAttribute;
extern PACKAGE GUID IID__CallConvCdecl;
extern PACKAGE GUID IID__CallConvStdcall;
extern PACKAGE GUID IID__CallConvThiscall;
extern PACKAGE GUID IID__CallConvFastcall;
extern PACKAGE GUID IID__RuntimeHelpers;
extern PACKAGE GUID IID__CustomConstantAttribute;
extern PACKAGE GUID IID__DateTimeConstantAttribute;
extern PACKAGE GUID IID__DiscardableAttribute;
extern PACKAGE GUID IID__DecimalConstantAttribute;
extern PACKAGE GUID IID__CompilationRelaxationsAttribute;
extern PACKAGE GUID IID__CompilerGlobalScopeAttribute;
extern PACKAGE GUID IID__IDispatchConstantAttribute;
extern PACKAGE GUID IID__IndexerNameAttribute;
extern PACKAGE GUID IID__IsVolatile;
extern PACKAGE GUID IID__IUnknownConstantAttribute;
extern PACKAGE GUID IID__MethodImplAttribute;
extern PACKAGE GUID IID__RequiredAttributeAttribute;
extern PACKAGE GUID IID_IStackWalk;
extern PACKAGE GUID IID__PermissionSet;
extern PACKAGE GUID IID__NamedPermissionSet;
extern PACKAGE GUID IID__SecurityElement;
extern PACKAGE GUID IID__XmlSyntaxException;
extern PACKAGE GUID IID_IPermission;
extern PACKAGE GUID IID__CodeAccessPermission;
extern PACKAGE GUID IID_IUnrestrictedPermission;
extern PACKAGE GUID IID__EnvironmentPermission;
extern PACKAGE GUID IID__FileDialogPermission;
extern PACKAGE GUID IID__FileIOPermission;
extern PACKAGE GUID IID__IsolatedStoragePermission;
extern PACKAGE GUID IID__IsolatedStorageFilePermission;
extern PACKAGE GUID IID__SecurityAttribute;
extern PACKAGE GUID IID__CodeAccessSecurityAttribute;
extern PACKAGE GUID IID__EnvironmentPermissionAttribute;
extern PACKAGE GUID IID__FileDialogPermissionAttribute;
extern PACKAGE GUID IID__FileIOPermissionAttribute;
extern PACKAGE GUID IID__PrincipalPermissionAttribute;
extern PACKAGE GUID IID__ReflectionPermissionAttribute;
extern PACKAGE GUID IID__RegistryPermissionAttribute;
extern PACKAGE GUID IID__SecurityPermissionAttribute;
extern PACKAGE GUID IID__UIPermissionAttribute;
extern PACKAGE GUID IID__ZoneIdentityPermissionAttribute;
extern PACKAGE GUID IID__StrongNameIdentityPermissionAttribute;
extern PACKAGE GUID IID__SiteIdentityPermissionAttribute;
extern PACKAGE GUID IID__UrlIdentityPermissionAttribute;
extern PACKAGE GUID IID__PublisherIdentityPermissionAttribute;
extern PACKAGE GUID IID__IsolatedStoragePermissionAttribute;
extern PACKAGE GUID IID__IsolatedStorageFilePermissionAttribute;
extern PACKAGE GUID IID__PermissionSetAttribute;
extern PACKAGE GUID IID__PublisherIdentityPermission;
extern PACKAGE GUID IID__ReflectionPermission;
extern PACKAGE GUID IID__RegistryPermission;
extern PACKAGE GUID IID__PrincipalPermission;
extern PACKAGE GUID IID__SecurityPermission;
extern PACKAGE GUID IID__SiteIdentityPermission;
extern PACKAGE GUID IID__StrongNameIdentityPermission;
extern PACKAGE GUID IID__StrongNamePublicKeyBlob;
extern PACKAGE GUID IID__UIPermission;
extern PACKAGE GUID IID__UrlIdentityPermission;
extern PACKAGE GUID IID__ZoneIdentityPermission;
extern PACKAGE GUID IID__SuppressUnmanagedCodeSecurityAttribute;
extern PACKAGE GUID IID__UnverifiableCodeAttribute;
extern PACKAGE GUID IID__AllowPartiallyTrustedCallersAttribute;
extern PACKAGE GUID IID__SecurityException;
extern PACKAGE GUID IID__SecurityManager;
extern PACKAGE GUID IID__VerificationException;
extern PACKAGE GUID IID_IContextAttribute;
extern PACKAGE GUID IID_IContextProperty;
extern PACKAGE GUID IID__ContextAttribute;
extern PACKAGE GUID IID_IActivator;
extern PACKAGE GUID IID_IMessageSink;
extern PACKAGE GUID IID__AsyncResult;
extern PACKAGE GUID IID__CallContext;
extern PACKAGE GUID IID_ILogicalThreadAffinative;
extern PACKAGE GUID IID__LogicalCallContext;
extern PACKAGE GUID IID__ChannelServices;
extern PACKAGE GUID IID_IClientResponseChannelSinkStack;
extern PACKAGE GUID IID_IClientChannelSinkStack;
extern PACKAGE GUID IID__ClientChannelSinkStack;
extern PACKAGE GUID IID_IServerResponseChannelSinkStack;
extern PACKAGE GUID IID_IServerChannelSinkStack;
extern PACKAGE GUID IID__ServerChannelSinkStack;
extern PACKAGE GUID IID__InternalMessageWrapper;
extern PACKAGE GUID IID_IMessage;
extern PACKAGE GUID IID_IMethodMessage;
extern PACKAGE GUID IID_IMethodCallMessage;
extern PACKAGE GUID IID__MethodCallMessageWrapper;
extern PACKAGE GUID IID_ISponsor;
extern PACKAGE GUID IID__ClientSponsor;
extern PACKAGE GUID IID__CrossContextDelegate;
extern PACKAGE GUID IID__Context;
extern PACKAGE GUID IID__ContextProperty;
extern PACKAGE GUID IID_IContextPropertyActivator;
extern PACKAGE GUID IID_IChannel;
extern PACKAGE GUID IID_IChannelSender;
extern PACKAGE GUID IID_IChannelReceiver;
extern PACKAGE GUID IID_IServerChannelSinkProvider;
extern PACKAGE GUID IID_IChannelSinkBase;
extern PACKAGE GUID IID_IServerChannelSink;
extern PACKAGE GUID IID__EnterpriseServicesHelper;
extern PACKAGE GUID IID__Header;
extern PACKAGE GUID IID__HeaderHandler;
extern PACKAGE GUID IID_IConstructionCallMessage;
extern PACKAGE GUID IID_IMethodReturnMessage;
extern PACKAGE GUID IID_IConstructionReturnMessage;
extern PACKAGE GUID IID_IChannelReceiverHook;
extern PACKAGE GUID IID_IClientChannelSinkProvider;
extern PACKAGE GUID IID_IClientFormatterSinkProvider;
extern PACKAGE GUID IID_IServerFormatterSinkProvider;
extern PACKAGE GUID IID_IClientChannelSink;
extern PACKAGE GUID IID_IClientFormatterSink;
extern PACKAGE GUID IID_IChannelDataStore;
extern PACKAGE GUID IID__ChannelDataStore;
extern PACKAGE GUID IID_ITransportHeaders;
extern PACKAGE GUID IID__TransportHeaders;
extern PACKAGE GUID IID__SinkProviderData;
extern PACKAGE GUID IID__BaseChannelObjectWithProperties;
extern PACKAGE GUID IID__BaseChannelSinkWithProperties;
extern PACKAGE GUID IID__BaseChannelWithProperties;
extern PACKAGE GUID IID_IContributeClientContextSink;
extern PACKAGE GUID IID_IContributeDynamicSink;
extern PACKAGE GUID IID_IContributeEnvoySink;
extern PACKAGE GUID IID_IContributeObjectSink;
extern PACKAGE GUID IID_IContributeServerContextSink;
extern PACKAGE GUID IID_IDynamicProperty;
extern PACKAGE GUID IID_IDynamicMessageSink;
extern PACKAGE GUID IID_ILease;
extern PACKAGE GUID IID_IMessageCtrl;
extern PACKAGE GUID IID_IRemotingFormatter;
extern PACKAGE GUID IID__LifetimeServices;
extern PACKAGE GUID IID__ReturnMessage;
extern PACKAGE GUID IID__MethodCall;
extern PACKAGE GUID IID__ConstructionCall;
extern PACKAGE GUID IID__MethodResponse;
extern PACKAGE GUID IID_IFieldInfo;
extern PACKAGE GUID IID__ConstructionResponse;
extern PACKAGE GUID IID__MethodReturnMessageWrapper;
extern PACKAGE GUID IID__ObjectHandle;
extern PACKAGE GUID IID_IRemotingTypeInfo;
extern PACKAGE GUID IID_IChannelInfo;
extern PACKAGE GUID IID_IEnvoyInfo;
extern PACKAGE GUID IID__ObjRef;
extern PACKAGE GUID IID__OneWayAttribute;
extern PACKAGE GUID IID__ProxyAttribute;
extern PACKAGE GUID IID__RealProxy;
extern PACKAGE GUID IID__SoapAttribute;
extern PACKAGE GUID IID__SoapTypeAttribute;
extern PACKAGE GUID IID__SoapMethodAttribute;
extern PACKAGE GUID IID__SoapFieldAttribute;
extern PACKAGE GUID IID__SoapParameterAttribute;
extern PACKAGE GUID IID__RemotingConfiguration;
extern PACKAGE GUID IID__System_Runtime_Remoting_TypeEntry;
extern PACKAGE GUID IID__ActivatedClientTypeEntry;
extern PACKAGE GUID IID__ActivatedServiceTypeEntry;
extern PACKAGE GUID IID__WellKnownClientTypeEntry;
extern PACKAGE GUID IID__WellKnownServiceTypeEntry;
extern PACKAGE GUID IID__RemotingException;
extern PACKAGE GUID IID__ServerException;
extern PACKAGE GUID IID__RemotingTimeoutException;
extern PACKAGE GUID IID__RemotingServices;
extern PACKAGE GUID IID__InternalRemotingServices;
extern PACKAGE GUID IID__MessageSurrogateFilter;
extern PACKAGE GUID IID__RemotingSurrogateSelector;
extern PACKAGE GUID IID__SoapServices;
extern PACKAGE GUID IID_ISoapXsd;
extern PACKAGE GUID IID__SoapDateTime;
extern PACKAGE GUID IID__SoapDuration;
extern PACKAGE GUID IID__SoapTime;
extern PACKAGE GUID IID__SoapDate;
extern PACKAGE GUID IID__SoapYearMonth;
extern PACKAGE GUID IID__SoapYear;
extern PACKAGE GUID IID__SoapMonthDay;
extern PACKAGE GUID IID__SoapDay;
extern PACKAGE GUID IID__SoapMonth;
extern PACKAGE GUID IID__SoapHexBinary;
extern PACKAGE GUID IID__SoapBase64Binary;
extern PACKAGE GUID IID__SoapInteger;
extern PACKAGE GUID IID__SoapPositiveInteger;
extern PACKAGE GUID IID__SoapNonPositiveInteger;
extern PACKAGE GUID IID__SoapNonNegativeInteger;
extern PACKAGE GUID IID__SoapNegativeInteger;
extern PACKAGE GUID IID__SoapAnyUri;
extern PACKAGE GUID IID__SoapQName;
extern PACKAGE GUID IID__SoapNotation;
extern PACKAGE GUID IID__SoapNormalizedString;
extern PACKAGE GUID IID__SoapToken;
extern PACKAGE GUID IID__SoapLanguage;
extern PACKAGE GUID IID__SoapName;
extern PACKAGE GUID IID__SoapIdrefs;
extern PACKAGE GUID IID__SoapEntities;
extern PACKAGE GUID IID__SoapNmtoken;
extern PACKAGE GUID IID__SoapNmtokens;
extern PACKAGE GUID IID__SoapNcName;
extern PACKAGE GUID IID__SoapId;
extern PACKAGE GUID IID__SoapIdref;
extern PACKAGE GUID IID__SoapEntity;
extern PACKAGE GUID IID__SynchronizationAttribute;
extern PACKAGE GUID IID_ITrackingHandler;
extern PACKAGE GUID IID__TrackingServices;
extern PACKAGE GUID IID__UrlAttribute;
extern PACKAGE GUID IID__IsolatedStorage;
extern PACKAGE GUID IID__IsolatedStorageFile;
extern PACKAGE GUID IID__IsolatedStorageFileStream;
extern PACKAGE GUID IID__IsolatedStorageException;
extern PACKAGE GUID IID_INormalizeForIsolatedStorage;
extern PACKAGE GUID IID_ISoapMessage;
extern PACKAGE GUID IID__InternalRM;
extern PACKAGE GUID IID__InternalST;
extern PACKAGE GUID IID__SoapMessage;
extern PACKAGE GUID IID__SoapFault;
extern PACKAGE GUID IID__ServerFault;
extern PACKAGE GUID IID__BinaryFormatter;
extern PACKAGE GUID IID__AssemblyBuilder;
extern PACKAGE GUID IID__ConstructorBuilder;
extern PACKAGE GUID IID__EventBuilder;
extern PACKAGE GUID IID__FieldBuilder;
extern PACKAGE GUID IID__ILGenerator;
extern PACKAGE GUID IID__LocalBuilder;
extern PACKAGE GUID IID__MethodBuilder;
extern PACKAGE GUID IID__CustomAttributeBuilder;
extern PACKAGE GUID IID__MethodRental;
extern PACKAGE GUID IID__ModuleBuilder;
extern PACKAGE GUID IID__OpCodes;
extern PACKAGE GUID IID__ParameterBuilder;
extern PACKAGE GUID IID__PropertyBuilder;
extern PACKAGE GUID IID__SignatureHelper;
extern PACKAGE GUID IID__TypeBuilder;
extern PACKAGE GUID IID__EnumBuilder;
extern PACKAGE GUID CLASS_AppDomainSetup;
extern PACKAGE GUID CLASS_Object_;
extern PACKAGE GUID CLASS_Array_;
extern PACKAGE GUID CLASS_String_;
extern PACKAGE GUID CLASS_StringBuilder;
extern PACKAGE GUID CLASS_Exception;
extern PACKAGE GUID CLASS_ValueType;
extern PACKAGE GUID CLASS_SystemException;
extern PACKAGE GUID CLASS_OutOfMemoryException;
extern PACKAGE GUID CLASS_StackOverflowException;
extern PACKAGE GUID CLASS_ExecutionEngineException;
extern PACKAGE GUID CLASS_Delegate;
extern PACKAGE GUID CLASS_MulticastDelegate;
extern PACKAGE GUID CLASS_Enum;
extern PACKAGE GUID CLASS_MemberAccessException;
extern PACKAGE GUID CLASS_Activator;
extern PACKAGE GUID CLASS_ApplicationException;
extern PACKAGE GUID CLASS_EventArgs;
extern PACKAGE GUID CLASS_ResolveEventArgs;
extern PACKAGE GUID CLASS_AssemblyLoadEventArgs;
extern PACKAGE GUID CLASS_ResolveEventHandler;
extern PACKAGE GUID CLASS_AssemblyLoadEventHandler;
extern PACKAGE GUID CLASS_MarshalByRefObject;
extern PACKAGE GUID CLASS_CrossAppDomainDelegate;
extern PACKAGE GUID CLASS_Attribute;
extern PACKAGE GUID CLASS_LoaderOptimizationAttribute;
extern PACKAGE GUID CLASS_AppDomainUnloadedException;
extern PACKAGE GUID CLASS_ArgumentException;
extern PACKAGE GUID CLASS_ArgumentNullException;
extern PACKAGE GUID CLASS_ArgumentOutOfRangeException;
extern PACKAGE GUID CLASS_ArithmeticException;
extern PACKAGE GUID CLASS_ArrayTypeMismatchException;
extern PACKAGE GUID CLASS_AsyncCallback;
extern PACKAGE GUID CLASS_AttributeUsageAttribute;
extern PACKAGE GUID CLASS_BadImageFormatException;
extern PACKAGE GUID CLASS_BitConverter;
extern PACKAGE GUID CLASS_Buffer;
extern PACKAGE GUID CLASS_CannotUnloadAppDomainException;
extern PACKAGE GUID CLASS_CharEnumerator;
extern PACKAGE GUID CLASS_CLSCompliantAttribute;
extern PACKAGE GUID CLASS_TypeUnloadedException;
extern PACKAGE GUID CLASS_Console;
extern PACKAGE GUID CLASS_ContextMarshalException;
extern PACKAGE GUID CLASS_Convert;
extern PACKAGE GUID CLASS_ContextBoundObject;
extern PACKAGE GUID CLASS_ContextStaticAttribute;
extern PACKAGE GUID CLASS_TimeZone;
extern PACKAGE GUID CLASS_DBNull;
extern PACKAGE GUID CLASS_Binder;
extern PACKAGE GUID CLASS_DivideByZeroException;
extern PACKAGE GUID CLASS_DuplicateWaitObjectException;
extern PACKAGE GUID CLASS_TypeLoadException;
extern PACKAGE GUID CLASS_EntryPointNotFoundException;
extern PACKAGE GUID CLASS_DllNotFoundException;
extern PACKAGE GUID CLASS_Environment;
extern PACKAGE GUID CLASS_EventHandler;
extern PACKAGE GUID CLASS_FieldAccessException;
extern PACKAGE GUID CLASS_FlagsAttribute;
extern PACKAGE GUID CLASS_FormatException;
extern PACKAGE GUID CLASS_GC;
extern PACKAGE GUID CLASS_IndexOutOfRangeException;
extern PACKAGE GUID CLASS_InvalidCastException;
extern PACKAGE GUID CLASS_InvalidOperationException;
extern PACKAGE GUID CLASS_InvalidProgramException;
extern PACKAGE GUID CLASS_LocalDataStoreSlot;
extern PACKAGE GUID CLASS_Math;
extern PACKAGE GUID CLASS_MethodAccessException;
extern PACKAGE GUID CLASS_MissingMemberException;
extern PACKAGE GUID CLASS_MissingFieldException;
extern PACKAGE GUID CLASS_MissingMethodException;
extern PACKAGE GUID CLASS_MulticastNotSupportedException;
extern PACKAGE GUID CLASS_NonSerializedAttribute;
extern PACKAGE GUID CLASS_NotFiniteNumberException;
extern PACKAGE GUID CLASS_NotImplementedException;
extern PACKAGE GUID CLASS_NotSupportedException;
extern PACKAGE GUID CLASS_NullReferenceException;
extern PACKAGE GUID CLASS_ObjectDisposedException;
extern PACKAGE GUID CLASS_ObsoleteAttribute;
extern PACKAGE GUID CLASS_OperatingSystem;
extern PACKAGE GUID CLASS_OverflowException;
extern PACKAGE GUID CLASS_ParamArrayAttribute;
extern PACKAGE GUID CLASS_PlatformNotSupportedException;
extern PACKAGE GUID CLASS_Random;
extern PACKAGE GUID CLASS_RankException;
extern PACKAGE GUID CLASS_MemberInfo;
extern PACKAGE GUID CLASS_Type_;
extern PACKAGE GUID CLASS_SerializableAttribute;
extern PACKAGE GUID CLASS_TypeInitializationException;
extern PACKAGE GUID CLASS_UnauthorizedAccessException;
extern PACKAGE GUID CLASS_UnhandledExceptionEventArgs;
extern PACKAGE GUID CLASS_UnhandledExceptionEventHandler;
extern PACKAGE GUID CLASS_Version;
extern PACKAGE GUID CLASS_WeakReference;
extern PACKAGE GUID CLASS_WaitHandle;
extern PACKAGE GUID CLASS_AutoResetEvent;
extern PACKAGE GUID CLASS_CompressedStack;
extern PACKAGE GUID CLASS_Interlocked;
extern PACKAGE GUID CLASS_ManualResetEvent;
extern PACKAGE GUID CLASS_Monitor;
extern PACKAGE GUID CLASS_Mutex;
extern PACKAGE GUID CLASS_Overlapped;
extern PACKAGE GUID CLASS_ReaderWriterLock;
extern PACKAGE GUID CLASS_SynchronizationLockException;
extern PACKAGE GUID CLASS_Thread;
extern PACKAGE GUID CLASS_ThreadAbortException;
extern PACKAGE GUID CLASS_STAThreadAttribute;
extern PACKAGE GUID CLASS_MTAThreadAttribute;
extern PACKAGE GUID CLASS_ThreadInterruptedException;
extern PACKAGE GUID CLASS_RegisteredWaitHandle;
extern PACKAGE GUID CLASS_WaitCallback;
extern PACKAGE GUID CLASS_WaitOrTimerCallback;
extern PACKAGE GUID CLASS_IOCompletionCallback;
extern PACKAGE GUID CLASS_ThreadPool;
extern PACKAGE GUID CLASS_ThreadStart;
extern PACKAGE GUID CLASS_ThreadStateException;
extern PACKAGE GUID CLASS_ThreadStaticAttribute;
extern PACKAGE GUID CLASS_Timeout;
extern PACKAGE GUID CLASS_TimerCallback;
extern PACKAGE GUID CLASS_Timer;
extern PACKAGE GUID CLASS_ArrayList;
extern PACKAGE GUID CLASS_BitArray;
extern PACKAGE GUID CLASS_CaseInsensitiveComparer;
extern PACKAGE GUID CLASS_CaseInsensitiveHashCodeProvider;
extern PACKAGE GUID CLASS_CollectionBase;
extern PACKAGE GUID CLASS_Comparer;
extern PACKAGE GUID CLASS_DictionaryBase;
extern PACKAGE GUID CLASS_Hashtable;
extern PACKAGE GUID CLASS_Queue;
extern PACKAGE GUID CLASS_ReadOnlyCollectionBase;
extern PACKAGE GUID CLASS_SortedList;
extern PACKAGE GUID CLASS_Stack;
extern PACKAGE GUID CLASS_ConditionalAttribute;
extern PACKAGE GUID CLASS_Debugger;
extern PACKAGE GUID CLASS_DebuggerStepThroughAttribute;
extern PACKAGE GUID CLASS_DebuggerHiddenAttribute;
extern PACKAGE GUID CLASS_DebuggableAttribute;
extern PACKAGE GUID CLASS_StackTrace;
extern PACKAGE GUID CLASS_StackFrame;
extern PACKAGE GUID CLASS_SymDocumentType;
extern PACKAGE GUID CLASS_SymLanguageType;
extern PACKAGE GUID CLASS_SymLanguageVendor;
extern PACKAGE GUID CLASS_AmbiguousMatchException;
extern PACKAGE GUID CLASS_ModuleResolveEventHandler;
extern PACKAGE GUID CLASS_Assembly;
extern PACKAGE GUID CLASS_AssemblyCultureAttribute;
extern PACKAGE GUID CLASS_AssemblyVersionAttribute;
extern PACKAGE GUID CLASS_AssemblyKeyFileAttribute;
extern PACKAGE GUID CLASS_AssemblyKeyNameAttribute;
extern PACKAGE GUID CLASS_AssemblyDelaySignAttribute;
extern PACKAGE GUID CLASS_AssemblyAlgorithmIdAttribute;
extern PACKAGE GUID CLASS_AssemblyFlagsAttribute;
extern PACKAGE GUID CLASS_AssemblyFileVersionAttribute;
extern PACKAGE GUID CLASS_AssemblyName;
extern PACKAGE GUID CLASS_AssemblyNameProxy;
extern PACKAGE GUID CLASS_AssemblyCopyrightAttribute;
extern PACKAGE GUID CLASS_AssemblyTrademarkAttribute;
extern PACKAGE GUID CLASS_AssemblyProductAttribute;
extern PACKAGE GUID CLASS_AssemblyCompanyAttribute;
extern PACKAGE GUID CLASS_AssemblyDescriptionAttribute;
extern PACKAGE GUID CLASS_AssemblyTitleAttribute;
extern PACKAGE GUID CLASS_AssemblyConfigurationAttribute;
extern PACKAGE GUID CLASS_AssemblyDefaultAliasAttribute;
extern PACKAGE GUID CLASS_AssemblyInformationalVersionAttribute;
extern PACKAGE GUID CLASS_CustomAttributeFormatException;
extern PACKAGE GUID CLASS_MethodBase;
extern PACKAGE GUID CLASS_ConstructorInfo;
extern PACKAGE GUID CLASS_DefaultMemberAttribute;
extern PACKAGE GUID CLASS_EventInfo;
extern PACKAGE GUID CLASS_FieldInfo;
extern PACKAGE GUID CLASS_InvalidFilterCriteriaException;
extern PACKAGE GUID CLASS_ManifestResourceInfo;
extern PACKAGE GUID CLASS_MemberFilter;
extern PACKAGE GUID CLASS_MethodInfo;
extern PACKAGE GUID CLASS_Missing;
extern PACKAGE GUID CLASS_Module;
extern PACKAGE GUID CLASS_ParameterInfo;
extern PACKAGE GUID CLASS_Pointer;
extern PACKAGE GUID CLASS_PropertyInfo;
extern PACKAGE GUID CLASS_ReflectionTypeLoadException;
extern PACKAGE GUID CLASS_StrongNameKeyPair;
extern PACKAGE GUID CLASS_TargetException;
extern PACKAGE GUID CLASS_TargetInvocationException;
extern PACKAGE GUID CLASS_TargetParameterCountException;
extern PACKAGE GUID CLASS_TypeDelegator;
extern PACKAGE GUID CLASS_TypeFilter;
extern PACKAGE GUID CLASS_UnmanagedMarshal;
extern PACKAGE GUID CLASS_Formatter;
extern PACKAGE GUID CLASS_FormatterConverter;
extern PACKAGE GUID CLASS_FormatterServices;
extern PACKAGE GUID CLASS_ObjectIDGenerator;
extern PACKAGE GUID CLASS_ObjectManager;
extern PACKAGE GUID CLASS_SerializationBinder;
extern PACKAGE GUID CLASS_SerializationInfo;
extern PACKAGE GUID CLASS_SerializationInfoEnumerator;
extern PACKAGE GUID CLASS_SerializationException;
extern PACKAGE GUID CLASS_SurrogateSelector;
extern PACKAGE GUID CLASS_Calendar;
extern PACKAGE GUID CLASS_CompareInfo;
extern PACKAGE GUID CLASS_CultureInfo;
extern PACKAGE GUID CLASS_DateTimeFormatInfo;
extern PACKAGE GUID CLASS_DaylightTime;
extern PACKAGE GUID CLASS_GregorianCalendar;
extern PACKAGE GUID CLASS_HebrewCalendar;
extern PACKAGE GUID CLASS_HijriCalendar;
extern PACKAGE GUID CLASS_JapaneseCalendar;
extern PACKAGE GUID CLASS_JulianCalendar;
extern PACKAGE GUID CLASS_KoreanCalendar;
extern PACKAGE GUID CLASS_RegionInfo;
extern PACKAGE GUID CLASS_SortKey;
extern PACKAGE GUID CLASS_StringInfo;
extern PACKAGE GUID CLASS_TaiwanCalendar;
extern PACKAGE GUID CLASS_TextElementEnumerator;
extern PACKAGE GUID CLASS_TextInfo;
extern PACKAGE GUID CLASS_ThaiBuddhistCalendar;
extern PACKAGE GUID CLASS_NumberFormatInfo;
extern PACKAGE GUID CLASS_Encoding;
extern PACKAGE GUID CLASS_System_Text_Decoder;
extern PACKAGE GUID CLASS_System_Text_Encoder;
extern PACKAGE GUID CLASS_ASCIIEncoding;
extern PACKAGE GUID CLASS_UnicodeEncoding;
extern PACKAGE GUID CLASS_UTF7Encoding;
extern PACKAGE GUID CLASS_UTF8Encoding;
extern PACKAGE GUID CLASS_MissingManifestResourceException;
extern PACKAGE GUID CLASS_NeutralResourcesLanguageAttribute;
extern PACKAGE GUID CLASS_ResourceManager;
extern PACKAGE GUID CLASS_ResourceReader;
extern PACKAGE GUID CLASS_ResourceSet;
extern PACKAGE GUID CLASS_ResourceWriter;
extern PACKAGE GUID CLASS_SatelliteContractVersionAttribute;
extern PACKAGE GUID CLASS_Registry;
extern PACKAGE GUID CLASS_RegistryKey;
extern PACKAGE GUID CLASS_X509Certificate;
extern PACKAGE GUID CLASS_AsymmetricAlgorithm;
extern PACKAGE GUID CLASS_AsymmetricKeyExchangeDeformatter;
extern PACKAGE GUID CLASS_AsymmetricKeyExchangeFormatter;
extern PACKAGE GUID CLASS_AsymmetricSignatureDeformatter;
extern PACKAGE GUID CLASS_AsymmetricSignatureFormatter;
extern PACKAGE GUID CLASS_ToBase64Transform;
extern PACKAGE GUID CLASS_FromBase64Transform;
extern PACKAGE GUID CLASS_KeySizes;
extern PACKAGE GUID CLASS_CryptographicException;
extern PACKAGE GUID CLASS_CryptographicUnexpectedOperationException;
extern PACKAGE GUID CLASS_CryptoAPITransform;
extern PACKAGE GUID CLASS_CspParameters;
extern PACKAGE GUID CLASS_CryptoConfig;
extern PACKAGE GUID CLASS_Stream;
extern PACKAGE GUID CLASS_CryptoStream;
extern PACKAGE GUID CLASS_SymmetricAlgorithm;
extern PACKAGE GUID CLASS_DES;
extern PACKAGE GUID CLASS_DESCryptoServiceProvider;
extern PACKAGE GUID CLASS_DeriveBytes;
extern PACKAGE GUID CLASS_DSA;
extern PACKAGE GUID CLASS_DSACryptoServiceProvider;
extern PACKAGE GUID CLASS_DSASignatureDeformatter;
extern PACKAGE GUID CLASS_DSASignatureFormatter;
extern PACKAGE GUID CLASS_HashAlgorithm;
extern PACKAGE GUID CLASS_KeyedHashAlgorithm;
extern PACKAGE GUID CLASS_HMACSHA1;
extern PACKAGE GUID CLASS_MACTripleDES;
extern PACKAGE GUID CLASS_MD5;
extern PACKAGE GUID CLASS_MD5CryptoServiceProvider;
extern PACKAGE GUID CLASS_MaskGenerationMethod;
extern PACKAGE GUID CLASS_PasswordDeriveBytes;
extern PACKAGE GUID CLASS_PKCS1MaskGenerationMethod;
extern PACKAGE GUID CLASS_RC2;
extern PACKAGE GUID CLASS_RC2CryptoServiceProvider;
extern PACKAGE GUID CLASS_RandomNumberGenerator;
extern PACKAGE GUID CLASS_RNGCryptoServiceProvider;
extern PACKAGE GUID CLASS_RSA;
extern PACKAGE GUID CLASS_RSACryptoServiceProvider;
extern PACKAGE GUID CLASS_RSAOAEPKeyExchangeDeformatter;
extern PACKAGE GUID CLASS_RSAOAEPKeyExchangeFormatter;
extern PACKAGE GUID CLASS_RSAPKCS1KeyExchangeDeformatter;
extern PACKAGE GUID CLASS_RSAPKCS1KeyExchangeFormatter;
extern PACKAGE GUID CLASS_RSAPKCS1SignatureDeformatter;
extern PACKAGE GUID CLASS_RSAPKCS1SignatureFormatter;
extern PACKAGE GUID CLASS_Rijndael;
extern PACKAGE GUID CLASS_RijndaelManaged;
extern PACKAGE GUID CLASS_SHA1;
extern PACKAGE GUID CLASS_SHA1CryptoServiceProvider;
extern PACKAGE GUID CLASS_SHA1Managed;
extern PACKAGE GUID CLASS_SHA256;
extern PACKAGE GUID CLASS_SHA256Managed;
extern PACKAGE GUID CLASS_SHA384;
extern PACKAGE GUID CLASS_SHA384Managed;
extern PACKAGE GUID CLASS_SHA512;
extern PACKAGE GUID CLASS_SHA512Managed;
extern PACKAGE GUID CLASS_SignatureDescription;
extern PACKAGE GUID CLASS_TripleDES;
extern PACKAGE GUID CLASS_TripleDESCryptoServiceProvider;
extern PACKAGE GUID CLASS_AllMembershipCondition;
extern PACKAGE GUID CLASS_ApplicationDirectory;
extern PACKAGE GUID CLASS_ApplicationDirectoryMembershipCondition;
extern PACKAGE GUID CLASS_CodeGroup;
extern PACKAGE GUID CLASS_Evidence;
extern PACKAGE GUID CLASS_FileCodeGroup;
extern PACKAGE GUID CLASS_FirstMatchCodeGroup;
extern PACKAGE GUID CLASS_Hash;
extern PACKAGE GUID CLASS_HashMembershipCondition;
extern PACKAGE GUID CLASS_NetCodeGroup;
extern PACKAGE GUID CLASS_PermissionRequestEvidence;
extern PACKAGE GUID CLASS_PolicyException;
extern PACKAGE GUID CLASS_PolicyLevel;
extern PACKAGE GUID CLASS_PolicyStatement;
extern PACKAGE GUID CLASS_Publisher;
extern PACKAGE GUID CLASS_PublisherMembershipCondition;
extern PACKAGE GUID CLASS_Site;
extern PACKAGE GUID CLASS_SiteMembershipCondition;
extern PACKAGE GUID CLASS_StrongName;
extern PACKAGE GUID CLASS_StrongNameMembershipCondition;
extern PACKAGE GUID CLASS_UnionCodeGroup;
extern PACKAGE GUID CLASS_Url;
extern PACKAGE GUID CLASS_UrlMembershipCondition;
extern PACKAGE GUID CLASS_Zone;
extern PACKAGE GUID CLASS_ZoneMembershipCondition;
extern PACKAGE GUID CLASS_GenericIdentity;
extern PACKAGE GUID CLASS_GenericPrincipal;
extern PACKAGE GUID CLASS_WindowsIdentity;
extern PACKAGE GUID CLASS_WindowsImpersonationContext;
extern PACKAGE GUID CLASS_WindowsPrincipal;
extern PACKAGE GUID CLASS_DispIdAttribute;
extern PACKAGE GUID CLASS_InterfaceTypeAttribute;
extern PACKAGE GUID CLASS_ClassInterfaceAttribute;
extern PACKAGE GUID CLASS_ComVisibleAttribute;
extern PACKAGE GUID CLASS_LCIDConversionAttribute;
extern PACKAGE GUID CLASS_ComRegisterFunctionAttribute;
extern PACKAGE GUID CLASS_ComUnregisterFunctionAttribute;
extern PACKAGE GUID CLASS_ProgIdAttribute;
extern PACKAGE GUID CLASS_ImportedFromTypeLibAttribute;
extern PACKAGE GUID CLASS_IDispatchImplAttribute;
extern PACKAGE GUID CLASS_ComSourceInterfacesAttribute;
extern PACKAGE GUID CLASS_ComConversionLossAttribute;
extern PACKAGE GUID CLASS_TypeLibTypeAttribute;
extern PACKAGE GUID CLASS_TypeLibFuncAttribute;
extern PACKAGE GUID CLASS_TypeLibVarAttribute;
extern PACKAGE GUID CLASS_MarshalAsAttribute;
extern PACKAGE GUID CLASS_ComImportAttribute;
extern PACKAGE GUID CLASS_GuidAttribute;
extern PACKAGE GUID CLASS_PreserveSigAttribute;
extern PACKAGE GUID CLASS_InAttribute;
extern PACKAGE GUID CLASS_OutAttribute;
extern PACKAGE GUID CLASS_OptionalAttribute;
extern PACKAGE GUID CLASS_DllImportAttribute;
extern PACKAGE GUID CLASS_StructLayoutAttribute;
extern PACKAGE GUID CLASS_FieldOffsetAttribute;
extern PACKAGE GUID CLASS_ComAliasNameAttribute;
extern PACKAGE GUID CLASS_AutomationProxyAttribute;
extern PACKAGE GUID CLASS_PrimaryInteropAssemblyAttribute;
extern PACKAGE GUID CLASS_CoClassAttribute;
extern PACKAGE GUID CLASS_ComEventInterfaceAttribute;
extern PACKAGE GUID CLASS_TypeLibVersionAttribute;
extern PACKAGE GUID CLASS_ComCompatibleVersionAttribute;
extern PACKAGE GUID CLASS_BestFitMappingAttribute;
extern PACKAGE GUID CLASS_ExternalException;
extern PACKAGE GUID CLASS_COMException;
extern PACKAGE GUID CLASS_CurrencyWrapper;
extern PACKAGE GUID CLASS_DispatchWrapper;
extern PACKAGE GUID CLASS_ErrorWrapper;
extern PACKAGE GUID CLASS_ExtensibleClassFactory;
extern PACKAGE GUID CLASS_InvalidComObjectException;
extern PACKAGE GUID CLASS_InvalidOleVariantTypeException;
extern PACKAGE GUID CLASS_Marshal;
extern PACKAGE GUID CLASS_MarshalDirectiveException;
extern PACKAGE GUID CLASS_ObjectCreationDelegate;
extern PACKAGE GUID CLASS_RuntimeEnvironment;
extern PACKAGE GUID CLASS_SafeArrayRankMismatchException;
extern PACKAGE GUID CLASS_SafeArrayTypeMismatchException;
extern PACKAGE GUID CLASS_SEHException;
extern PACKAGE GUID CLASS_UnknownWrapper;
extern PACKAGE GUID CLASS_BinaryReader;
extern PACKAGE GUID CLASS_BinaryWriter;
extern PACKAGE GUID CLASS_BufferedStream;
extern PACKAGE GUID CLASS_Directory;
extern PACKAGE GUID CLASS_FileSystemInfo;
extern PACKAGE GUID CLASS_DirectoryInfo;
extern PACKAGE GUID CLASS_IOException;
extern PACKAGE GUID CLASS_DirectoryNotFoundException;
extern PACKAGE GUID CLASS_EndOfStreamException;
extern PACKAGE GUID CLASS_File_;
extern PACKAGE GUID CLASS_FileInfo;
extern PACKAGE GUID CLASS_FileLoadException;
extern PACKAGE GUID CLASS_FileNotFoundException;
extern PACKAGE GUID CLASS_FileStream;
extern PACKAGE GUID CLASS_MemoryStream;
extern PACKAGE GUID CLASS_Path;
extern PACKAGE GUID CLASS_PathTooLongException;
extern PACKAGE GUID CLASS_TextReader;
extern PACKAGE GUID CLASS_StreamReader;
extern PACKAGE GUID CLASS_TextWriter;
extern PACKAGE GUID CLASS_StreamWriter;
extern PACKAGE GUID CLASS_StringReader;
extern PACKAGE GUID CLASS_StringWriter;
extern PACKAGE GUID CLASS_AccessedThroughPropertyAttribute;
extern PACKAGE GUID CLASS_CallConvCdecl;
extern PACKAGE GUID CLASS_CallConvStdcall;
extern PACKAGE GUID CLASS_CallConvThiscall;
extern PACKAGE GUID CLASS_CallConvFastcall;
extern PACKAGE GUID CLASS_RuntimeHelpers;
extern PACKAGE GUID CLASS_CustomConstantAttribute;
extern PACKAGE GUID CLASS_DateTimeConstantAttribute;
extern PACKAGE GUID CLASS_DiscardableAttribute;
extern PACKAGE GUID CLASS_DecimalConstantAttribute;
extern PACKAGE GUID CLASS_CompilationRelaxationsAttribute;
extern PACKAGE GUID CLASS_CompilerGlobalScopeAttribute;
extern PACKAGE GUID CLASS_IDispatchConstantAttribute;
extern PACKAGE GUID CLASS_IndexerNameAttribute;
extern PACKAGE GUID CLASS_IsVolatile;
extern PACKAGE GUID CLASS_IUnknownConstantAttribute;
extern PACKAGE GUID CLASS_MethodImplAttribute;
extern PACKAGE GUID CLASS_RequiredAttributeAttribute;
extern PACKAGE GUID CLASS_PermissionSet;
extern PACKAGE GUID CLASS_NamedPermissionSet;
extern PACKAGE GUID CLASS_SecurityElement;
extern PACKAGE GUID CLASS_XmlSyntaxException;
extern PACKAGE GUID CLASS_CodeAccessPermission;
extern PACKAGE GUID CLASS_EnvironmentPermission;
extern PACKAGE GUID CLASS_FileDialogPermission;
extern PACKAGE GUID CLASS_FileIOPermission;
extern PACKAGE GUID CLASS_IsolatedStoragePermission;
extern PACKAGE GUID CLASS_IsolatedStorageFilePermission;
extern PACKAGE GUID CLASS_SecurityAttribute;
extern PACKAGE GUID CLASS_CodeAccessSecurityAttribute;
extern PACKAGE GUID CLASS_EnvironmentPermissionAttribute;
extern PACKAGE GUID CLASS_FileDialogPermissionAttribute;
extern PACKAGE GUID CLASS_FileIOPermissionAttribute;
extern PACKAGE GUID CLASS_PrincipalPermissionAttribute;
extern PACKAGE GUID CLASS_ReflectionPermissionAttribute;
extern PACKAGE GUID CLASS_RegistryPermissionAttribute;
extern PACKAGE GUID CLASS_SecurityPermissionAttribute;
extern PACKAGE GUID CLASS_UIPermissionAttribute;
extern PACKAGE GUID CLASS_ZoneIdentityPermissionAttribute;
extern PACKAGE GUID CLASS_StrongNameIdentityPermissionAttribute;
extern PACKAGE GUID CLASS_SiteIdentityPermissionAttribute;
extern PACKAGE GUID CLASS_UrlIdentityPermissionAttribute;
extern PACKAGE GUID CLASS_PublisherIdentityPermissionAttribute;
extern PACKAGE GUID CLASS_IsolatedStoragePermissionAttribute;
extern PACKAGE GUID CLASS_IsolatedStorageFilePermissionAttribute;
extern PACKAGE GUID CLASS_PermissionSetAttribute;
extern PACKAGE GUID CLASS_PublisherIdentityPermission;
extern PACKAGE GUID CLASS_ReflectionPermission;
extern PACKAGE GUID CLASS_RegistryPermission;
extern PACKAGE GUID CLASS_PrincipalPermission;
extern PACKAGE GUID CLASS_SecurityPermission;
extern PACKAGE GUID CLASS_SiteIdentityPermission;
extern PACKAGE GUID CLASS_StrongNameIdentityPermission;
extern PACKAGE GUID CLASS_StrongNamePublicKeyBlob;
extern PACKAGE GUID CLASS_UIPermission;
extern PACKAGE GUID CLASS_UrlIdentityPermission;
extern PACKAGE GUID CLASS_ZoneIdentityPermission;
extern PACKAGE GUID CLASS_SuppressUnmanagedCodeSecurityAttribute;
extern PACKAGE GUID CLASS_UnverifiableCodeAttribute;
extern PACKAGE GUID CLASS_AllowPartiallyTrustedCallersAttribute;
extern PACKAGE GUID CLASS_SecurityException;
extern PACKAGE GUID CLASS_SecurityManager;
extern PACKAGE GUID CLASS_VerificationException;
extern PACKAGE GUID CLASS_ContextAttribute;
extern PACKAGE GUID CLASS_AsyncResult;
extern PACKAGE GUID CLASS_CallContext;
extern PACKAGE GUID CLASS_LogicalCallContext;
extern PACKAGE GUID CLASS_ChannelServices;
extern PACKAGE GUID CLASS_ClientChannelSinkStack;
extern PACKAGE GUID CLASS_ServerChannelSinkStack;
extern PACKAGE GUID CLASS_InternalMessageWrapper;
extern PACKAGE GUID CLASS_MethodCallMessageWrapper;
extern PACKAGE GUID CLASS_ClientSponsor;
extern PACKAGE GUID CLASS_CrossContextDelegate;
extern PACKAGE GUID CLASS_Context;
extern PACKAGE GUID CLASS_ContextProperty;
extern PACKAGE GUID CLASS_EnterpriseServicesHelper;
extern PACKAGE GUID CLASS_Header;
extern PACKAGE GUID CLASS_HeaderHandler;
extern PACKAGE GUID CLASS_ChannelDataStore;
extern PACKAGE GUID CLASS_TransportHeaders;
extern PACKAGE GUID CLASS_SinkProviderData;
extern PACKAGE GUID CLASS_BaseChannelObjectWithProperties;
extern PACKAGE GUID CLASS_BaseChannelSinkWithProperties;
extern PACKAGE GUID CLASS_BaseChannelWithProperties;
extern PACKAGE GUID CLASS_LifetimeServices;
extern PACKAGE GUID CLASS_ReturnMessage;
extern PACKAGE GUID CLASS_MethodCall;
extern PACKAGE GUID CLASS_ConstructionCall;
extern PACKAGE GUID CLASS_MethodResponse;
extern PACKAGE GUID CLASS_ConstructionResponse;
extern PACKAGE GUID CLASS_MethodReturnMessageWrapper;
extern PACKAGE GUID CLASS_ObjectHandle;
extern PACKAGE GUID CLASS_ObjRef;
extern PACKAGE GUID CLASS_OneWayAttribute;
extern PACKAGE GUID CLASS_ProxyAttribute;
extern PACKAGE GUID CLASS_RealProxy;
extern PACKAGE GUID CLASS_SoapAttribute;
extern PACKAGE GUID CLASS_SoapTypeAttribute;
extern PACKAGE GUID CLASS_SoapMethodAttribute;
extern PACKAGE GUID CLASS_SoapFieldAttribute;
extern PACKAGE GUID CLASS_SoapParameterAttribute;
extern PACKAGE GUID CLASS_RemotingConfiguration;
extern PACKAGE GUID CLASS_System_Runtime_Remoting_TypeEntry;
extern PACKAGE GUID CLASS_ActivatedClientTypeEntry;
extern PACKAGE GUID CLASS_ActivatedServiceTypeEntry;
extern PACKAGE GUID CLASS_WellKnownClientTypeEntry;
extern PACKAGE GUID CLASS_WellKnownServiceTypeEntry;
extern PACKAGE GUID CLASS_RemotingException;
extern PACKAGE GUID CLASS_ServerException;
extern PACKAGE GUID CLASS_RemotingTimeoutException;
extern PACKAGE GUID CLASS_RemotingServices;
extern PACKAGE GUID CLASS_InternalRemotingServices;
extern PACKAGE GUID CLASS_MessageSurrogateFilter;
extern PACKAGE GUID CLASS_RemotingSurrogateSelector;
extern PACKAGE GUID CLASS_SoapServices;
extern PACKAGE GUID CLASS_SoapDateTime;
extern PACKAGE GUID CLASS_SoapDuration;
extern PACKAGE GUID CLASS_SoapTime;
extern PACKAGE GUID CLASS_SoapDate;
extern PACKAGE GUID CLASS_SoapYearMonth;
extern PACKAGE GUID CLASS_SoapYear;
extern PACKAGE GUID CLASS_SoapMonthDay;
extern PACKAGE GUID CLASS_SoapDay;
extern PACKAGE GUID CLASS_SoapMonth;
extern PACKAGE GUID CLASS_SoapHexBinary;
extern PACKAGE GUID CLASS_SoapBase64Binary;
extern PACKAGE GUID CLASS_SoapInteger;
extern PACKAGE GUID CLASS_SoapPositiveInteger;
extern PACKAGE GUID CLASS_SoapNonPositiveInteger;
extern PACKAGE GUID CLASS_SoapNonNegativeInteger;
extern PACKAGE GUID CLASS_SoapNegativeInteger;
extern PACKAGE GUID CLASS_SoapAnyUri;
extern PACKAGE GUID CLASS_SoapQName;
extern PACKAGE GUID CLASS_SoapNotation;
extern PACKAGE GUID CLASS_SoapNormalizedString;
extern PACKAGE GUID CLASS_SoapToken;
extern PACKAGE GUID CLASS_SoapLanguage;
extern PACKAGE GUID CLASS_SoapName;
extern PACKAGE GUID CLASS_SoapIdrefs;
extern PACKAGE GUID CLASS_SoapEntities;
extern PACKAGE GUID CLASS_SoapNmtoken;
extern PACKAGE GUID CLASS_SoapNmtokens;
extern PACKAGE GUID CLASS_SoapNcName;
extern PACKAGE GUID CLASS_SoapId;
extern PACKAGE GUID CLASS_SoapIdref;
extern PACKAGE GUID CLASS_SoapEntity;
extern PACKAGE GUID CLASS_SynchronizationAttribute;
extern PACKAGE GUID CLASS_TrackingServices;
extern PACKAGE GUID CLASS_UrlAttribute;
extern PACKAGE GUID CLASS_IsolatedStorage;
extern PACKAGE GUID CLASS_IsolatedStorageFile;
extern PACKAGE GUID CLASS_IsolatedStorageFileStream;
extern PACKAGE GUID CLASS_IsolatedStorageException;
extern PACKAGE GUID CLASS_InternalRM;
extern PACKAGE GUID CLASS_InternalST;
extern PACKAGE GUID CLASS_SoapMessage;
extern PACKAGE GUID CLASS_SoapFault;
extern PACKAGE GUID CLASS_ServerFault;
extern PACKAGE GUID CLASS_BinaryFormatter;
extern PACKAGE GUID CLASS_AssemblyBuilder;
extern PACKAGE GUID CLASS_ConstructorBuilder;
extern PACKAGE GUID CLASS_EventBuilder;
extern PACKAGE GUID CLASS_FieldBuilder;
extern PACKAGE GUID CLASS_ILGenerator;
extern PACKAGE GUID CLASS_LocalBuilder;
extern PACKAGE GUID CLASS_MethodBuilder;
extern PACKAGE GUID CLASS_CustomAttributeBuilder;
extern PACKAGE GUID CLASS_MethodRental;
extern PACKAGE GUID CLASS_ModuleBuilder;
extern PACKAGE GUID CLASS_OpCodes;
extern PACKAGE GUID CLASS_ParameterBuilder;
extern PACKAGE GUID CLASS_PropertyBuilder;
extern PACKAGE GUID CLASS_SignatureHelper;
extern PACKAGE GUID CLASS_TypeBuilder;
extern PACKAGE GUID CLASS_EnumBuilder;
static const ShortInt LoaderOptimization_NotSpecified = 0x0;
static const ShortInt LoaderOptimization_SingleDomain = 0x1;
static const ShortInt LoaderOptimization_MultiDomain = 0x2;
static const ShortInt LoaderOptimization_MultiDomainHost = 0x3;
static const ShortInt LoaderOptimization_DomainMask = 0x3;
static const ShortInt LoaderOptimization_DisallowBindings = 0x4;
static const ShortInt AttributeTargets_Assembly = 0x1;
static const ShortInt AttributeTargets_Module = 0x2;
static const ShortInt AttributeTargets_Class = 0x4;
static const ShortInt AttributeTargets_Struct = 0x8;
static const ShortInt AttributeTargets_Enum = 0x10;
static const ShortInt AttributeTargets_Constructor = 0x20;
static const ShortInt AttributeTargets_Method = 0x40;
static const Byte AttributeTargets_Property = 0x80;
static const Word AttributeTargets_Field = 0x100;
static const Word AttributeTargets_Event = 0x200;
static const Word AttributeTargets_Interface = 0x400;
static const Word AttributeTargets_Parameter = 0x800;
static const Word AttributeTargets_Delegate = 0x1000;
static const Word AttributeTargets_ReturnValue = 0x2000;
static const Word AttributeTargets_All = 0x3fff;
static const ShortInt DayOfWeek_Sunday = 0x0;
static const ShortInt DayOfWeek_Monday = 0x1;
static const ShortInt DayOfWeek_Tuesday = 0x2;
static const ShortInt DayOfWeek_Wednesday = 0x3;
static const ShortInt DayOfWeek_Thursday = 0x4;
static const ShortInt DayOfWeek_Friday = 0x5;
static const ShortInt DayOfWeek_Saturday = 0x6;
static const ShortInt SpecialFolder_ApplicationData = 0x1a;
static const ShortInt SpecialFolder_CommonApplicationData = 0x23;
static const ShortInt SpecialFolder_LocalApplicationData = 0x1c;
static const ShortInt SpecialFolder_Cookies = 0x21;
static const ShortInt SpecialFolder_Desktop = 0x0;
static const ShortInt SpecialFolder_Favorites = 0x6;
static const ShortInt SpecialFolder_History = 0x22;
static const ShortInt SpecialFolder_InternetCache = 0x20;
static const ShortInt SpecialFolder_Programs = 0x2;
static const ShortInt SpecialFolder_MyComputer = 0x11;
static const ShortInt SpecialFolder_MyMusic = 0xd;
static const ShortInt SpecialFolder_MyPictures = 0x27;
static const ShortInt SpecialFolder_Recent = 0x8;
static const ShortInt SpecialFolder_SendTo = 0x9;
static const ShortInt SpecialFolder_StartMenu = 0xb;
static const ShortInt SpecialFolder_Startup = 0x7;
static const ShortInt SpecialFolder_System = 0x25;
static const ShortInt SpecialFolder_Templates = 0x15;
static const ShortInt SpecialFolder_DesktopDirectory = 0x10;
static const ShortInt SpecialFolder_Personal = 0x5;
static const ShortInt SpecialFolder_ProgramFiles = 0x26;
static const ShortInt SpecialFolder_CommonProgramFiles = 0x2b;
static const ShortInt PlatformID_Win32S = 0x0;
static const ShortInt PlatformID_Win32Windows = 0x1;
static const ShortInt PlatformID_Win32NT = 0x2;
static const ShortInt PlatformID_WinCE = 0x3;
static const ShortInt TypeCode_Empty = 0x0;
static const ShortInt TypeCode_Object = 0x1;
static const ShortInt TypeCode_DBNull = 0x2;
static const ShortInt TypeCode_Boolean = 0x3;
static const ShortInt TypeCode_Char = 0x4;
static const ShortInt TypeCode_SByte = 0x5;
static const ShortInt TypeCode_Byte = 0x6;
static const ShortInt TypeCode_Int16 = 0x7;
static const ShortInt TypeCode_UInt16 = 0x8;
static const ShortInt TypeCode_Int32 = 0x9;
static const ShortInt TypeCode_UInt32 = 0xa;
static const ShortInt TypeCode_Int64 = 0xb;
static const ShortInt TypeCode_UInt64 = 0xc;
static const ShortInt TypeCode_Single = 0xd;
static const ShortInt TypeCode_Double = 0xe;
static const ShortInt TypeCode_Decimal = 0xf;
static const ShortInt TypeCode_DateTime = 0x10;
static const ShortInt TypeCode_String = 0x12;
static const ShortInt ApartmentState_STA = 0x0;
static const ShortInt ApartmentState_MTA = 0x1;
static const ShortInt ApartmentState_Unknown = 0x2;
static const ShortInt ThreadPriority_Lowest = 0x0;
static const ShortInt ThreadPriority_BelowNormal = 0x1;
static const ShortInt ThreadPriority_Normal = 0x2;
static const ShortInt ThreadPriority_AboveNormal = 0x3;
static const ShortInt ThreadPriority_Highest = 0x4;
static const ShortInt ThreadState_Running = 0x0;
static const ShortInt ThreadState_StopRequested = 0x1;
static const ShortInt ThreadState_SuspendRequested = 0x2;
static const ShortInt ThreadState_Background = 0x4;
static const ShortInt ThreadState_Unstarted = 0x8;
static const ShortInt ThreadState_Stopped = 0x10;
static const ShortInt ThreadState_WaitSleepJoin = 0x20;
static const ShortInt ThreadState_Suspended = 0x40;
static const Byte ThreadState_AbortRequested = 0x80;
static const Word ThreadState_Aborted = 0x100;
static const ShortInt SymAddressKind_ILOffset = 0x1;
static const ShortInt SymAddressKind_NativeRVA = 0x2;
static const ShortInt SymAddressKind_NativeRegister = 0x3;
static const ShortInt SymAddressKind_NativeRegisterRelative = 0x4;
static const ShortInt SymAddressKind_NativeOffset = 0x5;
static const ShortInt SymAddressKind_NativeRegisterRegister = 0x6;
static const ShortInt SymAddressKind_NativeRegisterStack = 0x7;
static const ShortInt SymAddressKind_NativeStackRegister = 0x8;
static const ShortInt SymAddressKind_BitField = 0x9;
static const ShortInt AssemblyNameFlags_None = 0x0;
static const ShortInt AssemblyNameFlags_PublicKey = 0x1;
static const Word AssemblyNameFlags_Retargetable = 0x100;
static const ShortInt BindingFlags_Default = 0x0;
static const ShortInt BindingFlags_IgnoreCase = 0x1;
static const ShortInt BindingFlags_DeclaredOnly = 0x2;
static const ShortInt BindingFlags_Instance = 0x4;
static const ShortInt BindingFlags_Static = 0x8;
static const ShortInt BindingFlags_Public = 0x10;
static const ShortInt BindingFlags_NonPublic = 0x20;
static const ShortInt BindingFlags_FlattenHierarchy = 0x40;
static const Word BindingFlags_InvokeMethod = 0x100;
static const Word BindingFlags_CreateInstance = 0x200;
static const Word BindingFlags_GetField = 0x400;
static const Word BindingFlags_SetField = 0x800;
static const Word BindingFlags_GetProperty = 0x1000;
static const Word BindingFlags_SetProperty = 0x2000;
static const Word BindingFlags_PutDispProperty = 0x4000;
static const Word BindingFlags_PutRefDispProperty = 0x8000;
static const int BindingFlags_ExactBinding = 0x10000;
static const int BindingFlags_SuppressChangeType = 0x20000;
static const int BindingFlags_OptionalParamBinding = 0x40000;
static const int BindingFlags_IgnoreReturn = 0x1000000;
static const ShortInt CallingConventions_Standard = 0x1;
static const ShortInt CallingConventions_VarArgs = 0x2;
static const ShortInt CallingConventions_Any = 0x3;
static const ShortInt CallingConventions_HasThis = 0x20;
static const ShortInt CallingConventions_ExplicitThis = 0x40;
static const ShortInt EventAttributes_None = 0x0;
static const Word EventAttributes_SpecialName = 0x200;
static const Word EventAttributes_ReservedMask = 0x400;
static const Word EventAttributes_RTSpecialName = 0x400;
static const ShortInt FieldAttributes_FieldAccessMask = 0x7;
static const ShortInt FieldAttributes_PrivateScope = 0x0;
static const ShortInt FieldAttributes_Private = 0x1;
static const ShortInt FieldAttributes_FamANDAssem = 0x2;
static const ShortInt FieldAttributes_Assembly = 0x3;
static const ShortInt FieldAttributes_Family = 0x4;
static const ShortInt FieldAttributes_FamORAssem = 0x5;
static const ShortInt FieldAttributes_Public = 0x6;
static const ShortInt FieldAttributes_Static = 0x10;
static const ShortInt FieldAttributes_InitOnly = 0x20;
static const ShortInt FieldAttributes_Literal = 0x40;
static const Byte FieldAttributes_NotSerialized = 0x80;
static const Word FieldAttributes_SpecialName = 0x200;
static const Word FieldAttributes_PinvokeImpl = 0x2000;
static const Word FieldAttributes_ReservedMask = 0x9500;
static const Word FieldAttributes_RTSpecialName = 0x400;
static const Word FieldAttributes_HasFieldMarshal = 0x1000;
static const Word FieldAttributes_HasDefault = 0x8000;
static const Word FieldAttributes_HasFieldRVA = 0x100;
static const ShortInt ResourceLocation_Embedded = 0x1;
static const ShortInt ResourceLocation_ContainedInAnotherAssembly = 0x2;
static const ShortInt ResourceLocation_ContainedInManifestFile = 0x4;
static const ShortInt MemberTypes_Constructor = 0x1;
static const ShortInt MemberTypes_Event = 0x2;
static const ShortInt MemberTypes_Field = 0x4;
static const ShortInt MemberTypes_Method = 0x8;
static const ShortInt MemberTypes_Property = 0x10;
static const ShortInt MemberTypes_TypeInfo = 0x20;
static const ShortInt MemberTypes_Custom = 0x40;
static const Byte MemberTypes_NestedType = 0x80;
static const Byte MemberTypes_All = 0xbf;
static const ShortInt MethodAttributes_MemberAccessMask = 0x7;
static const ShortInt MethodAttributes_PrivateScope = 0x0;
static const ShortInt MethodAttributes_Private = 0x1;
static const ShortInt MethodAttributes_FamANDAssem = 0x2;
static const ShortInt MethodAttributes_Assembly = 0x3;
static const ShortInt MethodAttributes_Family = 0x4;
static const ShortInt MethodAttributes_FamORAssem = 0x5;
static const ShortInt MethodAttributes_Public = 0x6;
static const ShortInt MethodAttributes_Static = 0x10;
static const ShortInt MethodAttributes_Final = 0x20;
static const ShortInt MethodAttributes_Virtual = 0x40;
static const Byte MethodAttributes_HideBySig = 0x80;
static const Word MethodAttributes_CheckAccessOnOverride = 0x200;
static const Word MethodAttributes_VtableLayoutMask = 0x100;
static const ShortInt MethodAttributes_ReuseSlot = 0x0;
static const Word MethodAttributes_NewSlot = 0x100;
static const Word MethodAttributes_Abstract = 0x400;
static const Word MethodAttributes_SpecialName = 0x800;
static const Word MethodAttributes_PinvokeImpl = 0x2000;
static const ShortInt MethodAttributes_UnmanagedExport = 0x8;
static const Word MethodAttributes_RTSpecialName = 0x1000;
static const Word MethodAttributes_ReservedMask = 0xd000;
static const Word MethodAttributes_HasSecurity = 0x4000;
static const Word MethodAttributes_RequireSecObject = 0x8000;
static const ShortInt MethodImplAttributes_CodeTypeMask = 0x3;
static const ShortInt MethodImplAttributes_IL = 0x0;
static const ShortInt MethodImplAttributes_Native = 0x1;
static const ShortInt MethodImplAttributes_OPTIL = 0x2;
static const ShortInt MethodImplAttributes_Runtime = 0x3;
static const ShortInt MethodImplAttributes_ManagedMask = 0x4;
static const ShortInt MethodImplAttributes_Unmanaged = 0x4;
static const ShortInt MethodImplAttributes_Managed = 0x0;
static const ShortInt MethodImplAttributes_ForwardRef = 0x10;
static const Byte MethodImplAttributes_PreserveSig = 0x80;
static const Word MethodImplAttributes_InternalCall = 0x1000;
static const ShortInt MethodImplAttributes_Synchronized = 0x20;
static const ShortInt MethodImplAttributes_NoInlining = 0x8;
static const Word MethodImplAttributes_MaxMethodImplVal = 0xffff;
static const ShortInt ParameterAttributes_None = 0x0;
static const ShortInt ParameterAttributes_In = 0x1;
static const ShortInt ParameterAttributes_Out = 0x2;
static const ShortInt ParameterAttributes_Lcid = 0x4;
static const ShortInt ParameterAttributes_Retval = 0x8;
static const ShortInt ParameterAttributes_Optional = 0x10;
static const Word ParameterAttributes_ReservedMask = 0xf000;
static const Word ParameterAttributes_HasDefault = 0x1000;
static const Word ParameterAttributes_HasFieldMarshal = 0x2000;
static const Word ParameterAttributes_Reserved3 = 0x4000;
static const Word ParameterAttributes_Reserved4 = 0x8000;
static const ShortInt PropertyAttributes_None = 0x0;
static const Word PropertyAttributes_SpecialName = 0x200;
static const Word PropertyAttributes_ReservedMask = 0xf400;
static const Word PropertyAttributes_RTSpecialName = 0x400;
static const Word PropertyAttributes_HasDefault = 0x1000;
static const Word PropertyAttributes_Reserved2 = 0x2000;
static const Word PropertyAttributes_Reserved3 = 0x4000;
static const Word PropertyAttributes_Reserved4 = 0x8000;
static const ShortInt ResourceAttributes_Public = 0x1;
static const ShortInt ResourceAttributes_Private = 0x2;
static const ShortInt TypeAttributes_VisibilityMask = 0x7;
static const ShortInt TypeAttributes_NotPublic = 0x0;
static const ShortInt TypeAttributes_Public = 0x1;
static const ShortInt TypeAttributes_NestedPublic = 0x2;
static const ShortInt TypeAttributes_NestedPrivate = 0x3;
static const ShortInt TypeAttributes_NestedFamily = 0x4;
static const ShortInt TypeAttributes_NestedAssembly = 0x5;
static const ShortInt TypeAttributes_NestedFamANDAssem = 0x6;
static const ShortInt TypeAttributes_NestedFamORAssem = 0x7;
static const ShortInt TypeAttributes_LayoutMask = 0x18;
static const ShortInt TypeAttributes_AutoLayout = 0x0;
static const ShortInt TypeAttributes_SequentialLayout = 0x8;
static const ShortInt TypeAttributes_ExplicitLayout = 0x10;
static const ShortInt TypeAttributes_ClassSemanticsMask = 0x20;
static const ShortInt TypeAttributes_Class = 0x0;
static const ShortInt TypeAttributes_Interface = 0x20;
static const Byte TypeAttributes_Abstract = 0x80;
static const Word TypeAttributes_Sealed = 0x100;
static const Word TypeAttributes_SpecialName = 0x400;
static const Word TypeAttributes_Import = 0x1000;
static const Word TypeAttributes_Serializable = 0x2000;
static const int TypeAttributes_StringFormatMask = 0x30000;
static const ShortInt TypeAttributes_AnsiClass = 0x0;
static const int TypeAttributes_UnicodeClass = 0x10000;
static const int TypeAttributes_AutoClass = 0x20000;
static const int TypeAttributes_BeforeFieldInit = 0x100000;
static const int TypeAttributes_ReservedMask = 0x40800;
static const Word TypeAttributes_RTSpecialName = 0x800;
static const int TypeAttributes_HasSecurity = 0x40000;
static const ShortInt StreamingContextStates_CrossProcess = 0x1;
static const ShortInt StreamingContextStates_CrossMachine = 0x2;
static const ShortInt StreamingContextStates_File = 0x4;
static const ShortInt StreamingContextStates_Persistence = 0x8;
static const ShortInt StreamingContextStates_Remoting = 0x10;
static const ShortInt StreamingContextStates_Other = 0x20;
static const ShortInt StreamingContextStates_Clone = 0x40;
static const Byte StreamingContextStates_CrossAppDomain = 0x80;
static const Byte StreamingContextStates_All = 0xff;
static const ShortInt CalendarWeekRule_FirstDay = 0x0;
static const ShortInt CalendarWeekRule_FirstFullWeek = 0x1;
static const ShortInt CalendarWeekRule_FirstFourDayWeek = 0x2;
static const ShortInt CompareOptions_None = 0x0;
static const ShortInt CompareOptions_IgnoreCase = 0x1;
static const ShortInt CompareOptions_IgnoreNonSpace = 0x2;
static const ShortInt CompareOptions_IgnoreSymbols = 0x4;
static const ShortInt CompareOptions_IgnoreKanaType = 0x8;
static const ShortInt CompareOptions_IgnoreWidth = 0x10;
static const int CompareOptions_StringSort = 0x20000000;
static const int CompareOptions_Ordinal = 0x40000000;
static const ShortInt CultureTypes_NeutralCultures = 0x1;
static const ShortInt CultureTypes_SpecificCultures = 0x2;
static const ShortInt CultureTypes_InstalledWin32Cultures = 0x4;
static const ShortInt CultureTypes_AllCultures = 0x7;
static const ShortInt DateTimeStyles_None = 0x0;
static const ShortInt DateTimeStyles_AllowLeadingWhite = 0x1;
static const ShortInt DateTimeStyles_AllowTrailingWhite = 0x2;
static const ShortInt DateTimeStyles_AllowInnerWhite = 0x4;
static const ShortInt DateTimeStyles_AllowWhiteSpaces = 0x7;
static const ShortInt DateTimeStyles_NoCurrentDateDefault = 0x8;
static const ShortInt DateTimeStyles_AdjustToUniversal = 0x10;
static const ShortInt GregorianCalendarTypes_Localized = 0x1;
static const ShortInt GregorianCalendarTypes_USEnglish = 0x2;
static const ShortInt GregorianCalendarTypes_MiddleEastFrench = 0x9;
static const ShortInt GregorianCalendarTypes_Arabic = 0xa;
static const ShortInt GregorianCalendarTypes_TransliteratedEnglish = 0xb;
static const ShortInt GregorianCalendarTypes_TransliteratedFrench = 0xc;
static const ShortInt NumberStyles_None = 0x0;
static const ShortInt NumberStyles_AllowLeadingWhite = 0x1;
static const ShortInt NumberStyles_AllowTrailingWhite = 0x2;
static const ShortInt NumberStyles_AllowLeadingSign = 0x4;
static const ShortInt NumberStyles_AllowTrailingSign = 0x8;
static const ShortInt NumberStyles_AllowParentheses = 0x10;
static const ShortInt NumberStyles_AllowDecimalPoint = 0x20;
static const ShortInt NumberStyles_AllowThousands = 0x40;
static const Byte NumberStyles_AllowExponent = 0x80;
static const Word NumberStyles_AllowCurrencySymbol = 0x100;
static const Word NumberStyles_AllowHexSpecifier = 0x200;
static const ShortInt NumberStyles_Integer = 0x7;
static const Word NumberStyles_HexNumber = 0x203;
static const ShortInt NumberStyles_Number = 0x6f;
static const Byte NumberStyles_Float = 0xa7;
static const Word NumberStyles_Currency = 0x17f;
static const Word NumberStyles_Any = 0x1ff;
static const ShortInt UnicodeCategory_UppercaseLetter = 0x0;
static const ShortInt UnicodeCategory_LowercaseLetter = 0x1;
static const ShortInt UnicodeCategory_TitlecaseLetter = 0x2;
static const ShortInt UnicodeCategory_ModifierLetter = 0x3;
static const ShortInt UnicodeCategory_OtherLetter = 0x4;
static const ShortInt UnicodeCategory_NonSpacingMark = 0x5;
static const ShortInt UnicodeCategory_SpacingCombiningMark = 0x6;
static const ShortInt UnicodeCategory_EnclosingMark = 0x7;
static const ShortInt UnicodeCategory_DecimalDigitNumber = 0x8;
static const ShortInt UnicodeCategory_LetterNumber = 0x9;
static const ShortInt UnicodeCategory_OtherNumber = 0xa;
static const ShortInt UnicodeCategory_SpaceSeparator = 0xb;
static const ShortInt UnicodeCategory_LineSeparator = 0xc;
static const ShortInt UnicodeCategory_ParagraphSeparator = 0xd;
static const ShortInt UnicodeCategory_Control = 0xe;
static const ShortInt UnicodeCategory_Format = 0xf;
static const ShortInt UnicodeCategory_Surrogate = 0x10;
static const ShortInt UnicodeCategory_PrivateUse = 0x11;
static const ShortInt UnicodeCategory_ConnectorPunctuation = 0x12;
static const ShortInt UnicodeCategory_DashPunctuation = 0x13;
static const ShortInt UnicodeCategory_OpenPunctuation = 0x14;
static const ShortInt UnicodeCategory_ClosePunctuation = 0x15;
static const ShortInt UnicodeCategory_InitialQuotePunctuation = 0x16;
static const ShortInt UnicodeCategory_FinalQuotePunctuation = 0x17;
static const ShortInt UnicodeCategory_OtherPunctuation = 0x18;
static const ShortInt UnicodeCategory_MathSymbol = 0x19;
static const ShortInt UnicodeCategory_CurrencySymbol = 0x1a;
static const ShortInt UnicodeCategory_ModifierSymbol = 0x1b;
static const ShortInt UnicodeCategory_OtherSymbol = 0x1c;
static const ShortInt UnicodeCategory_OtherNotAssigned = 0x1d;
static const unsigned RegistryHive_ClassesRoot = 0x80000000;
static const unsigned RegistryHive_CurrentUser = 0x80000001;
static const unsigned RegistryHive_LocalMachine = 0x80000002;
static const unsigned RegistryHive_Users = 0x80000003;
static const unsigned RegistryHive_PerformanceData = 0x80000004;
static const unsigned RegistryHive_CurrentConfig = 0x80000005;
static const unsigned RegistryHive_DynData = 0x80000006;
static const ShortInt FromBase64TransformMode_IgnoreWhiteSpaces = 0x0;
static const ShortInt FromBase64TransformMode_DoNotIgnoreWhiteSpaces = 0x1;
static const ShortInt CipherMode_CBC = 0x1;
static const ShortInt CipherMode_ECB = 0x2;
static const ShortInt CipherMode_OFB = 0x3;
static const ShortInt CipherMode_CFB = 0x4;
static const ShortInt CipherMode_CTS = 0x5;
static const ShortInt PaddingMode_None = 0x1;
static const ShortInt PaddingMode_PKCS7 = 0x2;
static const ShortInt PaddingMode_Zeros = 0x3;
static const ShortInt CspProviderFlags_UseMachineKeyStore = 0x1;
static const ShortInt CspProviderFlags_UseDefaultKeyContainer = 0x2;
static const ShortInt CryptoStreamMode_Read = 0x0;
static const ShortInt CryptoStreamMode_Write = 0x1;
static const ShortInt PolicyStatementAttribute_Nothing = 0x0;
static const ShortInt PolicyStatementAttribute_Exclusive = 0x1;
static const ShortInt PolicyStatementAttribute_LevelFinal = 0x2;
static const ShortInt PolicyStatementAttribute_All = 0x3;
static const ShortInt PrincipalPolicy_UnauthenticatedPrincipal = 0x0;
static const ShortInt PrincipalPolicy_NoPrincipal = 0x1;
static const ShortInt PrincipalPolicy_WindowsPrincipal = 0x2;
static const ShortInt WindowsAccountType_Normal = 0x0;
static const ShortInt WindowsAccountType_Guest = 0x1;
static const ShortInt WindowsAccountType_System = 0x2;
static const ShortInt WindowsAccountType_Anonymous = 0x3;
static const Word WindowsBuiltInRole_Administrator = 0x220;
static const Word WindowsBuiltInRole_User = 0x221;
static const Word WindowsBuiltInRole_Guest = 0x222;
static const Word WindowsBuiltInRole_PowerUser = 0x223;
static const Word WindowsBuiltInRole_AccountOperator = 0x224;
static const Word WindowsBuiltInRole_SystemOperator = 0x225;
static const Word WindowsBuiltInRole_PrintOperator = 0x226;
static const Word WindowsBuiltInRole_BackupOperator = 0x227;
static const Word WindowsBuiltInRole_Replicator = 0x228;
static const ShortInt ComInterfaceType_InterfaceIsDual = 0x0;
static const ShortInt ComInterfaceType_InterfaceIsIUnknown = 0x1;
static const ShortInt ComInterfaceType_InterfaceIsIDispatch = 0x2;
static const ShortInt ClassInterfaceType_None = 0x0;
static const ShortInt ClassInterfaceType_AutoDispatch = 0x1;
static const ShortInt ClassInterfaceType_AutoDual = 0x2;
static const ShortInt IDispatchImplType_SystemDefinedImpl = 0x0;
static const ShortInt IDispatchImplType_InternalImpl = 0x1;
static const ShortInt IDispatchImplType_CompatibleImpl = 0x2;
static const ShortInt TypeLibTypeFlags_FAppObject = 0x1;
static const ShortInt TypeLibTypeFlags_FCanCreate = 0x2;
static const ShortInt TypeLibTypeFlags_FLicensed = 0x4;
static const ShortInt TypeLibTypeFlags_FPreDeclId = 0x8;
static const ShortInt TypeLibTypeFlags_FHidden = 0x10;
static const ShortInt TypeLibTypeFlags_FControl = 0x20;
static const ShortInt TypeLibTypeFlags_FDual = 0x40;
static const Byte TypeLibTypeFlags_FNonExtensible = 0x80;
static const Word TypeLibTypeFlags_FOleAutomation = 0x100;
static const Word TypeLibTypeFlags_FRestricted = 0x200;
static const Word TypeLibTypeFlags_FAggregatable = 0x400;
static const Word TypeLibTypeFlags_FReplaceable = 0x800;
static const Word TypeLibTypeFlags_FDispatchable = 0x1000;
static const Word TypeLibTypeFlags_FReverseBind = 0x2000;
static const ShortInt TypeLibFuncFlags_FRestricted = 0x1;
static const ShortInt TypeLibFuncFlags_FSource = 0x2;
static const ShortInt TypeLibFuncFlags_FBindable = 0x4;
static const ShortInt TypeLibFuncFlags_FRequestEdit = 0x8;
static const ShortInt TypeLibFuncFlags_FDisplayBind = 0x10;
static const ShortInt TypeLibFuncFlags_FDefaultBind = 0x20;
static const ShortInt TypeLibFuncFlags_FHidden = 0x40;
static const Byte TypeLibFuncFlags_FUsesGetLastError = 0x80;
static const Word TypeLibFuncFlags_FDefaultCollelem = 0x100;
static const Word TypeLibFuncFlags_FUiDefault = 0x200;
static const Word TypeLibFuncFlags_FNonBrowsable = 0x400;
static const Word TypeLibFuncFlags_FReplaceable = 0x800;
static const Word TypeLibFuncFlags_FImmediateBind = 0x1000;
static const ShortInt TypeLibVarFlags_FReadOnly = 0x1;
static const ShortInt TypeLibVarFlags_FSource = 0x2;
static const ShortInt TypeLibVarFlags_FBindable = 0x4;
static const ShortInt TypeLibVarFlags_FRequestEdit = 0x8;
static const ShortInt TypeLibVarFlags_FDisplayBind = 0x10;
static const ShortInt TypeLibVarFlags_FDefaultBind = 0x20;
static const ShortInt TypeLibVarFlags_FHidden = 0x40;
static const Byte TypeLibVarFlags_FRestricted = 0x80;
static const Word TypeLibVarFlags_FDefaultCollelem = 0x100;
static const Word TypeLibVarFlags_FUiDefault = 0x200;
static const Word TypeLibVarFlags_FNonBrowsable = 0x400;
static const Word TypeLibVarFlags_FReplaceable = 0x800;
static const Word TypeLibVarFlags_FImmediateBind = 0x1000;
static const ShortInt VarEnum_VT_EMPTY = 0x0;
static const ShortInt VarEnum_VT_NULL = 0x1;
static const ShortInt VarEnum_VT_I2 = 0x2;
static const ShortInt VarEnum_VT_I4 = 0x3;
static const ShortInt VarEnum_VT_R4 = 0x4;
static const ShortInt VarEnum_VT_R8 = 0x5;
static const ShortInt VarEnum_VT_CY = 0x6;
static const ShortInt VarEnum_VT_DATE = 0x7;
static const ShortInt VarEnum_VT_BSTR = 0x8;
static const ShortInt VarEnum_VT_DISPATCH = 0x9;
static const ShortInt VarEnum_VT_ERROR = 0xa;
static const ShortInt VarEnum_VT_BOOL = 0xb;
static const ShortInt VarEnum_VT_VARIANT = 0xc;
static const ShortInt VarEnum_VT_UNKNOWN = 0xd;
static const ShortInt VarEnum_VT_DECIMAL = 0xe;
static const ShortInt VarEnum_VT_I1 = 0x10;
static const ShortInt VarEnum_VT_UI1 = 0x11;
static const ShortInt VarEnum_VT_UI2 = 0x12;
static const ShortInt VarEnum_VT_UI4 = 0x13;
static const ShortInt VarEnum_VT_I8 = 0x14;
static const ShortInt VarEnum_VT_UI8 = 0x15;
static const ShortInt VarEnum_VT_INT = 0x16;
static const ShortInt VarEnum_VT_UINT = 0x17;
static const ShortInt VarEnum_VT_VOID = 0x18;
static const ShortInt VarEnum_VT_HRESULT = 0x19;
static const ShortInt VarEnum_VT_PTR = 0x1a;
static const ShortInt VarEnum_VT_SAFEARRAY = 0x1b;
static const ShortInt VarEnum_VT_CARRAY = 0x1c;
static const ShortInt VarEnum_VT_USERDEFINED = 0x1d;
static const ShortInt VarEnum_VT_LPSTR = 0x1e;
static const ShortInt VarEnum_VT_LPWSTR = 0x1f;
static const ShortInt VarEnum_VT_RECORD = 0x24;
static const ShortInt VarEnum_VT_FILETIME = 0x40;
static const ShortInt VarEnum_VT_BLOB = 0x41;
static const ShortInt VarEnum_VT_STREAM = 0x42;
static const ShortInt VarEnum_VT_STORAGE = 0x43;
static const ShortInt VarEnum_VT_STREAMED_OBJECT = 0x44;
static const ShortInt VarEnum_VT_STORED_OBJECT = 0x45;
static const ShortInt VarEnum_VT_BLOB_OBJECT = 0x46;
static const ShortInt VarEnum_VT_CF = 0x47;
static const ShortInt VarEnum_VT_CLSID = 0x48;
static const Word VarEnum_VT_VECTOR = 0x1000;
static const Word VarEnum_VT_ARRAY = 0x2000;
static const Word VarEnum_VT_BYREF = 0x4000;
static const ShortInt UnmanagedType_Bool = 0x2;
static const ShortInt UnmanagedType_I1 = 0x3;
static const ShortInt UnmanagedType_U1 = 0x4;
static const ShortInt UnmanagedType_I2 = 0x5;
static const ShortInt UnmanagedType_U2 = 0x6;
static const ShortInt UnmanagedType_I4 = 0x7;
static const ShortInt UnmanagedType_U4 = 0x8;
static const ShortInt UnmanagedType_I8 = 0x9;
static const ShortInt UnmanagedType_U8 = 0xa;
static const ShortInt UnmanagedType_R4 = 0xb;
static const ShortInt UnmanagedType_R8 = 0xc;
static const ShortInt UnmanagedType_Currency = 0xf;
static const ShortInt UnmanagedType_BStr = 0x13;
static const ShortInt UnmanagedType_LPStr = 0x14;
static const ShortInt UnmanagedType_LPWStr = 0x15;
static const ShortInt UnmanagedType_LPTStr = 0x16;
static const ShortInt UnmanagedType_ByValTStr = 0x17;
static const ShortInt UnmanagedType_IUnknown = 0x19;
static const ShortInt UnmanagedType_IDispatch = 0x1a;
static const ShortInt UnmanagedType_Struct = 0x1b;
static const ShortInt UnmanagedType_Interface = 0x1c;
static const ShortInt UnmanagedType_SafeArray = 0x1d;
static const ShortInt UnmanagedType_ByValArray = 0x1e;
static const ShortInt UnmanagedType_SysInt = 0x1f;
static const ShortInt UnmanagedType_SysUInt = 0x20;
static const ShortInt UnmanagedType_VBByRefStr = 0x22;
static const ShortInt UnmanagedType_AnsiBStr = 0x23;
static const ShortInt UnmanagedType_TBStr = 0x24;
static const ShortInt UnmanagedType_VariantBool = 0x25;
static const ShortInt UnmanagedType_FunctionPtr = 0x26;
static const ShortInt UnmanagedType_AsAny = 0x28;
static const ShortInt UnmanagedType_LPArray = 0x2a;
static const ShortInt UnmanagedType_LPStruct = 0x2b;
static const ShortInt UnmanagedType_CustomMarshaler = 0x2c;
static const ShortInt UnmanagedType_Error = 0x2d;
static const ShortInt CallingConvention_Winapi = 0x1;
static const ShortInt CallingConvention_Cdecl = 0x2;
static const ShortInt CallingConvention_StdCall = 0x3;
static const ShortInt CallingConvention_ThisCall = 0x4;
static const ShortInt CallingConvention_FastCall = 0x5;
static const ShortInt CharSet_None = 0x1;
static const ShortInt CharSet_Ansi = 0x2;
static const ShortInt CharSet_Unicode = 0x3;
static const ShortInt CharSet_Auto = 0x4;
static const ShortInt ComMemberType_Method = 0x0;
static const ShortInt ComMemberType_PropGet = 0x1;
static const ShortInt ComMemberType_PropSet = 0x2;
static const ShortInt GCHandleType_Weak = 0x0;
static const ShortInt GCHandleType_WeakTrackResurrection = 0x1;
static const ShortInt GCHandleType_Normal = 0x2;
static const ShortInt GCHandleType_Pinned = 0x3;
static const ShortInt AssemblyRegistrationFlags_None = 0x0;
static const ShortInt AssemblyRegistrationFlags_SetCodeBase = 0x1;
static const ShortInt TypeLibImporterFlags_PrimaryInteropAssembly = 0x1;
static const ShortInt TypeLibImporterFlags_UnsafeInterfaces = 0x2;
static const ShortInt TypeLibImporterFlags_SafeArrayAsSystemArray = 0x4;
static const ShortInt TypeLibImporterFlags_TransformDispRetVals = 0x8;
static const ShortInt TypeLibExporterFlags_OnlyReferenceRegistered = 0x1;
static const ShortInt ImporterEventKind_NOTIF_TYPECONVERTED = 0x0;
static const ShortInt ImporterEventKind_NOTIF_CONVERTWARNING = 0x1;
static const ShortInt ImporterEventKind_ERROR_REFTOINVALIDTYPELIB = 0x2;
static const ShortInt ExporterEventKind_NOTIF_TYPECONVERTED = 0x0;
static const ShortInt ExporterEventKind_NOTIF_CONVERTWARNING = 0x1;
static const ShortInt ExporterEventKind_ERROR_REFTOINVALIDASSEMBLY = 0x2;
static const ShortInt LayoutKind_Sequential = 0x0;
static const ShortInt LayoutKind_Explicit = 0x2;
static const ShortInt LayoutKind_Auto = 0x3;
static const ShortInt FileAccess_Read = 0x1;
static const ShortInt FileAccess_Write = 0x2;
static const ShortInt FileAccess_ReadWrite = 0x3;
static const ShortInt FileMode_CreateNew = 0x1;
static const ShortInt FileMode_Create = 0x2;
static const ShortInt FileMode_Open = 0x3;
static const ShortInt FileMode_OpenOrCreate = 0x4;
static const ShortInt FileMode_Truncate = 0x5;
static const ShortInt FileMode_Append = 0x6;
static const ShortInt FileShare_None = 0x0;
static const ShortInt FileShare_Read = 0x1;
static const ShortInt FileShare_Write = 0x2;
static const ShortInt FileShare_ReadWrite = 0x3;
static const ShortInt FileShare_Inheritable = 0x10;
static const ShortInt FileAttributes_ReadOnly = 0x1;
static const ShortInt FileAttributes_Hidden = 0x2;
static const ShortInt FileAttributes_System = 0x4;
static const ShortInt FileAttributes_Directory = 0x10;
static const ShortInt FileAttributes_Archive = 0x20;
static const ShortInt FileAttributes_Device = 0x40;
static const Byte FileAttributes_Normal = 0x80;
static const Word FileAttributes_Temporary = 0x100;
static const Word FileAttributes_SparseFile = 0x200;
static const Word FileAttributes_ReparsePoint = 0x400;
static const Word FileAttributes_Compressed = 0x800;
static const Word FileAttributes_Offline = 0x1000;
static const Word FileAttributes_NotContentIndexed = 0x2000;
static const Word FileAttributes_Encrypted = 0x4000;
static const ShortInt SeekOrigin_Begin = 0x0;
static const ShortInt SeekOrigin_Current = 0x1;
static const ShortInt SeekOrigin_End = 0x2;
static const ShortInt MethodImplOptions_Unmanaged = 0x4;
static const ShortInt MethodImplOptions_ForwardRef = 0x10;
static const Byte MethodImplOptions_PreserveSig = 0x80;
static const Word MethodImplOptions_InternalCall = 0x1000;
static const ShortInt MethodImplOptions_Synchronized = 0x20;
static const ShortInt MethodImplOptions_NoInlining = 0x8;
static const ShortInt MethodCodeType_IL = 0x0;
static const ShortInt MethodCodeType_Native = 0x1;
static const ShortInt MethodCodeType_OPTIL = 0x2;
static const ShortInt MethodCodeType_Runtime = 0x3;
static const ShortInt EnvironmentPermissionAccess_NoAccess = 0x0;
static const ShortInt EnvironmentPermissionAccess_Read = 0x1;
static const ShortInt EnvironmentPermissionAccess_Write = 0x2;
static const ShortInt EnvironmentPermissionAccess_AllAccess = 0x3;
static const ShortInt FileDialogPermissionAccess_None = 0x0;
static const ShortInt FileDialogPermissionAccess_Open = 0x1;
static const ShortInt FileDialogPermissionAccess_Save = 0x2;
static const ShortInt FileDialogPermissionAccess_OpenSave = 0x3;
static const ShortInt FileIOPermissionAccess_NoAccess = 0x0;
static const ShortInt FileIOPermissionAccess_Read = 0x1;
static const ShortInt FileIOPermissionAccess_Write = 0x2;
static const ShortInt FileIOPermissionAccess_Append = 0x4;
static const ShortInt FileIOPermissionAccess_PathDiscovery = 0x8;
static const ShortInt FileIOPermissionAccess_AllAccess = 0xf;
static const ShortInt IsolatedStorageContainment_None = 0x0;
static const ShortInt IsolatedStorageContainment_DomainIsolationByUser = 0x10;
static const ShortInt IsolatedStorageContainment_AssemblyIsolationByUser = 0x20;
static const ShortInt IsolatedStorageContainment_DomainIsolationByRoamingUser = 0x50;
static const ShortInt IsolatedStorageContainment_AssemblyIsolationByRoamingUser = 0x60;
static const ShortInt IsolatedStorageContainment_AdministerIsolatedStorageByUser = 0x70;
static const Byte IsolatedStorageContainment_UnrestrictedIsolatedStorage = 0xf0;
static const ShortInt PermissionState_Unrestricted = 0x1;
static const ShortInt PermissionState_None = 0x0;
static const ShortInt SecurityAction_Demand = 0x2;
static const ShortInt SecurityAction_Assert = 0x3;
static const ShortInt SecurityAction_Deny = 0x4;
static const ShortInt SecurityAction_PermitOnly = 0x5;
static const ShortInt SecurityAction_LinkDemand = 0x6;
static const ShortInt SecurityAction_InheritanceDemand = 0x7;
static const ShortInt SecurityAction_RequestMinimum = 0x8;
static const ShortInt SecurityAction_RequestOptional = 0x9;
static const ShortInt SecurityAction_RequestRefuse = 0xa;
static const ShortInt ReflectionPermissionFlag_NoFlags = 0x0;
static const ShortInt ReflectionPermissionFlag_TypeInformation = 0x1;
static const ShortInt ReflectionPermissionFlag_MemberAccess = 0x2;
static const ShortInt ReflectionPermissionFlag_ReflectionEmit = 0x4;
static const ShortInt ReflectionPermissionFlag_AllFlags = 0x7;
static const ShortInt RegistryPermissionAccess_NoAccess = 0x0;
static const ShortInt RegistryPermissionAccess_Read = 0x1;
static const ShortInt RegistryPermissionAccess_Write = 0x2;
static const ShortInt RegistryPermissionAccess_Create = 0x4;
static const ShortInt RegistryPermissionAccess_AllAccess = 0x7;
static const ShortInt SecurityPermissionFlag_NoFlags = 0x0;
static const ShortInt SecurityPermissionFlag_Assertion = 0x1;
static const ShortInt SecurityPermissionFlag_UnmanagedCode = 0x2;
static const ShortInt SecurityPermissionFlag_SkipVerification = 0x4;
static const ShortInt SecurityPermissionFlag_Execution = 0x8;
static const ShortInt SecurityPermissionFlag_ControlThread = 0x10;
static const ShortInt SecurityPermissionFlag_ControlEvidence = 0x20;
static const ShortInt SecurityPermissionFlag_ControlPolicy = 0x40;
static const Byte SecurityPermissionFlag_SerializationFormatter = 0x80;
static const Word SecurityPermissionFlag_ControlDomainPolicy = 0x100;
static const Word SecurityPermissionFlag_ControlPrincipal = 0x200;
static const Word SecurityPermissionFlag_ControlAppDomain = 0x400;
static const Word SecurityPermissionFlag_RemotingConfiguration = 0x800;
static const Word SecurityPermissionFlag_Infrastructure = 0x1000;
static const Word SecurityPermissionFlag_BindingRedirects = 0x2000;
static const Word SecurityPermissionFlag_AllFlags = 0x3fff;
static const ShortInt UIPermissionWindow_NoWindows = 0x0;
static const ShortInt UIPermissionWindow_SafeSubWindows = 0x1;
static const ShortInt UIPermissionWindow_SafeTopLevelWindows = 0x2;
static const ShortInt UIPermissionWindow_AllWindows = 0x3;
static const ShortInt UIPermissionClipboard_NoClipboard = 0x0;
static const ShortInt UIPermissionClipboard_OwnClipboard = 0x1;
static const ShortInt UIPermissionClipboard_AllClipboard = 0x2;
static const ShortInt PolicyLevelType_User = 0x0;
static const ShortInt PolicyLevelType_Machine = 0x1;
static const ShortInt PolicyLevelType_Enterprise = 0x2;
static const ShortInt PolicyLevelType_AppDomain = 0x3;
static const ShortInt SecurityZone_MyComputer = 0x0;
static const ShortInt SecurityZone_Intranet = 0x1;
static const ShortInt SecurityZone_Trusted = 0x2;
static const ShortInt SecurityZone_Internet = 0x3;
static const ShortInt SecurityZone_Untrusted = 0x4;
static const unsigned SecurityZone_NoZone = 0xffffffff;
static const ShortInt WellKnownObjectMode_Singleton = 0x1;
static const ShortInt WellKnownObjectMode_SingleCall = 0x2;
static const ShortInt ActivatorLevel_Construction = 0x4;
static const ShortInt ActivatorLevel_Context = 0x8;
static const ShortInt ActivatorLevel_AppDomain = 0xc;
static const ShortInt ActivatorLevel_Process = 0x10;
static const ShortInt ActivatorLevel_Machine = 0x14;
static const ShortInt ServerProcessing_Complete = 0x0;
static const ShortInt ServerProcessing_OneWay = 0x1;
static const ShortInt ServerProcessing_Async = 0x2;
static const ShortInt LeaseState_Null = 0x0;
static const ShortInt LeaseState_Initial = 0x1;
static const ShortInt LeaseState_Active = 0x2;
static const ShortInt LeaseState_Renewing = 0x3;
static const ShortInt LeaseState_Expired = 0x4;
static const ShortInt SoapOption_None = 0x0;
static const ShortInt SoapOption_AlwaysIncludeTypes = 0x1;
static const ShortInt SoapOption_XsdString = 0x2;
static const ShortInt SoapOption_EmbedAll = 0x4;
static const ShortInt SoapOption_Option1 = 0x8;
static const ShortInt SoapOption_Option2 = 0x10;
static const ShortInt XmlFieldOrderOption_All = 0x0;
static const ShortInt XmlFieldOrderOption_Sequence = 0x1;
static const ShortInt XmlFieldOrderOption_Choice = 0x2;
static const ShortInt IsolatedStorageScope_None = 0x0;
static const ShortInt IsolatedStorageScope_User = 0x1;
static const ShortInt IsolatedStorageScope_Domain = 0x2;
static const ShortInt IsolatedStorageScope_Assembly = 0x4;
static const ShortInt IsolatedStorageScope_Roaming = 0x8;
static const ShortInt FormatterTypeStyle_TypesWhenNeeded = 0x0;
static const ShortInt FormatterTypeStyle_TypesAlways = 0x1;
static const ShortInt FormatterTypeStyle_XsdString = 0x2;
static const ShortInt FormatterAssemblyStyle_Simple = 0x0;
static const ShortInt FormatterAssemblyStyle_Full = 0x1;
static const ShortInt TypeFilterLevel_Low = 0x2;
static const ShortInt TypeFilterLevel_Full = 0x3;
static const ShortInt AssemblyBuilderAccess_Run = 0x1;
static const ShortInt AssemblyBuilderAccess_Save = 0x2;
static const ShortInt AssemblyBuilderAccess_RunAndSave = 0x3;
static const ShortInt PEFileKinds_Dll = 0x1;
static const ShortInt PEFileKinds_ConsoleApplication = 0x2;
static const ShortInt PEFileKinds_WindowApplication = 0x3;
static const ShortInt OpCodeType_Annotation = 0x0;
static const ShortInt OpCodeType_Macro = 0x1;
static const ShortInt OpCodeType_Nternal = 0x2;
static const ShortInt OpCodeType_Objmodel = 0x3;
static const ShortInt OpCodeType_Prefix = 0x4;
static const ShortInt OpCodeType_Primitive = 0x5;
static const ShortInt StackBehaviour_Pop0 = 0x0;
static const ShortInt StackBehaviour_Pop1 = 0x1;
static const ShortInt StackBehaviour_Pop1_pop1 = 0x2;
static const ShortInt StackBehaviour_Popi = 0x3;
static const ShortInt StackBehaviour_Popi_pop1 = 0x4;
static const ShortInt StackBehaviour_Popi_popi = 0x5;
static const ShortInt StackBehaviour_Popi_popi8 = 0x6;
static const ShortInt StackBehaviour_Popi_popi_popi = 0x7;
static const ShortInt StackBehaviour_Popi_popr4 = 0x8;
static const ShortInt StackBehaviour_Popi_popr8 = 0x9;
static const ShortInt StackBehaviour_Popref = 0xa;
static const ShortInt StackBehaviour_Popref_pop1 = 0xb;
static const ShortInt StackBehaviour_Popref_popi = 0xc;
static const ShortInt StackBehaviour_Popref_popi_popi = 0xd;
static const ShortInt StackBehaviour_Popref_popi_popi8 = 0xe;
static const ShortInt StackBehaviour_Popref_popi_popr4 = 0xf;
static const ShortInt StackBehaviour_Popref_popi_popr8 = 0x10;
static const ShortInt StackBehaviour_Popref_popi_popref = 0x11;
static const ShortInt StackBehaviour_Push0 = 0x12;
static const ShortInt StackBehaviour_Push1 = 0x13;
static const ShortInt StackBehaviour_Push1_push1 = 0x14;
static const ShortInt StackBehaviour_Pushi = 0x15;
static const ShortInt StackBehaviour_Pushi8 = 0x16;
static const ShortInt StackBehaviour_Pushr4 = 0x17;
static const ShortInt StackBehaviour_Pushr8 = 0x18;
static const ShortInt StackBehaviour_Pushref = 0x19;
static const ShortInt StackBehaviour_Varpop = 0x1a;
static const ShortInt StackBehaviour_Varpush = 0x1b;
static const ShortInt OperandType_InlineBrTarget = 0x0;
static const ShortInt OperandType_InlineField = 0x1;
static const ShortInt OperandType_InlineI = 0x2;
static const ShortInt OperandType_InlineI8 = 0x3;
static const ShortInt OperandType_InlineMethod = 0x4;
static const ShortInt OperandType_InlineNone = 0x5;
static const ShortInt OperandType_InlinePhi = 0x6;
static const ShortInt OperandType_InlineR = 0x7;
static const ShortInt OperandType_InlineSig = 0x9;
static const ShortInt OperandType_InlineString = 0xa;
static const ShortInt OperandType_InlineSwitch = 0xb;
static const ShortInt OperandType_InlineTok = 0xc;
static const ShortInt OperandType_InlineType = 0xd;
static const ShortInt OperandType_InlineVar = 0xe;
static const ShortInt OperandType_ShortInlineBrTarget = 0xf;
static const ShortInt OperandType_ShortInlineI = 0x10;
static const ShortInt OperandType_ShortInlineR = 0x11;
static const ShortInt OperandType_ShortInlineVar = 0x12;
static const ShortInt FlowControl_Branch = 0x0;
static const ShortInt FlowControl_Break = 0x1;
static const ShortInt FlowControl_Call = 0x2;
static const ShortInt FlowControl_Cond_Branch = 0x3;
static const ShortInt FlowControl_Meta = 0x4;
static const ShortInt FlowControl_Next = 0x5;
static const ShortInt FlowControl_Phi = 0x6;
static const ShortInt FlowControl_Return = 0x7;
static const ShortInt FlowControl_Throw = 0x8;
static const ShortInt PackingSize_Unspecified = 0x0;
static const ShortInt PackingSize_Size1 = 0x1;
static const ShortInt PackingSize_Size2 = 0x2;
static const ShortInt PackingSize_Size4 = 0x4;
static const ShortInt PackingSize_Size8 = 0x8;
static const ShortInt PackingSize_Size16 = 0x10;
static const ShortInt AssemblyHashAlgorithm_None = 0x0;
static const Word AssemblyHashAlgorithm_MD5 = 0x8003;
static const Word AssemblyHashAlgorithm_SHA1 = 0x8004;
static const ShortInt AssemblyVersionCompatibility_SameMachine = 0x1;
static const ShortInt AssemblyVersionCompatibility_SameProcess = 0x2;
static const ShortInt AssemblyVersionCompatibility_SameDomain = 0x3;
extern PACKAGE Jclunitversioning::TUnitVersionInfo UnitVersioning;

}	/* namespace Mscorlib_tlb */
using namespace Mscorlib_tlb;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// Mscorlib_tlbHPP
