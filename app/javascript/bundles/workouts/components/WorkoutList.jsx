import PropTypes from 'prop-types';
import React from 'react';

import Workout from './Workout'

export default class WorkoutList extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      workouts: this.props.workouts
    }
  }

  handleUserInput(obj) {
    this.setState(obj);
  }

  render() {
    return(
      <div className="list-group">
        {this.state.workouts.map(function(workout) {
          return (
            <Workout workout={workout} key={workout.id} />
          )
        })}
      </div>
    )
  }
}
