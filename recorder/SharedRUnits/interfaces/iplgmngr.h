/******************************************************************************/
/*  Recorder\iface                                                            */
/*                                                                            */
/*  �������� ���������� IPluginsControl                                       */
/*  ��������� ������� � ��������� �������� ���������                          */
/*                                                                            */
/*                                                                            */
/*  �������� ��� �����: iplgmngr.h                                            */
/*  ����������: MVC++6.0                                                      */
/*                                                                            */
/*  (c) ��� "����"                                                            */
/******************************************************************************/

#ifndef IPLGMNGR_H
#define IPLGMNGR_H

#include "rcplugin.h"
#include <string>
using std::string;

// {EC4193D5-09D2-4741-8223-1A8DC5D81EA7}
static const GUID IID_IPluginsControl = 
{ 0xec4193d5, 0x9d2, 0x4741, { 0x82, 0x23, 0x1a, 0x8d, 0xc5, 0xd8, 0x1e, 0xa7 } };

typedef struct{
	bool create_;
	bool config_;
	bool execute_;
	HMODULE hdll_;
	ULONG configstate_;
	string name_;
}PLUGINCONTEXT;


class IPluginsControl : public IUnknown
{
	public:
	//�������� ����� ������������ ��������
	virtual ULONG            STDMETHODCALLTYPE GetPluginsCount() = 0;
	//�������� ������ �� ������������ ������ �� �������
	virtual IRecorderPlugin* STDMETHODCALLTYPE GetPlugin(ULONG a_nIndex) = 0;

	//�������� ����� ��������������� ��������
	virtual ULONG            STDMETHODCALLTYPE GetAutoLoadPluginsCount() = 0;
	//�������� ��� ���������������� �������
	virtual HRESULT          STDMETHODCALLTYPE GetAutoLoadPluginLibrary(ULONG a_nIndex, CHAR* a_pchLibrary) = 0;
	//�������� ������ � ������������
	virtual HRESULT          STDMETHODCALLTYPE AddPluginToAutoLoad(const char* a_pchLibrary) = 0;
	//������ ������ �� ������������
	virtual HRESULT          STDMETHODCALLTYPE RemovePluginFromAutoLoad(const char* a_pchLibrary) = 0;
	//��������� ���������� � ���������� �������
	virtual HRESULT          STDMETHODCALLTYPE RequestLibraryInfo(const char* a_pchLibrary, LPPLUGININFO a_pPluginInfo) = 0;


	virtual HRESULT          STDMETHODCALLTYPE CreatePlugin(const char* a_pchPluginPath,IRecorder* m_pOwner) = 0;
	virtual HRESULT          STDMETHODCALLTYPE ConfigPlugin(IRecorderPlugin* a_piPlugin) = 0;
	virtual HRESULT          STDMETHODCALLTYPE ExecutePlugin(IRecorderPlugin* a_piPlugin) = 0;
	virtual HRESULT          STDMETHODCALLTYPE ClosePlugin(IRecorderPlugin* a_piPlugin) = 0;

	virtual ULONG            STDMETHODCALLTYPE GetCount() = 0;
	virtual IRecorderPlugin* STDMETHODCALLTYPE GetAt(ULONG a_nIndex) = 0;

};
#endif