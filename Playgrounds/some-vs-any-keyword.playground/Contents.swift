import Foundation
import SwiftUI

// MARK: - Example#002: `some` vs `any`
    
// Help:
// https://medium.com/@tahabebek/any-vs-some-in-swift-10a1863b6109
// https://swiftsenpai.com/swift/understanding-some-and-any/
// https://www.donnywals.com/what-is-the-any-keyword-in-swift/

/// ```
/// ┌-------------------------------------------------------------------┐
/// │ let myCar: some Vehicle = Car()    let myCar: any Vehicle = Car() │
/// │                                                                   │
/// │                                              ┌───┐                │
/// │            X                                 │ X │                │
/// │                                              └───┘                │
/// │                                                                   │
/// │   myCar is opaque type              myCar is existential type     │
/// └-------------------------------------------------------------------┘
/// ```
///
/// As illustrated in the image above, the main difference between an opaque type and an existential type is the “box”.
/// The “box” enables us to store any concrete type within it as long as the underlying type conforms to the specified protocol, thus allowing us to do something that an opaque type doesn’t allow us to do.

protocol Vehicle<FuelType> {
    var name: String { get }
    
    // Car requires Gasoline whereas Bus requires Diesel.
    associatedtype FuelType
    func fillGasTank(with fuel: FuelType)
}

struct Car: Vehicle {
    let name = "car"
        
    func fillGasTank(with fuel: Gasoline) {
        print("Fill \(name) with \(fuel.name)")
    }
}

struct Bus: Vehicle {
    let name = "bus"
        
    func fillGasTank(with fuel: Diesel) {
        print("Fill \(name) with \(fuel.name)")
    }
}

struct Gasoline {
    let name = "gasoline"
}

struct Diesel {
    let name = "diesel"
}

// MARK: - `some` (opaque type)

// "Opaque type" that represents something that is conformed to a specific protocol.

func trySome() {
    // MARK: - Function's parameter
    
    // For parameters with opaque type, the underlying type is inferred from the argument value at the call site.
    
    // These three func declarations below are identical:
    func feed1<A: Vehicle>(_ animal: A) {}
    func feed2<A>(_ animal: A) where A: Vehicle {}
    func feed3(_ animal: some Vehicle) {}
    
    // For an opaque result type, the underlying type is inferred from the return value in the implementation.
    
    func makeCar() -> some Vehicle {
        return Car()
    }
    
    // MARK: - Variable
    
    /*
     When we use the some keyword on a variable, we are telling the compiler that we are working on a specific concrete type, thus the opaque type’s underlying type must be fixed for the scope of the variable.
     
     For a local variable, the underlying type is inferred from the value on the right-hand side of assignment.
     This means local variables with opaque type must always have an initial value; and if you don’t provide one, the compiler will report an error.
     */
    
    var myCar: some Vehicle = Car()
    // myCar = Bus() // 🔴 Compile error: Cannot assign value of type 'Bus' to type 'some Vehicle'
    
    /*
     One interesting point to be aware of is that assigning a new instance of the same concrete type to the variable is also prohibited by the compiler.
     */
    
    var myCar3: some Vehicle = Car()
    // myCar2 = Car() // 🔴 Compile error: Cannot assign value of type 'Car' to type 'some Vehicle'

    var myCar4: some Vehicle = Car()
    var myCar5: some Vehicle = Car()
    // myCar4 = myCar5 // 🔴 Compile error: Cannot assign value of type 'some Vehicle' (type of 'myCar1') to type 'some Vehicle' (type of 'myCar2')
    
    /// It can only store one type of child of `Vehicle`.
    // ✅ No compile error
    let vehicles: [some Vehicle] = [
        Car(),
        Car(),
        Car(),
    ]
    
    // 🔴 Compile error: Cannot convert value of type 'Bus' to expected element type 'Car'
    // let vehicles: [some Vehicle] = [
    //     Car(),
    //     Car(),
    //     Bus(),
    // ]
    
    // MARK: - Function's return type
    
    // ✅ No compile error
    func createSomeVehicle() -> some Vehicle {
        return Car()
    }

    // 🔴 Compile error: Function declares an opaque return type 'some Vehicle', but the return statements in its body do not have matching underlying types
    // func createSomeVehicle(isPublicTransport: Bool) -> some Vehicle {
    //    if isPublicTransport {
    //        return Bus()
    //    } else {
    //        return Car()
    //    }
    // }
    
    let myCar1 = createSomeVehicle()
    let myCar2 = createSomeVehicle()
    // let isSameVehicle = myCar1 == myCar2 // Error: Binary operator '==' cannot be applied to two 'some Vehicle' operands
    
    // MARK: -
    
    /// `some`: Something that conforms to `Mailmap`:
    ///
    /// ```swift
    /// struct EditableMailmap: Mailmap
    /// <Value: Mailmap>
    /// where Element: Mailmap
    /// some Mailmap
    /// ```
}

trySome()

// MARK: - `any` (existential type)

func tryAny() {
    let myCar: any Vehicle = Car()
        
    func wash(_ vehicle: any Vehicle) {
        // Wash the given vehicle
    }
        
    // ✅ No compile error when changing the underlying data type
    var myAnyCar: any Vehicle = Car()
    myAnyCar = Bus()
    myAnyCar = Car()
        
    // ✅ No compile error when returning different kind of concrete type
    func createAnyVehicle(isPublicTransport: Bool) -> any Vehicle {
        if isPublicTransport {
            return Bus()
        } else {
            return Car()
        }
    }
        
    /// It can hold any type of child of `Vehicle`.
    let anyVehicles: [any Vehicle] = [
        Car(),
        Car(),
        Bus(),
    ]
        
    let myCar1 = createAnyVehicle(isPublicTransport: false)
    let myCar2 = createAnyVehicle(isPublicTransport: false)
    // let isSameVehicle = myCar1 == myCar2 // Error: Binary operator '==' cannot be applied to two 'any CodeExampleViewModel.Vehicle' operands
        
    // NOTE: Another limitation that you should be aware of is that the existential types are less efficient than the opaque types (created using the some keyword).
    
    // MARK: -
    
    /// `any`: A box whose contents conform to `Mailmap`:
    ///
    /// ```swift
    /// var map: any Mailmap
    /// Array<any Mailmap>
    /// where Element == any Mailmap
    /// (any Mailmap) -> any Mailmap
    /// ```
}

tryAny()
