import React, { Component } from 'react'
import L from 'react-dom-factories'
L_ = React.createElement
import './App.less'
import * as mathjs from 'mathjs'

Greeting = ()->
  L.div className:'greeting',
    L.h2 style:textAlign:'center', 'Hello World'

export default class App extends React.Component
  constructor:->
    super()
    @state = {x:30, y:60}

  mouseMove:(e)=>
    @setState x: e.pageX, y: e.pageY

  get_path:(a, {width, height})=>
    {x, y} = @state
    xPos = x
    R = .7
    N = 2640
    trange = [0..N]
    T_scale = N
    path = ""

    xfunc = 'x(p,q,t) = sin(p*t) + 3sin(q*t)'
    yfunc = 'y(p,q,t) = cos(p*t) + 3cos(q*t)'
    zfunc = "z(p,q,t) = 2cos(4*t+1.57)"

    parser = mathjs.parser()
    parser.evaluate(xfunc)
    parser.evaluate(yfunc)
    parser.evaluate(zfunc)
    ###
    parser.evaluate('dx(p,q,t) = p*cos(p*t) +3q*cos(q*t)')
    parser.evaluate('dy(p,q,t) = -p*sin(p*t) - 3q*sin(q*t)')
    parser.evaluate('dz(p,q,t) = -8*sin(4*t+1.57)')


    # Unforutnately, evaluation is slow, of order of hundreds of millis
    dx = mathjs.derivative(xfunc, 't')
    dy = mathjs.derivative(yfunc, 't')
    dz = mathjs.derivative(zfunc, 't')
    ###

    norm_v = ({x,y,z})->
      n = Math.sqrt(x*x + y*y + z*z)
      {x:x/n, y:y/n, z:z/n}
    dict_to_list = ({x,y,z})-> [x,y,z]
    vec_prod = (a,b)->
      a = dict_to_list(norm_v(a))
      b = dict_to_list(norm_v(b))
      [x,y,z] = mathjs.cross(a,b)
      {x,y,z}
    dot_prod = (a,b)->
      a = dict_to_list(a)
      b = dict_to_list(b)
      v = mathjs.dot(a,b)
      v

    tangent_to_curve = (t)->
      [p, q]  = [1, -3]
      x = p*Math.cos(p*t) + 3*q*Math.cos(q*t)
      y = -p*Math.sin(p*t) - 3*q*Math.sin(q*t)
      z = -8*Math.sin(4*t + 1.57)

      return {x, y, z}
    
    al = y/200
    ph = xPos/200
    slice_plane =
      x: Math.sin(al)*Math.cos(ph)
      y: Math.sin(al)*Math.sin(ph)
      z: Math.cos(al)

    console.log 'slice_plane', slice_plane

    param_curve = (t)->
      [p, q]  = [1, -3]

      x = parser.get('x')(p,q,t)
      y = parser.get('y')(p,q,t)
      z = parser.get('z')(p,q,t)
      vr = {x, y, z}

      if dot_prod(vr, slice_plane) > R*1.5
        p = x:NaN, y:NaN
        dt = 0.05
        return [p,p, dt]

      vz =  tangent_to_curve(t)
      collin = Math.abs dot_prod(slice_plane, norm_v(vz))
      W = 20
      dt = W/(1 + W*collin) *.002

      #vx = vec_prod(vr, vz)
      #vy = vec_prod(vz, vx)
      vzar = [vz.x, vz.y, vz.z]
      vxar = mathjs.cross(vzar, [vr.x, vr.y, vr.z])
      #vxar = mathjs.cross([vr.x, vr.y, vr.z], vzar)
      vyar = mathjs.cross(vxar, vzar)
       
      #change for other plane
      #[a,b,c] = vxar
      vx = norm_v({x:vxar[0], y:vxar[1], z:vxar[2]})
      vy = norm_v({x:vyar[0], y:vyar[1], z:vyar[2]})
      a = dot_prod vx, slice_plane
      b = dot_prod vy, slice_plane
      cos_ro = dot_prod vr, slice_plane

      K = -cos_ro/R/Math.sign(a)/Math.sqrt(a*a + b*b)
      cos_th = slice_plane.z
      sin_th = Math.sqrt 1-cos_th*cos_th
      local_ort =
        x: slice_plane.x/sin_th
        y: slice_plane.y/sin_th

      pcirc = (theta)->
        proj_x = dot_prod vr, vx
        proj_y = dot_prod vr, vy
        x = vr.x + R*(vx.x*mathjs.cos(theta) + vy.x*mathjs.sin(theta))
        y = vr.y + R*(vx.y*mathjs.cos(theta) + vy.y*mathjs.sin(theta))
        distr_part = x*local_ort.x + y*local_ort.y
        x = x + local_ort.x*distr_part*(-1+ 1/cos_th)
        y = y + local_ort.y*distr_part*(-1+ 1/cos_th)
        {x,y}

      acos_ = Math.acos(K)
      atan_ = Math.atan(b/a)
      theta = acos_ + atan_
      theta2 = -acos_ + atan_
      {x,y} = pcirc(theta)

      #console.log x,y,z, 'th', theta, K, t,'ab', a, b, vx, vy, 'rz', vr, vz,'t',t
      return [{x,y}, pcirc(theta2), dt]



    [x0, y0, z0] = [width/2, height/2, 0]
    current_batch = []
    t = 0
    while t<(3.1415*2 + 0.005)
      [p1, p2, dt] = param_curve(t)
      t += dt
      if not p1.x
        S = 50
        for p in current_batch
          {x,y} = p
          path += "#{x0 + x*S},#{y0 - y*S} "

        if path.length>0 and path[path.length-1]!='M'
          path +='z M'
        current_batch = []
      else
        current_batch.unshift p1
        current_batch.push p2

    S = 50
    for p in current_batch
      {x,y} = p
      path += "#{x0 + x*S},#{y0 - y*S} "

    if path.length>0 and path[path.length-1]!='M'
      path +='z M'

    return path[..-2]
     
  render: ->
    {x, y} = @state
    [width, height] = [1000, 1000]

    L.div className:'app', onMouseMove:@mouseMove,
      "foo #{x} #{y}"

      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{width} #{height}">
        <defs>
          <linearGradient spreadMethod="pad" id="gradient" gradientTransform="rotate(-135) translate(-.5, -.5)" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stopColor="rgb(42, 11, 152)" stopOpacity="1" />
            <stop offset="100%" stopColor="rgb(249, 0, 255)" stopOpacity="1" />
          </linearGradient>
        </defs>
        <g fill="url(#gradient)" fillRule='nonzero'>
          <path stroke="blue" strokeWidth="2" strokeOpacity="0.5" d="
           M #{@get_path(1, {width, height})}
          " />
        </g> </svg>

      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 841.9 595.3">
        <g fill="#fa4455"> <path stroke="blue" stroke-width="3" d="
          M #{x} #{y} 444 333 444 555z
          " /> </g> </svg>

