/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */


#include "graph_runner.h"
#include "mediapipe/framework/port/parse_text_proto.h"
#include "src/utils/errors.h"
#include "src/utils/status.h"

void GraphRunner::open_graph(std::string graph_content) {
    mediapipe::CalculatorGraphConfig graph_config = mediapipe::ParseTextProtoOrDie<mediapipe::CalculatorGraphConfig>(absl::Substitute(graph_content));
    graph = std::make_shared<mediapipe::CalculatorGraph>(graph_config);
    poller = std::make_shared<mediapipe::OutputStreamPoller>(mediapipe::OutputStreamPoller(graph->AddOutputStreamPoller("output").value()));
    graph->StartRun({});
    auto status = graph->WaitUntilIdle();
    if (!status.ok()) {
        throw api_error(MediapipeGraphError, std::string{status.message()});
    }
}

std::string GraphRunner::get() {
    mediapipe::Packet output_packet;
    if (poller->Next(&output_packet)) {
        return output_packet.Get<std::string>();
    }
    throw api_error(MediapipeNextPackageFailure);
}

void GraphRunner::stop() {
    graph->CloseAllInputStreams();
    graph->WaitUntilDone();
}
