# atom-pivottable
This application is atom plugin which render pivot table using your json or csv


![Pivot table](http://y-takey.github.io/atom-pibottable.gif)


## Installation

In Atom, open [Preferences > Packages], search for `pivottable` package. Once it found, click `Install` button to install package.

### Manual installation

You can install the latest version manually from console:

```bash
cd ~/.atom/packages
git clone https://github.com/y-takey/atom-pivottable
cd atom-pivottable
npm install
```

Then restart Atom editor.

## Usage

Open your data file(json or csv)

Then

`right click and select [Pivot Tableize]`

or

`select menu-bar[Packages -> Pivot Table -> Tableize]`

or

<kbd>ctrl</kbd> + <kbd>option</kbd> + <kbd>p</kbd> (Mac)
<kbd>ctrl</kbd> + <kbd>alt</kbd> + <kbd>p</kbd> (Windows probably..)

[About UI tutorial](https://github.com/nicolaskruchten/pivottable/wiki/UI-Tutorial)

## Supported data format

1. json
  * Array **e.g.** `[{ a: 1, b: 2 }, { a: 3, b: 4 }]`
  * Object witch has array attribute **e.g.** `{ foo: [{ a: 1, b: 2 }, { a: 3, b: 4 }], bar: [{ c: 10, d: 11 }] }`
1. csv
  * must have header row

## Contributing

I don't have a deep knowledge of node.js and atom-editor. so, help me!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits
Many thanks to the [pivottable](https://github.com/nicolaskruchten/pivottable)  project!
