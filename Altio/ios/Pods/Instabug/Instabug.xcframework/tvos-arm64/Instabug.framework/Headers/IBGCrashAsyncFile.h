/*
 File:       InstabugCrashReporting/IBGCrashAsyncFile.h

 Contains:   API for using Instabug's SDK.

 Copyright:  (c) 2013-2022 by Instabug, Inc., all rights reserved.

 Version:    0.0.0
 */

#ifndef ibgcrash_async_file_h
#define ibgcrash_async_file_h


#ifdef __cplusplus
extern "C" {
#endif


/**
 * @internal
 * @ingroup ibgcrash_async_bufio
 *
 * Async-safe buffered file output. This implementation is only intended for use
 * within signal handler execution of crash log output.
 */
typedef struct ibgcrash_async_file {
    /** Output file descriptor */
    int fd;
    
    /** Output limit */
    off_t limit_bytes;
    
    /** Total bytes written */
    off_t total_bytes;
    
    /** Current length of data in buffer */
    size_t buflen;
    
    /** Buffered output */
    char buffer[256];
} ibgcrash_async_file_t;

#endif /* ibgcrash_async_file_h */

#ifdef __cplusplus
}
#endif
