/*
 File:       InstabugCrashReporting/IBGCrashReportWriter.h

 Contains:   API for using Instabug's SDK.

 Copyright:  (c) 2013-2022 by Instabug, Inc., all rights reserved.

 Version:    0.0.0
 */

#ifndef IBGCrashReportWriter_h
#define IBGCrashReportWriter_h

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>

#ifdef __OBJC__
#include <Foundation/Foundation.h>
#endif

#include "IBGCrashAsyncFile.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct IBGCrashReportWriterContext {
    const char *filePath;
    ibgcrash_async_file_t file;

    /** true if this is the first entry at the current container level. */
    bool containerFirstEntry;

    int addedElementsCount;

    /** Close File by writer Context*/
    void (*closeFile)(struct IBGCrashReportWriterContext *const context);
} IBGCrashReportWriterContext;

/**
 * Encapsulates report writing functionality.
 */
typedef struct IBGCrashReportWriter {
    /** Internal contextual data for the writer */
    void *context;

    /** Add an integer element to the report.
     * @param writer This writer.
     * @param key The name to give this element.
     * @param value The value to add.
     */
    void (*addIntegerElement)(struct IBGCrashReportWriter *writer, const char *key, int64_t value);

    /** Add an unsigned integer element to the report.
     * @param writer This writer.
     * @param key The name to give this element.
     * @param value The value to add.
     */
    void (*addUIntegerElement)(struct IBGCrashReportWriter *writer, const char *key, uint64_t value);

    /** Add a string element to the report.
     * @param writer This writer.
     * @param key The name to give this element.
     * @param value The string value to add.
     */
    void (*addStringElement)(struct IBGCrashReportWriter *writer, const char *key, const char *value);
} IBGCrashReportWriter;

#ifdef __cplusplus
}
#endif

#endif  // IBGCrashReportWriter_h


