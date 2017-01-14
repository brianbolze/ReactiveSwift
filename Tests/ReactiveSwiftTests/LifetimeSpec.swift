import Quick
import Nimble
@testable import ReactiveSwift
import Result

final class LifetimeSpec: QuickSpec {
	override func spec() {
		describe("Lifetime") {
			describe("ended") {
				it("should complete its lifetime ended signal when the it deinitializes") {
					let object = MutableReference(TestObject())

					var isCompleted = false

					object.value!.lifetime.observeEnded { isCompleted = true }
					expect(isCompleted) == false

					object.value = nil
					expect(isCompleted) == true
				}

				it("should complete its lifetime ended signal even if the lifetime object is being retained") {
					let object = MutableReference(TestObject())
					let lifetime = object.value!.lifetime

					var isCompleted = false

					lifetime.observeEnded { isCompleted = true }
					expect(isCompleted) == false

					object.value = nil
					expect(isCompleted) == true
				}
			}

			describe("observeEnded") {
				it("should complete its lifetime ended signal when the it deinitializes") {
					let object = MutableReference(TestObject())

					var isCompleted = false

					object.value!.lifetime.observeEnded { isCompleted = true }
					expect(isCompleted) == false

					object.value = nil
					expect(isCompleted) == true
				}

				it("should complete its lifetime ended signal even if the lifetime object is being retained") {
					let object = MutableReference(TestObject())
					let lifetime = object.value!.lifetime

					var isCompleted = false

					lifetime.observeEnded { isCompleted = true }
					expect(isCompleted) == false

					object.value = nil
					expect(isCompleted) == true
				}

				it("should invoke the action even if the lifetime has ended") {
					var isCompleted = false

					Lifetime.empty.observeEnded { isCompleted = true }
					expect(isCompleted) == true
				}
			}

			describe("attach") {
				it("should complete its lifetime ended signal when the it deinitializes") {
					let object = MutableReference(TestObject())

					let disposable = SimpleDisposable()

					object.value!.lifetime.attach(disposable)
					expect(disposable.isDisposed) == false

					object.value = nil
					expect(disposable.isDisposed) == true
				}

				it("should complete its lifetime ended signal even if the lifetime object is being retained") {
					let object = MutableReference(TestObject())
					let lifetime = object.value!.lifetime

					let disposable = SimpleDisposable()

					lifetime.attach(disposable)
					expect(disposable.isDisposed) == false

					object.value = nil
					expect(disposable.isDisposed) == true
				}
			}
		}
	}
}

internal final class MutableReference<Value: AnyObject> {
	var value: Value?
	init(_ value: Value?) {
		self.value = value
	}
}

internal final class TestObject {
	private let token = Lifetime.Token()
	var lifetime: Lifetime { return Lifetime(token) }
}
