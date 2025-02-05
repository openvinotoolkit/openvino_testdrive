/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef INPUT_DEVICES_H_
#define INPUT_DEVICES_H_

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
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/videodev2.h>

std::map<size_t, std::string> list_camera_devices() {
    std::map<size_t, std::string> cameras = {};

    for (int i = 0; i < 10; ++i) {  // Check up to 10 devices
        std::string devName = "/dev/video" + std::to_string(i);
        std::cout << devName << std::endl;
        int fd = open(devName.c_str(), O_RDONLY);
        if (fd == -1) continue;  // Skip if device doesn't exist

        struct v4l2_capability cap;
        if (ioctl(fd, VIDIOC_QUERYCAP, &cap) == 0) {
            if (cap.capabilities & V4L2_CAP_VIDEO_CAPTURE) {
                cameras.insert({i, std::string(reinterpret_cast<char*>(cap.card))});
            }
        }
        close(fd);
    }
    return cameras;
}
#else
std::map<size_t, std::string> list_camera_devices() {
    throw api_error(InputDeviceError, "Unsupported platform.");
}
#endif

#endif // INPUT_DEVICES_H_
