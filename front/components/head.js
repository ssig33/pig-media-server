import React from 'react';
import {Link} from 'react-router'

class LoginAs extends React.Component {
  render(){
    return <span>Login as {this.props.user_id}</span>
  }
}

class LoginLink extends React.Component {
  render(){
    return <a href='/sessions'>Login</a>
  }
}

class Session extends React.Component {
  render(){
    return <div>
      {session.data.user_id ? 
        <LoginAs user_id={session.data.user_id} /> :
        <LoginLink />
      }
    </div>
  }
}

export default class Head extends React.Component {
  render(){
    return <div>
      <Session/>
      <h2>
        <Link to='/'>{config.data.page_title}</Link>
      </h2>
    </div>
  }
}


