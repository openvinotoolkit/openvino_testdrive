// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart' as pkg_ffi;

class OpenVINO {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  OpenVINO(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  OpenVINO.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void freeStatus(
    ffi.Pointer<Status> status,
  ) {
    return _freeStatus(
      status,
    );
  }

  late final _freeStatusPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Status>)>>(
          'freeStatus');
  late final _freeStatus =
      _freeStatusPtr.asFunction<void Function(ffi.Pointer<Status>)>();

  void freeStatusOrString(
    ffi.Pointer<StatusOrString> status,
  ) {
    return _freeStatusOrString(
      status,
    );
  }

  late final _freeStatusOrStringPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<StatusOrString>)>>(
      'freeStatusOrString');
  late final _freeStatusOrString = _freeStatusOrStringPtr
      .asFunction<void Function(ffi.Pointer<StatusOrString>)>();

  void freeStatusOrImageInference(
    ffi.Pointer<StatusOrImageInference> status,
  ) {
    return _freeStatusOrImageInference(
      status,
    );
  }

  late final _freeStatusOrImageInferencePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<StatusOrImageInference>)>>(
      'freeStatusOrImageInference');
  late final _freeStatusOrImageInference = _freeStatusOrImageInferencePtr
      .asFunction<void Function(ffi.Pointer<StatusOrImageInference>)>();

  void freeStatusOrLLMInference(
    ffi.Pointer<StatusOrLLMInference> status,
  ) {
    return _freeStatusOrLLMInference(
      status,
    );
  }

  late final _freeStatusOrLLMInferencePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<StatusOrLLMInference>)>>('freeStatusOrLLMInference');
  late final _freeStatusOrLLMInference = _freeStatusOrLLMInferencePtr
      .asFunction<void Function(ffi.Pointer<StatusOrLLMInference>)>();

  void freeStatusOrSpeechToText(
    ffi.Pointer<StatusOrSpeechToText> status,
  ) {
    return _freeStatusOrSpeechToText(
      status,
    );
  }

  late final _freeStatusOrSpeechToTextPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<StatusOrSpeechToText>)>>('freeStatusOrSpeechToText');
  late final _freeStatusOrSpeechToText = _freeStatusOrSpeechToTextPtr
      .asFunction<void Function(ffi.Pointer<StatusOrSpeechToText>)>();

  void freeStatusOrDevices(
    ffi.Pointer<StatusOrDevices> status,
  ) {
    return _freeStatusOrDevices(
      status,
    );
  }

  late final _freeStatusOrDevicesPtr = _lookup<
          ffi.NativeFunction<ffi.Void Function(ffi.Pointer<StatusOrDevices>)>>(
      'freeStatusOrDevices');
  late final _freeStatusOrDevices = _freeStatusOrDevicesPtr
      .asFunction<void Function(ffi.Pointer<StatusOrDevices>)>();

  void freeStatusOrEmbeddings(
    ffi.Pointer<StatusOrEmbeddings> status,
  ) {
    return _freeStatusOrEmbeddings(
      status,
    );
  }

  late final _freeStatusOrEmbeddingsPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<StatusOrEmbeddings>)>>(
      'freeStatusOrEmbeddings');
  late final _freeStatusOrEmbeddings = _freeStatusOrEmbeddingsPtr
      .asFunction<void Function(ffi.Pointer<StatusOrEmbeddings>)>();

  ffi.Pointer<StatusOrImageInference> imageInferenceOpen(
    ffi.Pointer<pkg_ffi.Utf8> model_path,
    ffi.Pointer<pkg_ffi.Utf8> task,
    ffi.Pointer<pkg_ffi.Utf8> device,
    ffi.Pointer<pkg_ffi.Utf8> label_definitions_json,
  ) {
    return _imageInferenceOpen(
      model_path,
      task,
      device,
      label_definitions_json,
    );
  }

  late final _imageInferenceOpenPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrImageInference> Function(
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>)>>('imageInferenceOpen');
  late final _imageInferenceOpen = _imageInferenceOpenPtr.asFunction<
      ffi.Pointer<StatusOrImageInference> Function(
          ffi.Pointer<pkg_ffi.Utf8>,
          ffi.Pointer<pkg_ffi.Utf8>,
          ffi.Pointer<pkg_ffi.Utf8>,
          ffi.Pointer<pkg_ffi.Utf8>)>();

  ffi.Pointer<StatusOrString> imageInferenceInfer(
    CImageInference instance,
    ffi.Pointer<ffi.Uint8> image_data,
    int data_length,
    bool json,
    bool csv,
    bool overlay,
  ) {
    return _imageInferenceInfer(
      instance,
      image_data,
      data_length,
      json,
      csv,
      overlay,
    );
  }

  late final _imageInferenceInferPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrString> Function(
              CImageInference,
              ffi.Pointer<ffi.Uint8>,
              ffi.Size,
              ffi.Bool,
              ffi.Bool,
              ffi.Bool)>>('imageInferenceInfer');
  late final _imageInferenceInfer = _imageInferenceInferPtr.asFunction<
      ffi.Pointer<StatusOrString> Function(
          CImageInference, ffi.Pointer<ffi.Uint8>, int, bool, bool, bool)>();

  ffi.Pointer<StatusOrString> imageInferenceInferRoi(
    CImageInference instance,
    ffi.Pointer<ffi.Uint8> image_data,
    int data_length,
    int x,
    int y,
    int width,
    int height,
    bool json,
    bool csv,
    bool overlay,
  ) {
    return _imageInferenceInferRoi(
      instance,
      image_data,
      data_length,
      x,
      y,
      width,
      height,
      json,
      csv,
      overlay,
    );
  }

  late final _imageInferenceInferRoiPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrString> Function(
              CImageInference,
              ffi.Pointer<ffi.Uint8>,
              ffi.Size,
              ffi.Int,
              ffi.Int,
              ffi.Int,
              ffi.Int,
              ffi.Bool,
              ffi.Bool,
              ffi.Bool)>>('imageInferenceInferRoi');
  late final _imageInferenceInferRoi = _imageInferenceInferRoiPtr.asFunction<
      ffi.Pointer<StatusOrString> Function(CImageInference,
          ffi.Pointer<ffi.Uint8>, int, int, int, int, int, bool, bool, bool)>();

  ffi.Pointer<Status> imageInferenceInferAsync(
    CImageInference instance,
    ffi.Pointer<pkg_ffi.Utf8> id,
    ffi.Pointer<ffi.Uint8> image_data,
    int data_length,
    bool json,
    bool csv,
    bool overlay,
  ) {
    return _imageInferenceInferAsync(
      instance,
      id,
      image_data,
      data_length,
      json,
      csv,
      overlay,
    );
  }

  late final _imageInferenceInferAsyncPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Status> Function(
              CImageInference,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<ffi.Uint8>,
              ffi.Size,
              ffi.Bool,
              ffi.Bool,
              ffi.Bool)>>('imageInferenceInferAsync');
  late final _imageInferenceInferAsync =
      _imageInferenceInferAsyncPtr.asFunction<
          ffi.Pointer<Status> Function(
              CImageInference,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<ffi.Uint8>,
              int,
              bool,
              bool,
              bool)>();

  ffi.Pointer<Status> imageInferenceSetListener(
    CImageInference instance,
    ImageInferenceCallbackFunction callback,
  ) {
    return _imageInferenceSetListener(
      instance,
      callback,
    );
  }

  late final _imageInferenceSetListenerPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Status> Function(CImageInference,
              ImageInferenceCallbackFunction)>>('imageInferenceSetListener');
  late final _imageInferenceSetListener =
      _imageInferenceSetListenerPtr.asFunction<
          ffi.Pointer<Status> Function(
              CImageInference, ImageInferenceCallbackFunction)>();

  ffi.Pointer<Status> imageInferenceOpenCamera(
    CImageInference instance,
    int device,
  ) {
    return _imageInferenceOpenCamera(
      instance,
      device,
    );
  }

  late final _imageInferenceOpenCameraPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Status> Function(
              CImageInference, ffi.Int)>>('imageInferenceOpenCamera');
  late final _imageInferenceOpenCamera = _imageInferenceOpenCameraPtr
      .asFunction<ffi.Pointer<Status> Function(CImageInference, int)>();

  ffi.Pointer<Status> imageInferenceStopCamera(
    CImageInference instance,
  ) {
    return _imageInferenceStopCamera(
      instance,
    );
  }

  late final _imageInferenceStopCameraPtr = _lookup<
          ffi.NativeFunction<ffi.Pointer<Status> Function(CImageInference)>>(
      'imageInferenceStopCamera');
  late final _imageInferenceStopCamera = _imageInferenceStopCameraPtr
      .asFunction<ffi.Pointer<Status> Function(CImageInference)>();

  ffi.Pointer<Status> imageInferenceClose(
    CImageInference instance,
  ) {
    return _imageInferenceClose(
      instance,
    );
  }

  late final _imageInferenceClosePtr = _lookup<
          ffi.NativeFunction<ffi.Pointer<Status> Function(CImageInference)>>(
      'imageInferenceClose');
  late final _imageInferenceClose = _imageInferenceClosePtr
      .asFunction<ffi.Pointer<Status> Function(CImageInference)>();

  ffi.Pointer<Status> imageInferenceSerializeModel(
    ffi.Pointer<pkg_ffi.Utf8> model_path,
    ffi.Pointer<pkg_ffi.Utf8> output_path,
  ) {
    return _imageInferenceSerializeModel(
      model_path,
      output_path,
    );
  }

  late final _imageInferenceSerializeModelPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Status> Function(ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>)>>('imageInferenceSerializeModel');
  late final _imageInferenceSerializeModel =
      _imageInferenceSerializeModelPtr.asFunction<
          ffi.Pointer<Status> Function(
              ffi.Pointer<pkg_ffi.Utf8>, ffi.Pointer<pkg_ffi.Utf8>)>();

  ffi.Pointer<Status> load_font(
    ffi.Pointer<pkg_ffi.Utf8> font_path,
  ) {
    return _load_font(
      font_path,
    );
  }

  late final _load_fontPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Status> Function(
              ffi.Pointer<pkg_ffi.Utf8>)>>('load_font');
  late final _load_font = _load_fontPtr
      .asFunction<ffi.Pointer<Status> Function(ffi.Pointer<pkg_ffi.Utf8>)>();

  ffi.Pointer<StatusOrLLMInference> llmInferenceOpen(
    ffi.Pointer<pkg_ffi.Utf8> model_path,
    ffi.Pointer<pkg_ffi.Utf8> device,
  ) {
    return _llmInferenceOpen(
      model_path,
      device,
    );
  }

  late final _llmInferenceOpenPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrLLMInference> Function(ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>)>>('llmInferenceOpen');
  late final _llmInferenceOpen = _llmInferenceOpenPtr.asFunction<
      ffi.Pointer<StatusOrLLMInference> Function(
          ffi.Pointer<pkg_ffi.Utf8>, ffi.Pointer<pkg_ffi.Utf8>)>();

  ffi.Pointer<Status> llmInferenceSetListener(
    CLLMInference instance,
    LLMInferenceCallbackFunction callback,
  ) {
    return _llmInferenceSetListener(
      instance,
      callback,
    );
  }

  late final _llmInferenceSetListenerPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Status> Function(CLLMInference,
              LLMInferenceCallbackFunction)>>('llmInferenceSetListener');
  late final _llmInferenceSetListener = _llmInferenceSetListenerPtr.asFunction<
      ffi.Pointer<Status> Function(
          CLLMInference, LLMInferenceCallbackFunction)>();

  ffi.Pointer<StatusOrModelResponse> llmInferencePrompt(
    CLLMInference instance,
    ffi.Pointer<pkg_ffi.Utf8> message,
    double temperature,
    double top_p,
  ) {
    return _llmInferencePrompt(
      instance,
      message,
      temperature,
      top_p,
    );
  }

  late final _llmInferencePromptPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrModelResponse> Function(
              CLLMInference,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Float,
              ffi.Float)>>('llmInferencePrompt');
  late final _llmInferencePrompt = _llmInferencePromptPtr.asFunction<
      ffi.Pointer<StatusOrModelResponse> Function(
          CLLMInference, ffi.Pointer<pkg_ffi.Utf8>, double, double)>();

  ffi.Pointer<Status> llmInferenceClearHistory(
    CLLMInference instance,
  ) {
    return _llmInferenceClearHistory(
      instance,
    );
  }

  late final _llmInferenceClearHistoryPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Status> Function(CLLMInference)>>(
          'llmInferenceClearHistory');
  late final _llmInferenceClearHistory = _llmInferenceClearHistoryPtr
      .asFunction<ffi.Pointer<Status> Function(CLLMInference)>();

  ffi.Pointer<Status> llmInferenceForceStop(
    CLLMInference instance,
  ) {
    return _llmInferenceForceStop(
      instance,
    );
  }

  late final _llmInferenceForceStopPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Status> Function(CLLMInference)>>(
          'llmInferenceForceStop');
  late final _llmInferenceForceStop = _llmInferenceForceStopPtr
      .asFunction<ffi.Pointer<Status> Function(CLLMInference)>();

  ffi.Pointer<StatusOrBool> llmInferenceHasChatTemplate(
    CLLMInference instance,
  ) {
    return _llmInferenceHasChatTemplate(
      instance,
    );
  }

  late final _llmInferenceHasChatTemplatePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<StatusOrBool> Function(CLLMInference)>>(
      'llmInferenceHasChatTemplate');
  late final _llmInferenceHasChatTemplate = _llmInferenceHasChatTemplatePtr
      .asFunction<ffi.Pointer<StatusOrBool> Function(CLLMInference)>();

  ffi.Pointer<Status> llmInferenceClose(
    CLLMInference instance,
  ) {
    return _llmInferenceClose(
      instance,
    );
  }

  late final _llmInferenceClosePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Status> Function(CLLMInference)>>(
          'llmInferenceClose');
  late final _llmInferenceClose = _llmInferenceClosePtr
      .asFunction<ffi.Pointer<Status> Function(CLLMInference)>();

  ffi.Pointer<StatusOrTTIInference> ttiInferenceOpen(
    ffi.Pointer<pkg_ffi.Utf8> model_path,
    ffi.Pointer<pkg_ffi.Utf8> device,
  ) {
    return _ttiInferenceOpen(
      model_path,
      device,
    );
  }

  late final _ttiInferenceOpenPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrTTIInference> Function(ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>)>>('ttiInferenceOpen');
  late final _ttiInferenceOpen = _ttiInferenceOpenPtr.asFunction<
      ffi.Pointer<StatusOrTTIInference> Function(
          ffi.Pointer<pkg_ffi.Utf8>, ffi.Pointer<pkg_ffi.Utf8>)>();

  ffi.Pointer<StatusOrTTIModelResponse> ttiInferencePrompt(
    CTTIInference instance,
    ffi.Pointer<pkg_ffi.Utf8> message,
    int width,
    int height,
    int rounds,
  ) {
    return _ttiInferencePrompt(
      instance,
      message,
      width,
      height,
      rounds,
    );
  }

  late final _ttiInferencePromptPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrTTIModelResponse> Function(
              CTTIInference,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Int,
              ffi.Int,
              ffi.Int)>>('ttiInferencePrompt');
  late final _ttiInferencePrompt = _ttiInferencePromptPtr.asFunction<
      ffi.Pointer<StatusOrTTIModelResponse> Function(
          CTTIInference, ffi.Pointer<pkg_ffi.Utf8>, int, int, int)>();

  ffi.Pointer<StatusOrBool> ttiInferenceHasModelIndex(
    CTTIInference instance,
  ) {
    return _ttiInferenceHasModelIndex(
      instance,
    );
  }

  late final _ttiInferenceHasModelIndexPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<StatusOrBool> Function(CTTIInference)>>(
      'ttiInferenceHasModelIndex');
  late final _ttiInferenceHasModelIndex = _ttiInferenceHasModelIndexPtr
      .asFunction<ffi.Pointer<StatusOrBool> Function(CTTIInference)>();

  ffi.Pointer<Status> ttiInferenceClose(
    CLLMInference instance,
  ) {
    return _ttiInferenceClose(
      instance,
    );
  }

  late final _ttiInferenceClosePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Status> Function(CLLMInference)>>(
          'ttiInferenceClose');
  late final _ttiInferenceClose = _ttiInferenceClosePtr
      .asFunction<ffi.Pointer<Status> Function(CLLMInference)>();

  ffi.Pointer<StatusOrGraphRunner> graphRunnerOpen(
    ffi.Pointer<pkg_ffi.Utf8> graph,
  ) {
    return _graphRunnerOpen(
      graph,
    );
  }

  late final _graphRunnerOpenPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrGraphRunner> Function(
              ffi.Pointer<pkg_ffi.Utf8>)>>('graphRunnerOpen');
  late final _graphRunnerOpen = _graphRunnerOpenPtr.asFunction<
      ffi.Pointer<StatusOrGraphRunner> Function(ffi.Pointer<pkg_ffi.Utf8>)>();

  ffi.Pointer<Status> graphRunnerQueueImage(
    CGraphRunner instance,
    ffi.Pointer<pkg_ffi.Utf8> name,
    int timestamp,
    ffi.Pointer<ffi.Uint8> image_data,
    int data_length,
  ) {
    return _graphRunnerQueueImage(
      instance,
      name,
      timestamp,
      image_data,
      data_length,
    );
  }

  late final _graphRunnerQueueImagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Status> Function(
              CGraphRunner,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Int,
              ffi.Pointer<ffi.Uint8>,
              ffi.Size)>>('graphRunnerQueueImage');
  late final _graphRunnerQueueImage = _graphRunnerQueueImagePtr.asFunction<
      ffi.Pointer<Status> Function(CGraphRunner, ffi.Pointer<pkg_ffi.Utf8>, int,
          ffi.Pointer<ffi.Uint8>, int)>();

  ffi.Pointer<Status> graphRunnerQueueSerializationOutput(
    CGraphRunner instance,
    ffi.Pointer<pkg_ffi.Utf8> name,
    int timestamp,
    bool json,
    bool csv,
    bool overlay,
  ) {
    return _graphRunnerQueueSerializationOutput(
      instance,
      name,
      timestamp,
      json,
      csv,
      overlay,
    );
  }

  late final _graphRunnerQueueSerializationOutputPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<Status> Function(
              CGraphRunner,
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Int,
              ffi.Bool,
              ffi.Bool,
              ffi.Bool)>>('graphRunnerQueueSerializationOutput');
  late final _graphRunnerQueueSerializationOutput =
      _graphRunnerQueueSerializationOutputPtr.asFunction<
          ffi.Pointer<Status> Function(CGraphRunner, ffi.Pointer<pkg_ffi.Utf8>,
              int, bool, bool, bool)>();

  ffi.Pointer<StatusOrString> graphRunnerGet(
    CGraphRunner instance,
  ) {
    return _graphRunnerGet(
      instance,
    );
  }

  late final _graphRunnerGetPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<StatusOrString> Function(CGraphRunner)>>(
      'graphRunnerGet');
  late final _graphRunnerGet = _graphRunnerGetPtr
      .asFunction<ffi.Pointer<StatusOrString> Function(CGraphRunner)>();

  ffi.Pointer<Status> graphRunnerStop(
    CGraphRunner instance,
  ) {
    return _graphRunnerStop(
      instance,
    );
  }

  late final _graphRunnerStopPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Status> Function(CGraphRunner)>>(
          'graphRunnerStop');
  late final _graphRunnerStop = _graphRunnerStopPtr
      .asFunction<ffi.Pointer<Status> Function(CGraphRunner)>();

  ffi.Pointer<StatusOrSentenceTransformer> sentenceTransformerOpen(
    ffi.Pointer<pkg_ffi.Utf8> model_path,
    ffi.Pointer<pkg_ffi.Utf8> device,
  ) {
    return _sentenceTransformerOpen(
      model_path,
      device,
    );
  }

  late final _sentenceTransformerOpenPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrSentenceTransformer> Function(
              ffi.Pointer<pkg_ffi.Utf8>,
              ffi.Pointer<pkg_ffi.Utf8>)>>('sentenceTransformerOpen');
  late final _sentenceTransformerOpen = _sentenceTransformerOpenPtr.asFunction<
      ffi.Pointer<StatusOrSentenceTransformer> Function(
          ffi.Pointer<pkg_ffi.Utf8>, ffi.Pointer<pkg_ffi.Utf8>)>();

  ffi.Pointer<StatusOrEmbeddings> sentenceTransformerGenerate(
    CSentenceTransformer instance,
    ffi.Pointer<pkg_ffi.Utf8> prompt,
  ) {
    return _sentenceTransformerGenerate(
      instance,
      prompt,
    );
  }

  late final _sentenceTransformerGeneratePtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<StatusOrEmbeddings> Function(CSentenceTransformer,
              ffi.Pointer<pkg_ffi.Utf8>)>>('sentenceTransformerGenerate');
  late final _sentenceTransformerGenerate =
      _sentenceTransformerGeneratePtr.asFunction<
          ffi.Pointer<StatusOrEmbeddings> Function(
              CSentenceTransformer, ffi.Pointer<pkg_ffi.Utf8>)>();

  ffi.Pointer<Status> sentenceTransformerClose(
    CSentenceTransformer instance,
  ) {
    return _sentenceTransformerClose(
      instance,
    );
  }

  late final _sentenceTransformerClosePtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<Status> Function(CSentenceTransformer)>>(
      'sentenceTransformerClose');
  late final _sentenceTransformerClose = _sentenceTransformerClosePtr
      .asFunction<ffi.Pointer<Status> Function(CSentenceTransformer)>();

  ffi.Pointer<StatusOrDevices> getAvailableDevices() {
    return _getAvailableDevices();
  }

  late final _getAvailableDevicesPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<StatusOrDevices> Function()>>(
          'getAvailableDevices');
  late final _getAvailableDevices = _getAvailableDevicesPtr
      .asFunction<ffi.Pointer<StatusOrDevices> Function()>();

  ffi.Pointer<Status> handle_exceptions() {
    return _handle_exceptions();
  }

  late final _handle_exceptionsPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<Status> Function()>>(
          'handle_exceptions');
  late final _handle_exceptions =
      _handle_exceptionsPtr.asFunction<ffi.Pointer<Status> Function()>();
}

