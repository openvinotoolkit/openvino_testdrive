We appreciate any contribution to the OpenVINO Test Drive, whether it's in the form of a
Pull Request, Feature Request or general comment/issue that you found. For feature
requests and issues, please feel free to create a GitHub Issue in this repository.

# Development and pull requests
To set up your development environment, please follow the steps below:

1. Fork the repo.
2. Setup environment using instructions in [readme](README.md#Build)
3. Create your branch based off the `main` branch.
4. Setup bindings and put them in `./bindings`
    1. By downloading the latest bindings from the release
    2. By building it yourself. Follow the instructions in 
    [bindings readme](openvino_bindings/README.md#how-to-build)
5. Run `flutter run`

You should now be ready to make changes and create a Pull Request!

## Updating model manifest

OpenVINO Test Drive shows more information on the model than the huggingface API exposes. In order to show this information we use a model manifest.
You can update this information by running: `dart scripts/create_manifest > assets/manifest.json`.

Not all information can be automatically found. So a couple of manual steps might be required.
