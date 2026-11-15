# family_scheduling
A simple app to schedule for your family across services.

The spec is [docs/design.md](docs/design.md).

## Layout

- `App/`: the SwiftUI app target.
- `Packages/FamilyCore/`: app logic in plain Swift with no UI. Its tests run on macOS and Linux.
- `project.yml`: the Xcode project spec. The `.xcodeproj` is generated from it and is not checked in.

## Build

Requires Xcode 16 or later and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
open FamilyScheduling.xcodeproj
```

Core tests without Xcode:

```sh
swift test --package-path Packages/FamilyCore
```

## License

Copyright (C) 2026 Glen Ferguson

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License version 3 as published by the Free Software Foundation. See [LICENSE](LICENSE).

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