enum StatusEnum {
  OkStatus(0),
  ErrorStatus(-1),
  OpenVINOError(-2),
  ModelTypeNotSupplied(-10),
  ModelTypeNotSupported(-11),
  TaskTypeNotSupported(-12),
  OverlayUnableToLoadFont(-20),
  OverlayLabelNotFound(-21),
  OverlayNoOutputSelected(-22),
  FontLoadError(-30),
  InferenceAnomalyLabelsIncorrect(-40),
  CameraNotOpenend(-50),
  MediapipeNextPackageFailure(-61),
  MediapipeGraphError(-62),
  LLMNoMetricsYet(-71),
  SpeechToTextError(-80),
  SpeechToTextFileNotOpened(-81),
  SpeechToTextChunkHasNoData(-82),
  SpeechToTextChunkOutOfBounds(-83);

  final int value;
  const StatusEnum(this.value);

  static StatusEnum fromValue(int value) => switch (value) {
        0 => OkStatus,
        -1 => ErrorStatus,
        -2 => OpenVINOError,
        -10 => ModelTypeNotSupplied,
        -11 => ModelTypeNotSupported,
        -12 => TaskTypeNotSupported,
        -20 => OverlayUnableToLoadFont,
        -21 => OverlayLabelNotFound,
        -22 => OverlayNoOutputSelected,
        -30 => FontLoadError,
        -40 => InferenceAnomalyLabelsIncorrect,
        -50 => CameraNotOpenend,
        -61 => MediapipeNextPackageFailure,
        -62 => MediapipeGraphError,
        -71 => LLMNoMetricsYet,
        -80 => SpeechToTextError,
        -81 => SpeechToTextFileNotOpened,
        -82 => SpeechToTextChunkHasNoData,
        -83 => SpeechToTextChunkOutOfBounds,
        _ => throw ArgumentError("Unknown value for StatusEnum: $value"),
      };
}

