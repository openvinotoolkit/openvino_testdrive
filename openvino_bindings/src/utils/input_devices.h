#ifndef WINDOWS_INPUT_DEVICES_H_
#define WINDOWS_INPUT_DEVICES_H_

#include <iostream>
#include <vector>
#include <map>
#include <string>

#include "status.h"
#include "errors.h"


#if _WIN32
#include <windows.h>
#include <mfapi.h>
#include <mfidl.h>
#include <mfobjects.h>
#include <mferror.h>
#pragma comment(lib, "mfplat.lib")
#pragma comment(lib, "mf.lib")

std::map<size_t, std::string> list_camera_devices() {
    HRESULT hr = MFStartup(MF_VERSION);
    if (FAILED(hr)) {
        throw api_error(InputDeviceError, "MFStartup failed.");
    }

    IMFAttributes* pAttributes = nullptr;
    hr = MFCreateAttributes(&pAttributes, 1);
    if (FAILED(hr)) {
        MFShutdown();
        throw api_error(InputDeviceError, "MFCreateAttributes failed.");
    }

    // Specify that we want video capture devices
    hr = pAttributes->SetGUID(MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE, MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID);
    if (FAILED(hr)) {
        pAttributes->Release();
        MFShutdown();
        throw api_error(InputDeviceError, "SetGUID failed.");
    }

    IMFActivate** ppDevices = nullptr;
    UINT32 count = 0;


    std::map<size_t, std::string> cameras = {};
    hr = MFEnumDeviceSources(pAttributes, &ppDevices, &count);
    if (SUCCEEDED(hr)) {
        for (UINT32 i = 0; i < count; i++) {
            WCHAR* szFriendlyName = nullptr;
            UINT32 cchName = 0;
            hr = ppDevices[i]->GetAllocatedString(MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME, &szFriendlyName, &cchName);
            if (SUCCEEDED(hr)) {
                std::wstring ws(szFriendlyName);
                cameras.insert({i, std::string(ws.begin(), ws.end())});
                //std::wcout << L"[" << i << L"]: " << szFriendlyName << std::endl;
                CoTaskMemFree(szFriendlyName);
            }
            ppDevices[i]->Release();
        }
        CoTaskMemFree(ppDevices);
    } else {
        std::cerr << "No camera devices found.\n";
    }

    pAttributes->Release();
    MFShutdown();

    return cameras;
}
#elif __APPLE__
std::map<size_t, std::string> list_camera_devices() {
    return {};
}
#elif __linux__
std::map<size_t, std::string> list_camera_devices() {
    return {};
}
#else
std::map<size_t, std::string> list_camera_devices() {
    throw api_error(InputDeviceError, "Unsupported platform.");
}
#endif

#endif // WINDOWS_INPUT_DEVICES_H_
