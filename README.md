# Slice of a knot

Grab a banana, grab a knife, slice a banana, and look at the slice.

Then grab linear algebra, knot theory, and coffeescript + react and create a slicing tool.

## Intro

Knot is a closed line in 3 dimensions. The line can wind up in so many ways, that there exist a separate 
[mathematical theory](https://en.wikipedia.org/wiki/Knot_theory)
about knots.

How to describe a knot in x-y-z:

- [Torus Knot](https://en.wikipedia.org/wiki/Torus_knot)
- [Parametrisation of knot](http://www.mi.sanu.ac.rs/vismath/taylor2009/index.html)

A [video](https://youtu.be/ntCuQei0xuk) by CGmatter that inspired me. 
He created an animation in blender and called it procedural. 
This was not procedural enough for me.

## Determine the intersection.

The idea is to put circles on your line in 3d. 
Then find the intersection circles and some plane.

Strictly speaking,

1. We have parametrisation function f: R -> R^3 we can 
2. We have the tangent vector   \tau = df/dt
3. for every t put a circle perpendicular to \tau(t) with center at f(t)
4. Find the intersection of this circle with the plane of interest

The 4 is the most interesting.

Suppose our slicing plane is defined by vertor v.
We also should have vector x(theta) which traces a circle at origin.
Then matrix U defines rotation of our circle corresponding to \tau(t).

then v(Ux + f(t)) = 0, which means "angle between point on circle and v is 90 degrees".

(vU) x = -f(t)v

x(theta) = [cos(theta), sin(theta), 0] ^ T

The trick is how to define the U matrix.

## Basis in the point.


first vector: vz = \tau.

second vector: vy = \tau X f(t)

third vector: vx = vy X \tau

Basically, just couple of cross products to obtain a basis.
We don't really care what are our vx and vy are as long as they are perpendicular to vz or \tau.


## Adapting dt  

If \tau faces in almost same direction as v, our circles won't touch the plane. 
This means we should adjust the dt based on the angle between those.
I use this formula: `dt = W/(1+W*v*\tau)`


This project uses boilerplate for react and coffeescript.

You can find it here: https://github.com/DaniloZZZ/webext-react-coffeescript-boilerplate

---


# React + Coffeescript + Hot reload = <3

libraries included:

 - coffeescript
 - less, css
 - react-router
 - axios

Also, webpack configured to serve for all ip, work with react-router and use CORS

Use this repo to set up your development for web apps in coffeescript.

# Why coffeescript?

because it's less verbose. I personally love to use this style of syntax:

```coffeescript
import React, { Component } from 'react'
import L from 'react-dom-factories'
L_ = React.createElement

Greeting = ()->
  L.div className:'greeting',
	L.h2 style:textAlign:'center', 'Hello World'

export default class App extends React.Component
  constructor:->
    super()
     
  render: ->
    L.div className:'app',
      L_ Greeting, null

ReactDOM.render <App />, document.getElementById 'root'

```
