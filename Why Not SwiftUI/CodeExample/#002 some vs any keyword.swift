//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

// MARK: - Example#002: `some` vs `any`
    
// Help:
// https://medium.com/@tahabebek/any-vs-some-in-swift-10a1863b6109
// https://swiftsenpai.com/swift/understanding-some-and-any/
// https://www.donnywals.com/what-is-the-any-keyword-in-swift/

protocol E2Vehicle {
    var name: String { get }
        
    associatedtype FuelType
    func fillGasTank(with fuel: FuelType)
}

struct E2Car: E2Vehicle {
    let name = "car"
        
    func fillGasTank(with fuel: E2Gasoline) {
        print("Fill \(name) with \(fuel.name)")
    }
}

struct E2Bus: E2Vehicle {
    let name = "bus"
        
    func fillGasTank(with fuel: E2Diesel) {
        print("Fill \(name) with \(fuel.name)")
    }
}

struct E2Gasoline {
    let name = "gasoline"
}

struct E2Diesel {
    let name = "diesel"
}

// MARK: - `some`

func trySome() {
    var mySomeCar: some E2Vehicle = E2Car()
        
    // ✅ No compile error
    let someVehicles: [some E2Vehicle] = [
        E2Car(),
        E2Car(),
        E2Car(),
    ]
        
    func createSomeVehicle() -> some E2Vehicle {
        return E2Car()
    }
        
    let myCar1 = createSomeVehicle()
    let myCar2 = createSomeVehicle()
    // let isSameVehicle = myCar1 == myCar2 // Error: Binary operator '==' cannot be applied to two 'some Vehicle' operands
}

// MARK: - `any`

func tryAny() {
    let myCar: any E2Vehicle = E2Car()
        
    func wash(_ vehicle: any E2Vehicle) {
        // Wash the given vehicle
    }
        
    // ✅ No compile error when changing the underlying data type
    var myAnyCar: any E2Vehicle = E2Car()
    myAnyCar = E2Bus()
    myAnyCar = E2Car()
        
    // ✅ No compile error when returning different kind of concrete type
    func createAnyVehicle(isPublicTransport: Bool) -> any E2Vehicle {
        if isPublicTransport {
            return E2Bus()
        } else {
            return E2Car()
        }
    }
        
    let anyVehicles: [any E2Vehicle] = [
        E2Car(),
        E2Car(),
        E2Bus(),
    ]
        
    let myCar1 = createAnyVehicle(isPublicTransport: false)
    let myCar2 = createAnyVehicle(isPublicTransport: false)
    // let isSameVehicle = myCar1 == myCar2 // Error: Binary operator '==' cannot be applied to two 'any CodeExampleViewModel.Vehicle' operands
        
    // NOTE: Another limitation that you should be aware of is that the existential types are less efficient than the opaque types (created using the some keyword).
}
