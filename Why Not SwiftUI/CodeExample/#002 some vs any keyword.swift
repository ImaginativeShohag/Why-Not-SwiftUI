//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

// MARK: - Example#002: `some` vs `any`
    
// Help:
// https://medium.com/@tahabebek/any-vs-some-in-swift-10a1863b6109
// https://swiftsenpai.com/swift/understanding-some-and-any/
// https://www.donnywals.com/what-is-the-any-keyword-in-swift/

protocol E2_Vehicle {
    var name: String { get }
        
    associatedtype FuelType
    func fillGasTank(with fuel: FuelType)
}

struct E2_Car: E2_Vehicle {
    let name = "car"
        
    func fillGasTank(with fuel: E2_Gasoline) {
        print("Fill \(name) with \(fuel.name)")
    }
}

struct E2_Bus: E2_Vehicle {
    let name = "bus"
        
    func fillGasTank(with fuel: E2_Diesel) {
        print("Fill \(name) with \(fuel.name)")
    }
}

struct E2_Gasoline {
    let name = "gasoline"
}

struct E2_Diesel {
    let name = "diesel"
}

// MARK: - `some`

func trySome() {
    var mySomeCar: some E2_Vehicle = E2_Car()
        
    // ✅ No compile error
    let someVehicles: [some E2_Vehicle] = [
        E2_Car(),
        E2_Car(),
        E2_Car(),
    ]
        
    func createSomeVehicle() -> some E2_Vehicle {
        return E2_Car()
    }
        
    let myCar1 = createSomeVehicle()
    let myCar2 = createSomeVehicle()
    // let isSameVehicle = myCar1 == myCar2 // Error: Binary operator '==' cannot be applied to two 'some Vehicle' operands
    
    // MARK: -
    
    // These three func declarations below are identical:
    func feed1<A: E2_Vehicle>(_ animal: A) {}
    func feed2<A>(_ animal: A) where A: E2_Vehicle {}
    func feed3(_ animal: some E2_Vehicle) {}
    
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

// MARK: - `any`

func tryAny() {
    let myCar: any E2_Vehicle = E2_Car()
        
    func wash(_ vehicle: any E2_Vehicle) {
        // Wash the given vehicle
    }
        
    // ✅ No compile error when changing the underlying data type
    var myAnyCar: any E2_Vehicle = E2_Car()
    myAnyCar = E2_Bus()
    myAnyCar = E2_Car()
        
    // ✅ No compile error when returning different kind of concrete type
    func createAnyVehicle(isPublicTransport: Bool) -> any E2_Vehicle {
        if isPublicTransport {
            return E2_Bus()
        } else {
            return E2_Car()
        }
    }
        
    let anyVehicles: [any E2_Vehicle] = [
        E2_Car(),
        E2_Car(),
        E2_Bus(),
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
