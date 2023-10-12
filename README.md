# Why Not SwiftUI!

A collection of Swift, SwiftUI and iOS goodies.

Feel free to request features or suggestions for improvements.

[![Developer](https://img.shields.io/badge/Maintainer-ImaginativeShohag-green)](https://github.com/ImaginativeShohag)
[![Developer](https://img.shields.io/badge/-buy_me_a_coffee-gray?logo=buy-me-a-coffee)](https://www.buymeacoffee.com/ImShohag)

## What we have hare!

### Jailbroken checker

Check for device is jail-broken status.

<img src="images/jailbroken-checker.png" width=250/>

### Notification

Example for showing local notifications.

<img src="images/sample-notification.png" width=250>

### Accessibility Example

Example of common accessibility modifiers.

### Bottom Nav vs Side Bar

A simple example to demonstrate separate views for iPhone and iPad. Users will see the bottom nav on iPhone and Sidebar on iPad.

| <img src="images/bottom-nav.png" width=165/> | <img src="images/side-bar.png" width=250/> |
| :-: | :-: |

### Component: `CoolProgress`

<img src="images/cool-progress.gif" width=250/>

### Component: `CoolToast`

A cool "Android Toast" like implementation for SwiftUI.

<img src="images/cool-toast.gif" width=250/>

### Component: `ImageViewCapturer`: Media Capture & Select Example

Example for capturing image, recording video and selecting media from library.

<img src="images/media-capture-select.gif" width=250/>

### Component: `LabelToggle`

A custom Toggle like component with inside label support.

<img src="images/label-toggle.gif" width=250/>

### MetricKit crash report example

On going...

### Component: `NativeAlert`

SwiftUI modifier for `UIAlertController`. This is created to be able to change the Alert button colors.

<img src="images/native-alert.gif" width=250/>

### Component: `RingChart`

<img src="images/ring-chart.gif" width=250/>

### Component: `CustomTextFieldView` with validation example

<img src="images/custom-text-field.gif" width=250/>

### Typography: Custom Font

Add fonts to the [project](https://github.com/ImaginativeShohag/Why-Not-SwiftUI/tree/main/Why%20Not%20SwiftUI/Resources/Fonts), add the fonts name to the [plist](https://github.com/ImaginativeShohag/Why-Not-SwiftUI/blob/main/Why-Not-SwiftUI-Info.plist) file. Finally, use [`fontStyle(size:weight:)`](https://github.com/ImaginativeShohag/Why-Not-SwiftUI/blob/main/Why%20Not%20SwiftUI/Utils/Typography.swift) to set fonts.

<img src="images/typography.png" width=250/>

### Date Format Playground

Total 3 playground related to date formatting. Inspired by [NSDateFormatter.com](https://nsdateformatter.com).

| <img src="images/date-format-1.png" width=250/> | <img src="images/date-format-2.png" width=250/> | <img src="images/date-format-3.png" width=250/> |
| :-: | :-: | :-: |

## Others

- Example to create preview with mock Models and ViewModels (`ObservableObject`). (See **Media Capture & Select** Example)
- Macro example (see `packages/URLMacro` directory)
    - Resources
        - [Swift Macros: Extend Swift with New Kinds of Expressions](https://www.avanderlee.com/swift/macros/)

## TODO

- [ ] MetricKit crash report example (WIP)
- [ ] Full app custom font
- [ ] Custom Sidebar: Finalize it (WIP)
- [ ] Custom Build variant
- [ ] Add documentation to the extensions
- [ ] Moya finalize
- [ ] Home list multiple accent color
- [ ] Use system font styles
- [ ] CMS Module
- [ ] System UI Components Collection
    - [ ] [https://developer.apple.com/documentation/swiftui/grid](Grid)
- [ ] Navigation system update
- [ ] SF Symbol animation ((How to animate SF Symbols)[https://www.hackingwithswift.com/quick-start/swiftui/how-to-animate-sf-symbols])
- [ ] Migrate to Tuist

## Extensions

### `String` (`String+.swift`)

- `md5()`
- `fileName()`
- `fileExtension()`
- `isValidEmail()`
- `isBlank()`

### `Array` (`Array+.swift`)

- `commaSeparatedString(emptyValue:) -> String` : Combine string array separated by a comma.

### `UIImage` (`UIImage+.swift`)

- `fileSize() -> Int` : The file size in KB.

### `URL` (`URL+.swift`)

- `fileSize() -> Int` : The file size in KB.

# Macro

## Pre-built Swift macros:

- `#warning("message")`
- `#line`
- `#function`
- `#file`
- `#column`
- `#id` ... `#endif`
- `#filePath`
- `#colorLiteral(red: 0.292, green: 0.081, blue: 0.6, alpha: 255)`

## Licence

```
Copyright 2021 Md. Mahmudul Hasan Shohagm

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
