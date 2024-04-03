//
//  FileProviderProxy.h
//  Runner
//
//  Created by Peter Jankuliak on 03/04/2024.
//

#ifndef FileProviderProxy_h
#define FileProviderProxy_h

#include <stdint.h>

typedef uint64_t SessionHandle;

struct SessionCreateResult {
    SessionHandle session;
    uint16_t errorCode;
    const char* errorMessage;
};

typedef struct SessionCreateResult SessionCreateResult;

#endif /* FileProviderProxy_h */
