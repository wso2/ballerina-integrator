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

import ballerina/http;

@http:ServiceConfig {
    basePath: "/xyz"
}
service xyz on new http:Listener(8082) {
    @http:ResourceConfig {
        methods: ["GET"],
        path: "quote"
    }
    resource function quote(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setTextPayload("12000.00");
        error? respond = caller->respond(response);
    }
}

