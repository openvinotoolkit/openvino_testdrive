/*
 * Copyright (c) 2024 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:inference/annotation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttClientWrapper {
  final MqttServerClient client;
  final String topic;
  final bool retain;

  const MqttClientWrapper({required this.client, required this.topic, required this.retain});

  void publish(String data) {
    if (client.connectionStatus?.state == MqttConnectionState.connected){
      final builder = MqttClientPayloadBuilder();
      builder.addString(data);
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!, retain: retain);
    }
  }

  void disconnect() {
    client.disconnect();
  }
}

class AutomationOptions extends StatefulWidget {
  final Stream<ImageInferenceResult> stream;

  const AutomationOptions({required this.stream, super.key});

  @override
  State<AutomationOptions> createState() => _AutomationOptionsState();
}

class _AutomationOptionsState extends State<AutomationOptions> {

  MqttClientWrapper? client;

  void publishToMqtt(ImageInferenceResult result) {
    if (client != null && result.json != null) {
      client!.publish(jsonEncode(result.json!));
    }
  }

  @override
  void initState() {
    super.initState();
    widget.stream.listen(publishToMqtt);
  }

  @override
  void dispose() {
    super.dispose();
    client?.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          style: ButtonStyle(
            shape:WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
              side:  const BorderSide(color: Color(0XFF545454)),
            )),
          ),
          onPressed: () async {
            print("open dialog");
            if (client != null) {
              client?.disconnect();
              setState(() {
                  client = null;
              });
            } else {
              final newClient = await showDialog<MqttClientWrapper?>(
                context: context,
                builder: (context) => AutomationOptionsDialog()
              );

              print("New client: $newClient");

              setState(() {
                client = newClient;
              });
            }
          },
          child: Text((client == null ? "Connect to MQTT Broker": "Disconnect")),
        ),
      ],
    );
  }
}

class AutomationOptionsDialog extends StatefulWidget {
  const AutomationOptionsDialog({super.key});

  @override
  State<AutomationOptionsDialog> createState() => _AutomationOptionsDialogState();
}

class _AutomationOptionsDialogState extends State<AutomationOptionsDialog> {
  final TextEditingController _hostController = TextEditingController(text: "");
  final TextEditingController _portController = TextEditingController(text: "1883");
  final TextEditingController _usernameController = TextEditingController(text: "");
  final TextEditingController _passwordController = TextEditingController(text: "");
  final TextEditingController _topicController = TextEditingController(text: "");

  bool retain = false;
  bool loading = false;

  List<String> errors = [];

  void connect() async {
      final client = MqttServerClient.withPort(_hostController.text, "test drive", int.parse(_portController.text));
      setState(() { loading = true; errors = []; });
      client.connect(_usernameController.text, _passwordController.text)
        .then((status) {
          setState(() { loading = false; });
          print(status.toString());
          if (status?.state == MqttConnectionState.connected) {
            if (mounted) {
              Navigator.pop(context, MqttClientWrapper(client: client, retain: retain, topic: _topicController.text));
              return;
            }
          }
          MqttUtilities.asyncSleep(3).then((_) => client.disconnect); // ensure the client is disconnected on error
        })
       .onError((e, stacktrace) {
          setState(() {
            errors.add(e.toString());
            loading = false;
          });
          print("Error: $e: \n $stacktrace") ;
       });
  }

  @override
  void dispose() {
    super.dispose();

    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _topicController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(
        maxWidth: 756,
        maxHeight: 500,
      ),
      title: const Text('Connect to MQTT Broker'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 600,
                      child: InfoLabel(
                        label: "Host",
                        child: TextBox(
                          placeholder: "",
                          controller: _hostController,
                          onChanged: (_) {},
                        )
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: InfoLabel(
                        label: "Port",
                        child: TextBox(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                          placeholder: "",
                          controller: _portController,
                          onChanged: (_) {},
                        )
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                InfoLabel(
                  label: "Username",
                  child: TextBox(
                    placeholder: "",
                    controller: _usernameController,
                    onChanged: (_) {},
                  )
                ),
                SizedBox(height: 10),
                InfoLabel(
                  label: "Password",
                  child: TextBox(
                    placeholder: "",
                    controller: _passwordController,
                    onChanged: (_) {},
                  )
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 600,
                      child: InfoLabel(
                        label: "Topic",
                        child: TextBox(
                          placeholder: "",
                          controller: _topicController,
                          onChanged: (_) {},
                        )
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: InfoLabel(
                        label: "Retain",
                        child: ToggleSwitch(
                          onChanged: (v) { setState(() { retain = v; });},
                          checked: retain,
                        ),
                      ),
                    ),

                  ],
                )
              ],
            ),
          ),
          Column(
            children: <Widget>[
              for (var error in errors) Text(error)
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 500,
                child: (loading ? ProgressBar() : Container())
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: connect,
                    child: const Text("Connect"),
                  ),
                ],
              ),
            ],
          )
        ],
      )
    );
  }
}
