// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/log;
import ballerina/http;
import wso2/messageStore;
import ballerina/runtime;
import ballerina/io;


public function main(string... args) {

    // CODE-SEGMENT-BEGIN: segment_1
    messageStore:MessageStoreConfiguration myMessageStoreConfig = {
        messageBroker: "ACTIVE_MQ",
        providerUrl: "tcp://localhost:61616",
        queueName: "myStore"
    };
    // CODE-SEGMENT-END: segment_1

    // CODE-SEGMENT-BEGIN: segment_2
    // Create a DLC store
    messageStore:MessageStoreConfiguration dlcMessageStoreConfig = {
        messageBroker: "ACTIVE_MQ",
        providerUrl: "tcp://localhost:61616",
        queueName: "myDLCStore"
    };

    messageStore:Client dlcStoreClient = checkpanic new messageStore:Client(dlcMessageStoreConfig);

    // Config for message processor
    messageStore:ForwardingProcessorConfiguration myProcessorConfig = {
        storeConfig: myMessageStoreConfig,
        HTTPEndpoint: "http://localhost:9090/grandoaks/categories/surgery/reserve",
        pollTimeConfig: "0/2 * * * * ?" ,

        // Forwarding retry
        retryInterval: 3000,
        retryHTTPStatusCodes:[http:INTERNAL_SERVER_ERROR_500, http:BAD_REQUEST_400],
        maxRedeliveryAttempts: 5,

        // Connection retry
        maxStoreConnectionAttemptInterval: 120,
        storeConnectionAttemptInterval: 15,
        storeConnectionBackOffFactor: 1.5,
        deactivateOnFail: false,
        DLCStore: dlcStoreClient
    };
    // CODE-SEGMENT-END: segment_2

    // CODE-SEGMENT-BEGIN: segment_3
    // Create message processor
    var myMessageProcessor = new messageStore:MessageForwardingProcessor(myProcessorConfig, handleResponseFromBE);
    if(myMessageProcessor is error) {
        log:printError("Error while initializing Message Processor", err = myMessageProcessor);
        panic myMessageProcessor;
    } else {
        // Start the processor
        var processorStartResult = myMessageProcessor.start();
        if(processorStartResult is error) {
            panic processorStartResult;
        } else {
            //TODO:temp fix
            myMessageProcessor.keepRunning();
        }
    }
    // CODE-SEGMENT-END: segment_3
}

// Function to handle response
function handleResponseFromBE(http:Response resp) {
    var payload =  resp.getJsonPayload();
    if(payload is json) {
        log:printInfo("Response received " + "Response status code= " + resp.statusCode + ": " + payload.toString());
    } else {
        log:printError("Error while getting response payload", err = payload);
    }
}