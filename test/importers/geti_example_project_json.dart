final cattleDetectionDeploymentJson = {
   "id": "662aac1fedcb02d8b6323097",
   "name": "Cattle detection",
   "creation_time": "2024-04-25T19:16:51.714000+00:00",
   "creator_id": "c2457771-24ea-4e37-aff1-64ea6314e91e",
   "pipeline": {
      "tasks": [
         {
            "id": "662aac23edcb02d8b6323098",
            "title": "Dataset",
            "task_type": "dataset"
         },
         {
            "id": "662aac23edcb02d8b632309a",
            "title": "Detection",
            "task_type": "detection",
            "labels": [
               {
                  "id": "662aac23edcb02d8b632309c",
                  "name": "Cow",
                  "is_anomalous": false,
                  "color": "#ff7d00ff",
                  "hotkey": "CTRL+2",
                  "is_empty": false,
                  "group": "Detection labels",
                  "parent_id": null
               },
               {
                  "id": "662aac23edcb02d8b632309d",
                  "name": "Sheep",
                  "is_anomalous": false,
                  "color": "#076984ff",
                  "hotkey": "CTRL+1",
                  "is_empty": false,
                  "group": "Detection labels",
                  "parent_id": null
               },
               {
                  "id": "662aac23edcb02d8b63230a1",
                  "name": "No object",
                  "is_anomalous": false,
                  "color": "#000000ff",
                  "hotkey": "",
                  "is_empty": true,
                  "group": "No object",
                  "parent_id": null
               }
            ],
            "label_schema_id": "662aac23edcb02d8b63230a3"
         }
      ],
      "connections": [
         {
            "from": "662aac23edcb02d8b6323098",
            "to": "662aac23edcb02d8b632309a"
         }
      ]
   },
   "thumbnail": "/api/v1/organizations/44937648-d420-49a4-a51b-efd032d6aa10/workspaces/143e9c55-4834-4def-bdfc-ec34a282d439/projects/662aac1fedcb02d8b6323097/thumbnail",
   "performance": {
      "score": 0.8999999999999999,
      "task_performances": [
         {
            "task_id": "662aac23edcb02d8b632309a",
            "score": {
               "value": 0.8999999999999999,
               "metric_type": "f-measure"
            }
         }
      ]
   },
   "storage_info": {},
   "datasets": [
      {
         "id": "662aac23edcb02d8b632309e",
         "name": "Dataset",
         "use_for_training": true,
         "creation_time": "2024-04-25T19:16:51.700000+00:00"
      }
   ]
};

final cattleDetectionModelJson = {
   "id": "665073da9c0b2d712b5447a3",
   "name": "MobileNetV2-ATSS OpenVINO INT8",
   "version": 1,
   "creation_date": "2024-05-24T11:02:50.102000+00:00",
   "model_format": "OpenVINO",
   "precision": [
      "INT8"
   ],
   "has_xai_head": false,
   "target_device": "CPU",
   "target_device_type": null,
   "performance": {
      "score": 0.7999999999999999
   },
   "size": 4420720,
   "latency": 0,
   "fps_throughput": 0,
   "optimization_type": "POT",
   "optimization_objectives": {},
   "model_status": "SUCCESS",
   "configurations": [
      {
         "name": "sample_size",
         "value": 300
      }
   ],
   "previous_revision_id": "665073da9c0b2d712b5447a2",
   "previous_trained_revision_id": "662aad1b72a5d0929de710c0",
   "optimization_methods": [
      "QUANTIZATION"
   ]
};
