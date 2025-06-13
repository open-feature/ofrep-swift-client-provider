# Openfeature Swift Client Provider

This repository contains the OFREP *(openfeature remote evaluation protocol)* Swift OpenFeature provider for accessing your feature flags with the [OFREP protocol](https://github.com/open-feature/protocol/).

In conjuction with the [OpenFeature SDK](https://openfeature.dev/docs/reference/concepts/provider) you will be able to evaluate your feature flags in your **iOS**/**tvOS**/**macOS**/**watchOS** applications.

## Dependency Setup

### Swift Package Manager

In the dependencies section of `Package.swift` add:
```swift
.package(url: "https://github.com/open-feature/ofrep-swift-client-provider", from: "0.1.0")
```

and in the target dependencies section add:
```swift
.product(name: "OFREPClientProvider", package: "ofrep-swift-client-provider"),  
```

### Xcode Dependencies

You have two options, both start from File > Add Packages... in the code menu.

First, ensure you have your GitHub account added as an option (+ > Add Source Control Account...). You will need to create a [Personal Access Token](https://github.com/settings/tokens) with the permissions defined in the Xcode interface.

1. Add as a remote repository
    * Search for `git@github.com:open-feature/ofrep-swift-client-provider.git` and click "Add Package"
2. Clone the repository locally
    * Clone locally using your preferred method
    * Use the "Add Local..." button to select the local folder

**Note:** Option 2 is only recommended if you are making changes to the SDK. You will also need to add the relevant OpenFeature SDK dependency manually.

## Getting started

### Initialize the provider

OFREP  provider needs to be created and then set in the global OpenFeatureAPI. 

The only required option to create an `OfrepClientProvider` is the URL to your OFREP API instance.

```swift
import OFREPClientProvider
import OpenFeature


let options = OfrepProviderOptions(endpoint: "https://your_domain.io")
let provider = OfrepClientProvider(options: options)

let evaluationContext = MutableContext(targetingKey: "myTargetingKey", structure: MutableStructure())
OpenFeatureAPI.shared.setProvider(provider: provider, initialContext: evaluationContext)
```

The evaluation context is the way for the client to specify contextual data that the flag management system uses to evaluate the feature flags, it allows to define rules on the flag.

The `setProvider()` function is synchronous and returns immediately, however this does not mean that the provider is ready to be used. An asynchronous network request to the flag management system to fetch all the flags configured for your application must be completed by the provider first. The provider will then emit a `READY` event indicating you can start resolving flags.

If you prefer to wait until the fetch is done you can use the `async/await` compatible API available for waiting the Provider to become ready:

```swift
await OpenFeatureAPI.shared.setProviderAndWait(provider: provider)
```

### Update the Evaluation Context

During the usage of your application it may appears that the `EvaluationContext` should be updated. For example if a not logged in user, authentify himself you will probably have to update the evaluation context.

```swift
let ctx = MutableContext(targetingKey: "myNewTargetingKey", structure: MutableStructure())
OpenFeatureAPI.shared.setEvaluationContext(evaluationContext: ctx)
```

`setEvaluationContext()` is a synchronous function similar to `setProvider()` and will fetch the new version of the feature flags based on this new `EvaluationContext`.

### Evaluate a feature flag
The client is used to retrieve values for the current `EvaluationContext`. For example, retrieving a boolean value for the flag **"my-flag"**:

```swift
let client = OpenFeatureAPI.shared.getClient()
let result = client.getBooleanValue(key: "my-flag", defaultValue: false)
```

OFREP supports different all OpenFeature supported types of feature flags, it means that you can use all the accessor directly
```swift
// Bool
client.getBooleanValue(key: "my-flag", defaultValue: false)

// String
client.getStringValue(key: "my-flag", defaultValue: "default")

// Integer
client.getIntegerValue(key: "my-flag", defaultValue: 1)

// Double
client.getDoubleValue(key: "my-flag", defaultValue: 1.1)

// Object
client.getObjectValue(key: "my-flag", defaultValue: Value.structure(["key":Value.integer("1234")])
```

> [!NOTE]  
> If you add a new flag in your flag management system, expect some delay before having it available for the provider.
> Refreshing the cache from remote happens when setting a new provider and/or evaluation context in the global OpenFeatureAPI, but also when a configuration change is detected during the polling.

### Handling Provider Events

When setting the provider or the context *(via `setEvaluationContext()` or `setProvider()`)* some events can be triggered to know the state of the provider.

To listen to them you can add an event handler via the `OpenFeatureAPI` shared instance:

```swift
OpenFeatureAPI.shared.observe().sink { event in
    if event == .error {
        // An error has been emitted
    }
}
```

#### Existing type of events are:
- `.ready`: Provider is ready.
- `.error`: Provider in error.
- `.configurationChanged`: Configuration has changed in the flag management system.
- `.PROVIDER_STALE`: Provider has not the latest version of the feature flags.
- `.notReady`: Provider is not ready to evaluate the feature flags.
