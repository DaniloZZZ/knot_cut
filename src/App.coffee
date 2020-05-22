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
    N = 1040
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
      [p, q]  = [1, 2]
      x = p*Math.cos(p*t) + 3*q*Math.cos(q*t)
      y = -p*Math.sin(p*t) - 3*q*Math.sin(q*t)
      z = -8*Math.sin(4*t + 1.57)
      return {x, y, z}

    param_curve = (t)->
      [p, q]  = [1, 2]

      x = parser.get('x')(p,q,t)
      y = parser.get('y')(p,q,t)
      z = parser.get('z')(p,q,t)
      R = 0.76
      if z>R
        p = x:NaN, y:NaN
        return [p,p]

      vr = {x, y, z}
      vz =  tangent_to_curve(t)
      #vx = vec_prod(vr, vz)
      #vy = vec_prod(vz, vx)
      vzar = [vz.x, vz.y, vz.z]
      vxar = mathjs.cross([vr.x, vr.y, vr.z], vzar)
      vyar = mathjs.cross(vzar, vxar)
       
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
        continue
      {x,y} = p1
      S = 50
      path += "#{x0 + x*S},#{y0 - y*S} "
      {x,y} = p2
      path += "#{x0 + x*S},#{y0 - y*S} "
    return path
     
  render: ->
    {x, y} = @state
    [width, height] = [1000, 1000]

    L.div className:'app', onMouseMove:@mouseMove,
      "foo #{x} #{y}"
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{width} #{height}">
        <g fill="#ff443311">
          <path stroke="blue" strokeWidth="2" d="
          M #{@get_path(1, {width, height})}
          " />
        </g> </svg>

      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 841.9 595.3">
        <g fill="#fa4455"> <path stroke="blue" stroke-width="3" d="
          M #{x} #{y} 444 333 444 555z
          " /> </g> </svg>

      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 841.9 595.3">
        <g fill="#61DAFB">
          <path d="M666.3 296.5
          c0-60-40.7-63.3-#{x}-82.4 30-63.6 8-114.2-20.2-130.4-6.5-3.8-14.1-5.6-22.4-5.6
          v22.3
          c4.6 0 8.3.9 11.4 2.6 13.6 7.8 19.5 37.5 14.9 75.7-1.1 9.4-2.9 19.3-5.1 29.4-19.6-4.8-41-8.5-63.5-10.9-13.5-18.5-27.5-35.3-41.6-50 32.6-30.3 63.2-46.9 84-46.9
          V78
          c-27.5 0-63.5 19.6-99.9 53.6-36.4-33.8-72.4-53.2-99.9-53.2
          v22.3
          c20.7 0 51.4 16.5 84 46.6-14 14.7-28 31.4-41.3 49.9-22.6 2.4-44 6.1-63.6 11-2.3-10-4-19.7-5.2-29-4.7-38.2 1.1-67.9 14.6-75.8 3-1.8 6.9-2.6 11.5-2.6
          V78.5
          z
          m-130.2-66.7
          c-3.7 12.9-8.3 26.2-13.5 39.5-4.1-8-8.4-16-13.1-24-4.6-8-9.5-15.8-14.4-23.4 14.2 2.1 27.9 4.7 41 7.9zm-45.8 106.5
          z
          M#{x} #{y}
          c9.3 9.6 18.6 20.3 27.8 32-9-.4-18.2-.7-27.5-.7-9.4 0-18.7.2-27.8.7 9-11.7 18.3-22.4 27.5-32z
          m-74 58.9c-4.9 7.7-9.8 15.6-14.4 23.7-4.6 8-8.9 16-13 24-5.4-13.4-10-26.8-13.8-39.8 13.1-3.1 26.9-5.8 41.2-7.9
          z
          m-90.5 125.2
          c-35.4-15.1-58.3-34.9-58.3-50.6 0-15.7 22.9-35.6 58.3-50.6 8.6-3.7 18-7 27.7-10.1 5.7 19.6 13.2 40 22.5 60.9-9.2 20.8-16.6 41.1-22.2 60.6-9.9-3.1-19.3-6.5-28-10.2
          z
          c-13.6-7.8-19.5-37.5-14.9-75.7 1.1-9.4 2.9-19.3 5.1-29.4 19.6 4.8 41 8.5 63.5 10.9 13.5 18.5 27.5 35.3 41.6 50-32.6 30.3-63.2 46.9-84 46.9-4.5-.1-8.3-1-11.3-2.7
          z
          m237.2-76.2
          c4.7 38.2-1.1 67.9-14.6 75.8-3 1.8-6.9 2.6-11.5 2.6-20.7 0-51.4-16.5-84-46.6 14-14.7 28-31.4 41.3-49.9 22.6-2.4 44-6.1 63.6-11 2.3 10.1 4.1 19.8 5.2 29.1z
          m38.5-66.7
          c-8.6 3.7-18 7-27.7 10.1-5.7-19.6-13.2-40-22.5-60.9 9.2-20.8 16.6-41.1 22.2-60.6 9.9 3.1 19.3 6.5 28.1 10.2 35.4 15.1 58.3 34.9 58.3 50.6-.1 15.7-23 35.6-58.4 50.6
          z
          M320.8 78.4z"/>
          <circle cx="420.9" cy="296.5" r="45.7"/>
          <path d="M520.5 78.1z"/>
        </g>
      </svg>

