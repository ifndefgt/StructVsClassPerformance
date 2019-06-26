# Struct vs Class Performance

This is a POC for my Medium article [Stop Using Structs!!](https://medium.com/commencis/stop-using-structs-e1be9a86376f) which compares performance characteristics of structs and classes, with a view to show where structs are misused and contain other reference types.

## Warning

The article and POC was published for Swift version 4.0 and this POC is valid for Swift 4.0 and -very likely- previous versions. But with Swift 4.1 and 4.2 Apple changed calling convention and ownership model and these changes directly effect language's performance characteristics.

Therefore **the results of this POC may vary and is not perfectly valid for Swift versions after 4.0.**

## Results

I tested each configuration with 100 iterations, results are averages in milliseconds, smaller is better :)

| Optimization Level   | Class           | Struct  | Ratio|
| -------------- |:-------------:| :-----:|-----:|
| -Onone (unoptimized)          | 47926 | 89411 | ~1.86x    |
| -O (single file optimization) | 5981  | 16503 | ~2.76x    |
| -O -whole-module-optimization | 372   | 24809 | ~67x      |

## Requirements

- Xcode 9.0
- Swift 4.0

## Running

```bash
xcrun -sdk macosx swiftc -O -whole-module-optimization StructvsClassPerformance.swift
./StructvsClassPerformance
```

## License

Licensed under the terms of the MIT license. See the [LICENSE](https://github.com/ifndefgt/StructvsClassPerformance/blob/master/LICENSE) file.