final class Metrics extends ffi.Struct {
  @ffi.Float()
  external double load_time;

  @ffi.Float()
  external double generate_time;

  @ffi.Float()
  external double tokenization_time;

  @ffi.Float()
  external double detokenization_time;

  @ffi.Float()
  external double ttft;

  @ffi.Float()
  external double tpot;

  @ffi.Float()
  external double throughput;

  @ffi.Int()
  external int number_of_generated_tokens;

  @ffi.Int()
  external int number_of_input_tokens;
}

final class TTIMetrics extends ffi.Struct {
  @ffi.Float()
  external double load_time;

  @ffi.Float()
  external double generate_time;
}

final class StringWithMetrics extends ffi.Struct {
  external ffi.Pointer<pkg_ffi.Utf8> string;

  external TTIMetrics metrics;
}

final class Device extends ffi.Struct {
  external ffi.Pointer<pkg_ffi.Utf8> id;

  external ffi.Pointer<pkg_ffi.Utf8> name;
}

final class Status extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;
}

final class StatusOrString extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external ffi.Pointer<pkg_ffi.Utf8> value;
}

final class StatusOrBool extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  @ffi.Bool()
  external bool value;
}

final class StatusOrInt extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  @ffi.Int()
  external int value;
}

final class StatusOrImageInference extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external CImageInference value;
}

