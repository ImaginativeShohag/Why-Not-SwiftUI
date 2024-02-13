//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import Core
import Foundation
import XCTest

private extension NavController {
    func reset() {
        navStack = []
    }
}

final class NavControllerTests: XCTestCase {
    let navController = NavController.shared
    
    // MARK: Blank

    func test_popUpToRoot_stackShouldBeBlank() {
        navController.popUpToRoot()
        
        XCTAssert(NavController.shared.navStack.isEmpty)
    }
    
    func test_navigateTo() {
        // MARK: navigateTo(Destination.A()) => A

        navController.reset()
        navController.navigateTo(Destination.A())
        
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack.first == Destination.A())
        
        // MARK: A > B navigateTo(Destination.C(id: UUID().hashValue)) => A > B > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B()])
        
        navController.navigateTo(Destination.C(id: UUID().hashValue))
        
        XCTAssert(navController.navStack.count == 3)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        
        // MARK: A > B navigateTo(Destination.C(id: UUID().hashValue), launchSingleTop: false) => A > B > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B()])
        
        navController.navigateTo(Destination.B(), launchSingleTop: false)
        
        XCTAssert(navController.navStack.count == 3)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.B())
        
        // MARK: A > B navigateTo(Destination.B(), launchSingleTop: true) => A > B

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B()])
        
        navController.navigateTo(Destination.B(), launchSingleTop: true)
        
        XCTAssert(navController.navStack.count == 2)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
    }
    
    func test_navigateToMultipleDestination() {
        // MARK: navigateTo([A(),B(),C()]) => A > B > C

        navController.reset()
        navController.navigateTo(Destination.A())
        
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack.first == Destination.A())
        
        // MARK: A > B navigateTo([A()]) => A > B > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B()])
        
        navController.navigateTo([
            Destination.A(),
            Destination.B(),
            Destination.A()
        ])
        
        XCTAssert(navController.navStack.count == 5)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.A())
        
        // MARK: A > B navigateTo([A(),B(),C(id: UUID().hashValue)]) => A > B > A > B > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B()])
        
        navController.navigateTo([
            Destination.A(),
            Destination.B(),
            Destination.C(id: UUID().hashValue)
        ])
        
        XCTAssert(navController.navStack.count == 5)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.A())
        XCTAssert(navController.navStack[3] == Destination.B())
        XCTAssert(navController.navStack[4] == Destination.C(id: UUID().hashValue))
        
        // MARK: A > B navigateTo([A(),A(),C(id: UUID().hashValue)]) => A > B > A > A > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B()])
        
        navController.navigateTo([
            Destination.A(),
            Destination.A(),
            Destination.C(id: UUID().hashValue)
        ])
        
        XCTAssert(navController.navStack.count == 5)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.A())
        XCTAssert(navController.navStack[3] == Destination.A())
        XCTAssert(navController.navStack[4] == Destination.C(id: UUID().hashValue))
    }
    
    func test_popBackStack() {
        // MARK: popBackStack

        navController.reset()
        
        XCTAssertNoThrow(navController.popBackStack())
            
        // MARK: A > B > C popBackStack

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.popBackStack()
        
        XCTAssert(navController.navStack.count == 2)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
    }
    
    func test_popUpTo() {
        // MARK: [Empty Stack] popUpTo(Destination.A()) => No Throw

        navController.reset()
        
        XCTAssertNoThrow(navController.popUpTo(Destination.A.self))
        
        // MARK: A > B > C popUpTo(Destination.A()) => A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.popUpTo(Destination.A.self)
        
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack[0] == Destination.A())
        
        // MARK: A > B > C > A > B > C popUpTo(Destination.A()) => A > B > C > A
        
        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.popUpTo(Destination.A.self)
        
        XCTAssert(navController.navStack.count == 4)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())
        
        // MARK: [Empty Stack] popUpTo(Destination.A(), inclusive: true) => No Throw

        navController.reset()
        
        XCTAssertNoThrow(navController.popUpTo(Destination.A.self, inclusive: true))
        
        // MARK: A > B > C popUpTo(Destination.A(), inclusive: true) => [Empty Stack]

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.popUpTo(Destination.A.self, inclusive: true)
        
        XCTAssert(navController.navStack.isEmpty)
        
        // MARK: A > B > C > A > B > C popUpTo(Destination.A(), inclusive: true) => A > B > C
        
        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.popUpTo(Destination.A.self, inclusive: true)
        
        XCTAssert(navController.navStack.count == 3)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
    }
    
    func test_navigateToWithPopUpTo() {
        // MARK: [Empty Stack] navigateTo(Destination.A(), popUpTo: Destination.B()) => A

        navController.reset()
        
        navController.navigateTo(Destination.A(), popUpTo: Destination.B.self)
        
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack[0] == Destination.A())
        
        // MARK: A > B > C > B > A > C navigateTo(Destination.A(), popUpTo: Destination.B()) => A > B > C > B > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.B(), Destination.A(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(Destination.A(), popUpTo: Destination.B.self)
        
        XCTAssert(navController.navStack.count == 5)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.B())
        XCTAssert(navController.navStack[4] == Destination.A())

        // MARK: A > B > C > A > B > C navigateTo(Destination.A(), popUpTo: Destination.A()) => A > B > C > A > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(Destination.A(), popUpTo: Destination.A.self)
        
        XCTAssert(navController.navStack.count == 5)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())
        XCTAssert(navController.navStack[4] == Destination.A())

        // MARK: A > B > C navigateTo(Destination.B(), popUpTo: Destination.A()) => A > B

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(Destination.B(), popUpTo: Destination.A.self)
        
        XCTAssert(navController.navStack.count == 2)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        
        // MARK: - launchSingleTop = true
        
        // MARK: [Empty Stack] navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.B()) => A

        navController.reset()
            
        navController.navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.B.self)
            
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack[0] == Destination.A())
            
        // MARK: A > B > C > B > A > C navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.B()) => A > B > C > B > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.B(), Destination.A(), Destination.C(id: UUID().hashValue)])
            
        navController.navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.B.self)
        
        XCTAssert(navController.navStack.count == 5)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.B())
        XCTAssert(navController.navStack[4] == Destination.A())

        // MARK: A > B > C > A > B > C navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.A()) => A > B > C > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
            
        navController.navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.A.self)
            
        XCTAssert(navController.navStack.count == 4)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())

        // MARK: A > B > C navigateTo(Destination.B(), launchSingleTop: true, popUpTo: Destination.A()) => A > B
        
        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(Destination.B(), popUpTo: Destination.A.self)
        
        XCTAssert(navController.navStack.count == 2)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        
        // MARK: - inclusive = true
        
        // MARK: [Empty Stack] navigateTo(Destination.A(), popUpTo: Destination.B(), inclusive:  true) => A

        navController.reset()
        
        navController.navigateTo(Destination.A(), popUpTo: Destination.B.self, inclusive: true)
        
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack[0] == Destination.A())
        
        // MARK: A > B > C > B > A > C navigateTo(Destination.A(), popUpTo: Destination.B(), inclusive:  true) => A > B > C > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.B(), Destination.A(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(Destination.A(), popUpTo: Destination.B.self, inclusive: true)
        
        XCTAssert(navController.navStack.count == 4)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())

        // MARK: A > B > C > A > B > C navigateTo(Destination.A(), popUpTo: Destination.A(), inclusive:  true) => A > B > C > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(Destination.A(), popUpTo: Destination.A.self, inclusive: true)
        
        XCTAssert(navController.navStack.count == 4)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())

        // MARK: A > B > C navigateTo(Destination.B(), popUpTo: Destination.A(), inclusive:  true) => B

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(Destination.B(), popUpTo: Destination.A.self, inclusive: true)
        
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack[0] == Destination.B())
        
        // MARK: - launchSingleTop = true,  inclusive = true
        
        // MARK: [Empty Stack] navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.B(), inclusive:  true) => A

        navController.reset()
            
        navController.navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.B.self, inclusive: true)
            
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack[0] == Destination.A())
            
        // MARK: A > B > C > B > A > C navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.B(), inclusive:  true) => A > B > C > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.B(), Destination.A(), Destination.C(id: UUID().hashValue)])
            
        navController.navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.B.self, inclusive: true)
            
        XCTAssert(navController.navStack.count == 4)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())

        // MARK: A > B > C > A > A > B > C navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.A(), inclusive:  true) => A > B > C > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.A(), Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
            
        navController.navigateTo(Destination.A(), launchSingleTop: true, popUpTo: Destination.A.self, inclusive: true)
            
        XCTAssert(navController.navStack.count == 4)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A()) // This is the old Destination.A(), nothing is added to stack.

        // MARK: A > B > C navigateTo(Destination.B(), launchSingleTop: true, popUpTo: Destination.A(), inclusive:  true) => B

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
            
        navController.navigateTo(Destination.B(), launchSingleTop: true, popUpTo: Destination.A.self, inclusive: true)
            
        XCTAssert(navController.navStack.count == 1)
        XCTAssert(navController.navStack[0] == Destination.B())
    }
    
    func test_navigateToMultipleDestinationWithPopUpTo() {
        // MARK: [Empty Stack] navigateTo([A(),B(),C()], popUpTo: Destination.B()) => A > B > C

        navController.reset()
        
        navController.navigateTo(
            [
                Destination.A(),
                Destination.B(),
                Destination.C(id: UUID().hashValue)
            ],
            popUpTo: Destination.B.self
        )
        
        XCTAssert(navController.navStack.count == 3)
        XCTAssert(navController.navStack[0] == Destination.A())
        
        // MARK: A > B > C > B > A > C navigateTo([A(),B(),C()], popUpTo: Destination.B()) => A > B > C > B > A > B > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.B(), Destination.A(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(
            [
                Destination.A(),
                Destination.B(),
                Destination.C(id: UUID().hashValue)
            ],
            popUpTo: Destination.B.self
        )
        
        XCTAssert(navController.navStack.count == 7)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.B())
        XCTAssert(navController.navStack[4] == Destination.A())
        XCTAssert(navController.navStack[5] == Destination.B())
        XCTAssert(navController.navStack[6] == Destination.C(id: UUID().hashValue))

        // MARK: A > B > C > A > B > C navigateTo([A(),B(),C()], popUpTo: Destination.A()) => A > B > C > A > A > B > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(
            [
                Destination.A(),
                Destination.B(),
                Destination.C(id: UUID().hashValue)
            ],
            popUpTo: Destination.A.self
        )
        
        XCTAssert(navController.navStack.count == 7)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())
        XCTAssert(navController.navStack[4] == Destination.A())
        XCTAssert(navController.navStack[5] == Destination.B())
        XCTAssert(navController.navStack[6] == Destination.C(id: UUID().hashValue))

        // MARK: A > B > C navigateTo([B(),C(),A()], popUpTo: Destination.A()) => A > B > C > A

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(
            [
                Destination.B(),
                Destination.C(id: UUID().hashValue),
                Destination.A()
            ],
            popUpTo: Destination.A.self
        )
        
        XCTAssert(navController.navStack.count == 4)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())
        
        // MARK: - inclusive = true
        
        // MARK: [Empty Stack] navigateTo([A(),B(),C()], popUpTo: Destination.B(), inclusive:  true) => A > B > C

        navController.reset()
        
        navController.navigateTo(
            [
                Destination.A(),
                Destination.B(),
                Destination.C(id: UUID().hashValue)
            ],
            popUpTo: Destination.B.self,
            inclusive: true
        )
        
        XCTAssert(navController.navStack.count == 3)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        
        // MARK: A > B > C > B > A > C navigateTo([A(),B(),C()], popUpTo: Destination.B(), inclusive:  true) => A > B > C > A > B > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.B(), Destination.A(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(
            [
                Destination.A(),
                Destination.B(),
                Destination.C(id: UUID().hashValue)
            ],
            popUpTo: Destination.B.self,
            inclusive: true
        )
        
        XCTAssert(navController.navStack.count == 6)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())
        XCTAssert(navController.navStack[4] == Destination.B())
        XCTAssert(navController.navStack[5] == Destination.C(id: UUID().hashValue))

        // MARK: A > B > C > A > B > C navigateTo([A(),B(),C()], popUpTo: Destination.A(), inclusive:  true) => A > B > C > A > B > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue), Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(
            [
                Destination.A(),
                Destination.B(),
                Destination.C(id: UUID().hashValue)
            ],
            popUpTo: Destination.A.self,
            inclusive: true
        )
        
        XCTAssert(navController.navStack.count == 6)
        XCTAssert(navController.navStack[0] == Destination.A())
        XCTAssert(navController.navStack[1] == Destination.B())
        XCTAssert(navController.navStack[2] == Destination.C(id: UUID().hashValue))
        XCTAssert(navController.navStack[3] == Destination.A())
        XCTAssert(navController.navStack[4] == Destination.B())
        XCTAssert(navController.navStack[5] == Destination.C(id: UUID().hashValue))

        // MARK: A > B > C navigateTo([B(),C()], popUpTo: Destination.A(), inclusive:  true) => B > C

        navController.reset()
        navController.navStack.append(contentsOf: [Destination.A(), Destination.B(), Destination.C(id: UUID().hashValue)])
        
        navController.navigateTo(
            [
                Destination.B(),
                Destination.C(id: UUID().hashValue)
            ],
            popUpTo: Destination.A.self,
            inclusive: true
        )
        
        XCTAssert(navController.navStack.count == 2)
        XCTAssert(navController.navStack[0] == Destination.B())
        XCTAssert(navController.navStack[1] == Destination.C(id: UUID().hashValue))
    }
}
