import UIKit
import XCTest
@testable import IQKeyboardManagerSwift

final class IQRootControllerConfigurationTests: XCTestCase {

    @MainActor
    func testRestoreAfterTransitionWithoutKeyboardAdjustment() {
        let controller = UIViewController()
        let view = UIView(frame: CGRect(x: 20, y: 40, width: 320, height: 480))
        controller.view = view
        let center = view.center
        let bounds = view.bounds
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        let configuration = IQRootControllerConfiguration(rootController: controller, orientation: .unknown)

        view.transform = .identity

        XCTAssertFalse(configuration.hasChanged)
        XCTAssertFalse(configuration.restore())
        XCTAssertEqual(view.center, center)
        XCTAssertEqual(view.bounds, bounds)
        XCTAssertEqual(view.transform, .identity)
    }

    @MainActor
    func testRepeatedAdjustmentsAndRestorePreserveOtherGeometry() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 360, height: 640))
        let controller = UIViewController()
        let view = UIView(frame: CGRect(x: 20, y: 40, width: 320, height: 480))
        controller.view = view
        container.addSubview(view)
        let originalCenterY = view.center.y
        let configuration = IQRootControllerConfiguration(rootController: controller, orientation: .unknown)

        configuration.adjust(upBy: 300, keyboardHeight: 180)
        XCTAssertEqual(configuration.movedDistance, 220)
        XCTAssertEqual(view.center.y, originalCenterY - 220)

        configuration.adjust(upBy: -70, keyboardHeight: 180)
        XCTAssertEqual(configuration.movedDistance, 150)
        XCTAssertEqual(view.center.y, originalCenterY - 150)

        view.center.x += 15
        view.bounds.size.width += 30
        let transform = CGAffineTransform(rotationAngle: .pi / 8)
        view.transform = transform
        let bounds = view.bounds
        let centerX = view.center.x

        XCTAssertTrue(configuration.restore())
        XCTAssertEqual(view.center, CGPoint(x: centerX, y: originalCenterY))
        XCTAssertEqual(view.bounds, bounds)
        XCTAssertEqual(view.transform, transform)
        XCTAssertFalse(configuration.restore())
        XCTAssertEqual(configuration.movedDistance, 0)
    }

    @MainActor
    func testAdjustmentOfTransformedRootMovesItsCenterInSuperviewCoordinates() {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 360, height: 640))
        let controller = UIViewController()
        let view = UIView(frame: CGRect(x: 20, y: 40, width: 320, height: 480))
        container.addSubview(view)
        controller.view = view
        let transform = CGAffineTransform(scaleX: 0.75, y: 0.75).rotated(by: .pi / 12)
        view.transform = transform
        let center = view.center
        let bounds = view.bounds
        let configuration = IQRootControllerConfiguration(rootController: controller, orientation: .unknown)

        configuration.adjust(upBy: 30, keyboardHeight: 180)

        XCTAssertEqual(view.center, CGPoint(x: center.x, y: center.y - 30))
        XCTAssertEqual(view.bounds, bounds)
        XCTAssertEqual(view.transform, transform)
        XCTAssertTrue(configuration.restore())
        XCTAssertEqual(view.center, center)
    }

    @MainActor
    func testExternalLayoutReplacesAdjustment() {
        let controller = UIViewController()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        controller.view = view
        let configuration = IQRootControllerConfiguration(rootController: controller, orientation: .unknown)

        configuration.adjust(upBy: 60, keyboardHeight: 200)
        view.center.y = 300

        XCTAssertFalse(configuration.hasChanged)
        XCTAssertFalse(configuration.restore())
        XCTAssertEqual(view.center.y, 300)

        configuration.adjust(upBy: 40, keyboardHeight: 200)
        XCTAssertEqual(configuration.movedDistance, 40)
        XCTAssertEqual(view.center.y, 260)
        XCTAssertTrue(configuration.restore())
        XCTAssertEqual(view.center.y, 300)
    }

    @MainActor
    func testRestorePreservesHeightChangeThatKeptTheAdjustedOrigin() {
        let controller = UIViewController()
        let frame = CGRect(x: 20, y: 40, width: 320, height: 480)
        let view = UIView(frame: frame)
        controller.view = view
        let configuration = IQRootControllerConfiguration(rootController: controller, orientation: .unknown)

        configuration.adjust(upBy: 60, keyboardHeight: 200)
        view.frame.size.height += 40

        XCTAssertTrue(configuration.restore())
        XCTAssertEqual(view.frame.origin, frame.origin)
        XCTAssertEqual(view.bounds.height, frame.height + 40)
    }

    @MainActor
    func testReplacementCapturesSafeAreaInsetsAfterRestoringRoot() {
        let controller = UIViewController()
        let view = PositionDependentSafeAreaView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        controller.view = view
        let textField = UITextField()
        view.addSubview(textField)
        let previous = IQRootControllerConfiguration(rootController: controller, orientation: .portrait)
        let active = IQActiveConfiguration()
        active.rootConfiguration = previous
        previous.adjust(upBy: 60, keyboardHeight: 200)
        XCTAssertNotEqual(view.safeAreaInsets, previous.beginSafeAreaInsets)

        NotificationCenter.default.post(name: UITextField.textDidBeginEditingNotification, object: textField)

        XCTAssertFalse(active.rootConfiguration === previous)
        XCTAssertEqual(active.rootConfiguration?.beginSafeAreaInsets, previous.beginSafeAreaInsets)
    }
}

private final class PositionDependentSafeAreaView: UIView {
    override var safeAreaInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: center.y == bounds.midY ? 24 : 0, right: 0)
    }
}
