const String faceDetectionExampleGraph = """
output_stream : "output"

node {
    calculator : "OpenVINOInferenceAdapterCalculator"
    output_side_packet : "INFERENCE_ADAPTER:adapter"
    node_options: {
        [type.googleapis.com/mediapipe.OpenVINOInferenceAdapterCalculatorOptions] {
            model_path: "/data/omz_models/intel/face-detection-retail-0004/face-detection-retail-0004.xml"
        }
    }
}

node {
    calculator : "VideoInputCalculator"
    output_stream: "IMAGE:input_image"
}

node {
    calculator : "DetectionCalculator"
    input_side_packet : "INFERENCE_ADAPTER:adapter"
    input_stream : "IMAGE:input_image"
    output_stream: "INFERENCE_RESULT:inference_detections"
}

node {
    calculator : "OverlayCalculator"
    input_stream : "IMAGE:input_image"
    input_stream : "INFERENCE_RESULT:inference_detections"
    output_stream: "IMAGE:output"
    node_options: {
        [type.googleapis.com/mediapipe.OverlayCalculatorOptions] {
            labels: {
                id: "face"
                name: "face"
                color: "#f7dab3ff"
                is_empty: false
            }

            stroke_width: 2
            opacity: 0.4
            font_size: 1.0
        }
    }
}
""";
