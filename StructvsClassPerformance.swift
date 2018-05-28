//
//  StructvsClassPerformance.swift
//
//  MIT License
//  Copyright (c) 2018 Gokhan Topcu
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import Darwin

/// xcrun -sdk macosx swiftc -O -whole-module-optimization StructvsClassPerformance.swift

typealias MachTime = UInt64

enum MachTimeUtils {

    /// - Returns: Current mach time of execution
    static func now() -> MachTime {
        return mach_absolute_time()
    }

    /// Finds time difference between two mach time
    ///
    /// - Parameters:
    ///   - start: Starting mach time
    ///   - end: Ending mach time
    /// - Returns: Time difference in milliseconds
    static func milliSecondsBetween(start: MachTime, end: MachTime) -> MachTime {
        return MachTime(convertToNanoSeconds(end - start) / 1e6)
    }

    /// Converts given mach time to nanoseconds
    ///
    /// - Parameter time: Mach time to convert
    /// - Returns: Time in naneseconds
    static func convertToNanoSeconds(_ time: MachTime) -> Double {
        var timeBase = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&timeBase)
        return Double(time) * Double(timeBase.numer) / Double(timeBase.denom)
    }
}

class DummyClass
{
    var flag: Bool
    var count: Int
    init(flag: Bool, count: Int)
    {
        self.flag = flag
        self.count = count
    }
}

class ContainerClass
{
    var dummy0: DummyClass
    var dummy1: DummyClass
    var dummy2: DummyClass
    var dummy3: DummyClass
    var dummy4: DummyClass
    var dummy5: DummyClass
    var dummy6: DummyClass
    var dummy7: DummyClass
    var dummy8: DummyClass
    var dummy9: DummyClass

    init(dummy0: DummyClass,
         dummy1: DummyClass,
         dummy2: DummyClass,
         dummy3: DummyClass,
         dummy4: DummyClass,
         dummy5: DummyClass,
         dummy6: DummyClass,
         dummy7: DummyClass,
         dummy8: DummyClass,
         dummy9: DummyClass)
    {
        self.dummy0 = dummy0
        self.dummy1 = dummy1
        self.dummy2 = dummy2
        self.dummy3 = dummy3
        self.dummy4 = dummy4
        self.dummy5 = dummy5
        self.dummy6 = dummy6
        self.dummy7 = dummy7
        self.dummy8 = dummy8
        self.dummy9 = dummy9
    }
}

struct ContainerStruct
{
    var dummy0: DummyClass
    var dummy1: DummyClass
    var dummy2: DummyClass
    var dummy3: DummyClass
    var dummy4: DummyClass
    var dummy5: DummyClass
    var dummy6: DummyClass
    var dummy7: DummyClass
    var dummy8: DummyClass
    var dummy9: DummyClass
}

@inline(never)
func testClass(_ container: ContainerClass) -> Int
{
    // Just call other function to create a new reference to the class
    let value = simpleCalculationForClass(container)
    return value
}

@inline(never)
func testStruct(_ container: ContainerStruct) -> Int
{
    // Just call other function to create a new copy of the struct
    let value =  simpleCalculationForStruct(container)
    return value
}

@inline(never)
func simpleCalculationForClass(_ testClass: ContainerClass) -> Int
{
    // Make a simple operation
    return (testClass.dummy3.count ^ 0x9e3779b9) >> testClass.dummy9.count
}

@inline(never)
func simpleCalculationForStruct(_ testStruct: ContainerStruct) -> Int
{
    // Make a simple operation
    return (testStruct.dummy3.count ^ 0x9e3779b9) >> testStruct.dummy9.count
}


/// Function to test class performance
@inline(never)
func calculateClassPerformance(with dummies: ContiguousArray<DummyClass>, iterations: Int64)
{
    // Create a container class instance
    let container = ContainerClass(
        dummy0: dummies[0],
        dummy1: dummies[1],
        dummy2: dummies[2],
        dummy3: dummies[3],
        dummy4: dummies[4],
        dummy5: dummies[5],
        dummy6: dummies[6],
        dummy7: dummies[7],
        dummy8: dummies[8],
        dummy9: dummies[9]
    )

    let startTime = MachTimeUtils.now()
    var result: Int = 0

    for _ in 0..<iterations
    {
        // Create a copy of instance then pass it to the function
        // to create new pointers to the original instance
        let copy = container
        result += testClass(copy)
    }

    let endTime = MachTimeUtils.now()
    let period = MachTimeUtils.milliSecondsBetween(start: startTime, end: endTime)

    print("Class: \(period)")
    print("Result: \(result)")
}

@inline(never)
func calculateStructPerformance(with dummies: ContiguousArray<DummyClass>, iterations: Int64)
{
    // Create an instance of struct that contains multiple classes
    let container = ContainerStruct(
        dummy0: dummies[0],
        dummy1: dummies[1],
        dummy2: dummies[2],
        dummy3: dummies[3],
        dummy4: dummies[4],
        dummy5: dummies[5],
        dummy6: dummies[6],
        dummy7: dummies[7],
        dummy8: dummies[8],
        dummy9: dummies[9]
    )

    let startTime = MachTimeUtils.now()
    var result: Int = 0

    for _ in 0..<iterations
    {
        // Create a copy of instance then pass it to the function
        // to create new copies of the original instance
        let copy = container
        result += testStruct(copy)
    }

    let endTime = MachTimeUtils.now()
    let period = MachTimeUtils.milliSecondsBetween(start: startTime, end: endTime)

    print("Struct: \(period)")
    print("Result: \(result)")
}

////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// EXECUTION STARS HERE ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

/// Iteration count for execution
let testIterationCount: Int64 = 100_000_000

/// Create an array of dummy classes with different data
var dummies = ContiguousArray<DummyClass>()
for j in 0..<10
{
    let dummy = DummyClass(flag: j % 2 == 0, count: j)
    dummies.append(dummy)
}

// Test performance for class
calculateClassPerformance(with: dummies, iterations: testIterationCount)

// Test performance for struct
calculateStructPerformance(with: dummies, iterations: testIterationCount)

