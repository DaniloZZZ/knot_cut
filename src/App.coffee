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
    R = 1
    N = 2040
    trange = [0..N]
    T_scale = N
    path = ""
    console.log 're'

    xfunc = 'x(p,q,t) = sin(p*t) + 3sin(q*t)'
    yfunc = 'y(p,q,t) = cos(p*t) + 3cos(q*t)'
    zfunc = "z(p,q,t) = 2cos(4*t+1.57) + #{y/200}-2.5"
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

    tangent_to_curve = (t)->
      [p, q]  = [1, -3]
      [p, q]  = [1, 5-xPos/100]
      x = p*Math.cos(p*t) + 3*q*Math.cos(q*t)
      y = -p*Math.sin(p*t) - 3*q*Math.sin(q*t)
      z = -8*Math.sin(4*t + 1.57)
      return {x, y, z}

    param_curve = (t)->
      [p, q]  = [1, 5-xPos/100]

      x = parser.get('x')(p,q,t)
      y = parser.get('y')(p,q,t)
      z = parser.get('z')(p,q,t)
      vr = {x, y, z}
      if z>R
        p = x:NaN, y:NaN
        return [p,p]

      vz =  tangent_to_curve(t)
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
      [a,b] = [vx.z, vy.z]

      K = -vr.z/R/Math.sqrt(a*a + b*b)
      pcirc = (theta)->
        x = vr.x + R*(vx.x*mathjs.cos(theta) + vy.x*mathjs.sin(theta))
        y = vr.y + R*(vx.y*mathjs.cos(theta) + vy.y*mathjs.sin(theta))
        {x,y}

      acos_ = Math.acos(K)
      atan_ = Math.atan(b/a)
      theta = acos_ + atan_
      theta2 = -acos_ + atan_
      {x,y} = pcirc(theta)

        #console.log x,y,z, 'th', theta, K, t
      return [{x,y}, pcirc(theta2)]



    [x0, y0, z0] = [width/2, height/2, 0]
    for t in trange
      [p1, p2] = param_curve(t/T_scale*6.28)
      if not p1.x
        if path[-1..][0]!='M' and  path.length>0
          path +='z M'
        continue
      {x,y} = p1
      S = 50
      path += "#{x0 + x*S},#{y0 - y*S} "
      {x,y} = p2
      path += "#{x0 + x*S},#{y0 - y*S} "

    return path[..-2]
     
  render: ->
    {x, y} = @state
    [width, height] = [1000, 1000]

    L.div className:'app', onMouseMove:@mouseMove,
      "foo #{x} #{y}"
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{width} #{height}">
        <g fill="#ff443311">
          <path stroke="blue" strokeWidth="2" strokeOpacity="0.5" d="
           M #{@get_path(1, {width, height})}
          " />
        </g> </svg>

      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 841.9 595.3">
        <g fill="#fa4455"> <path stroke="blue" stroke-width="3" d="
          M #{x} #{y} 444 333 444 555z
          " /> </g> </svg>

