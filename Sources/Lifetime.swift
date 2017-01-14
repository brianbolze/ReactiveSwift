import Foundation
import enum Result.NoError

/// Represents the lifetime of an object, and provides a hook to observe when
/// the object deinitializes.
public final class Lifetime {
	/// MARK: Type properties and methods

	/// A `Lifetime` that has already ended.
	public static var empty: Lifetime {
		return Lifetime(ended: .empty)
	}

	/// MARK: Instance properties

	private let _ended: Signal<(), NoError>

	/// A signal that sends a `completed` event when the lifetime ends.
	@available(*, deprecated, message:"Use `Lifetime.observeEnded` and `Lifetime.attach` instead.")
	public var ended: Signal<(), NoError> {
		return _ended
	}

	/// MARK: Initializers

	/// Initialize a `Lifetime` object with the supplied ended signal.
	///
	/// - parameters:
	///   - signal: The ended signal.
	private init(ended signal: Signal<(), NoError>) {
		_ended = signal
	}

	/// Initialize a `Lifetime` from a lifetime token, which is expected to be
	/// associated with an object.
	///
	/// - important: The resulting lifetime object does not retain the lifetime
	///              token.
	///
	/// - parameters:
	///   - token: A lifetime token for detecting the deinitialization of the
	///            associated object.
	public convenience init(_ token: Token) {
		self.init(ended: token.ended)
	}

	/// Dispose of the given disposable when `self` ends.
	///
	/// - parameters:
	///   - disposable: The disposable to be disposed of.
	///
	/// - returns: A disposable that detaches `action` from the lifetime, or `nil`
	///            if `lifetime` has already ended.
	@discardableResult
	public func attach(_ disposable: Disposable?) -> Disposable? {
		return disposable.flatMap { observeEnded($0.dispose) }
	}

	/// Observe the termination of `self`.
	///
	/// - parameters:
	///   - action: The action to be invoked when `self` ends.
	///
	/// - returns: A disposable that detaches `action` from the lifetime, or `nil`
	///            if `lifetime` has already ended.
	@discardableResult
	public func observeEnded(_ action: @escaping () -> Void) -> Disposable? {
		return _ended.observe(Observer(terminated: action))
	}

	/// Attach a `Disposable` to the lifetime.
	///
	/// - parameters:
	///   - lifetime: The lifetime to attach to.
	///   - disposable: The disposable to be attached.
	///
	/// - returns: A disposable that detaches `disposable` from the lifetime, or
	///            `nil` if `lifetime` has already ended.
	@discardableResult
	public static func +=(lifetime: Lifetime, disposable: Disposable?) -> Disposable? {
		return lifetime.attach(disposable)
	}

	/// A token object which completes its signal when it deinitializes.
	///
	/// It is generally used in conjuncion with `Lifetime` as a private
	/// deinitialization trigger.
	///
	/// ```
	/// class MyController {
	///		private let token = Lifetime.Token()
	///		public var lifetime: Lifetime {
	///			return Lifetime(token)
	///		}
	/// }
	/// ```
	public final class Token {
		/// A signal that sends a Completed event when the lifetime ends.
		fileprivate let ended: Signal<(), NoError>

		private let endedObserver: Signal<(), NoError>.Observer

		public init() {
			(ended, endedObserver) = Signal.pipe()
		}

		deinit {
			endedObserver.sendCompleted()
		}
	}
}