typedef CImageInference = ffi.Pointer<ffi.Void>;

final class StatusOrGraphRunner extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external CGraphRunner value;
}

typedef CGraphRunner = ffi.Pointer<ffi.Void>;

final class StatusOrSentenceTransformer extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external CSentenceTransformer value;
}

typedef CSentenceTransformer = ffi.Pointer<ffi.Void>;

final class StatusOrSpeechToText extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external CSpeechToText value;
}

typedef CSpeechToText = ffi.Pointer<ffi.Void>;

final class StatusOrLLMInference extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external CLLMInference value;
}

typedef CLLMInference = ffi.Pointer<ffi.Void>;

final class StatusOrTTIInference extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external CLLMInference value;
}

final class StatusOrModelResponse extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external Metrics metrics;

  external ffi.Pointer<pkg_ffi.Utf8> value;
}

final class StatusOrTTIModelResponse extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external TTIMetrics metrics;

  external ffi.Pointer<pkg_ffi.Utf8> value;
}

final class StatusOrEmbeddings extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external ffi.Pointer<ffi.Float> value;

  @ffi.Int()
  external int size;
}

final class StatusOrDevices extends ffi.Struct {
  @ffi.Int()
  external int status;

  external ffi.Pointer<pkg_ffi.Utf8> message;

  external ffi.Pointer<Device> value;

  @ffi.Int()
  external int size;
}

typedef ImageInferenceCallbackFunction
    = ffi.Pointer<ffi.NativeFunction<ImageInferenceCallbackFunctionFunction>>;
typedef ImageInferenceCallbackFunctionFunction = ffi.Void Function(
    ffi.Pointer<StatusOrString>);
typedef DartImageInferenceCallbackFunctionFunction = void Function(
    ffi.Pointer<StatusOrString>);
typedef LLMInferenceCallbackFunction
    = ffi.Pointer<ffi.NativeFunction<LLMInferenceCallbackFunctionFunction>>;
typedef LLMInferenceCallbackFunctionFunction = ffi.Void Function(
    ffi.Pointer<StatusOrString>);
typedef DartLLMInferenceCallbackFunctionFunction = void Function(
    ffi.Pointer<StatusOrString>);
typedef CTTIInference = ffi.Pointer<ffi.Void>;
