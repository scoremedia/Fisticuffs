//  The MIT License (MIT)
//
//  Copyright (c) 2016 theScore Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


// Protocol representing Optionals (and ImplicitlyUnwrappedOptionals) so that we can 
// support concepts like binding a Observable<String> to a BindableProperty<String?>

struct OptionalIsNone: Error {}

public protocol OptionalType {
    associatedtype Wrapped
    init(wrappedValue: Wrapped)
    func toUnwrappedValue() throws -> Wrapped
}

extension Optional: OptionalType {
    public init(wrappedValue: Wrapped) {
        self = .some(wrappedValue)
    }
    public func toUnwrappedValue() throws -> Wrapped {
        if let unwrapped = self {
            return unwrapped
        } else {
            throw OptionalIsNone()
        }
    }
}

extension ImplicitlyUnwrappedOptional: OptionalType {
    public init(wrappedValue: Wrapped) {
        self = .some(wrappedValue)
    }
    public func toUnwrappedValue() throws -> Wrapped {
        switch self {
        case .some(let unwrapped):
            return unwrapped
        case .none:
            throw OptionalIsNone()
        }
    }
}
