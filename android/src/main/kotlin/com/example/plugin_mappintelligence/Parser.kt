package com.example.plugin_mappintelligence

import webtrekk.android.sdk.ActiveConfig
import webtrekk.android.sdk.ExceptionType

object Parser {
    fun ActiveConfig.toMap():Map<String,Any?>{
        return mapOf(
            "everId" to this.everId,
            "everIdMode" to this.everIdMode?.name,
            "appFirstOpen" to this.appFirstOpen,
            "trackIds" to this.trackIds.joinToString(separator = ","),
            "trackDomains" to this.trackDomains,
            "anonymousParams" to this.anonymousParams.joinToString(separator = ","),
            "exceptionLogLevel" to this.exceptionLogLevel?.name,
            "isActivityAutoTracking" to this.isActivityAutoTracking,
            "isFragmentAutoTracking" to this.isFragmentAutoTracking,
            "isAnonymous" to this.isAnonymous,
            "isAutoTracking" to this.isAutoTracking,
            "isBatchSupport" to this.isBatchSupport,
            "isOptOut" to this.isOptOut,
            "isUserMatchingEnabled" to this.isUserMatchingEnabled(),
            "userMatchingId" to this.userMatchingId,
            "logLevel" to this.logLevel.name,
            "requestInterval" to this.requestInterval,
            "requestsPerBatch" to this.requestsPerBatch,
            "sendVersionInEachRequest" to this.sendVersionInEachRequest,
            "shouldMigrate" to this.shouldMigrate,
            "temporarySessionId" to this.temporarySessionId
        )
    }
}