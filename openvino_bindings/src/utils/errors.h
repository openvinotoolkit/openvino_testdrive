/**
 * Copyright 2024 Intel Corporation.
 * SPDX-License-Identifier: Apache-2.0
 */

#ifndef ERRORS_H_
#define ERRORS_H_

#include <string>
#include <exception>
#include "status.h"

inline std::string error_to_string(StatusEnum error) {
    switch(error) {
        case OkStatus:
            return "Ok";
        case ErrorStatus:
            return "ErrorStatus"; //generic error
        case ModelTypeNotSupplied:
            return "ModelTypeNotSupplied";
        case ModelTypeNotSupported:
            return "ModelTypeNotSupported";
        case OverlayUnableToLoadFont:
            return "OverlayUnableToLoadFont";
        case OverlayLabelNotFound:
            return "OverlayLabelNotFound";
        case OverlayNoOutputSelected:
            return "OverlayNoOutputSelected";
        case FontLoadError:
            return "FontLoadError";
        default:
            return "Undefined";
    }
}

class api_error : public std::exception {
public:
    StatusEnum status;
    std::string additional_info;

    api_error(StatusEnum status): status(status) {};
    api_error(StatusEnum status, std::string message): status(status), additional_info(message) {};

    virtual const char * what() const noexcept {
        // Not sure about this. Concurrency could cause two errors thrown at the same time to cause some issues
        static std::string message = "Error: ";
        message += error_to_string(status);
        message += ": " + additional_info;
        return message.c_str();
    }

};

#endif // ERRORS_H_
