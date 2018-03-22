# flutter_plot
R. C. Howell - 2018

A pretty plotting package for Flutter apps. Sizing and autopadding isn't great right now, but tinkering with padding and fontSize will allow for you to align things well.

## Example 1

![Screenshot](https://i.imgur.com/17QwWzg.png)

This example is more complicated than typical because it's showing off the styling capability.

```
final List<Point> data = [
  const Point(21.0, 19.0),
  const Point(3.0, 7.0),
  const Point(8.0, 9.0),
  const Point(11.0, 14.0),
  const Point(18.0, 17.0),
  const Point(7.0, 8.0),
  const Point(-4.0, -4.0),
  const Point(6.0, 12.0),
];

new Card(
  child: new Column(
    children: <Widget>[
      new Container(
        padding: const EdgeInsets.only(top: 12.0),
        child: new Text('Super Neat Plot'),
      ),
      new Container(
        child: new Plot(
          height: 200.0,
          data: widget.data,
          gridSize: new Offset(2.0, 2.0),
          style: new PlotStyle(
            pointRadius: 3.0,
            outlineRadius: 1.0,
            primary: Colors.white,
            secondary: Colors.orange,
            textStyle: new TextStyle(
              fontSize: 8.0,
              color: Colors.blueGrey,
            ),
            axis: Colors.blueGrey[600],
            gridline: Colors.blueGrey[100],
          ),
          padding: const EdgeInsets.fromLTRB(40.0, 12.0, 12.0, 40.0),
          xTitle: 'My X Title',
          yTitle: 'My Y Title',
          ),
      ),
    ],
  ),
),
```

## Example 2

![Screenshot 2](https://i.imgur.com/yPUG61p.png)

```
// Using the same data as before

Plot simplePlot = new Plot(
  height: 200.0,
  data: widget.data,
  gridSize: new Offset(2.0, 2.0),
  style: new PlotStyle(
    primary: Colors.black,
    textStyle: new TextStyle(
      fontSize: 8.0,
      color: Colors.blueGrey,
    ),
    axis: Colors.blueGrey[600],
  ),
  padding: const EdgeInsets.fromLTRB(40.0, 12.0, 12.0, 40.0),
);
```

## How to Use
1. Add as a dependency
2. `import 'package:flutter_plot/plot.dart';`
3. See examples! There's not much to this package yet!
