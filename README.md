# Caprice

![platforms](https://img.shields.io/badge/platforms-iOS%20%7C-333333.svg)

> Capriccio is a type of composition characterized by a certain freedom of realization. 

Caprice is a library build with the intention of explore the functional programming world without constraints.

## Installation

### CocoaPods

Add the following to your `Podfile`:

```ruby
source 'https://github.com/jrBordet/Sources.git'
source 'https://cdn.cocoapods.org/'

target 'Target' do

    pod 'Caprice', '0.0.6'

end

```

```ruby
pod install
```
## Table of Contents

* [Optics](#optics)
* [Lens](#Lens)
    * [get](#get)
    * [set](#set)
    * [over](#over)

## Operators

* [map](#map)
* [filter](#filter)
* [sort](#sort)

## [Predicate](#Predicate)

## `Optics`
A `Lens` type and a bridge between the lens world and the Swift key path world.

```swift

    struct Book: Equatable {
        var id: Int
        var title: String

        var author: Author
    }

    struct Author: Equatable {
        var name: String
        var surname: String
    }

    extension Book {
        static var galacticGuideForHitchhikers = Book(id: 2, title: "galactic guide for hitchhikers", author: .adams)
    }

    extension Author {
        static var adams = Author(name: "Adams", surname: "Douglas")
    }

    let name = .galacticGuideForHitchhikers |> ^\Book.author.name
    
    let newBook = .galacticGuideForHitchhikers |> \Book.author.name *~ "Adams Noël"
```

### `Lens`

#### `get`
```swift
    let authorName = .galacticGuideForHitchhikers |> ^\Book.author.name
    
    let authorName = .stoicism |> (lens(\Book.author) >>> lens(\Author.name)).get
    
    let authorName = .stoicism |> (lens(\Book.author.name)).get
```

#### `set`
```swift
    let result: Book = .it |> \Book.author.name *~ "new author"
    
    let newUser = lens(\User.id).set(0, user)
```

#### `over`
```swift
    let update =
        lens(\Book.author.name).over { $0.uppercased() }
            >>> lens(\Book.author.surname).over { $0.uppercased() }
            >>> lens(\Book.title) %~ { $0 +  " ♥️" }
    
    let newBook = Book.galacticGuideForHitchhikers |> update
```

### `Operators`

#### `map`


```swift
    let surname = books
            .filter(by(^\.author.name, "Massimo"))
            .map(^\.author.surname)
            .reduce("", +)
            .lowercased()
            
    // surname == "pigliucci"
```

#### `filter`

Filters out elements whose value match a predicates.

```swift
    let book = books.filter(by(^\.author.name, "Massimo"))
```

#### `sort`

Sorts the elements with respect to a Comparable property.

```swift
    let usersSorted = users.sorted(by: their(^\User.id, >))
```

### `Predicate`

```swift
    let user = User(
        id: 0,
        email: "email@gmail.com"
    )

    let emailPredicate = Predicate<String> {
        $0 |> NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with:)
    }

    let userEmailCmp = emailPredicate.contramap(^\User.email)

    XCTAssertTrue(user.email |> emailPredicate.contains)
    XCTAssertTrue(user |> userEmailCmp.contains)
```
